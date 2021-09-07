# coding: utf-8

require "nokogiri"
require "open-uri"
require "sqlite3"
require "date"
require "time"

require "fileutils"
require "parallel"

require_relative "lib/date_utils"
require_relative "lib/db_operation"
require_relative "lib/genres"
require_relative "lib/parse_each_page"
require_relative "lib/parse_sitemap"
require_relative "lib/progress_manager"
require_relative "lib/read_url"
require_relative "lib/url_util"

MAX_THREADS = 8

STDOUT.sync = true

last_update_tuesday = DateUtils.last_update_tuesday(Date.today)
last_update_tuesday_str = last_update_tuesday.iso8601.gsub("-", "_")

folder_name = "result/result_#{last_update_tuesday_str}"
FileUtils.mkdir_p(folder_name)
progress_json_filename = "#{folder_name}/progress_#{last_update_tuesday_str}.json"
log_filename = "#{folder_name}/error_#{last_update_tuesday_str}.log"
sqlite_filename = "#{folder_name}/tabelog_#{last_update_tuesday_str}.sqlite"

pm = ProgressManager.new(progress_json_filename)

pm.add_process(:create_db) do |db_operation, error_io, (read_url_with_error_abort, read_url_with_error_skip)|
  db_operation.create_tables()
end

pm.add_process(:read_sitemap_xml) do |db_operation, error_io, (read_url_with_error_abort, read_url_with_error_skip)|
  read_url = read_url_with_error_abort

  url = UrlUtil::SITEMAP_XML_URL
  child_sitemap_urls = ParseSitemap.parse_top_sitemap(
    read_url.read_xml(url)
  )

  ParseSitemap.select_rst_pref(child_sitemap_urls).each do |url|
    prefectures = ParseSitemap.parse_rst_pref(
      read_url.read_xml(url)
    )
    db_operation.with_transaction do
      prefectures.each do |prefecture|
        db_operation.add_prefecture(prefecture)
      end
    end
  end

  db_operation.with_transaction do
    Parallel.each(ParseSitemap.select_rvwdtl(child_sitemap_urls), in_threads: MAX_THREADS) do |url|
      restaurant_review_urls = ParseSitemap.parse_rvwdtl(
        read_url.read_xml(url)
      )
      restaurant_review_urls.each do |restaurant_review_url|
        _, restaurant_id, review_id = UrlUtil.parse_restaurant_review_url(restaurant_review_url)
        db_operation.add_review_url_in_sitemap(review_id, restaurant_id, restaurant_review_url)
      end
    end
  end

  prefectures = db_operation.get_all_prefectures()

  $stdout.puts "INFO: prefectures.length: #{prefectures.length}"

  db_operation.with_transaction do
    Parallel.each(ParseSitemap.select_rstdtl(child_sitemap_urls), in_threads: MAX_THREADS) do |url|
      sitemap_last_modified = nil
      child_sitemap = read_url_with_error_skip.read_xml(url) { |io, url| sitemap_last_modified = io.last_modified }
      restaurant_urls = child_sitemap.nil? ? [] : ParseSitemap.parse_rstdtl(child_sitemap)
      restaurant_urls.each do |restaurant_url|
        (prefecture, area1, area2), restaurant_id = UrlUtil.parse_restaurant_url(restaurant_url)
        is_japan = prefectures.include?(prefecture)
        if is_japan
          db_operation.add_area2(prefecture, area1, area2)
        end
        db_operation.add_restaurant_url(restaurant_id, restaurant_url, is_japan, sitemap_last_modified)
      end
    end
  end
end

def need_to_get_reviews(restaurant_hash)
  restaurant_hash[:rating_int] >= 350 || restaurant_hash[:review_count] >= 80
end

RESTAURANTS_SEARCH_MAX_PAGE = 60
RESTAURANTS_SEARCH_ENTRY_PER_PAGE = 20

def process_restaurants_search_url(search_url, area_array, genre, subgenres, db_operation, error_io, read_url)
  doc = read_url.read_html(search_url)
  if doc
    search_result = ParseEachPage.process_restaurants_search_result(doc, area_array, search_url, Time.now)
    search_result[:restaurants].each do |restaurant_in_search_result_hash|
      db_operation.add_restaurants_in_search_result(restaurant_in_search_result_hash)
      if need_to_get_reviews(restaurant_in_search_result_hash)
        db_operation.add_restaurant_url_for_scraping_reviews(restaurant_in_search_result_hash[:restaurant_id], restaurant_in_search_result_hash[:restaurant_url])
      end
    end
    canonical_url = search_result[:canonical_url]
    return search_result[:list_count]
  else
    return nil
  end
end

def process_area_genre(area_array, genre, subgenres, db_operation, error_io, read_url)
  list_count = process_restaurants_search_url(UrlUtil.create_search_url(area_array, genre, 1, :standard),
                                              area_array, genre, subgenres, db_operation, error_io, read_url)
  if !list_count.nil?
    if (list_count > RESTAURANTS_SEARCH_MAX_PAGE * RESTAURANTS_SEARCH_ENTRY_PER_PAGE) && subgenres.any?
      subgenres.each do |subgenre|
        process_area_genre(area_array, subgenre.key, subgenre.subgenres, db_operation, error_io, read_url)
      end
    else
      for page in 2..UrlUtil.get_last_page(list_count, RESTAURANTS_SEARCH_ENTRY_PER_PAGE, RESTAURANTS_SEARCH_MAX_PAGE)
        list_count = process_restaurants_search_url(UrlUtil.create_search_url(area_array, genre, page, :standard),
                                                    area_array, genre, subgenres, db_operation, error_io, read_url)
      end
    end
  else
    # if error happens: skip this area
    error_io.print "ERROR: skip area #{area_array.join("/")} genre #{genre}\n"
  end
end

SEARCH_AREA_CHUNK_SIZE = 64

pm.add_process(:area_search_result) do |db_operation, error_io, (read_url_with_error_abort, read_url_with_error_skip)|
  read_url = read_url_with_error_skip

  area2s_count = db_operation.get_count_of_area2s()

  loop do
    area_arrays = db_operation.get_not_complete_area_arrays(SEARCH_AREA_CHUNK_SIZE)
    count_of_not_complete_area_arrays = db_operation.get_count_of_not_complete_area_arrays()
    $stdout.puts "INFO: count_of_not_complete_area_arrays #{count_of_not_complete_area_arrays}/#{area2s_count} areas"
    break if area_arrays.empty?
    db_operation.with_transaction do
      Parallel.each(area_arrays, in_threads: MAX_THREADS) do |area_array|
        process_area_genre(area_array, nil, Genres::GENRE_TREE, db_operation, error_io, read_url)
        db_operation.update_area2_to_scraping_complete(*area_array)
        count_of_restaurants_in_search_result = db_operation.get_count_of_restaurants_in_search_result()
        $stdout.puts "INFO: count_of_restaurants_in_search_result = #{count_of_restaurants_in_search_result}"
      end
    end
  end
end

pm.add_process(:update_restaurant_urls_scraping_completed_from_restaurants_in_search_result) do |db_operation, error_io, (read_url_with_error_abort, read_url_with_error_skip)|
  db_operation.update_restaurant_urls_scraping_completed_from_restaurants_in_search_result()
end

def process_single_restaurant_url(restaurant_url, area_array, db_operation, error_io, read_url)
  doc = read_url.read_html(restaurant_url)
  if doc
    restaurant_from_top_page_hash = ParseEachPage.process_single_restaurant_top_page(doc, area_array, restaurant_url, Time.now)
    db_operation.add_restaurants_from_top_page(restaurant_from_top_page_hash)
    if need_to_get_reviews(restaurant_from_top_page_hash)
      db_operation.add_restaurant_url_for_scraping_reviews(restaurant_from_top_page_hash[:restaurant_id], restaurant_from_top_page_hash[:restaurant_url])
    end
  end
end

SINGLE_RESTAURANTS_CHUNK_SIZE = 64

pm.add_process(:process_single_restaurants) do |db_operation, error_io, (read_url_with_error_abort, read_url_with_error_skip)|
  read_url = read_url_with_error_skip

  db_operation.update_restaurant_urls_scraping_completed_from_restaurants_from_top_page()

  loop do
    not_complete_restaurant_urls = db_operation.get_not_complete_restaurant_urls(SINGLE_RESTAURANTS_CHUNK_SIZE)
    count_of_not_complete_restaurant_urls = db_operation.get_count_of_not_complete_restaurant_urls()
    $stdout.puts "INFO: count_of_not_complete_restaurant_urls #{count_of_not_complete_restaurant_urls}"
    break if not_complete_restaurant_urls.empty?
    db_operation.with_transaction do
      Parallel.each(not_complete_restaurant_urls, in_threads: MAX_THREADS) do |restaurant_url|
        area_array, restaurant_id = UrlUtil.parse_restaurant_url(restaurant_url)
        process_single_restaurant_url(restaurant_url, area_array, db_operation, error_io, read_url)
        db_operation.update_restaurant_urls_scraping_completed(restaurant_id)
      end
    end
  end
end

REVIEWS_MAX_PAGE = 12
REVIEWS_PER_PAGE = 100

def process_review_page_url(review_page_url, db_operation, error_io, read_url)
  doc = read_url.read_html(review_page_url)
  if doc
    review_page_result = ParseEachPage.process_reviews(doc, review_page_url, Time.now)
    db_operation.add_review_page(review_page_result)
    return review_page_result[:review_count]
  else
    return nil
  end
end

def process_reviews_for_restaurant_url(restaurant_url, db_operation, error_io, read_url)
  review_count = process_review_page_url(UrlUtil.create_reviews_url(restaurant_url, 1), db_operation, error_io, read_url)
  if review_count
    for page in (2..UrlUtil.get_last_page(review_count, REVIEWS_PER_PAGE, REVIEWS_MAX_PAGE))
      process_review_page_url(UrlUtil.create_reviews_url(restaurant_url, page), db_operation, error_io, read_url)
    end
  else
    # if error happens: skip this restaurant
    error_io.print "ERROR: skip restaurant #{restaurant_url}\n"
  end
end

RESTAURANTS_TO_SCRAPING_REVIEWS_CHUNK_SIZE = 64

pm.add_process(:process_reviews) do |db_operation, error_io, (read_url_with_error_abort, read_url_with_error_skip)|
  read_url = read_url_with_error_skip

  loop do
    not_complete_restaurant_urls = db_operation.get_not_complete_restaurant_urls_for_scraping_reviews(RESTAURANTS_TO_SCRAPING_REVIEWS_CHUNK_SIZE)
    count_of_not_complete_restaurant_urls_for_scraping_reviews = db_operation.get_count_of_not_complete_restaurant_urls_for_scraping_reviews()
    $stdout.puts "INFO: count_of_not_complete_restaurant_urls_for_scraping_reviews #{count_of_not_complete_restaurant_urls_for_scraping_reviews}"
    break if not_complete_restaurant_urls.empty?
    db_operation.with_transaction do
      Parallel.each(not_complete_restaurant_urls, in_threads: MAX_THREADS) do |restaurant_url|
        _, restaurant_id = UrlUtil.parse_restaurant_url(restaurant_url)
        process_reviews_for_restaurant_url(restaurant_url, db_operation, error_io, read_url)
        db_operation.update_restaurant_urls_for_scraping_reviews_scraping_reviews_completed(restaurant_id)
      end
    end
  end
end

pm.add_process(:check_db_reviews) do |db_operation, error_io, (read_url_with_error_abort, read_url_with_error_skip)|
  count_of_no_score_reviews = db_operation.get_count_of_no_score_reviews()
  $stdout.puts "INFO: count_of_no_score_reviews #{count_of_no_score_reviews}"
  if count_of_no_score_reviews > 1
    # if error happens: skip this area
    error_io.print "ERROR: count_of_no_score_reviews is greater than 1\n"
  end
end

File.open(log_filename, "a") do |error_io|
  SQLite3::Database.new(sqlite_filename) do |db|
    db_operation = DbOperation.new(db)

    read_url_with_error_abort = ReadUrl.new(UrlUtil::RECAPTCHA_URL,
                                            proc { |e, url| $stdout.print "INFO: redirect occurred to #{e.uri} from #{url}\n" },
                                            proc { |e, url| error_io.print "ERROR: forbidden redirect occurred to #{e.uri} from #{url}\n"; raise },
                                            proc { |e, url| error_io.print "ERROR: #{e.io.status.join(" ")} for #{url}\n"; raise })

    read_url_with_error_skip = ReadUrl.new(UrlUtil::RECAPTCHA_URL,
                                           proc { |e, url| $stdout.print "INFO: redirect occurred to #{e.uri} from #{url}\n" },
                                           proc { |e, url| error_io.print "ERROR: forbidden redirect occurred to #{e.uri} from #{url}\n"; raise },
                                           proc { |e, url| error_io.print "ERROR: #{e.io.status.join(" ")} for #{url}\n" })

    pm.execute([db_operation, error_io, [read_url_with_error_abort, read_url_with_error_skip]])
  end
end
