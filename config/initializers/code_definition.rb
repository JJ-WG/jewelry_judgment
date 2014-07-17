# encoding: utf-8

#
#= 各種コード定義
#
# Created:: 2012/10/5
#

# 都道府県コード定義
PREF_CODE = {
  '00' => '海外',
  '01' => '北海道',
  '02' => '青森県',
  '03' => '岩手県',
  '04' => '宮城県',
  '05' => '秋田県',
  '06' => '山形県',
  '07' => '福島県',
  '08' => '茨城県',
  '09' => '栃木県',
  '10' => '群馬県',
  '11' => '埼玉県',
  '12' => '千葉県',
  '13' => '東京都',
  '14' => '神奈川県',
  '15' => '新潟県',
  '16' => '富山県',
  '17' => '石川県',
  '18' => '福井県',
  '19' => '山梨県',
  '20' => '長野県',
  '21' => '岐阜県',
  '22' => '静岡県',
  '23' => '愛知県',
  '24' => '三重県',
  '25' => '滋賀県',
  '26' => '京都府',
  '27' => '大阪府',
  '28' => '兵庫県',
  '29' => '奈良県',
  '30' => '和歌山県',
  '31' => '鳥取県',
  '32' => '島根県',
  '33' => '岡山県',
  '34' => '広島県',
  '35' => '山口県',
  '36' => '徳島県',
  '37' => '香川県',
  '38' => '愛媛県',
  '39' => '高知県',
  '40' => '福岡県',
  '41' => '佐賀県',
  '42' => '長崎県',
  '43' => '熊本県',
  '44' => '大分県',
  '45' => '宮崎県',
  '46' => '鹿児島県',
  '47' => '沖縄県'
}

# ユーザー区分コード定義
USER_RANK_CODE = {
  :parttimer    => 10,  # 外注・アルバイト
  :employee     => 30,  # 一般社員
  :manager      => 50,  # マネージャー
  :system_admin => 99   # システム管理者
}

# 業務区分コード定義
OFFICE_JOB_CODE = {
  :development => 0,  # 開発業務
  :office_job  => 1   # 社内業務
}

# プロジェクト状態コード定義
STATUS_CODE = {
  :preparation => 10,  # 準備中
  :progress    => 50,  # 進行中
  :finished    => 90   # 完了
}

# 評価ランクコード定義
EVALUATION_RANK_CODE = {
  1 => 'A',
  2 => 'B',
  3 => 'C',
  4 => 'D'
}

# 受注形態コード定義
ORDER_TYPE_CODE = {
  :contract    => 10,  # 請負(CS)
  :instrument  => 20,  # 機器(CH)
  :maintenance => 30,  # 保守(CR)
  :investment  => 40   # 投資開発(CT)
}

# 税種別コード定義
TAX_TYPE_CODE = {
  :tax_exempt    =>  0,  # 非課税
  :tax_exclusive => 10,  # 外税
  :tax_inclusive => 20   # 内税
}

# 経費科目コード定義
EXPENSE_ITEM_CODE = {
  :transportation_and_stay => 10,  # 交通・宿泊費
  :subcontract             => 30,  # 外注費
  :other                   => 99   # その他
}

# 間接労務費計算方法コード定義
INDIRECT_COST_METHOD_CODE = {
  :method1 =>  0,  # 間接労務費を0とする
  :method2 => 10,  # 受注額に間接労務費率を掛ける
  :method3 => 20,  # 直接労務費、外注費に間接労務費率を掛ける
}

# 間接労務費対象区分コード定義
INDIRECT_COST_SUBJECT_CODE = {
  :employee    => 10,  # 社員
  :cooperative => 20   # 外注・協力会社
}

# 通知メッセージコード定義
MESSAGE_CODE = {
  :start_project          =>  1,  # プロジェクト開始
  :finish_project         =>  2,  # プロジェクト終了
  :restart_project        =>  3,  # プロジェクト再開
  :delete_project         =>  4,  # プロジェクト削除
  :restore_project        =>  5,  # プロジェクト復帰
  :leader_assign          => 11,  # リーダーアサイン
  :relieve_leader         => 12,  # リーダーアサイン解除
  :manager_assign         => 13,  # マネージャーアサイン
  :relieve_manager        => 14,  # マネージャーアサイン解除
  :assign_member          => 21,  # メンバーアサイン
  :relieve_member         => 22,  # メンバーアサイン解除
  :man_days_over          => 31,  # 工数超過
  :cancel_man_days_over   => 32,  # 工数超過解消
  :behind_schedule        => 41,  # 期間超過
  :cancel_behind_schedule => 42,  # 期間超過解消
  :cost_over              => 51,  # 経費超過
  :cancel_cost_over       => 52,  # 経費超過解消
  :profit_shortage        => 61,  # 利益不足
  :cancel_profit_shortage => 62,  # 利益不足解消
  :deficit                => 63,  # 赤字転落
  :surplus                => 64,  # 黒字復帰
}

# 商談ステータスコード定義
DEAL_STATUS_CODE = {
  :under_negotiation => 10,  # 商談中
  :demo_request      => 20,  # デモ依頼
  :making_estimate   => 30,  # 見積中
  :being_proposed    => 40,  # 提案中
  :order_decision    => 50,  # 受注決定
  :pj_progress       => 60,  # PJ進行中
  :accepted          => 70,  # 検収済
  :declinature       => 91,  # 辞退
  :failure_order     => 92   # 失注
}

# 受注確度コード定義
RELIABILITY_CODE = {
  :appear_deal  => 10,  # 商談登場
  :start_deal   => 20,  # 商談開始
  :strong       => 30,  # 濃厚
  :notification => 40,  # 内示
  :decision     => 50   # 確定
}

# プロジェクト情報検索 状態コード定義
PROJECT_SEARCH_STATUS_CODE = {
  :not_include_deleted     => 0,    # 削除済み以外すべて
  :preparation_or_progress => 1,    # 準備中または進行中
  :preparation             => 2,    # 準備中
  :progress                => 3,    # 進行中
  :completed               => 4,    # 完了
  :deleted                 => 5     # 削除済み
}

# プロジェクト情報検索 オーダー種別コード定義
PROJECT_SEARCH_ORDER_CODE = {
  :preorder => 1,  # プレオーダー
  :normal   => 2,  # 通常
  :nothing =>  3   # オーダー無し
}

# 営業方法
ACTIVITY_METHOD_CODE = {
  :visit        => 10,  # 訪問
  :telephone    => 20,  # 電話
  :mail         => 30,  # メール
  :other        => 90,  # その他
}
