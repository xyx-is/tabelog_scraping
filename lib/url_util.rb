class UrlUtil
  ORDER_TYPES = {
    ranking: "?Srt=D&SrtT=rt&sort_mode=1",
    standard: "",
    new_open: "?Srt=D&SrtT=nod",
  }

  BASE_URL = "https://tabelog.com/"
  SITEMAP_XML_URL = "#{BASE_URL}sitemap.xml"

  RECAPTCHA_URL = "https://tabelog.com/access_check/recaptcha"

  class << self
    def relative_path_to_absolute_url(relative_path)
      if relative_path.start_with?("/")
        BASE_URL + relative_path[1..-1]
      else
        BASE_URL + relative_path
      end
    end

    def to_absolute_url(url_or_path)
      if url_or_path.start_with?(BASE_URL)
        return url_or_path
      else
        return relative_path_to_absolute_url(url_or_path)
      end
    end

    def create_search_url(area_array, genre, page, order_type)
      area_str = area_array.join("/")
      genre_str = genre ? "#{genre}/" : ""
      page_str = page ? "#{page}/" : ""
      order_type_str = ORDER_TYPES[order_type]

      "#{BASE_URL}#{area_str}/rstLst/#{genre_str}#{page_str}#{order_type_str}"
    end

    def search_url_to_area_array(search_url)
      search_url.gsub(BASE_URL, "").split("/rstLst/").first.split("/")
    end

    # "https://tabelog.com/nagano/A2003/A200303/20007049/"
    #   => [["nagano", "A2003", "A200303"], "20007049"]
    def parse_restaurant_url(restaurant_url)
      prefecture, area1, area2, restaurant_id = restaurant_url.gsub(BASE_URL, "").split("/")
      [[prefecture, area1, area2], restaurant_id]
    end

    # "https://tabelog.com/tokyo/A1303/A130302/13003326/dtlrvwlst/B11/"
    #   => [["tokyo", "A1303", "A130302"], "13003326", "B11"]
    def parse_restaurant_review_url(restaurant_url)
      prefecture, area1, area2, restaurant_id, _, review_id = restaurant_url.gsub(BASE_URL, "").split("/")
      [[prefecture, area1, area2], restaurant_id, review_id]
    end

    def create_reviews_url(restaurant_url, page)
      if page == 1
        "#{restaurant_url}dtlrvwlst/?srt=visit&lc=2"
      else
        "#{restaurant_url}dtlrvwlst/?srt=visit&lc=2&PG=#{page}"
      end
    end

    def get_last_page(count, count_per_page, max_page)
      [(count - 1) / count_per_page + 1, max_page].min
    end
  end
end
