# coding: utf-8

require "date"
require "time"
require "nokogiri"
require_relative "date_utils"

class ParseEachPage
  class << self
    # "3.45" => 345
    # "4.1" => 410
    # "-" => 0
    # "" => 0
    def rating_str_to_integer(rating_str)
      ((rating_str || "").gsub(/[^\d]+/, "") + "000").slice(0, 3).to_i
    end

    # process restaurants search result list page
    def process_restaurants_search_result(doc, (prefecture, area1, area2), source_url, scraped_at)
      {
        list_count: doc.css(".c-page-count .c-page-count__num").last.text.strip.to_i,
        restaurants: doc.css(".list-rst").map { |entry|
          area_name, genre = entry.css(".list-rst__area-genre")[0].text.strip.split("/").map(&:strip)
          rating_str = entry.css(".list-rst__rating-val")[0]&.text&.strip || ""
          {
            restaurant_id: entry.attribute("data-rst-id").value,
            prefecture: prefecture,
            area1: area1,
            area2: area2,
            restaurant_url: entry.attribute("data-detail-url").value,
            name: entry.css("a.list-rst__rst-name-target")[0].text.strip,
            area_name: area_name,
            genre: genre,
            has_pr: entry.css(".list-rst__pr").any?,
            rating: rating_str,
            rating_int: rating_str_to_integer(rating_str),
            review_count: entry.css(".list-rst__rvw-count-num")[0].text.strip.to_i,
            dinner_budget: entry.css(".cpy-dinner-budget-val")[0].text.strip,
            lunch_budget: entry.css(".cpy-lunch-budget-val")[0].text.strip,
            has_holiday_notice: entry.css(".list-rst__holiday-notice").any?,
            search_words: entry.css("ul.list-rst__search-word li.list-rst__search-word-item").map(&:text).map(&:strip).join("|"),
            img_count: entry.css(".list-rst__rst-photo")[0].attribute("data-photo-set").value.split(",").select { |id_str| id_str.length > 0 }.length,
            has_calendar: entry.css(".list-rst__calendar").any?,
            source_url: source_url,
            scraped_at: scraped_at,
          }
        },
      }
    end

    # process top page of a single restaurant
    def process_single_restaurant_top_page(doc, (prefecture, area1, area2), source_url, scraped_at)
      result = process_single_restaurant_review_page_restaurant_info(doc, source_url, scraped_at)
      return result.merge({
               prefecture: prefecture,
               area1: area1,
               area2: area2,
               has_pr: doc.css(".pr-comment-title").any?,
               search_words: (m = doc.css("meta[name=description]").attribute("content").value.match(/【([^【】]+)】口コミや評価、写真など/); m ? m[1].split("/").map(&:strip).map { |str| str.sub(/あり$/, "") }.join("|") : ""),
             })
    end

    # process restaurant information in review page of a single restaurant
    def process_single_restaurant_review_page_restaurant_info(doc, source_url, scraped_at)
      has_station = doc.css(".rdheader-subinfo__item--station").any?
      rating_str = doc.css("#js-header-rating .rdheader-rating__score-val-dtl")[0]&.text&.strip || ""
      status_badge_entry = doc.css(".rdheader-title-data .rdheader-rstname-wrap .rst-status-badge-large")[0]
      status_badge = status_badge_entry && status_badge_entry.attribute("class").value.split(" ").select { |cls| cls.start_with? "rst-st-" }.first.slice("rst-st-".length..-1)
      {
        restaurant_id: doc.css(".js-bookmark[data-rst-id]").attribute("data-rst-id").value,
        restaurant_url: doc.css("meta[property='og:url']").attribute("content").value,
        status_badge: status_badge,
        name: doc.css(".rdheader-title-data .display-name a,.rdheader-title-data .display-name span")[0].text.strip,
        area_name: has_station ? doc.css(".rdheader-subinfo__item--station .linktree .linktree__parent-target-text")[0].text.strip : doc.css(".rdheader-subinfo")[0].css("dl.rdheader-subinfo__item")[0].css(".rdheader-subinfo__item-text")[0].text.strip,
        genre: has_station ? doc.css(".rdheader-subinfo__item--station ~ dl.rdheader-subinfo__item dd.rdheader-subinfo__item-text .linktree .linktree__parent-target-text").map(&:text).map(&:strip).join("、") : doc.css(".rdheader-subinfo")[0].css("dl.rdheader-subinfo__item")[1].css("dd.rdheader-subinfo__item-text .linktree .linktree__parent-target-text").map(&:text).map(&:strip).join("、"),
        # has_pr: ,
        rating: rating_str,
        rating_int: rating_str_to_integer(rating_str),
        review_count: doc.css("#js-header-rating .rdheader-rating__review .num")[0].text.strip.to_i,
        dinner_budget: doc.css(".rdheader-budget__icon--dinner .rdheader-budget__price-target")[0].text.strip,
        lunch_budget: doc.css(".rdheader-budget__icon--lunch .rdheader-budget__price-target")[0].text.strip,
        has_holiday_notice: doc.css(".rdheader-subinfo__item-title-ellipsis").any?,
        # search_words: ,
        img_count: doc.css("#rdnavi-photo .rstdtl-navi__total-count strong")[0]&.text&.strip&.to_i || 0,
        has_calendar: doc.css(".rstdtl-side-yoyaku__booking").any?,
        has_pillow_word: doc.css(".rdheader-rstname .pillow-word").any?,
        has_owner_badge: doc.css(".rdheader-rstname .rdheader-official-info .owner-badge").any?,
        has_group_badge: doc.css(".rdheader-rstname .rdheader-official-info .group-badge").any?,
        has_advertisement: doc.css(".rstdtl-side-banner").any?,
        save_target_count: doc.css("#js-header-rating .rdheader-rating__hozon-target .num")[0]&.text&.strip&.to_i || 0,
        source_url: source_url,
        scraped_at: scraped_at,
      }
    end

    ## for debug
    # require_relative "lib/parse_each_page"
    # require_relative "lib/read_url"
    # require_relative "lib/url_util"
    #
    # read_url= ReadUrl.new(UrlUtil::RECAPTCHA_URL,
    #   proc { |e, url| $stdout.print "INFO: redirect occurred to #{e.uri} from #{url}\n" },
    #   proc { |e, url| error_io.print "ERROR: forbidden redirect occurred to #{e.uri} from #{url}\n"; raise },
    #   proc { |e, url| error_io.print "ERROR: #{e.io.status.join(" ")} for #{url}\n"; raise })
    #
    # %w{
    #   https://tabelog.com/tokyo/A1321/A132103/13022818/dtlrvwlst/?srt=visit&lc=2
    #   https://tabelog.com/ibaraki/A0802/A080201/8012178/dtlrvwlst/?srt=visit&lc=2
    #   https://tabelog.com/saitama/A1103/A110301/11006122/dtlrvwlst/?srt=visit&lc=2
    # }.each{|url|
    #   doc = read_url.read_html(url)
    #   review_page_result = ParseEachPage.process_reviews(doc, url, Time.now)
    #   pp review_page_result;nil
    # }

    def process_reviews(doc, source_url, scraped_at)
      # meal_time: "lunch" | "dinner" | "takeout"
      get_lunch_or_dinner_review_info_list_item = proc { |entry, meal_time|
        entry.css(".rvw-item__rvw-info ul.rvw-item__ratings li.rvw-item__ratings-item .c-rating-v2 span.c-rating-v2__time--#{meal_time}")[0]&.ancestors("li.rvw-item__ratings-item")&.[](0)
      }
      # lunch_or_dinner: "lunch" | "dinner"
      review_info_proc_lunch_or_dinner = proc { |lunch_or_dinner, review_info_list_item|
        if review_info_list_item
          rating = review_info_list_item.css(".c-rating-v2__val")[0].text.strip
          detail_inner_items = review_info_list_item.css("ul.rvw-item__ratings-dtlscore > li")
          if detail_inner_items.length != 1 then raise "There are #{detail_inner_items.length} (!= 1) detail_inner_items (ul.rvw-item__ratings-dtlscore > li) on #{source_url}" end
          detail_inner_item = detail_inner_items[0]
          detail_scores = detail_inner_items.css("ul.rvw-item__score-detail li.rvw-item__score-detail-item strong.rvw-item__ratings-dtlscore-score")
          if detail_scores.length != 5 then raise "There are #{detail_scores.length} (!= 5) detail_scores on #{source_url}" end
          {
            :"#{lunch_or_dinner}_rating" => rating,
            :"#{lunch_or_dinner}_rating_int" => rating_str_to_integer(rating),
            :"#{lunch_or_dinner}_rating_food" => detail_scores[0].text.strip,
            :"#{lunch_or_dinner}_rating_service" => detail_scores[1].text.strip,
            :"#{lunch_or_dinner}_rating_mood" => detail_scores[2].text.strip,
            :"#{lunch_or_dinner}_rating_cp" => detail_scores[3].text.strip,
            :"#{lunch_or_dinner}_rating_drink" => detail_scores[4].text.strip,
            :"#{lunch_or_dinner}_rating_details_count" => detail_scores.length,
            :"#{lunch_or_dinner}_rating_details_text" => detail_inner_item.css("ul.rvw-item__score-detail")[0].text.strip.gsub(/\r|\n/, "").gsub(/\s+/, " "),
            :"#{lunch_or_dinner}_usedprice" => detail_inner_item.css("span.rvw-item__ratings-dtlscore-score")[0].text.strip,
          }
        else
          {
            :"#{lunch_or_dinner}_rating" => nil,
            :"#{lunch_or_dinner}_rating_int" => nil,
            :"#{lunch_or_dinner}_rating_food" => nil,
            :"#{lunch_or_dinner}_rating_service" => nil,
            :"#{lunch_or_dinner}_rating_mood" => nil,
            :"#{lunch_or_dinner}_rating_cp" => nil,
            :"#{lunch_or_dinner}_rating_drink" => nil,
            :"#{lunch_or_dinner}_rating_details_count" => nil,
            :"#{lunch_or_dinner}_rating_details_text" => nil,
            :"#{lunch_or_dinner}_usedprice" => nil,
          }
        end
      }

      # non_detail_sort: "takeout" | "delivery" | "etc"
      review_info_proc_non_detail_sort = proc { |non_detail_sort, review_info_list_item|
        if review_info_list_item
          rating = review_info_list_item.css(".c-rating-v2__val")[0].text.strip
          detail_inner_items = review_info_list_item.css("ul.rvw-item__ratings-dtlscore > li")
          if detail_inner_items.length != 1 then raise "There are #{detail_inner_items.length} (!= 1) detail_inner_items (ul.rvw-item__ratings-dtlscore > li) on #{source_url}" end
          detail_inner_item = detail_inner_items[0]
          {
            :"#{non_detail_sort}_rating" => rating,
            :"#{non_detail_sort}_rating_int" => rating_str_to_integer(rating),
            :"#{non_detail_sort}_usedprice" => detail_inner_item.css("span.rvw-item__ratings-dtlscore-score")[0].text.strip,
          }
        else
          {
            :"#{non_detail_sort}_rating" => nil,
            :"#{non_detail_sort}_rating_int" => nil,
            :"#{non_detail_sort}_usedprice" => nil,
          }
        end
      }

      entries = doc.css(".rvw-item")
      {
        restaurant: process_single_restaurant_review_page_restaurant_info(doc, source_url, scraped_at),
        review_count: doc.css(".rstdtl-rvwlst .p-list-control .p-list-control__page-count .c-page-count .c-page-count__num strong")[2].text.strip.to_i,
        reviews: entries.map { |entry|
          review_id = entry.css(".rvw-item__contents .rvw-item__visit-contents .rvw-item__showall-trigger[data-bookmark-id]")[0].attribute("data-bookmark-id").value
          rating_list = entry.css(".rvw-item__rvw-info ul.rvw-item__ratings")[0] # rating_list may be nil
          # e.g. https://tabelog.com/tokyo/A1321/A132103/13022818/dtlrvwlst/?srt=visit&lc=2 > https://tabelog.com/tokyo/A1321/A132103/13022818/dtlrvwlst/B222546607/?use_type=0&srt=visit&lc=2&smp=1
          lunch_rating_item = get_lunch_or_dinner_review_info_list_item[entry, "lunch"]
          dinner_rating_item = get_lunch_or_dinner_review_info_list_item[entry, "dinner"]
          takeout_rating_item = get_lunch_or_dinner_review_info_list_item[entry, "takeout"]
          delivery_rating_item = get_lunch_or_dinner_review_info_list_item[entry, "delivery"]
          etc_rating_item = get_lunch_or_dinner_review_info_list_item[entry, "etc"]
          if review_id == "222546607"
            # rating_list can be null
          else
            raise "neither lunch, dinner, takeout, delivery, nor etc rating item exists on #{source_url}" unless lunch_rating_item || dinner_rating_item || takeout_rating_item || delivery_rating_item || etc_rating_item
          end
          ({
            review_id: review_id,
            review_url: entry.attribute("data-detail-url").value.split("?")[0],

            reviewer: {
              reviewer_url_path: entry.css(".rvw-item__rvwr-data p.rvw-item__rvwr-name a")[0].attribute("href").value,
              reviewer_name: entry.css(".rvw-item__rvwr-data p.rvw-item__rvwr-name .lev span:first-child")[0].text.strip,
              reviewer_is_mobile_authorized: entry.css(".rvw-item__rvwr-data p.rvw-item__rvwr-name .mark-auth-mobile").any?,
              reviewer_is_celebrity: entry.css(".rvw-item__rvwr-data p.rvw-item__rvwr-name .rvw-item__rvwr-badge .c-badge-celebrity").any?,
              reviewer_profile: entry.css(".rvw-item__rvwr-data p.rvw-item__rvwr-name .rvw-item__rvwr-profile")[0].text.strip,
              reviewer_logs_count: entry.css(".rvw-item__rvwr-data .rvw-item__rvwr-balloon-text")[0].text.strip.sub("ログ", "").gsub(",", "").to_i,
              reviewer_restaurants_count: entry.css(".rvw-item__rvwr-data .rvw-item__rvwr-balloon-text+span")[0].text.strip.sub("行ったお店", "").sub("件", "").gsub(",", "").to_i,
              reviewer_following_count: entry.css(".rvw-item__rvwr-data .rvw-item__rvwr-balloon-text")[1].text.strip.sub("フォロー", "").sub("人", "").gsub(",", "").to_i,
              reviewer_followers_count: entry.css(".rvw-item__rvwr-data .rvw-item__rvwr-balloon-text+strong")[0].text.strip.sub("フォロワー", "").sub("人", "").gsub(",", "").to_i,
            },

            visit_count: entry.css(".rvw-item__rvw-info .rvw-item__visit-count .rvw-item__visit-count-num")[0].text.strip.to_i,

            visit_date: entry.css(".rvw-item__contents .rvw-item__visit-contents .rvw-item__date")[0]&.text&.strip,
            has_title: entry.css(".rvw-item__contents .rvw-item__visit-contents .rvw-item__title strong").any?,
            photo_count: entry.css(".rvw-item__contents .rvw-item__visit-contents .rvw-photo ul.rvw-photo__list li.rvw-photo__list-item a.js-show-bookmark-images .c-photo-more__num").any? ?
              entry.css(".rvw-item__contents .rvw-item__visit-contents .rvw-photo ul.rvw-photo__list li.rvw-photo__list-item a.js-show-bookmark-images .c-photo-more__num")[0].text.strip :
              entry.css(".rvw-item__contents .rvw-item__visit-contents .rvw-photo ul.rvw-photo__list li.rvw-photo__list-item a.js-imagebox-trigger").length,
            title: entry.css(".rvw-item__contents .rvw-item__visit-contents .rvw-item__title strong")[0]&.text&.strip,
            comment: entry.css(".rvw-item__contents .rvw-item__visit-contents .rvw-item__rvw-comment")[0].text.strip,
          }).merge(review_info_proc_lunch_or_dinner["lunch", lunch_rating_item]).
            merge(review_info_proc_lunch_or_dinner["dinner", dinner_rating_item]).
            merge(review_info_proc_non_detail_sort["takeout", takeout_rating_item]).
            merge(review_info_proc_non_detail_sort["delivery", delivery_rating_item]).
            merge(review_info_proc_non_detail_sort["etc", etc_rating_item])
        },
      }
    end
  end
end
