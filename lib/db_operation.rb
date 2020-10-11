require "sqlite3"
require "date"
require_relative "create_db_tables"

class DbOperation
  def initialize(db)
    @db = db
  end

  private def convert_ruby_value_to_sql_value(ruby_value)
    case ruby_value
    when true
      1
    when false
      0
    when Date
      ruby_value.iso8601
    when Time
      ruby_value.iso8601
    else
      ruby_value
    end
  end

  private def convert_ruby_values_hash_to_sql_values_hash(ruby_values_hash)
    ruby_values_hash.map { |key, ruby_value| [key, convert_ruby_value_to_sql_value(ruby_value)] }.to_h
  end

  private def insert_or_ignore_to_table(table, ruby_values_hash)
    column_definitions_hash = CreateDbTables::TABLES_DEFINITION[table]
    column_names = column_definitions_hash.keys
    columns_sql = column_names.join(", ")
    values_placeholders_sql = column_names.map { |column_name| ":#{column_name}" }.join(", ")

    sql = "INSERT OR IGNORE INTO #{table} (#{columns_sql}) VALUES (#{values_placeholders_sql});"

    ruby_values_hash = column_names.map { |column_name| [column_name, ruby_values_hash[column_name]] }.to_h

    missing_columns = column_names - ruby_values_hash.keys
    if missing_columns.any?
      raise "missing columns: #{missing_columns.inspect}"
    end
    column_names.each do |column_name|
      column_definition = column_definitions_hash[column_name]
      if column_definition[:primary_key] || column_definition[:not_null]
        if ruby_values_hash[column_name].nil?
          raise "column #{column_name} has #{ruby_values_hash[column_name].inspect} value but the column is not null"
        end
      end
    end

    @db.execute(sql, convert_ruby_values_hash_to_sql_values_hash(ruby_values_hash))
  end

  private def update_columns_of_table_with_eq_condition(table, column_and_new_value_hash, column_and_condition_value_hash)
    new_value_symbol_proc = proc { |column| "new_value_#{column}".to_sym }
    condition_symbol_proc = proc { |column| "condition_#{column}".to_sym }
    ruby_values_hash = {}
    new_value_sql = column_and_new_value_hash.map { |column, new_value| key = new_value_symbol_proc[column]; ruby_values_hash[key] = new_value; "#{column} = :#{key}" }.join(", ")
    condition_sql = column_and_condition_value_hash.map { |column, value| key = condition_symbol_proc[column]; ruby_values_hash[key] = value; "(#{column} = :#{key})" }.join(" AND ")
    sql = "UPDATE #{table} SET #{new_value_sql} WHERE #{condition_sql};"
    @db.execute(sql, convert_ruby_values_hash_to_sql_values_hash(ruby_values_hash))
  end

  def create_tables
    @db.execute_batch(CreateDbTables.create_tables_sql(CreateDbTables::TABLES_DEFINITION))
    @db.execute_batch(CreateDbTables.create_indexes_sql(CreateDbTables::INDEXES_DEFINITION))
  end

  def with_transaction()
    @db.transaction
    yield
    @db.commit
  end

  def add_prefecture(prefecture)
    insert_or_ignore_to_table(:prefectures, { prefecture: prefecture })
  end

  def add_area2(prefecture, area1, area2)
    insert_or_ignore_to_table(:area2s, { prefecture: prefecture, area1: area1, area2: area2, scraping_completed: false })
  end

  # this method actually uses only area2
  def update_area2_to_scraping_complete(prefecture, area1, area2)
    update_columns_of_table_with_eq_condition(:area2s, { scraping_completed: true }, { area2: area2 })
  end

  def get_all_prefectures()
    @db.execute("SELECT #{:prefecture} FROM #{:prefectures};").map(&:first)
  end

  def get_not_complete_area_arrays(limit)
    @db.execute("SELECT #{:prefecture}, #{:area1}, #{:area2} FROM #{:area2s} WHERE #{:scraping_completed} = :false LIMIT :limit;", convert_ruby_values_hash_to_sql_values_hash(false: false, limit: limit))
  end

  def get_count_of_area2s()
    @db.execute("SELECT COUNT(*) FROM #{:area2s};").first.first
  end

  def get_count_of_not_complete_area_arrays()
    @db.execute("SELECT COUNT(*) FROM #{:area2s} WHERE #{:scraping_completed} = :false;", convert_ruby_values_hash_to_sql_values_hash(false: false)).first.first
  end

  def add_restaurant_url(restaurant_id, restaurant_url, is_japan, sitemap_last_modified)
    insert_or_ignore_to_table(:restaurant_urls, { restaurant_id: restaurant_id, restaurant_url: restaurant_url, is_japan: is_japan, sitemap_last_modified: sitemap_last_modified, scraping_completed: false })
  end

  def update_restaurant_urls_scraping_completed(restaurant_id)
    update_columns_of_table_with_eq_condition(:restaurant_urls, { scraping_completed: true }, { restaurant_id: restaurant_id })
  end

  def update_restaurant_urls_scraping_completed_from_restaurants_in_search_result()
    @db.execute("UPDATE #{:restaurant_urls} SET #{:scraping_completed} = :true WHERE #{:scraping_completed} = :false AND #{:restaurant_id} IN (SELECT #{:restaurant_id} FROM #{:restaurants_in_search_result});", convert_ruby_values_hash_to_sql_values_hash(true: true, false: false))
  end

  def update_restaurant_urls_scraping_completed_from_restaurants_from_top_page()
    @db.execute("UPDATE #{:restaurant_urls} SET #{:scraping_completed} = :true WHERE #{:scraping_completed} = :false AND #{:restaurant_id} IN (SELECT #{:restaurant_id} FROM #{:restaurants_from_top_page});", convert_ruby_values_hash_to_sql_values_hash(true: true, false: false))
  end

  def get_not_complete_restaurant_urls(limit)
    @db.execute("SELECT #{:restaurant_url} FROM #{:restaurant_urls} WHERE #{:scraping_completed} = :false AND #{:is_japan} = :true LIMIT :limit;", convert_ruby_values_hash_to_sql_values_hash(true: true, false: false, limit: limit)).map(&:first)
  end

  def get_count_of_not_complete_restaurant_urls()
    @db.execute("SELECT count(*) FROM #{:restaurant_urls} WHERE #{:scraping_completed} = :false AND #{:is_japan} = :true;", convert_ruby_values_hash_to_sql_values_hash(true: true, false: false)).first.first
  end

  def add_review_url_in_sitemap(review_id, restaurant_id, review_url)
    insert_or_ignore_to_table(:review_urls_in_sitemap, { review_id: review_id, restaurant_id: restaurant_id, review_url: review_url })
  end

  def add_restaurant_url_for_scraping_reviews(restaurant_id, restaurant_url)
    insert_or_ignore_to_table(:restaurant_urls_for_scraping_reviews, { restaurant_id: restaurant_id, restaurant_url: restaurant_url, scraping_reviews_completed: false })
  end

  def update_restaurant_urls_for_scraping_reviews_scraping_reviews_completed(restaurant_id)
    update_columns_of_table_with_eq_condition(:restaurant_urls_for_scraping_reviews, { scraping_reviews_completed: true }, { restaurant_id: restaurant_id })
  end

  def get_not_complete_restaurant_urls_for_scraping_reviews(limit)
    @db.execute("SELECT #{:restaurant_url} FROM #{:restaurant_urls_for_scraping_reviews} WHERE #{:scraping_reviews_completed} = :false LIMIT :limit;", convert_ruby_values_hash_to_sql_values_hash(false: false, limit: limit)).map(&:first)
  end

  def get_count_of_not_complete_restaurant_urls_for_scraping_reviews()
    @db.execute("SELECT count(*) FROM #{:restaurant_urls_for_scraping_reviews} WHERE #{:scraping_reviews_completed} = :false;", convert_ruby_values_hash_to_sql_values_hash(false: false)).first.first
  end

  def add_restaurants_in_search_result(restaurant_in_search_result_hash)
    insert_or_ignore_to_table(:restaurants_in_search_result, restaurant_in_search_result_hash)
  end

  def get_count_of_restaurants_in_search_result()
    @db.execute("SELECT COUNT(*) FROM #{:restaurants_in_search_result};").first.first
  end

  def add_restaurants_from_top_page(restaurant_from_top_page_hash)
    insert_or_ignore_to_table(:restaurants_from_top_page, restaurant_from_top_page_hash)
  end

  def add_review_page(reviews_result_hash)
    restaurant_review_page_restaurant_info_hash = reviews_result_hash[:restaurant]
    restaurant_review_page_restaurant_info_hash[:review_actual_count] = reviews_result_hash[:review_count]

    reviews = reviews_result_hash[:reviews]
    restaurant_id = restaurant_review_page_restaurant_info_hash[:restaurant_id]
    source_url = restaurant_review_page_restaurant_info_hash[:source_url]
    scraped_at = restaurant_review_page_restaurant_info_hash[:scraped_at]

    insert_or_ignore_to_table(:restaurants_from_review_page, restaurant_review_page_restaurant_info_hash)
    reviews.each do |review_hash|
      add_review_page_review(restaurant_id, review_hash, source_url, scraped_at)
    end
  end

  def add_review_page_review(restaurant_id, review_hash, source_url, scraped_at)
    reviewer = review_hash[:reviewer]
    reviewer[:source_url] = source_url
    reviewer[:scraped_at] = scraped_at
    insert_or_ignore_to_table(:reviewers, reviewer)

    review_hash[:restaurant_id] = restaurant_id
    review_hash[:reviewer_url_path] = reviewer[:reviewer_url_path]
    review_hash[:source_url] = source_url
    review_hash[:scraped_at] = scraped_at
    insert_or_ignore_to_table(:reviews, review_hash)
  end

  def get_count_of_no_score_reviews()
    @db.execute("SELECT count(*) FROM #{:reviews} WHERE #{:dinner_rating} IS NULL AND #{:lunch_rating} IS NULL AND #{:takeout_rating} IS NULL AND #{:delivery_rating} IS NULL AND #{:etc_rating} IS NULL;").first.first
  end
end
