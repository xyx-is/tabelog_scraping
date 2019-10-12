# coding: utf-8

require 'nokogiri'
require 'open-uri'
require 'csv'

areas = [
#    add areas from areas.csv

  "tokyo/A1301/A130101",
  "tokyo/A1301/A130102",
]

CSV_ARRAY_ELEMENTS = [
  {name: "restaurant_url", proc: lambda{|entry| entry.attribute("data-detail-url").value } },
  {name: "restaurant_id", proc: lambda{|entry| entry.attribute("data-rst-id").value } },
  {name: "restaurant_name", proc: lambda{|entry| entry.css("a.list-rst__rst-name-target")[0].text.strip } },
  {name: "restaurant_area", proc: lambda{|entry| entry.css("span.list-rst__area-genre")[0].text.strip.split("/")[0] } },
  {name: "restaurant_genre", proc: lambda{|entry| entry.css("span.list-rst__area-genre")[0].text.strip.split("/")[1] } },
  {name: "restaurant_has_pr", proc: lambda{|entry| entry.css("div.list-rst__pr").any? } },
  {name: "restaurant_rating", proc: lambda{|entry| entry.css("span.list-rst__rating-val")[0].try(:text).try(:strip) } },
  {name: "restaurant_review_count", proc: lambda{|entry| entry.css(".list-rst__rvw-count-num")[0].text.strip } },

  {name: "restaurant_dinner_budget", proc: lambda{|entry| entry.css("span.cpy-dinner-budget-val")[0].text.strip } },
  {name: "restaurant_lunch_budget", proc: lambda{|entry| entry.css("span.cpy-lunch-budget-val")[0].text.strip } },

  {name: "restaurant_has_holiday_notice", proc: lambda{|entry| entry.css(".list-rst__holiday-notice").any? } },

  {name: "restaurant_search_words", proc: lambda{|entry| entry.css("ul.list-rst__search-word li.list-rst__search-word-item").map(&:text).map(&:strip).join("|") } },

  {name: "restaurant_has_calendar", proc: lambda{|entry| entry.css(".list-rst__calendar").any? } },
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



def read_to_csv_array(url, entry_css, csv_array_elements)
  doc = Nokogiri::HTML.parse(open(url, &:read))
  doc.css(entry_css).map do |entry|
    csv_array_elements.map{|csv_array_element| csv_array_element[:proc][entry]}
  end
end



# print CSV in UTF-8 with BOM
print("\xEF\xBB\xBF")
puts (["area"] + CSV_ARRAY_ELEMENTS.map{|e| e[:name]}).to_csv

areas.each_with_index do |area, idx|
  url_list = (1..60).map{|page| "https://tabelog.com/#{area}/rstLst/#{page}/?Srt=D&SrtT=rt&sort_mode=1"}
  $stderr.puts "#{idx + 1}/#{areas.length}"
  for url in url_list do
    $stderr.puts "  GET: #{url}"
    line_arrays = read_to_csv_array(url, "li.list-rst", CSV_ARRAY_ELEMENTS)
    line_arrays.each{|line_array| puts ([area] + line_array).to_csv }
    if line_arrays.length < 20 then
      break
    end
  end
end

