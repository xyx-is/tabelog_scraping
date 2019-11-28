require "nokogiri"

class ParseSitemap
  class << self
    # https://tabelog.com/sitemap.xml
    # returns array of "sitemap_....xml.gz"
    def parse_top_sitemap(xml_doc)
      return xml_doc.xpath("//xmlns:sitemap/xmlns:loc").map { |e| e.text.strip }
    end

    private def select_and_sort_by_prefix(prefix, urls)
      urls.select { |url| url.start_with?(prefix) }.sort_by { |url| url.gsub(prefix, "").gsub(".xml.gz", "").to_i }
    end

    ### rst_pref

    def select_rst_pref(urls)
      select_and_sort_by_prefix("https://tabelog.com/sitemap_pc_rst_pref_", urls)
    end

    # returns array of area_array
    def parse_rst_pref(xml_doc)
      return xml_doc.xpath("//xmlns:url/xmlns:loc").map { |e| get_prefecture(e.text.strip) }
    end

    # "https://tabelog.com/shizuoka/" -> "shizuoka"
    private def get_prefecture(prefecture_rstLst_url)
      prefecture_rstLst_url.gsub("https://tabelog.com/", "").split("/")[0]
    end

    ### rvwdtl

    def select_rvwdtl(urls)
      select_and_sort_by_prefix("https://tabelog.com/sitemap_pc_rvwdtl_", urls)
    end

    # returns array of review url
    def parse_rvwdtl(xml_doc)
      return xml_doc.xpath("//xmlns:url/xmlns:loc").map { |e| e.text.strip }
    end

    ### rstdtl

    def select_rstdtl(urls)
      select_and_sort_by_prefix("https://tabelog.com/sitemap_pc_rstdtl_", urls)
    end

    # returns array of restaurant url
    def parse_rstdtl(xml_doc)
      return xml_doc.xpath("//xmlns:url/xmlns:loc").map { |e| e.text.strip }
    end
  end
end
