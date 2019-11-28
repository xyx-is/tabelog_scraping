module CreateDbTables
  # CreateDbTables.create_tables_sql(CreateDbTables::TABLES_DEFINITION)
  # CreateDbTables.create_indexes_sql(CreateDbTables::INDEXES_DEFINITION)

  module Type
    INTEGER = "integer"
    TEXT = "text"
    DATE = "text"
    BOOL = "int(1)"
  end

  TABLES_DEFINITION = {
    prefectures: {
      prefecture: { type: Type::TEXT, primary_key: true },
    },
    area2s: {
      prefecture: { type: Type::TEXT, not_null: true },
      area1: { type: Type::TEXT, not_null: true },
      area2: { type: Type::TEXT, primary_key: true },
      scraping_completed: { type: Type::BOOL, not_null: true },
    },
    review_urls_in_sitemap: {
      review_id: { type: Type::TEXT, primary_key: true },
      restaurant_id: { type: Type::TEXT, not_null: true },
      review_url: { type: Type::TEXT, not_null: true },
    },

    restaurant_urls: {
      restaurant_id: { type: Type::TEXT, primary_key: true },
      restaurant_url: { type: Type::TEXT, not_null: true },
      is_japan: { type: Type::BOOL, not_null: true },
      sitemap_last_modified: { type: Type::DATE, not_null: true },
      scraping_completed: { type: Type::BOOL, not_null: true },
    },

    restaurant_urls_for_scraping_reviews: {
      restaurant_id: { type: Type::TEXT, primary_key: true },
      restaurant_url: { type: Type::TEXT, not_null: true },
      scraping_reviews_completed: { type: Type::BOOL, not_null: true },
    },

    restaurants_in_search_result: {
      restaurant_id: { type: Type::TEXT, primary_key: true },
      prefecture: { type: Type::TEXT, not_null: true },
      area1: { type: Type::TEXT, not_null: true },
      area2: { type: Type::TEXT, not_null: true },
      restaurant_url: { type: Type::TEXT, not_null: true },
      name: { type: Type::TEXT, not_null: true },
      area_name: { type: Type::TEXT, not_null: true },
      genre: { type: Type::TEXT, not_null: true },
      has_pr: { type: Type::BOOL, not_null: true },
      rating: { type: Type::TEXT, not_null: true },
      rating_int: { type: Type::INTEGER, not_null: true },
      review_count: { type: Type::INTEGER, not_null: true },
      dinner_budget: { type: Type::TEXT, not_null: true },
      lunch_budget: { type: Type::TEXT, not_null: true },
      has_holiday_notice: { type: Type::BOOL, not_null: true },
      search_words: { type: Type::TEXT, not_null: true },
      img_count: { type: Type::INTEGER, not_null: true },
      has_calendar: { type: Type::BOOL, not_null: true },
      source_url: { type: Type::TEXT, not_null: true },
      scraped_at: { type: Type::DATE, not_null: true },
    },
    restaurants_from_top_page: {
      restaurant_id: { type: Type::TEXT, primary_key: true },
      prefecture: { type: Type::TEXT, not_null: true },
      area1: { type: Type::TEXT, not_null: true },
      area2: { type: Type::TEXT, not_null: true },
      restaurant_url: { type: Type::TEXT, not_null: true },
      status_badge: { type: Type::TEXT, not_null: false },
      name: { type: Type::TEXT, not_null: true },
      area_name: { type: Type::TEXT, not_null: true },
      genre: { type: Type::TEXT, not_null: true },
      has_pr: { type: Type::BOOL, not_null: true },
      rating: { type: Type::TEXT, not_null: true },
      rating_int: { type: Type::INTEGER, not_null: true },
      review_count: { type: Type::INTEGER, not_null: true },
      dinner_budget: { type: Type::TEXT, not_null: true },
      lunch_budget: { type: Type::TEXT, not_null: true },
      has_holiday_notice: { type: Type::BOOL, not_null: true },
      search_words: { type: Type::TEXT, not_null: true },
      img_count: { type: Type::INTEGER, not_null: true },
      has_calendar: { type: Type::BOOL, not_null: true },
      has_pillow_word: { type: Type::BOOL, not_null: true },
      has_owner_badge: { type: Type::BOOL, not_null: true },
      has_group_badge: { type: Type::BOOL, not_null: true },
      has_advertisement: { type: Type::BOOL, not_null: true },
      save_target_count: { type: Type::INTEGER, not_null: true },
      source_url: { type: Type::TEXT, not_null: true },
      scraped_at: { type: Type::DATE, not_null: true },
    },
    restaurants_from_review_page: {
      restaurant_id: { type: Type::TEXT, primary_key: true },
      restaurant_url: { type: Type::TEXT, not_null: true },
      status_badge: { type: Type::TEXT, not_null: false },
      name: { type: Type::TEXT, not_null: true },
      area_name: { type: Type::TEXT, not_null: true },
      genre: { type: Type::TEXT, not_null: true },
      # has_pr: { type: Type::BOOL, not_null: true },
      rating: { type: Type::TEXT, not_null: true },
      rating_int: { type: Type::INTEGER, not_null: true },
      review_count: { type: Type::INTEGER, not_null: true },
      dinner_budget: { type: Type::TEXT, not_null: true },
      lunch_budget: { type: Type::TEXT, not_null: true },
      has_holiday_notice: { type: Type::BOOL, not_null: true },
      # search_words: { type: Type::TEXT, not_null: true },
      img_count: { type: Type::INTEGER, not_null: true },
      has_calendar: { type: Type::BOOL, not_null: true },
      has_pillow_word: { type: Type::BOOL, not_null: true },
      has_owner_badge: { type: Type::BOOL, not_null: true },
      has_group_badge: { type: Type::BOOL, not_null: true },
      has_advertisement: { type: Type::BOOL, not_null: true },
      save_target_count: { type: Type::INTEGER, not_null: true },
      source_url: { type: Type::TEXT, not_null: true },
      scraped_at: { type: Type::DATE, not_null: true },

      review_actual_count: { type: Type::INTEGER, not_null: true },
    },
    reviewers: {
      reviewer_url_path: { type: Type::TEXT, primary_key: true },
      reviewer_name: { type: Type::TEXT, not_null: true },
      reviewer_is_mobile_authorized: { type: Type::BOOL, not_null: true },
      reviewer_is_celebrity: { type: Type::BOOL, not_null: true },
      reviewer_profile: { type: Type::TEXT, not_null: true },
      reviewer_logs_count: { type: Type::INTEGER, not_null: true },
      reviewer_restaurants_count: { type: Type::INTEGER, not_null: true },
      reviewer_following_count: { type: Type::INTEGER, not_null: true },
      reviewer_followers_count: { type: Type::INTEGER, not_null: true },
      source_url: { type: Type::TEXT, not_null: true },
      scraped_at: { type: Type::DATE, not_null: true },
    },
    reviews: {
      review_id: { type: Type::TEXT, primary_key: true },
      restaurant_id: { type: Type::INTEGER, foreign_key: [:restaurants_from_review_page, :restaurant_id] },
      reviewer_url_path: { type: Type::TEXT, foreign_key: [:reviewers, :reviewer_url_path] },

      review_url: { type: Type::TEXT, not_null: true },

      visit_count: { type: Type::INTEGER, not_null: true },

      dinner_rating: { type: Type::TEXT, not_null: false },
      dinner_rating_int: { type: Type::INTEGER, not_null: false },
      dinner_rating_food: { type: Type::TEXT, not_null: false },
      dinner_rating_service: { type: Type::TEXT, not_null: false },
      dinner_rating_mood: { type: Type::TEXT, not_null: false },
      dinner_rating_cp: { type: Type::TEXT, not_null: false },
      dinner_rating_drink: { type: Type::TEXT, not_null: false },
      dinner_rating_details_count: { type: Type::INTEGER, not_null: false },
      dinner_rating_details_text: { type: Type::TEXT, not_null: false },

      lunch_rating: { type: Type::TEXT, not_null: false },
      lunch_rating_int: { type: Type::INTEGER, not_null: false },
      lunch_rating_food: { type: Type::TEXT, not_null: false },
      lunch_rating_service: { type: Type::TEXT, not_null: false },
      lunch_rating_mood: { type: Type::TEXT, not_null: false },
      lunch_rating_cp: { type: Type::TEXT, not_null: false },
      lunch_rating_drink: { type: Type::TEXT, not_null: false },
      lunch_rating_details_count: { type: Type::INTEGER, not_null: false },
      lunch_rating_details_text: { type: Type::TEXT, not_null: false },

      dinner_usedprice: { type: Type::TEXT, not_null: false },
      lunch_usedprice: { type: Type::TEXT, not_null: false },

      visit_date: { type: Type::TEXT, not_null: false },
      has_title: { type: Type::BOOL, not_null: true },
      photo_count: { type: Type::INTEGER, not_null: true },
      title: { type: Type::TEXT, not_null: false },
      comment: { type: Type::TEXT, not_null: false },

      source_url: { type: Type::TEXT, not_null: true },
      scraped_at: { type: Type::DATE, not_null: true },
    },
  }

  INDEXES_DEFINITION = {
    area2s_prefecture: { table: :area2s, columns: [:prefecture] },
    area2s_area1: { table: :area2s, columns: [:area1] },

    review_urls_in_sitemap_restaurant_id: { table: :review_urls_in_sitemap, columns: [:restaurant_id] },

    restaurants_in_search_result_prefecture: { table: :restaurants_in_search_result, columns: [:prefecture] },
    restaurants_in_search_result_area1: { table: :restaurants_in_search_result, columns: [:area1] },
    restaurants_in_search_result_area2: { table: :restaurants_in_search_result, columns: [:area2] },

    restaurants_from_top_page_prefecture: { table: :restaurants_from_top_page, columns: [:prefecture] },
    restaurants_from_top_page_area1: { table: :restaurants_from_top_page, columns: [:area1] },
    restaurants_from_top_page_area2: { table: :restaurants_from_top_page, columns: [:area2] },

    reviews_review_id: { table: :reviews, columns: [:review_id] },
    reviews_reviewer_url_path: { table: :reviews, columns: [:reviewer_url_path] },
  }

  def self.create_column_sql(column_name, column_definition_hash)
    sql = "#{column_name} #{column_definition_hash[:type]}"
    if column_definition_hash[:primary_key]
      sql += " not null primary key"
    elsif column_definition_hash[:not_null]
      sql += " not null"
    end

    return sql
  end

  def self.create_table_sql(table_name, columns_hash)
    column_definition_sqls = columns_hash.map { |column_name, column_definition_hash| create_column_sql(column_name, column_definition_hash) }
    foreign_key_sqls = columns_hash.select { |column_name, column_definition_hash| column_definition_hash[:foreign_key] }.map { |column_name, column_definition_hash|
      foreign_table, foreign_table_key = column_definition_hash[:foreign_key]
      "FOREIGN KEY(#{column_name}) REFERENCES #{foreign_table}(#{foreign_table_key})"
    }

    return "CREATE TABLE IF NOT EXISTS #{table_name} (\n#{(column_definition_sqls + foreign_key_sqls).join(",\n")}\n);"
  end

  def self.create_tables_sql(tables_definition_hash)
    tables_definition_hash.map { |table_name, columns_hash| create_table_sql(table_name, columns_hash) }.join("\n")
  end

  def self.create_index_sql(index_name, index_definition_hash)
    "CREATE INDEX IF NOT EXISTS #{index_name} ON #{index_definition_hash[:table]} (#{index_definition_hash[:columns].join(", ")});"
  end

  def self.create_indexes_sql(indexes_definition_hash)
    indexes_definition_hash.map { |index_name, index_definition_hash| create_index_sql(index_name, index_definition_hash) }.join("\n")
  end
end
