# tabelog_scraping
食べログの検索結果から、店舗の情報をスクレイピングします。

食べログ3.8問題の検証用に作成したものです。

## 実行方法
1. Rubyを使用します。gemなどでnokogiri, parallel, sqlite3を適宜インストールしてください。

2. MAX_THREADSに並列度を指定してください。

3. Rubyを実行してください。
```
ruby tabelog_scraping.rb
```

4. resultフォルダ以下のSqliteのファイルに情報が出力されます。

## 動作
最初にサイトマップから県一覧、お店のURL一覧を取得します。参考として、レビューのURL一覧も取得します。
お店のURL一覧からエリア一覧を生成します。

各エリアごとの取得については、そのエリアの検索結果に1200件以上店があるかを確認し、1200件以下の場合は取得、1200件より多い場合はジャンルをより細かくして取得を試みます。
大阪梅田と東京新宿の居酒屋は、最もジャンルの分類が細かい状態で検索しても1200件以上ある場合ため、お店のURL一覧から、お店のトップページにアクセスして情報を取得します。

そして、点数3.5以上または口コミ数80以上(この条件はtabelog_scraping.rb の need_to_get_reviews で定義されており、変更可能です)のお店のレビュー一覧を取得します。食べログのバグにより、口コミ数が1200以上あるお店は、1200件までしか取得することができません。（レビュー一覧から1200件目以降も取得可能ですが、実装していません。）

中断しても、再実行により再開することが可能です。
大量のアクセスを行うと、アクセス制限が行わわれることがあります。(https://tabelog.com/access_check/recaptcha)

## 収集する情報
### Sqliteのテーブルとカラム一覧
#### prefectures
県一覧。

- prefecture: 県名。"hokkaido"など

#### area2s
エリア一覧。

- prefecture: 県。"hokkaido/A0101/A010101"の場合、"hokkaido"
- area1: エリアの区切りの1つ目。"hokkaido/A0101/A010101"の場合、"A0101"
- area2: エリアの区切りの2つ目。"hokkaido/A0101/A010101"の場合、"A010101"
- scraping_completed: このエリアのスクレイピングが完了したか

#### review_urls_in_sitemap
レビューのサイトマップ https://tabelog.com/sitemap_pc_rvwdtl_nnn.xml.gz に含まれるレビュー一覧。

- review_id: レビューのID
- restaurant_id: お店のID
- review_url: レビューのURL

#### restaurant_urls
お店のサイトマップ https://tabelog.com/sitemap_pc_rstdtl_nnn.xml.gz に含まれるお店一覧。

- restaurant_id: お店のID
- restaurant_url: お店のURL
- is_japan: 日本のお店か
- sitemap_last_modified: サイトマップの最終更新日
- scraping_completed: このお店のスクレイピングが完了しているか

#### restaurant_urls_for_scraping_reviews
レビューをスクレイピングする必要があるかを管理するテーブル。

#### restaurants_in_search_result
お店の検索結果から取得したお店の情報。

- restaurant_id: お店のID
- prefecture: 県
- area1: エリア1
- area2: エリア2
- restaurant_url: お店のURL
- name: お店の名前
- area_name: 地域名
- genre: ジャンル("、"区切り)
- has_pr: PR文を持っているか(存在する場合、有料会員)
- rating: お店の点数(文字列)
- rating_int: お店の点数を100倍して整数にしたもの。空欄の場合0
- review_count: 口コミ数
- dinner_budget: ディナー予算
- lunch_budget: ランチ予算
- has_holiday_notice: 休日欄に「非公式」の注意があるか(存在する場合、非会員)
- search_words: 検索キーワード("|"区切り)
- img_count: 一覧に画像がいくつ表示されているか(0--5)
- has_calendar: 予約カレンダーを表示しているか
- source_url: 取得したURL
- scraped_at: 取得時刻

#### restaurants_from_top_page
お店のサイトマップに含まれているが、お店の検索結果から取得できなかった(restaurants_in_search_result)お店の情報を、各店のトップページから取得したもの。

- restaurant_id: お店のID
- prefecture: 県
- area1: エリア1
- area2: エリア2
- restaurant_url: お店のURL
- status_badge: お店の状態のバッジのクラス名(移転ならremoved, 閉店ならclosedなど)
- name: お店の名前
- area_name: 地域名
- genre: ジャンル("、"区切り)
- has_pr: PR文を持っているか(存在する場合、有料会員)
- rating: お店の点数(文字列)
- rating_int: お店の点数を100倍して整数にしたもの。空欄の場合0
- review_count: 口コミ数
- dinner_budget: ディナー予算
- lunch_budget: ランチ予算
- has_holiday_notice: 休日欄に「非公式」の注意があるか(存在する場合、非会員)
- search_words: 検索キーワード("|"区切り、restaurants_in_search_resultのsearch_wordsとは微妙に内容が違う)
- img_count: 一覧に画像がいくつ表示されているか(0--5)
- has_calendar: 予約カレンダーを表示しているか
- has_pillow_word: お店の見出しの上部に宣伝文があるか
- has_owner_badge: お店の名前欄に「公式情報」のバッジがあるか(会員か非会員かを確実に見分けられる)
- has_group_badge: お店の名前欄に「関連店舗」のバッジがあるか
- has_advertisement: 広告が表示されているか(非会員または無料会員か、有料会員かを確実に見分けられる)
- save_target_count: お店が保存された数
- source_url: 取得したURL
- scraped_at: 取得時刻

#### restaurants_from_review_page
お店の口コミ一覧から取得したお店の情報

- restaurant_id: お店のID
- restaurant_url: お店のURL
- status_badge: お店の状態のバッジのクラス名(移転ならremoved, 閉店ならclosedなど)
- name: お店の名前
- area_name: 地域名
- genre: ジャンル("、"区切り)
- rating: お店の点数(文字列)
- rating_int: お店の点数を100倍して整数にしたもの。空欄の場合0
- review_count: 口コミ数
- dinner_budget: ディナー予算
- lunch_budget: ランチ予算
- has_holiday_notice: 休日欄に「非公式」の注意があるか(存在する場合、非会員)
- img_count: 一覧に画像がいくつ表示されているか(0--5)
- has_calendar: 予約カレンダーを表示しているか
- has_pillow_word: お店の見出しの上部に宣伝文があるか
- has_owner_badge: お店の名前欄に「公式情報」のバッジがあるか(会員か非会員かを確実に見分けられる)
- has_group_badge: お店の名前欄に「関連店舗」のバッジがあるか
- has_advertisement: 広告が表示されているか(非会員または無料会員か、有料会員かを確実に見分けられる)
- save_target_count: お店が保存された数
- source_url: 取得したURL
- scraped_at: 取得時刻
- review_actual_count: 実際に検索で表示されている口コミ数(上記review_countと異なることがある)

#### reviewers
レビュアーの情報(取得対象のお店に投稿した人のみ)

- reviewer_url_path: レビュアーのURLのパス(IDのように使用できる)
- reviewer_name: レビュアーの名前
- reviewer_is_mobile_authorized: 携帯で認証されているか
- reviewer_is_celebrity: グルメ著名人か
- reviewer_profile: レビュアーのプロフィール
- reviewer_logs_count: 食べログ投稿数
- reviewer_restaurants_count: 行ったお店
- reviewer_following_count: フォロー数
- reviewer_followers_count: フォロワー数
- source_url: 取得したURL
- scraped_at: 取得時刻

#### reviews
口コミの情報

- review_id: 口コミのID
- restaurant_id: お店のID
- reviewer_url_path: レビュアーのURLのパス(IDのように使用できる)
- review_url: 口コミのURL
- visit_count: 行った回数
- dinner_rating: ディナーの点数(文字列)
- dinner_rating_int: 上記の点数を100倍して整数にしたもの
- dinner_rating_food: 料理
- dinner_rating_service: サービス
- dinner_rating_mood: 雰囲気
- dinner_rating_cp: CP
- dinner_rating_drink: ドリンク
- dinner_rating_details_count: 5
- dinner_rating_details_text: 上記を文字列にしたもの
- lunch_rating: ランチの点数(文字列)
- lunch_rating_int: 上記の点数を100倍して整数にしたもの
- lunch_rating_food: 料理
- lunch_rating_service: サービス
- lunch_rating_mood: 雰囲気
- lunch_rating_cp: CP
- lunch_rating_drink: ドリンク
- lunch_rating_details_count: 5
- lunch_rating_details_text: 上記を文字列にしたもの
- dinner_usedprice: ディナーに使った金額
- lunch_usedprice: ランチに使った金額
- visit_date: 訪れた月(「2019/11訪問」の形式)
- has_title: タイトルが存在するか
- photo_count: 画像数
- title: タイトル
- comment: コメントの先頭部分
- source_url: 取得したURL
- scraped_at: 取得時刻
