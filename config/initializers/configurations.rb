# coding: utf-8

#
#= アプリケーション固有設定
#
# Authors:: 青山 ひろ子
# Created:: 2012/10/5
#

# 一覧の１ページ当たり表示項目数（システム管理）
ITEMS_PER_PAGE = 10

# 一覧の１ページ当たり表示項目数（プロジェクト関連通知）
MESSAGE_ITEMS_PER_PAGE = 5

# 一覧の１ページ当たり表示項目数（プロジェクト一覧）
PROJECT_ITEMS_PER_PAGE = 5

# 一覧の１ページ当たり表示項目数（経費一覧）
EXPENSE_ITEMS_PER_PAGE = 10

# 1日あたりの業務時間(作業時間を人日に換算する時に使用する)
WORK_HOURS_PER_DAY = 8.0

# 年選択の間隔
SELECT_YEAR_INTERVAL = 10

# 一覧の１ページ当たり表示項目数（スケジュール一覧）
SCHEDULE_ITEMS_PER_PAGE = 30

# 一覧の１ページ当たり表示項目数（商談情報一覧）
DEAL_ITEMS_PER_PAGE = 20

# 商談情報関連資料保存ディレクトリ
DEAL_FILES_PATH = "#{Rails.root}/deal_files/"
# ファイル制限 10M
DEAL_FILE_SIZE_LIMIT = 10 * 1024 * 1024

# 一覧の１ページ当たり表示項目数（年間実績データ情報一覧）
HISTORIC_DATA_LIST_PER_PAGE = 10

# 一覧の１ページ当たり表示項目数（年間実績データ情報詳細一覧）
HISTORIC_DATA_DETAIL_PER_PAGE = 10

# 一覧の１ページ当たり表示項目数（工数実績一覧）
RESULT_ITEMS_PER_PAGE = 30

# 都道府県のデフォルト値
DEFAULT_PREF_CODE = 13 # 東京

# 金額を表す数値の最大桁数
PRICE_MAX_DIGITS = 10

# 使用データベースでのBoolean型のTrue値を示す値
dbconfig = Rails.configuration.database_configuration[Rails.env]
DB_TRUE_VALUE = dbconfig['true_value'].nil? ? '"t"' : dbconfig['true_value'].to_s

# 使用データベースでのBoolean型のFalse値を示す値
DB_FALSE_VALUE = dbconfig['false_value'].nil? ? '"f"' : dbconfig['false_value'].to_s

# Date型データのデータベース格納フォーマット
DB_DATE_FORMAT = dbconfig['date_format'].nil? ? '%Y/%m/%d' : dbconfig['date_format']

# PDF出力時に使用するフォントファイルのパス
# (IPAフォント: http://ossipedia.ipa.go.jp/ipafont/index.html)
PDF_FONT_PATH = "#{Rails.root}/vendor/fonts/ipaexg.ttf"
