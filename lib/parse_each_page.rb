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
          area_name, genre = entry.css("span.list-rst__area-genre")[0].text.strip.split("/").map(&:strip)
          rating_str = entry.css("span.list-rst__rating-val")[0]&.text&.strip || ""
          {
            restaurant_id: entry.attribute("data-rst-id").value,
            prefecture: prefecture,
            area1: area1,
            area2: area2,
            restaurant_url: entry.attribute("data-detail-url").value,
            name: entry.css("a.list-rst__rst-name-target")[0].text.strip,
            area_name: area_name,
            genre: genre,
            has_pr: entry.css("div.list-rst__pr").any?,
            rating: rating_str,
            rating_int: rating_str_to_integer(rating_str),
            review_count: entry.css(".list-rst__rvw-count-num")[0].text.strip.to_i,
            dinner_budget: entry.css("span.cpy-dinner-budget-val")[0].text.strip,
            lunch_budget: entry.css("span.cpy-lunch-budget-val")[0].text.strip,
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

    def process_reviews(doc, source_url, scraped_at)
      entries = doc.css(".rvw-item")
      {
        restaurant: process_single_restaurant_review_page_restaurant_info(doc, source_url, scraped_at),
        review_count: doc.css(".rstdtl-rvwlst .p-list-control .p-list-control__page-count .c-page-count .c-page-count__num strong")[2].text.strip.to_i,
        reviews: entries.map { |entry|
          dinner_rating_item = entry.css(".rvw-item__rvw-info ul.rvw-item__ratings li.rvw-item__ratings-item .c-rating span.c-rating__time--dinner")[0]&.ancestors("li.rvw-item__ratings-item")&.[](0)
          dinner_rating = if dinner_rating_item then dinner_rating_item.css(".c-rating__val")[0].text.strip else nil end
          dinner_detail_scores = dinner_rating_item&.css("ul.rvw-item__ratings-dtlscore li strong.rvw-item__ratings-dtlscore-score")
          lunch_rating_item = entry.css(".rvw-item__rvw-info ul.rvw-item__ratings li.rvw-item__ratings-item .c-rating span.c-rating__time--lunch")[0]&.ancestors("li.rvw-item__ratings-item")&.[](0)
          lunch_rating = if lunch_rating_item then lunch_rating_item.css(".c-rating__val")[0].text.strip else nil end
          lunch_detail_scores = lunch_rating_item&.css("ul.rvw-item__ratings-dtlscore li strong.rvw-item__ratings-dtlscore-score")
          {
            review_id: entry.css(".rvw-item__contents .rvw-item__visit-contents .rvw-item__showall-trigger[data-bookmark-id]")[0].attribute("data-bookmark-id").value,
            review_url: entry.attribute("data-detail-url").value.split("?")[0],

            reviewer: {
              reviewer_url_path: entry.css(".rvw-item__rvwr-data p.rvw-item__rvwr-name a")[0].attribute("href").value,
              reviewer_name: entry.css(".rvw-item__rvwr-data p.rvw-item__rvwr-name span[property='v:reviewer']")[0].text.strip,
              reviewer_is_mobile_authorized: entry.css(".rvw-item__rvwr-data p.rvw-item__rvwr-name .mark-auth-mobile").any?,
              reviewer_is_celebrity: entry.css(".rvw-item__rvwr-data p.rvw-item__rvwr-name .rvw-item__rvwr-badge .c-badge-celebrity").any?,
              reviewer_profile: entry.css(".rvw-item__rvwr-data p.rvw-item__rvwr-name .rvw-item__rvwr-profile")[0].text.strip,
              reviewer_logs_count: entry.css(".rvw-item__rvwr-data .rvw-item__rvwr-balloon-text")[0].text.strip.sub("ログ", "").gsub(",", "").to_i,
              reviewer_restaurants_count: entry.css(".rvw-item__rvwr-data .rvw-item__rvwr-balloon-text+span")[0].text.strip.sub("行ったお店", "").sub("件", "").gsub(",", "").to_i,
              reviewer_following_count: entry.css(".rvw-item__rvwr-data .rvw-item__rvwr-balloon-text")[1].text.strip.sub("フォロー", "").sub("人", "").gsub(",", "").to_i,
              reviewer_followers_count: entry.css(".rvw-item__rvwr-data .rvw-item__rvwr-balloon-text+strong")[0].text.strip.sub("フォロワー", "").sub("人", "").gsub(",", "").to_i,
            },

            visit_count: entry.css(".rvw-item__rvw-info .rvw-item__visit-count .rvw-item__visit-count-num")[0].text.strip.to_i,

            dinner_rating: dinner_rating,
            dinner_rating_int: rating_str_to_integer(dinner_rating),
            dinner_rating_food: if dinner_detail_scores then dinner_detail_scores[0].text.strip else nil end,
            dinner_rating_service: if dinner_detail_scores then dinner_detail_scores[1].text.strip else nil end,
            dinner_rating_mood: if dinner_detail_scores then dinner_detail_scores[2].text.strip else nil end,
            dinner_rating_cp: if dinner_detail_scores then dinner_detail_scores[3].text.strip else nil end,
            dinner_rating_drink: if dinner_detail_scores then dinner_detail_scores[4].text.strip else nil end,
            dinner_rating_details_count: dinner_detail_scores&.length,
            dinner_rating_details_text: if dinner_rating_item then dinner_rating_item.css("ul.rvw-item__ratings-dtlscore")[0].text.strip.gsub(/\r|\n/, "").gsub(/\s+/, " ") else nil end,

            lunch_rating: lunch_rating,
            lunch_rating_int: rating_str_to_integer(lunch_rating),
            lunch_rating_food: if lunch_detail_scores then lunch_detail_scores[0].text.strip else nil end,
            lunch_rating_service: if lunch_detail_scores then lunch_detail_scores[1].text.strip else nil end,
            lunch_rating_mood: if lunch_detail_scores then lunch_detail_scores[2].text.strip else nil end,
            lunch_rating_cp: if lunch_detail_scores then lunch_detail_scores[3].text.strip else nil end,
            lunch_rating_drink: if lunch_detail_scores then lunch_detail_scores[4].text.strip else nil end,
            lunch_rating_details_count: lunch_detail_scores&.length,
            lunch_rating_details_text: if lunch_rating_item then lunch_rating_item.css("ul.rvw-item__ratings-dtlscore")[0].text.strip.gsub(/\r|\n/, "").gsub(/\s+/, " ") else nil end,

            dinner_usedprice: entry.css("li.rvw-item__otherdata .rvw-item__usedprice dd.rvw-item__usedprice-data .c-rating__time--dinner+.rvw-item__usedprice-price")[0]&.text&.strip,
            lunch_usedprice: entry.css("li.rvw-item__otherdata .rvw-item__usedprice dd.rvw-item__usedprice-data .c-rating__time--lunch+.rvw-item__usedprice-price")[0]&.text&.strip,

            visit_date: entry.css(".rvw-item__contents .rvw-item__visit-contents .rvw-item__date")[0]&.text&.strip,
            has_title: entry.css(".rvw-item__contents .rvw-item__visit-contents .rvw-item__title strong").any?,
            photo_count: entry.css(".rvw-item__contents .rvw-item__visit-contents .rvw-photo ul.rvw-photo__list li.rvw-photo__list-item a.js-show-bookmark-images .c-photo-more__num").any? ?
              entry.css(".rvw-item__contents .rvw-item__visit-contents .rvw-photo ul.rvw-photo__list li.rvw-photo__list-item a.js-show-bookmark-images .c-photo-more__num")[0].text.strip :
              entry.css(".rvw-item__contents .rvw-item__visit-contents .rvw-photo ul.rvw-photo__list li.rvw-photo__list-item a.js-imagebox-trigger").length,
            title: entry.css(".rvw-item__contents .rvw-item__visit-contents .rvw-item__title strong")[0]&.text&.strip,
            comment: entry.css(".rvw-item__contents .rvw-item__visit-contents .rvw-item__rvw-comment")[0].text.strip,
          }
        },
      }
    end
  end
end
