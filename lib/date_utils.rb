require "date"

class DateUtils
  class << self
    # get 1st specific weekday of the month
    def first_weekday_of_the_month(begin_of_the_month, wday)
      begin_of_the_month + ((7 + wday - begin_of_the_month.wday) % 7)
    end

    # get last 1st or 3rd Tuesday of the month
    def last_update_tuesday(date)
      date = date.to_date
      begin_of_the_month = Date.new(date.year, date.month, 1)
      begin_of_the_month_first_tuesday = first_weekday_of_the_month(begin_of_the_month, 2)
      begin_of_the_last_month = begin_of_the_month << 1
      begin_of_the_last_month_first_tuesday = first_weekday_of_the_month(begin_of_the_last_month, 2)

      candidate_tuesdays = [
        begin_of_the_last_month_first_tuesday,
        begin_of_the_last_month_first_tuesday + 14,
        begin_of_the_month_first_tuesday,
        begin_of_the_month_first_tuesday + 14,
      ]
      candidate_tuesdays.select { |tuesday| tuesday <= date }.last
    end
  end
end
