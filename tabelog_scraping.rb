# coding: utf-8

require 'nokogiri'
require 'open-uri'
require 'csv'
require 'set'
require 'fileutils'
require 'parallel'
require 'date'

MAX_THREADS = 4

areas = [
  "tokyo/A1304/A130401",
  "osaka/A2701/A270101",
]

GENRE_TREES = [
  {key: "RC", subgenres: [
    {key: "washoku", subgenres: [
      {key: "japanese", subgenres: [
        {key: "RC010101",},
        {key: "RC010103",},
        {key: "RC010105",},
        {key: "RC010104",},
      ]},
      {key: "sushi", subgenres: [
        {key: "RC010201",},
        {key: "RC010202",},
        {key: "RC010203",},
      ]},
      {key: "seafood", subgenres: [
        {key: "RC011211",},
        {key: "RC011212",},
        {key: "RC011213",},
        {key: "RC011214",},
        {key: "RC011215",},
      ]},
      {key: "RC0103", subgenres: [
        {key: "tempura",},
        {key: "tonkatsu",},
        {key: "kushiage",},
        {key: "RC010304",},
        {key: "RC010399",},
      ]},
      {key: "RC0104", subgenres: [
        {key: "soba",},
        {key: "RC010408",},
        {key: "udon",},
        {key: "RC010407",},
        {key: "RC010406",},
        {key: "RC010404",},
        {key: "RC010403",},
        {key: "RC010405",},
        {key: "RC010499",},
      ]},
      {key: "RC0105", subgenres: [
        {key: "unagi",},
        {key: "RC010502",},
        {key: "RC010503",},
      ]},
      {key: "RC0106", subgenres: [
        {key: "yakitori",},
        {key: "RC010602",},
        {key: "RC010604",},
        {key: "RC010605",},
        {key: "RC010603",},
        {key: "RC010606",},
      ]},
      {key: "RC0107", subgenres: [
        {key: "RC010701",},
        {key: "syabusyabu",},
        {key: "RC010703",},
      ]},
      {key: "RC0108",},
      {key: "RC0109", subgenres: [
        {key: "okonomiyaki",},
        {key: "monjya",},
        {key: "RC010911",},
        {key: "RC010912",},
        {key: "RC010999",},
      ]},
      {key: "RC0110", subgenres: [
        {key: "okinawafood",},
        {key: "RC011002",},
        {key: "RC011099",},
      ]},
      {key: "RC0111", subgenres: [
        {key: "RC011101",},
        {key: "RC011102",},
        {key: "RC011103",},
        {key: "RC011104",},
        {key: "RC011105",},
        {key: "RC011106",},
        {key: "RC011199",},
      ]},
      {key: "RC0199", subgenres: [
        {key: "RC019910",},
        {key: "RC019908",},
        {key: "RC019909",},
        {key: "RC019912",},
        {key: "RC019911",},
        {key: "RC019907",},
        {key: "RC019903",},
        {key: "RC019999",},
      ]},
    ]},
    {key: "RC02", subgenres: [
      {key: "RC0201", subgenres: [
        {key: "steak",},
        {key: "hamburgersteak",},
      ]},
      {key: "RC0203",},
      {key: "RC0202", subgenres: [
        {key: "pasta",},
        {key: "pizza",},
      ]},
      {key: "hamburger",},
      {key: "RC0209", subgenres: [
        {key: "yoshoku",},
        {key: "RC020911",},
        {key: "RC020912",},
        {key: "RC020913",},
        {key: "RC020914",},
        {key: "RC020915",},
        {key: "RC020999",},
      ]},
      {key: "french", subgenres: [
        {key: "RC021101",},
        {key: "RC021102",},
        {key: "RC021103",},
      ]},
      {key: "italian",},
      {key: "spain", subgenres: [
        {key: "RC021301",},
        {key: "RC021302",},
      ]},
      {key: "RC0219", subgenres: [
        {key: "RC021902",},
        {key: "RC021903",},
        {key: "RC021904",},
        {key: "RC021905",},
        {key: "RC021906",},
        {key: "RC021907",},
        {key: "RC021908",},
        {key: "RC021999",},
      ]},
    ]},
    {key: "chinese", subgenres: [
      {key: "RC0301", subgenres: [
        {key: "RC030101",},
        {key: "RC030102",},
        {key: "RC030103",},
        {key: "RC030104",},
        {key: "RC030105",},
        {key: "RC030106",},
        {key: "RC030107",},
      ]},
      {key: "RC0302", subgenres: [
        {key: "gyouza",},
        {key: "RC030202",},
      ]},
      {key: "RC0303",},
      {key: "RC0304", subgenres: [
        {key: "RC030401",},
        {key: "RC030402",},
        {key: "RC030403",},
      ]},
    ]},
    {key: "RC04", subgenres: [
      {key: "korea", subgenres: [
        {key: "RC040101",},
        {key: "RC040102",},
      ]},
      {key: "RC0402", subgenres: [
        {key: "thai",},
        {key: "RC040202",},
        {key: "RC040203",},
        {key: "RC040204",},
        {key: "RC040299",},
      ]},
      {key: "RC0403", subgenres: [
        {key: "RC040301",},
        {key: "RC040302",},
        {key: "RC040303",},
        {key: "RC040304",},
        {key: "RC040399",},
      ]},
      {key: "RC0404", subgenres: [
        {key: "RC040401",},
        {key: "RC040499",},
      ]},
      {key: "RC0411", subgenres: [
        {key: "RC041101",},
        {key: "RC041102",},
        {key: "RC041199",},
      ]},
      {key: "RC0412",},
      {key: "RC0499",},
    ]},
    {key: "curry", subgenres: [
      {key: "RC1201",},
      {key: "RC1202",},
      {key: "RC1203",},
      {key: "RC1204",},
      {key: "RC1205",},
      {key: "RC1299",},
    ]},
    {key: "RC13", subgenres: [
      {key: "RC1301", subgenres: [
        {key: "yakiniku",},
        {key: "horumon",},
      ]},
      {key: "RC1302",},
    ]},
    {key: "nabe", subgenres: [
      {key: "RC1401",},
      {key: "RC1402",},
      {key: "motsu",},
      {key: "RC1404",},
      {key: "RC1405",},
      {key: "RC1406",},
      {key: "RC1407",},
      {key: "RC1409",},
      {key: "RC1408",},
    ]},
    {key: "RC21", subgenres: [
      {key: "izakaya",},
      {key: "RC2102",},
      {key: "RC2199", subgenres: [
        {key: "RC219902",},
        {key: "RC219903",},
        {key: "RC219904",},
        {key: "RC219999",},
      ]},
    ]},
    {key: "RC22", subgenres: [
      {key: "RC2201",},
      {key: "RC2202",},
      {key: "RC2203",},
    ]},
    {key: "RC23",},
    {key: "RC99", subgenres: [
      {key: "RC9901", subgenres: [
        {key: "RC990101",},
        {key: "RC990102",},
        {key: "RC990103",},
      ]},
      {key: "RC9903", subgenres: [
        {key: "RC990301",},
        {key: "RC990302",},
      ]},
      {key: "RC9904", subgenres: [
        {key: "RC990401",},
        {key: "RC990402",},
      ]},
      {key: "RC9999", subgenres: [
        {key: "viking",},
        {key: "RC999903",},
        {key: "RC999901",},
        {key: "RC999913",},
        {key: "RC999902",},
        {key: "RC999905",},
        {key: "RC999907",},
        {key: "RC999908",},
        {key: "RC999909",},
        {key: "RC999910",},
        {key: "RC999911",},
        {key: "RC999912",},
        {key: "RC999914",},
        {key: "RC999999",},
      ]},
    ]},
  ]},
  {key: "MC", subgenres: [
    {key: "ramen",},
    {key: "MC21", subgenres: [
      {key: "MC2101",},
      {key: "MC2102",},
      {key: "MC2103",},
    ]},
    {key: "MC11",},
  ]},
  {key: "cafe", subgenres: [
    {key: "CC01",},
    {key: "CC02",},
    {key: "CC03",},
    {key: "CC04",},
    {key: "CC05",},
    {key: "CC06",},
    {key: "CC99",},
  ]},
  {key: "SC", subgenres: [
    {key: "pan", subgenres: [
      {key: "SC0101",},
      {key: "SC0102",},
      {key: "SC0103",},
      {key: "SC0199",},
    ]},
    {key: "sweets", subgenres: [
      {key: "SC0201", subgenres: [
        {key: "cake",},
        {key: "SC020102",},
        {key: "SC020103",},
        {key: "SC020104",},
        {key: "SC020199",},
      ]},
      {key: "SC0202", subgenres: [
        {key: "SC020201",},
        {key: "SC020202",},
        {key: "SC020203",},
        {key: "SC020204",},
        {key: "SC020205",},
        {key: "SC020206",},
      ]},
      {key: "SC0203",},
      {key: "SC0299", subgenres: [
        {key: "SC029901",},
        {key: "SC029909",},
        {key: "SC029907",},
        {key: "SC029903",},
        {key: "SC029904",},
        {key: "SC029902",},
        {key: "SC029905",},
        {key: "SC029906",},
        {key: "SC029908",},
        {key: "SC029910",},
        {key: "SC029911",},
        {key: "SC029999",},
      ]},
    ]},
  ]},
  {key: "bar", subgenres: [
    {key: "BC01",},
    {key: "BC02",},
    {key: "BC03",},
    {key: "BC04",},
    {key: "BC05",},
    {key: "BC06",},
    {key: "BC07",},
    {key: "BC99", subgenres: [
      {key: "BC9901", subgenres: [
        {key: "BC990101",},
        {key: "BC990102",},
      ]},
      {key: "BC9999",},
    ]},
  ]},
  {key: "YC", subgenres: [
    {key: "ryokan",},
    {key: "YC02",},
    {key: "YC99",},
  ]},
  {key: "ZZ",},
]



# define try of Rails
class Object
  alias try send
end

class NilClass
  def try(*args)
    nil
  end
end


SEARCH_RESULT_PROCESS = lambda do |doc|
  entries = doc.css("li.list-rst")
  {
    list_count: doc.css(".list-condition__count").text.strip.to_i,
    restaurants: entries.map{|entry|
      area, genre = entry.css("span.list-rst__area-genre")[0].text.strip.split("/")
      {
        url: entry.attribute("data-detail-url").value,
        id: entry.attribute("data-rst-id").value,
        name: entry.css("a.list-rst__rst-name-target")[0].text.strip,
        area: area,
        genre: genre,
        has_pr: entry.css("div.list-rst__pr").any?,
        rating: entry.css("span.list-rst__rating-val")[0].try(:text).try(:strip),
        review_count: entry.css(".list-rst__rvw-count-num")[0].text.strip.to_i,
        dinner_budget: entry.css("span.cpy-dinner-budget-val")[0].text.strip,
        lunch_budget: entry.css("span.cpy-lunch-budget-val")[0].text.strip,
        has_holiday_notice: entry.css(".list-rst__holiday-notice").any?,
        search_words: entry.css("ul.list-rst__search-word li.list-rst__search-word-item").map(&:text).map(&:strip).join("|"),
        img_count: entry.css(".list-rst__rst-photo")[0].attribute("data-photo-set").value.split(",").select{|id_str| id_str.length>0}.length,
        has_calendar: entry.css(".list-rst__calendar").any?,
      }
    },
  }
end

INDEX_SIZE_PER_PAGE = 200

SITEMAP_INDEX_PROCESS = lambda do |doc|
  doc.css("#arealst_sitemap ul li a").flat_map do |entry|
    base_url = entry.attribute("href")
    count = entry.text.strip.match(/\d+/)[0].to_i
    max_page = (count-1)/INDEX_SIZE_PER_PAGE + 1
    (1..max_page).to_a.map{|page| "#{base_url}?PG=#{page}" }
  end
end

SITEMAP_PROCESS = lambda do |doc|
  entries = doc.css("#rstlst_sitemap .list .item .rstname")
  entries.map{|entry|
    url = entry.css("a").attribute("href").value
    area_and_genre = entry.css(".cat_sta").text.strip
    area, genre = area_and_genre.gsub(/（|）/,"").split("/").map(&:strip)
    {
      id: url.split("/")[4],
      url: url,
      name: entry.css("a").text.strip,
      area: area,
      genre: genre,
    }
  }
end

SINGLE_RESTAURANT_PROCESS = lambda do |doc|
  has_station = doc.css(".rdheader-subinfo__item--station").any?
  {
    url: doc.css("meta[property='og:url']").attribute("content").value,
    id: doc.css("#js-status-report").attribute("data-rst-id").value,
    name: doc.css(".rdheader-title-data .display-name a,.rdheader-title-data .display-name span")[0].text.strip,
    area: has_station ? doc.css(".rdheader-subinfo__item--station .linktree .linktree__parent-target-text")[0].text.strip : doc.css(".rdheader-subinfo")[0].css("dl.rdheader-subinfo__item")[0].css(".rdheader-subinfo__item-text")[0].text.strip,
    genre: has_station ? doc.css(".rdheader-subinfo__item--station ~ dl.rdheader-subinfo__item dd.rdheader-subinfo__item-text .linktree .linktree__parent-target-text").map(&:text).map(&:strip).join("、") : doc.css(".rdheader-subinfo")[0].css("dl.rdheader-subinfo__item")[1].css("dd.rdheader-subinfo__item-text .linktree .linktree__parent-target-text").map(&:text).map(&:strip).join("、"),
    has_pr: doc.css(".pr-comment-title").any?,
    rating: doc.css("#js-header-rating .rdheader-rating__score-val-dtl")[0].try(:text).try(:strip),
    review_count: doc.css("#js-header-rating .rdheader-rating__review .num")[0].text.strip.to_i,
    dinner_budget: doc.css(".rdheader-budget__icon--dinner .rdheader-budget__price-target")[0].text.strip,
    lunch_budget: doc.css(".rdheader-budget__icon--lunch .rdheader-budget__price-target")[0].text.strip,
    has_holiday_notice: doc.css(".rdheader-subinfo__item-title-ellipsis").any?,
    search_words: (m = doc.css("meta[name=description]").attribute("content").value.match(/【([^【】]+)】口コミや評価、写真など/); m ? m[1].split("/").map(&:strip).map{|str| str.sub(/あり$/,"")}.join("|") : nil),
    img_count: doc.css("#rdnavi-photo .rstdtl-navi__total-count strong")[0].try(:text).try(:strip),
    has_calendar: doc.css(".rstdtl-side-yoyaku__booking").any?,
    has_pillow_word: doc.css(".rdheader-rstname .pillow-word").any?,
    has_owner_badge: doc.css(".rdheader-rstname .rdheader-official-info .owner-badge").any?,
    has_group_badge: doc.css(".rdheader-rstname .rdheader-official-info .group-badge").any?,
    has_advertisement: doc.css(".rstdtl-side-banner").any?,
    save_target_count: doc.css("#js-header-rating .rdheader-rating__hozon-target .num")[0].try(:text).try(:strip),
  }
end


def read_data_from_url(url, process)
  doc = Nokogiri::HTML.parse(open(url), url)
  process[doc]
end

ORDER_TYPES = {
  raking: "?Srt=D&SrtT=rt&sort_mode=1",
  standard: "",
  new_open: "?Srt=D&SrtT=nod",
}

def create_search_url(area, genre, page, order_type)
  genre_str = genre ? "#{genre}/" : ""
  page_str = page ? "#{page}/" : ""
  order_type_str = ORDER_TYPES[order_type]

  "https://tabelog.com/#{area}/rstLst/#{genre_str}#{page_str}#{order_type_str}"
end

def create_area_sitemap_url(area)
  pref, area_id1, area_id2 = area.split("/")
  "https://tabelog.com/sitemap/#{pref}/#{area_id1}-#{area_id2}/"
end

def create_single_restaurant_url(url_path)
  "https://tabelog.com#{url_path}"
end

MAX_PAGE = 60
ENTRY_PER_PAGE = 20

def process_area_genre(area, genre, subgenre_trees, output_restaurant_lines_proc, no_subgenre_proc)
  search_data = read_data_from_url(create_search_url(area, genre, 1, :raking), SEARCH_RESULT_PROCESS)
  output_restaurant_lines_proc[search_data[:restaurants]]
  list_count = search_data[:list_count]

  if list_count > ENTRY_PER_PAGE*MAX_PAGE then
    # subgenre_trees is nil or Array
    if subgenre_trees then
      # if there are over 1200 search results and subgenres, use subgenres
      subgenre_trees.each do |subgenre_tree|
        process_area_genre(area, subgenre_tree[:key], subgenre_tree[:subgenres], output_restaurant_lines_proc, no_subgenre_proc)
      end
    else
      # no subgenre
      for page in (2...MAX_PAGE) do
        search_data = read_data_from_url(create_search_url(area, genre, page, :raking), SEARCH_RESULT_PROCESS)
        output_restaurant_lines_proc[search_data[:restaurants]]
      end

      last_url = create_search_url(area, genre, MAX_PAGE, :raking)
      search_data = read_data_from_url(last_url, SEARCH_RESULT_PROCESS)
      output_restaurant_lines_proc[search_data[:restaurants]]
      min_rating = search_data[:restaurants].last[:rating]
      no_subgenre_proc[area, genre, last_url, min_rating]

      [:standard, :new_open].each do |order_type|
        for page in (1..MAX_PAGE) do
          search_data = read_data_from_url(create_search_url(area, genre, page, :raking), SEARCH_RESULT_PROCESS)
          output_restaurant_lines_proc[search_data[:restaurants]]
        end
      end
    end
  else
    for page in (2..MAX_PAGE) do
      search_data = read_data_from_url(create_search_url(area, genre, page, :raking), SEARCH_RESULT_PROCESS)
      output_restaurant_lines_proc[search_data[:restaurants]]
      if search_data[:restaurants].length < ENTRY_PER_PAGE then
        break
      end
    end
  end
end

def restaurant_line_data_to_array(area, restaurant_line_data)
  [area] + [:url, :id, :name, :area, :genre, :has_pr, :rating, :review_count, :dinner_budget, :lunch_budget, :has_holiday_notice, :search_words, :img_count, :has_calendar].map{|key| restaurant_line_data[key]}
end

def single_restaurant_data_to_array(area, single_restaurant_data)
  [area] + [:url, :id, :name, :area, :genre, :has_pr, :rating, :review_count, :dinner_budget, :lunch_budget, :has_holiday_notice, :search_words, :img_count, :has_calendar, :has_pillow_word, :has_owner_badge, :has_group_badge, :has_advertisement, :save_target_count].map{|key| single_restaurant_data[key]}
end

def process_area(area)
  area_output_name = area.gsub("/", "_")
  FileUtils.mkdir_p("result/restaurants")
  FileUtils.mkdir_p("result/no_subgenre")
  area_restaurant_csv_path = "result/restaurants/restaurants_#{area_output_name}.csv"
  area_no_subgenre_csv_path = "result/no_subgenre/no_subgenre_#{area_output_name}.csv"

  ids = Set.new
  has_no_subgenre = false

  File.open(area_restaurant_csv_path, "w"){|area_restaurant_csv_io|
    process_area_genre(area, nil, GENRE_TREES, proc{|restaurant_lines|
      for restaurant_line in restaurant_lines do
        id = restaurant_line[:id]
        if ids.include?(id) then
          # ignore
        else
          ids.add(id)
          csv_line = restaurant_line_data_to_array(area, restaurant_line).to_csv
          area_restaurant_csv_io.puts csv_line
        end
      end
      area_restaurant_csv_io.flush
    }, proc{|area, genre, last_url, min_rating|
      File.open(area_no_subgenre_csv_path, "a"){|area_no_subgenre_csv_io|
        area_no_subgenre_csv_io.puts([area, genre, last_url, min_rating].to_csv)
      }
      has_no_subgenre = true
    })

    if has_no_subgenre then
      process_area_index(area, ids)
    end
  }
end

def process_area_index(area, got_restaurant_ids)
  area_output_name = area.gsub("/", "_")
  FileUtils.mkdir_p("result/indexes")
  FileUtils.mkdir_p("result/single_restaurant")
  index_csv_path = "result/indexes/index_#{area_output_name}.csv"
  single_restaurant_csv_path = "result/single_restaurant/single_restaurant_#{area_output_name}.csv"

  sitemap_urls = read_data_from_url(create_area_sitemap_url(area), SITEMAP_INDEX_PROCESS)
  
  all_restaurant_ids = Set.new
  all_restaurant_url_hash = {}
  
  File.open(index_csv_path, "w"){|index_csv_io|
    sitemap_urls.each do |url|
      read_data_from_url(url, SITEMAP_PROCESS).each do |data|
        index_csv_io.puts [:id, :url, :name, :area, :genre].map{|key| data[key]}.to_csv

        all_restaurant_ids.add(data[:id])
        all_restaurant_url_hash[data[:id]] = data[:url]
      end
      index_csv_io.flush
    end
  }

  not_got_ids = all_restaurant_ids - got_restaurant_ids

  File.open(single_restaurant_csv_path, "w"){|single_restaurant_csv_io|
    not_got_ids.each do |not_got_id|
      url_path = all_restaurant_url_hash[not_got_id]
      url = create_single_restaurant_url(url_path)
      single_restaurant_data = read_data_from_url(url, SINGLE_RESTAURANT_PROCESS)
      
      single_restaurant_csv_io.puts single_restaurant_data_to_array(area, single_restaurant_data).to_csv
    end
  }
end

Parallel.each_with_index(areas, in_threads: MAX_THREADS) do |area, idx|
  puts "[#{Time.now}] #{idx + 1}/#{areas.length} AREA #{area}"
  process_area(area)
end
