# tabelog_scraping
食べログの検索結果から、店舗の情報をスクレイピングします。

食べログ3.8問題の検証用に作成したものです。

## 実行方法
Rubyを使用します。
gemなどでnokogiriを適宜インストールしてください。

```
ruby tabelog_scraping.rb > result.csv
```

## 収集する情報
* area: 検索対象のエリア
* restaurant_url: レストランのURL
* restaurant_id: レストランのID
* restaurant_name: レストランの名前
* restaurant_area: 最寄り駅情報
* restaurant_genre: レストランのジャンル
* restaurant_has_pr: PR文があるか
* restaurant_rating: 点数
* restaurant_review_count: 口コミ数
* restaurant_dinner_budget: ディナー予算
* restaurant_lunch_budget: ランチ予算
* restaurant_has_holiday_notice: 休日欄に注意書きがあるか(非公式情報の場合注意書きがあるようです)
* restaurant_search_words: 「個室」「完全禁煙」などの情報を"|"でつないだもの
* restaurant_has_calendar: 予約用カレンダーが表示されているか
