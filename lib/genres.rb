# coding: utf-8

module Genres
  class Genre
    # subgenres: Array
    attr_reader :key, :name, :subgenres

    def initialize(hash)
      @key = hash[:key]
      @name = hash[:name]
      @subgenres = hash[:subgenres]
    end
  end

  GENRE_TREE = [
      Genre.new(
          key: "RC",
          name: "レストラン",
          subgenres: [
              Genre.new(
                  key: "washoku",
                  name: "和食",
                  subgenres: [
                      Genre.new(
                          key: "japanese",
                          name: "日本料理",
                          subgenres: [
                              Genre.new(
                                  key: "RC010101",
                                  name: "懐石・会席料理",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC010103",
                                  name: "割烹・小料理",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC010105",
                                  name: "精進料理",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC010104",
                                  name: "京料理",
                                  subgenres: [],
                              ),
                          ],
                      ),
                      Genre.new(
                          key: "sushi",
                          name: "寿司",
                          subgenres: [
                              Genre.new(
                                  key: "RC010201",
                                  name: "寿司",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC010202",
                                  name: "回転寿司",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC010203",
                                  name: "立ち食い寿司",
                                  subgenres: [],
                              ),
                          ],
                      ),
                      Genre.new(
                          key: "seafood",
                          name: "魚介料理・海鮮料理",
                          subgenres: [
                              Genre.new(
                                  key: "RC011211",
                                  name: "魚介料理・海鮮料理",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC011212",
                                  name: "ふぐ",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC011213",
                                  name: "かに",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC011214",
                                  name: "すっぽん",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC011215",
                                  name: "あんこう",
                                  subgenres: [],
                              ),
                          ],
                      ),
                      Genre.new(
                          key: "RC0103",
                          name: "天ぷら・揚げ物",
                          subgenres: [
                              Genre.new(
                                  key: "tempura",
                                  name: "天ぷら",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "tonkatsu",
                                  name: "とんかつ",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "kushiage",
                                  name: "串揚げ・串かつ",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC010304",
                                  name: "からあげ",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC010399",
                                  name: "天ぷら・揚げ物（その他）",
                                  subgenres: [],
                              ),
                          ],
                      ),
                      Genre.new(
                          key: "RC0104",
                          name: "そば・うどん・麺類",
                          subgenres: [
                              Genre.new(
                                  key: "soba",
                                  name: "そば",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC010408",
                                  name: "立ち食いそば",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "udon",
                                  name: "うどん",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC010407",
                                  name: "カレーうどん",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC010406",
                                  name: "焼きそば",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC010404",
                                  name: "沖縄そば",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC010403",
                                  name: "ほうとう",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC010405",
                                  name: "ちゃんぽん",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC010499",
                                  name: "そば・うどん・麺類（その他）",
                                  subgenres: [],
                              ),
                          ],
                      ),
                      Genre.new(
                          key: "RC0105",
                          name: "うなぎ・どじょう・あなご",
                          subgenres: [
                              Genre.new(
                                  key: "unagi",
                                  name: "うなぎ",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC010502",
                                  name: "どじょう",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC010503",
                                  name: "あなご",
                                  subgenres: [],
                              ),
                          ],
                      ),
                      Genre.new(
                          key: "RC0106",
                          name: "焼鳥・串焼・鳥料理",
                          subgenres: [
                              Genre.new(
                                  key: "yakitori",
                                  name: "焼鳥",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC010602",
                                  name: "串焼き",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC010604",
                                  name: "もつ焼き",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC010605",
                                  name: "焼きとん",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC010603",
                                  name: "鳥料理",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC010606",
                                  name: "手羽先",
                                  subgenres: [],
                              ),
                          ],
                      ),
                      Genre.new(
                          key: "RC0107",
                          name: "すき焼き・しゃぶしゃぶ",
                          subgenres: [
                              Genre.new(
                                  key: "RC010701",
                                  name: "すき焼き",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "syabusyabu",
                                  name: "しゃぶしゃぶ",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC010703",
                                  name: "豚しゃぶ",
                                  subgenres: [],
                              ),
                          ],
                      ),
                      Genre.new(
                          key: "RC0108",
                          name: "おでん",
                          subgenres: [],
                      ),
                      Genre.new(
                          key: "RC0109",
                          name: "お好み焼き・たこ焼き",
                          subgenres: [
                              Genre.new(
                                  key: "okonomiyaki",
                                  name: "お好み焼き",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "monjya",
                                  name: "もんじゃ焼き",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC010911",
                                  name: "たこ焼き",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC010912",
                                  name: "明石焼き",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC010999",
                                  name: "お好み焼き・たこ焼き（その他）",
                                  subgenres: [],
                              ),
                          ],
                      ),
                      Genre.new(
                          key: "RC0110",
                          name: "郷土料理",
                          subgenres: [
                              Genre.new(
                                  key: "okinawafood",
                                  name: "沖縄料理",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC011002",
                                  name: "きりたんぽ",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC011099",
                                  name: "郷土料理（その他）",
                                  subgenres: [],
                              ),
                          ],
                      ),
                      Genre.new(
                          key: "RC0111",
                          name: "丼もの",
                          subgenres: [
                              Genre.new(
                                  key: "RC011101",
                                  name: "牛丼",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC011102",
                                  name: "親子丼",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC011103",
                                  name: "天丼・天重",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC011104",
                                  name: "かつ丼・かつ重",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC011105",
                                  name: "海鮮丼",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC011106",
                                  name: "豚丼",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC011199",
                                  name: "丼もの（その他）",
                                  subgenres: [],
                              ),
                          ],
                      ),
                      Genre.new(
                          key: "RC0199",
                          name: "和食（その他）",
                          subgenres: [
                              Genre.new(
                                  key: "RC019910",
                                  name: "豆腐料理・湯葉料理",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC019908",
                                  name: "麦とろ",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC019909",
                                  name: "釜飯",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC019912",
                                  name: "もつ料理",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC019911",
                                  name: "くじら料理",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC019907",
                                  name: "牛タン",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC019903",
                                  name: "ろばた焼き",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC019999",
                                  name: "和食（その他）",
                                  subgenres: [],
                              ),
                          ],
                      ),
                  ],
              ),
              Genre.new(
                  key: "RC02",
                  name: "洋食・西洋料理",
                  subgenres: [
                      Genre.new(
                          key: "RC0201",
                          name: "ステーキ・ハンバーグ",
                          subgenres: [
                              Genre.new(
                                  key: "steak",
                                  name: "ステーキ",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "hamburgersteak",
                                  name: "ハンバーグ",
                                  subgenres: [],
                              ),
                          ],
                      ),
                      Genre.new(
                          key: "RC0203",
                          name: "鉄板焼き",
                          subgenres: [],
                      ),
                      Genre.new(
                          key: "RC0202",
                          name: "パスタ・ピザ",
                          subgenres: [
                              Genre.new(
                                  key: "pasta",
                                  name: "パスタ",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "pizza",
                                  name: "ピザ",
                                  subgenres: [],
                              ),
                          ],
                      ),
                      Genre.new(
                          key: "hamburger",
                          name: "ハンバーガー",
                          subgenres: [],
                      ),
                      Genre.new(
                          key: "RC0209",
                          name: "洋食・欧風料理",
                          subgenres: [
                              Genre.new(
                                  key: "yoshoku",
                                  name: "洋食",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC020911",
                                  name: "ハヤシライス",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC020912",
                                  name: "オムライス",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC020913",
                                  name: "シチュー",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC020914",
                                  name: "スープ",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC020915",
                                  name: "コロッケ・フライ",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC020999",
                                  name: "洋食・欧風料理（その他）",
                                  subgenres: [],
                              ),
                          ],
                      ),
                      Genre.new(
                          key: "french",
                          name: "フレンチ",
                          subgenres: [
                              Genre.new(
                                  key: "RC021101",
                                  name: "フレンチ",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC021102",
                                  name: "ビストロ",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC021103",
                                  name: "モダンフレンチ",
                                  subgenres: [],
                              ),
                          ],
                      ),
                      Genre.new(
                          key: "italian",
                          name: "イタリアン",
                          subgenres: [],
                      ),
                      Genre.new(
                          key: "spain",
                          name: "スペイン料理",
                          subgenres: [
                              Genre.new(
                                  key: "RC021301",
                                  name: "スペイン料理",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC021302",
                                  name: "モダンスパニッシュ",
                                  subgenres: [],
                              ),
                          ],
                      ),
                      Genre.new(
                          key: "RC0219",
                          name: "西洋各国料理",
                          subgenres: [
                              Genre.new(
                                  key: "RC021902",
                                  name: "地中海料理",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC021903",
                                  name: "ドイツ料理",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC021904",
                                  name: "ロシア料理",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC021905",
                                  name: "アメリカ料理",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC021906",
                                  name: "カリフォルニア料理",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC021907",
                                  name: "オセアニア料理",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC021908",
                                  name: "ハワイ料理",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC021999",
                                  name: "西洋各国料理（その他）",
                                  subgenres: [],
                              ),
                          ],
                      ),
                  ],
              ),
              Genre.new(
                  key: "chinese",
                  name: "中華料理",
                  subgenres: [
                      Genre.new(
                          key: "RC0301",
                          name: "中華料理",
                          subgenres: [
                              Genre.new(
                                  key: "RC030101",
                                  name: "中華料理",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC030102",
                                  name: "飲茶・点心",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC030103",
                                  name: "北京料理",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC030104",
                                  name: "上海料理",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC030105",
                                  name: "広東料理",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC030106",
                                  name: "四川料理",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC030107",
                                  name: "台湾料理",
                                  subgenres: [],
                              ),
                          ],
                      ),
                      Genre.new(
                          key: "RC0302",
                          name: "餃子・肉まん",
                          subgenres: [
                              Genre.new(
                                  key: "gyouza",
                                  name: "餃子",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC030202",
                                  name: "肉まん・中華まん",
                                  subgenres: [],
                              ),
                          ],
                      ),
                      Genre.new(
                          key: "RC0303",
                          name: "中華粥",
                          subgenres: [],
                      ),
                      Genre.new(
                          key: "RC0304",
                          name: "中華麺",
                          subgenres: [
                              Genre.new(
                                  key: "RC030401",
                                  name: "担々麺",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC030402",
                                  name: "刀削麺",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC030403",
                                  name: "中華麺（その他）",
                                  subgenres: [],
                              ),
                          ],
                      ),
                  ],
              ),
              Genre.new(
                  key: "RC04",
                  name: "アジア・エスニック",
                  subgenres: [
                      Genre.new(
                          key: "korea",
                          name: "韓国料理",
                          subgenres: [
                              Genre.new(
                                  key: "RC040101",
                                  name: "韓国料理",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC040102",
                                  name: "冷麺",
                                  subgenres: [],
                              ),
                          ],
                      ),
                      Genre.new(
                          key: "RC0402",
                          name: "東南アジア料理",
                          subgenres: [
                              Genre.new(
                                  key: "thai",
                                  name: "タイ料理",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC040202",
                                  name: "ベトナム料理",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC040203",
                                  name: "インドネシア料理",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC040204",
                                  name: "シンガポール料理",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC040299",
                                  name: "東南アジア料理（その他）",
                                  subgenres: [],
                              ),
                          ],
                      ),
                      Genre.new(
                          key: "RC0403",
                          name: "南アジア料理",
                          subgenres: [
                              Genre.new(
                                  key: "RC040301",
                                  name: "インド料理",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC040302",
                                  name: "ネパール料理",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC040303",
                                  name: "パキスタン料理",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC040304",
                                  name: "スリランカ料理",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC040399",
                                  name: "南アジア料理（その他）",
                                  subgenres: [],
                              ),
                          ],
                      ),
                      Genre.new(
                          key: "RC0404",
                          name: "西アジア料理",
                          subgenres: [
                              Genre.new(
                                  key: "RC040401",
                                  name: "トルコ料理",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC040499",
                                  name: "西アジア料理（その他）",
                                  subgenres: [],
                              ),
                          ],
                      ),
                      Genre.new(
                          key: "RC0411",
                          name: "中南米料理",
                          subgenres: [
                              Genre.new(
                                  key: "RC041101",
                                  name: "メキシコ料理",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC041102",
                                  name: "ブラジル料理",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC041199",
                                  name: "中南米料理（その他）",
                                  subgenres: [],
                              ),
                          ],
                      ),
                      Genre.new(
                          key: "RC0412",
                          name: "アフリカ料理",
                          subgenres: [],
                      ),
                      Genre.new(
                          key: "RC0499",
                          name: "アジア・エスニック（その他）",
                          subgenres: [],
                      ),
                  ],
              ),
              Genre.new(
                  key: "curry",
                  name: "カレー",
                  subgenres: [
                      Genre.new(
                          key: "RC1201",
                          name: "カレーライス",
                          subgenres: [],
                      ),
                      Genre.new(
                          key: "RC1202",
                          name: "欧風カレー",
                          subgenres: [],
                      ),
                      Genre.new(
                          key: "RC1203",
                          name: "インドカレー",
                          subgenres: [],
                      ),
                      Genre.new(
                          key: "RC1204",
                          name: "タイカレー",
                          subgenres: [],
                      ),
                      Genre.new(
                          key: "RC1205",
                          name: "スープカレー",
                          subgenres: [],
                      ),
                      Genre.new(
                          key: "RC1299",
                          name: "カレー（その他）",
                          subgenres: [],
                      ),
                  ],
              ),
              Genre.new(
                  key: "RC13",
                  name: "焼肉・ホルモン",
                  subgenres: [
                      Genre.new(
                          key: "RC1301",
                          name: "焼肉・ホルモン",
                          subgenres: [
                              Genre.new(
                                  key: "yakiniku",
                                  name: "焼肉",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "horumon",
                                  name: "ホルモン",
                                  subgenres: [],
                              ),
                          ],
                      ),
                      Genre.new(
                          key: "RC1302",
                          name: "ジンギスカン",
                          subgenres: [],
                      ),
                  ],
              ),
              Genre.new(
                  key: "nabe",
                  name: "鍋",
                  subgenres: [
                      Genre.new(
                          key: "RC1401",
                          name: "ちゃんこ鍋",
                          subgenres: [],
                      ),
                      Genre.new(
                          key: "RC1402",
                          name: "うどんすき",
                          subgenres: [],
                      ),
                      Genre.new(
                          key: "motsu",
                          name: "もつ鍋",
                          subgenres: [],
                      ),
                      Genre.new(
                          key: "RC1404",
                          name: "水炊き",
                          subgenres: [],
                      ),
                      Genre.new(
                          key: "RC1405",
                          name: "ちりとり鍋・てっちゃん鍋",
                          subgenres: [],
                      ),
                      Genre.new(
                          key: "RC1406",
                          name: "中国鍋・火鍋",
                          subgenres: [],
                      ),
                      Genre.new(
                          key: "RC1407",
                          name: "韓国鍋",
                          subgenres: [],
                      ),
                      Genre.new(
                          key: "RC1409",
                          name: "タイスキ",
                          subgenres: [],
                      ),
                      Genre.new(
                          key: "RC1408",
                          name: "鍋（その他）",
                          subgenres: [],
                      ),
                  ],
              ),
              Genre.new(
                  key: "RC21",
                  name: "居酒屋・ダイニングバー",
                  subgenres: [
                      Genre.new(
                          key: "izakaya",
                          name: "居酒屋",
                          subgenres: [],
                      ),
                      Genre.new(
                          key: "RC2102",
                          name: "ダイニングバー",
                          subgenres: [],
                      ),
                      Genre.new(
                          key: "RC2199",
                          name: "居酒屋・ダイニングバー（その他）",
                          subgenres: [
                              Genre.new(
                                  key: "RC219902",
                                  name: "立ち飲み居酒屋・バー",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC219903",
                                  name: "バル・バール",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC219904",
                                  name: "ビアホール・ビアレストラン",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC219999",
                                  name: "居酒屋・ダイニングバー（その他）",
                                  subgenres: [],
                              ),
                          ],
                      ),
                  ],
              ),
              Genre.new(
                  key: "RC22",
                  name: "創作料理・無国籍料理",
                  subgenres: [
                      Genre.new(
                          key: "RC2201",
                          name: "創作料理",
                          subgenres: [],
                      ),
                      Genre.new(
                          key: "RC2202",
                          name: "イノベーティブ・フュージョン",
                          subgenres: [],
                      ),
                      Genre.new(
                          key: "RC2203",
                          name: "無国籍料理",
                          subgenres: [],
                      ),
                  ],
              ),
              Genre.new(
                  key: "RC23",
                  name: "ファミレス",
                  subgenres: [],
              ),
              Genre.new(
                  key: "RC99",
                  name: "レストラン（その他）",
                  subgenres: [
                      Genre.new(
                          key: "RC9901",
                          name: "定食・食堂",
                          subgenres: [
                              Genre.new(
                                  key: "RC990101",
                                  name: "定食・食堂",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC990102",
                                  name: "学生食堂",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC990103",
                                  name: "社員食堂",
                                  subgenres: [],
                              ),
                          ],
                      ),
                      Genre.new(
                          key: "RC9903",
                          name: "自然食・薬膳",
                          subgenres: [
                              Genre.new(
                                  key: "RC990301",
                                  name: "自然食",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC990302",
                                  name: "薬膳",
                                  subgenres: [],
                              ),
                          ],
                      ),
                      Genre.new(
                          key: "RC9904",
                          name: "弁当・おにぎり",
                          subgenres: [
                              Genre.new(
                                  key: "RC990401",
                                  name: "弁当",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC990402",
                                  name: "おにぎり",
                                  subgenres: [],
                              ),
                          ],
                      ),
                      Genre.new(
                          key: "RC9999",
                          name: "レストラン（その他）",
                          subgenres: [
                              Genre.new(
                                  key: "viking",
                                  name: "バイキング",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC999903",
                                  name: "デリカテッセン",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC999901",
                                  name: "シーフード",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC999913",
                                  name: "オイスターバー",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC999902",
                                  name: "にんにく料理",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC999905",
                                  name: "野菜料理",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC999907",
                                  name: "牛料理",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC999908",
                                  name: "豚料理",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC999909",
                                  name: "馬肉料理",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC999910",
                                  name: "炭火焼き",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC999911",
                                  name: "バーベキュー",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC999912",
                                  name: "その他肉料理",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC999914",
                                  name: "屋形船・クルージング",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "RC999999",
                                  name: "レストラン（その他）",
                                  subgenres: [],
                              ),
                          ],
                      ),
                  ],
              ),
          ],
      ),
      Genre.new(
          key: "MC",
          name: "ラーメン",
          subgenres: [
              Genre.new(
                  key: "ramen",
                  name: "ラーメン",
                  subgenres: [],
              ),
              Genre.new(
                  key: "MC21",
                  name: "汁なしラーメン",
                  subgenres: [
                      Genre.new(
                          key: "MC2101",
                          name: "油そば",
                          subgenres: [],
                      ),
                      Genre.new(
                          key: "MC2102",
                          name: "台湾まぜそば",
                          subgenres: [],
                      ),
                      Genre.new(
                          key: "MC2103",
                          name: "汁なし担々麺",
                          subgenres: [],
                      ),
                  ],
              ),
              Genre.new(
                  key: "MC11",
                  name: "つけ麺",
                  subgenres: [],
              ),
          ],
      ),
      Genre.new(
          key: "cafe",
          name: "カフェ・喫茶",
          subgenres: [
              Genre.new(
                  key: "CC01",
                  name: "カフェ",
                  subgenres: [],
              ),
              Genre.new(
                  key: "CC02",
                  name: "喫茶店",
                  subgenres: [],
              ),
              Genre.new(
                  key: "CC03",
                  name: "コーヒー専門店",
                  subgenres: [],
              ),
              Genre.new(
                  key: "CC04",
                  name: "紅茶専門店",
                  subgenres: [],
              ),
              Genre.new(
                  key: "CC05",
                  name: "中国茶専門店",
                  subgenres: [],
              ),
              Genre.new(
                  key: "CC06",
                  name: "日本茶専門店",
                  subgenres: [],
              ),
              Genre.new(
                  key: "CC99",
                  name: "カフェ・喫茶（その他）",
                  subgenres: [],
              ),
          ],
      ),
      Genre.new(
          key: "SC",
          name: "パン・スイーツ",
          subgenres: [
              Genre.new(
                  key: "pan",
                  name: "パン・サンドイッチ",
                  subgenres: [
                      Genre.new(
                          key: "SC0101",
                          name: "パン",
                          subgenres: [],
                      ),
                      Genre.new(
                          key: "SC0102",
                          name: "サンドイッチ",
                          subgenres: [],
                      ),
                      Genre.new(
                          key: "SC0103",
                          name: "ベーグル",
                          subgenres: [],
                      ),
                      Genre.new(
                          key: "SC0199",
                          name: "パン・サンドイッチ（その他）",
                          subgenres: [],
                      ),
                  ],
              ),
              Genre.new(
                  key: "sweets",
                  name: "スイーツ",
                  subgenres: [
                      Genre.new(
                          key: "SC0201",
                          name: "洋菓子",
                          subgenres: [
                              Genre.new(
                                  key: "cake",
                                  name: "ケーキ",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "SC020102",
                                  name: "チョコレート",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "SC020103",
                                  name: "マカロン",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "SC020104",
                                  name: "バームクーヘン",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "SC020199",
                                  name: "洋菓子（その他）",
                                  subgenres: [],
                              ),
                          ],
                      ),
                      Genre.new(
                          key: "SC0202",
                          name: "和菓子・甘味処",
                          subgenres: [
                              Genre.new(
                                  key: "SC020201",
                                  name: "和菓子",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "SC020202",
                                  name: "甘味処",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "SC020203",
                                  name: "たい焼き・大判焼き",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "SC020204",
                                  name: "どら焼き",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "SC020205",
                                  name: "大福",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "SC020206",
                                  name: "せんべい",
                                  subgenres: [],
                              ),
                          ],
                      ),
                      Genre.new(
                          key: "SC0203",
                          name: "中華菓子",
                          subgenres: [],
                      ),
                      Genre.new(
                          key: "SC0299",
                          name: "スイーツ（その他）",
                          subgenres: [
                              Genre.new(
                                  key: "SC029901",
                                  name: "アイスクリーム",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "SC029909",
                                  name: "ソフトクリーム",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "SC029907",
                                  name: "かき氷",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "SC029903",
                                  name: "クレープ",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "SC029904",
                                  name: "パフェ",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "SC029902",
                                  name: "フルーツパーラー",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "SC029905",
                                  name: "ジュースバー",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "SC029906",
                                  name: "パンケーキ",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "SC029908",
                                  name: "ドーナツ",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "SC029910",
                                  name: "フレンチトースト",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "SC029911",
                                  name: "アサイーボウル",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "SC029999",
                                  name: "スイーツ（その他）",
                                  subgenres: [],
                              ),
                          ],
                      ),
                  ],
              ),
          ],
      ),
      Genre.new(
          key: "bar",
          name: "バー・お酒",
          subgenres: [
              Genre.new(
                  key: "BC01",
                  name: "バー",
                  subgenres: [],
              ),
              Genre.new(
                  key: "BC02",
                  name: "パブ",
                  subgenres: [],
              ),
              Genre.new(
                  key: "BC03",
                  name: "ラウンジ",
                  subgenres: [],
              ),
              Genre.new(
                  key: "BC04",
                  name: "ワインバー",
                  subgenres: [],
              ),
              Genre.new(
                  key: "BC05",
                  name: "ビアガーデン",
                  subgenres: [],
              ),
              Genre.new(
                  key: "BC06",
                  name: "ビアバー",
                  subgenres: [],
              ),
              Genre.new(
                  key: "BC07",
                  name: "スポーツバー",
                  subgenres: [],
              ),
              Genre.new(
                  key: "BC99",
                  name: "バー・お酒（その他）",
                  subgenres: [
                      Genre.new(
                          key: "BC9901",
                          name: "日本酒バー・焼酎バー",
                          subgenres: [
                              Genre.new(
                                  key: "BC990101",
                                  name: "日本酒バー",
                                  subgenres: [],
                              ),
                              Genre.new(
                                  key: "BC990102",
                                  name: "焼酎バー",
                                  subgenres: [],
                              ),
                          ],
                      ),
                      Genre.new(
                          key: "BC9999",
                          name: "バー・お酒（その他）",
                          subgenres: [],
                      ),
                  ],
              ),
          ],
      ),
      Genre.new(
          key: "YC",
          name: "旅館・オーベルジュ",
          subgenres: [
              Genre.new(
                  key: "ryokan",
                  name: "旅館",
                  subgenres: [],
              ),
              Genre.new(
                  key: "YC02",
                  name: "オーベルジュ",
                  subgenres: [],
              ),
              Genre.new(
                  key: "YC99",
                  name: "旅館・オーベルジュ（その他）",
                  subgenres: [],
              ),
          ],
      ),
      Genre.new(
          key: "ZZ",
          name: "その他",
          subgenres: [],
      ),
  ];
end
