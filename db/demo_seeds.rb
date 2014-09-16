# encoding: UTF-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Section.create([
{name: '開発１課' , view_order: 1},
{name: '開発２課' , view_order: 2},
{name: '開発３課' , view_order: 3, deleted: 1},
{name: '営業１課' , view_order: 4},
{name: '営業２課' , view_order: 5},
{name: '総務課' , view_order: 6},
])

User.create([
{ login: 'admin', name: 'システム管理者', name_ruby: 'システムカンリシャ', user_rank_cd: User::USER_RANK_CODE[:system_admin], password: 'password', password_confirmation: 'password', mail_address1: 'test_admin@wacom-it.co.jp', user_code: 'admin' },
{ login: 'nakai', name: '中居正広', name_ruby: 'ナカイ　マサヒロ', section_id: 1, user_rank_cd: 50, password: 'masahiro', password_confirmation: 'masahiro', mail_address1: 'nakai@smap', user_code: 'nakai' },
{ login: 'kimura', name: '木村拓哉', name_ruby: 'キムラ　タクヤ', section_id: 1, user_rank_cd: 30, password: 'takuya', password_confirmation: 'takuya', mail_address1: 'kimura@smap', user_code: 'kimura' },
{ login: 'inagaki', name: '稲垣吾郎', name_ruby: 'イナガキ　ゴロウ', section_id: 1, user_rank_cd: 30, password: 'gorou', password_confirmation: 'gorou', mail_address1: 'inagaki@smap', user_code: 'inagaki' },
{ login: 'kusanagi', name: '草彅剛', name_ruby: 'クサナギ　ツヨシ', section_id: 1, user_rank_cd: 30, password: 'tsuyoshi', password_confirmation: 'tsuyoshi', mail_address1: 'kusanagi@smap', deleted: 1, user_code: 'kusanagi'  },
{ login: 'katori', name: '香取慎吾', name_ruby: 'カトリ　シンゴ', section_id: 1, user_rank_cd: 10, password: 'shingo', password_confirmation: 'shingo', mail_address1: 'katori@smap', user_code: 'katori' },
{ login: 'mori', name: '森且行', name_ruby: 'モリ　カツユキ', section_id: 1, user_rank_cd: 10, password: 'katsuyuki', password_confirmation: 'katsuyuki', mail_address1: 'mori@smap', deleted: true, user_code: 'mori' }
])

#Notice.create([
#{ user_id:1, project_id:1, message_cd:11, message:'プロジェクトのリーダにアサインされました。' },
#{ user_id:1, project_id:1, message_cd:1, message:'プロジェクトが開始されました。' }
#])

Message.create([
{title:'社内管理システムの運用開始', message:'社内管理システムの運用を開始しました。
ご意見、不具合、不明な点などがございましたら
担当の○○までご連絡いただけますようお願いいたします。'},
{title:'システムメンテナンスのご案内', message:'○月○日、システムのメンテナンスを実施します。'},
])

Customer.create([
{code: '001', name: 'ＡＢＣ工業', name_ruby: 'ＡＢＣコウギョウ', pref_cd: 1, },
{code: '002', name: '△△△商店', name_ruby: '△△△ショウテン', pref_cd: 13},
{code: '003', name: '島根県', name_ruby: 'シマネケン', pref_cd: 32},
{code: '004', name: '鳥取県', name_ruby: 'トットリケン', pref_cd: 31},
{code: '005', name: '山口県', name_ruby: 'ヤマグチケン', pref_cd: 35},
{code: '006', name: '広島県', name_ruby: 'ヒロシマケン', pref_cd: 34},
])

DevelopmentLanguage.create([
{name: 'Ruby', view_order: 1},
{name: 'PHP', view_order: 2},
{name: 'Java', view_order: 3},
{name: 'C#', view_order: 4},
{name: 'C++', view_order: 5},
{name: 'C', view_order: 6},
{name: 'Basic', view_order: 7},
])

OperatingSystem.create([
{name: 'Windows Server', view_order: 1},
{name: 'Linux', view_order: 2},
{name: 'Windows7', view_order: 3},
{name: 'Mac OS', view_order: 4},
{name: 'Windows Vista', view_order: 5},
{name: 'Windows XP', view_order: 6},
])

Database.create([
{name: 'Oracle', view_order: 1},
{name: 'SQL Server', view_order: 2},
{name: 'MySQL', view_order: 3},
{name: 'PostgreSQL', view_order: 4},
{name: 'Access', view_order: 5},
{name: 'HiRDB', view_order: 6},
])

WorkType.create([
{name: '要件定義', view_order: 1, work_type_code: 'DR' },
{name: '基本設計', view_order: 2, work_type_code: 'BD' },
{name: '詳細設計', view_order: 3, work_type_code: 'DD' },
{name: 'PG開発', view_order: 4, work_type_code: 'PGD' },
{name: '単体テスト', view_order: 5, work_type_code: 'UT' },
{name: '結合テスト', view_order: 6, work_type_code: 'CT' },
{name: 'システムテスト', view_order: 7, work_type_code: 'ST' },
{name: '社内事務作業', view_order: 1, office_job: true, work_type_code: 'OW' },
{name: '社内会議', view_order: 2, office_job: true, work_type_code: 'OM' },
{name: '社内サーバ管理', view_order: 3, office_job: true, work_type_code: 'OSM' },
{name: '社内レビュー', view_order: 4, office_job: true, work_type_code: 'OR' },
{name: 'プロジェクト外営業活動', view_order: 5, office_job: true, work_type_code: 'PBA' },
{name: '学習・教育', view_order: 6, office_job: true, work_type_code: 'ED' },
{name: '移動', view_order: 7, office_job: true, work_type_code: 'MV' },
])

TaxDivision.create([
{name: '税込5%', view_order: 1, tax_type_cd: 20, tax_rate: 5.00},
{name: '税抜5%', view_order: 2, tax_type_cd: 10, tax_rate: 5.00},
{name: '税込3%', view_order: 3, tax_type_cd: 20, tax_rate: 3.00},
{name: '税抜3%', view_order: 4, tax_type_cd: 10, tax_rate: 3.00},
{name: '税込8%', view_order: 5, tax_type_cd: 20, tax_rate: 8.00},
{name: '税抜8%', view_order: 6, tax_type_cd: 10, tax_rate: 8.00},
{name: '非課税', view_order: 7, tax_type_cd: 0},
])

ExpenseType.create([
{name: '出張経費', view_order: 1, expense_item_cd: 10, tax_division_id: 1},
{name: '自己所有車', view_order: 2, expense_item_cd: 10, tax_division_id: 1},
{name: '交通・宿泊費', view_order: 3, expense_item_cd: 10, tax_division_id: 1},
{name: '外注費', view_order: 4, expense_item_cd: 30, tax_division_id: 2},
{name: '会議費', view_order: 5, expense_item_cd: 99, tax_division_id: 1},
{name: 'その他経費', view_order: 6, expense_item_cd: 99, tax_division_id: 1},
])

Occupation.create([
{name: 'システムエンジニア', view_order: 1},
{name: 'プログラマー', view_order: 2},
{name: 'デザイナー', view_order: 3},
{name: 'プランナー', view_order: 4},
{name: '販売員', view_order: 5},
{name: '事務員', view_order: 6},
{name: 'マネージャー', view_order: 7},
])

Deal.create([
{customer_id: 1, staff_user_id: 2, name: '案件１', budge_amount: 1000000000, anticipated_price: 1000000000, order_volume: 1000000000, order_type_cd: 10, deal_status_cd: 10, prj_managed: true },
{customer_id: 2, staff_user_id: 2, name: '案件２', budge_amount: 2000000000, anticipated_price: 2000000000, order_volume: 2000000000, order_type_cd: 20, deal_status_cd: 10, prj_managed: true },
{customer_id: 3, staff_user_id: 2, name: '案件３', budge_amount: 3000000000, anticipated_price: 3000000000, order_volume: 3000000000, order_type_cd: 30, deal_status_cd: 10, prj_managed: true },
{customer_id: 4, staff_user_id: 2, name: '案件４', budge_amount: 4000000000, anticipated_price: 4000000000, order_volume: 4000000000, order_type_cd: 40, deal_status_cd: 10, prj_managed: true },
{customer_id: 5, staff_user_id: 2, name: '案件５', budge_amount: 5000000000, anticipated_price: 5000000000, order_volume: 5000000000, order_type_cd: 10, deal_status_cd: 10, prj_managed: true },
{customer_id: 6, staff_user_id: 2, name: '案件６', budge_amount: 6000000000, anticipated_price: 6000000000, order_volume: 6000000000, order_type_cd: 10, deal_status_cd: 10, prj_managed: true },
])

Project.create([
{customer_id: 3, manager_id: 1, leader_id: 1, deal_id: 1, order_type_cd: 10, status_cd: 10, name: '○○更新業務', start_date: '2012-09-01', finish_date: '2012-12-31', attention: 1, deleted: 0, project_code: 'PRJ1', order_volume: 1000000 },
{customer_id: 1, manager_id: 1, leader_id: 1, order_type_cd: 10, status_cd: 50, name: 'ＡＢＣシステム', start_date: '2012-09-01', finish_date: '2012-12-31', started_date: '2012-09-02', attention: 0, deleted: 0, locked: 1, project_code: 'PRJ2', order_volume: 2000000 },
{customer_id: 2, manager_id: 1, leader_id: 1, order_type_cd: 10, status_cd: 90, name: '△△△システム', start_date: '2012-09-01', finish_date: '2012-12-31', started_date: '2012-09-02', finished_date: '2013-01-01', attention: 1, deleted: 0, locked: 1, project_code: 'PRJ3', order_volume: 3000000 },
{customer_id: 3, manager_id: 1, leader_id: 1, order_type_cd: 10, status_cd: 10, name: '××システム改修', start_date: '2012-09-01', finish_date: '2012-12-31', attention: 1, deleted: 1, project_code: 'PRJ4', order_volume: 4000000 },
{customer_id: 3, manager_id: 1, leader_id: 1, order_type_cd: 10, status_cd: 10, name: '○○システム', start_date: '2012-09-01', finish_date: '2012-12-31', attention: 1, deleted: 0, project_code: 'PRJ5', order_volume: 5000000 },
{customer_id: 3, manager_id: 1, leader_id: 1, order_type_cd: 10, status_cd: 10, name: '△△更新業務', start_date: '2012-09-01', finish_date: '2012-12-31', attention: 1, deleted: 0, project_code: 'PRJ6', order_volume: 6000000 },
])

PrjReflection.create([
{project_id: 1, order_volume: 1000000000, sales_cost: 1000000000, man_day: 1000.00, direct_labor_cost: 1000000000, subcontract_cost: 1000000000, expense: 1000000000, indirect_labor_cost: 1000000000, development_cost: 1000000000, gross_profit: 1000000000, profit_ratio: 100.00, overall_rank: 1, finished_date: '2012-12-31', planned_finish_date: '2012-12-31', delay_days: 5, schedule_rank: 2, planned_man_days: 1000.00, exceeded_man_days: 1000.00, man_days_rank: 3, expense_budget: 1000000000, exceeded_expense: 1000000000, expense_rank: 4},
{project_id: 2, order_volume: 1000000000, sales_cost: 1000000000, man_day: 1000.00, direct_labor_cost: 1000000000, subcontract_cost: 1000000000, expense: 1000000000, indirect_labor_cost: 1000000000, development_cost: 1000000000, gross_profit: 1000000000, profit_ratio: 100.00, overall_rank: 1, finished_date: '2012-12-31', planned_finish_date: '2012-12-31', delay_days: 5, schedule_rank: 2, planned_man_days: 1000.00, exceeded_man_days: 1000.00, man_days_rank: 3, expense_budget: 1000000000, exceeded_expense: 1000000000, expense_rank: 4},
{project_id: 3, order_volume: 1000000000, sales_cost: 1000000000, man_day: 1000.00, direct_labor_cost: 1000000000, subcontract_cost: 1000000000, expense: 1000000000, indirect_labor_cost: 1000000000, development_cost: 1000000000, gross_profit: 1000000000, profit_ratio: 100.00, overall_rank: 1, finished_date: '2012-12-31', planned_finish_date: '2012-12-31', delay_days: 5, schedule_rank: 2, planned_man_days: 1000.00, exceeded_man_days: 1000.00, man_days_rank: 3, expense_budget: 1000000000, exceeded_expense: 1000000000, expense_rank: 4},
{project_id: 4, order_volume: 1000000000, sales_cost: 1000000000, man_day: 1000.00, direct_labor_cost: 1000000000, subcontract_cost: 1000000000, expense: 1000000000, indirect_labor_cost: 1000000000, development_cost: 1000000000, gross_profit: 1000000000, profit_ratio: 100.00, overall_rank: 1, finished_date: '2012-12-31', planned_finish_date: '2012-12-31', delay_days: 5, schedule_rank: 2, planned_man_days: 1000.00, exceeded_man_days: 1000.00, man_days_rank: 3, expense_budget: 1000000000, exceeded_expense: 1000000000, expense_rank: 4}
])

SystemSetting.create([
{id: 1, notice_indication_days: 30, default_unit_price: 0.0, lock_project_after_editing: 1 },
])

Expense.create([
{ user_id: 3, project_id: 2, expense_type_id: 1, tax_division_id: 1, adjusted_date: '2012-07-10', item_name: '東京出張', amount_paid: 68460 },
{ user_id: 3, project_id: 2, expense_type_id: 2, tax_division_id: 1, adjusted_date: '2012-07-13', item_name: '岡山へ移動', amount_paid: 5040 },
{ user_id: 3, project_id: 2, expense_type_id: 3, tax_division_id: 1, adjusted_date: '2012-07-10', item_name: '東京出張', amount_paid: 8000 },
{ user_id: 2, project_id: 2, expense_type_id: 4, tax_division_id: 1, adjusted_date: '2012-07-01', item_name: '6月分外注費', amount_paid: 500000 },
{ user_id: 2, project_id: 2, expense_type_id: 4, tax_division_id: 1, adjusted_date: '2012-08-01', item_name: '7月分外注費', amount_paid: 500000 },
{ user_id: 2, project_id: 2, expense_type_id: 5, tax_division_id: 1, adjusted_date: '2012-07-15', item_name: '会場費用', amount_paid: 5000 },
{ user_id: 4, project_id: 2, expense_type_id: 6, tax_division_id: 1, adjusted_date: '2012-07-13', item_name: 'SDKライセンス料', amount_paid: 52500 },
{ user_id: 4, project_id: 2, expense_type_id: 6, tax_division_id: 1, adjusted_date: '2012-07-10', item_name: '開発ツール購入', amount_paid: 5290 },
{ user_id: 3, project_id: 3, expense_type_id: 1, tax_division_id: 1, adjusted_date: '2012-07-10', item_name: '東京出張', amount_paid: 68460 },
{ user_id: 3, project_id: 3, expense_type_id: 2, tax_division_id: 1, adjusted_date: '2012-07-13', item_name: '岡山へ移動', amount_paid: 5040 },
{ user_id: 3, project_id: 3, expense_type_id: 3, tax_division_id: 1, adjusted_date: '2012-07-10', item_name: '東京出張', amount_paid: 8000 },
{ user_id: 2, project_id: 3, expense_type_id: 4, tax_division_id: 1, adjusted_date: '2012-07-01', item_name: '6月分外注費', amount_paid: 500000 },
{ user_id: 2, project_id: 3, expense_type_id: 4, tax_division_id: 1, adjusted_date: '2012-08-01', item_name: '7月分外注費', amount_paid: 500000 },
{ user_id: 2, project_id: 3, expense_type_id: 5, tax_division_id: 1, adjusted_date: '2012-07-15', item_name: '会場費用', amount_paid: 5000 },
{ user_id: 4, project_id: 3, expense_type_id: 6, tax_division_id: 1, adjusted_date: '2012-07-13', item_name: 'SDKライセンス料', amount_paid: 52500 },
{ user_id: 4, project_id: 3, expense_type_id: 6, tax_division_id: 1, adjusted_date: '2012-07-10', item_name: '開発ツール購入', amount_paid: 5290 },
])

Schedule.create([
{project_id: 1, work_type_id: 1, schedule_date: '2012-09-01', start_at: '2012-09-01 9:00', end_at: '2012-09-01 12:00', auto_reflect: 0 },
{project_id: 2, work_type_id: 2, schedule_date: '2012-09-01', start_at: '2012-09-01 13:00', end_at: '2012-09-01 15:00', auto_reflect: 0 },
{project_id: 2, work_type_id: 3, schedule_date: '2012-09-01', start_at: '2012-09-01 15:00', end_at: '2012-09-01 18:00', auto_reflect: 0 }
])

IndirectCost.create([
{start_date: '2011-09-01', indirect_cost_method_cd:  0 },
{start_date: '2012-04-01', indirect_cost_method_cd: 20 },
{start_date: '2012-09-01', indirect_cost_method_cd: 10 },
])

IndirectCostRatio.create([
{indirect_cost_id: 1, indirect_cost_subject_cd: 10, order_type_cd: 10, ratio: 0.0 },
{indirect_cost_id: 1, indirect_cost_subject_cd: 10, order_type_cd: 20, ratio: 0.0 },
{indirect_cost_id: 1, indirect_cost_subject_cd: 10, order_type_cd: 30, ratio: 0.0 },
{indirect_cost_id: 1, indirect_cost_subject_cd: 10, order_type_cd: 40, ratio: 0.0 },
{indirect_cost_id: 1, indirect_cost_subject_cd: 20, order_type_cd: 10, ratio: 0.0 },
{indirect_cost_id: 1, indirect_cost_subject_cd: 20, order_type_cd: 20, ratio: 0.0 },
{indirect_cost_id: 1, indirect_cost_subject_cd: 20, order_type_cd: 30, ratio: 0.0 },
{indirect_cost_id: 1, indirect_cost_subject_cd: 20, order_type_cd: 40, ratio: 0.0 },
{indirect_cost_id: 2, indirect_cost_subject_cd: 10, order_type_cd: 10, ratio: 0.0 },
{indirect_cost_id: 2, indirect_cost_subject_cd: 10, order_type_cd: 20, ratio: 0.0 },
{indirect_cost_id: 2, indirect_cost_subject_cd: 10, order_type_cd: 30, ratio: 0.0 },
{indirect_cost_id: 2, indirect_cost_subject_cd: 10, order_type_cd: 40, ratio: 0.0 },
{indirect_cost_id: 2, indirect_cost_subject_cd: 20, order_type_cd: 10, ratio: 0.0 },
{indirect_cost_id: 2, indirect_cost_subject_cd: 20, order_type_cd: 20, ratio: 0.0 },
{indirect_cost_id: 2, indirect_cost_subject_cd: 20, order_type_cd: 30, ratio: 0.0 },
{indirect_cost_id: 2, indirect_cost_subject_cd: 20, order_type_cd: 40, ratio: 0.0 },
{indirect_cost_id: 3, indirect_cost_subject_cd: 10, order_type_cd: 10, ratio: 25.0 },
{indirect_cost_id: 3, indirect_cost_subject_cd: 10, order_type_cd: 20, ratio: 25.0 },
{indirect_cost_id: 3, indirect_cost_subject_cd: 10, order_type_cd: 30, ratio: 25.0 },
{indirect_cost_id: 3, indirect_cost_subject_cd: 10, order_type_cd: 40, ratio: 25.0 },
{indirect_cost_id: 3, indirect_cost_subject_cd: 20, order_type_cd: 10, ratio: 0.0 },
{indirect_cost_id: 3, indirect_cost_subject_cd: 20, order_type_cd: 20, ratio: 0.0 },
{indirect_cost_id: 3, indirect_cost_subject_cd: 20, order_type_cd: 30, ratio: 0.0 },
{indirect_cost_id: 3, indirect_cost_subject_cd: 20, order_type_cd: 40, ratio: 0.0 },
])

PrjExpenseBudget.create([
{project_id: 1, expense_item_cd: 10, expense_budget: 100000 },
{project_id: 1, expense_item_cd: 30, expense_budget: 100000 },
{project_id: 1, expense_item_cd: 99, expense_budget: 100000 },
{project_id: 2, expense_item_cd: 10, expense_budget: 100000 },
{project_id: 2, expense_item_cd: 30, expense_budget: 100000 },
{project_id: 2, expense_item_cd: 99, expense_budget: 100000 },
{project_id: 3, expense_item_cd: 10, expense_budget: 100000 },
{project_id: 3, expense_item_cd: 30, expense_budget: 100000 },
{project_id: 3, expense_item_cd: 99, expense_budget: 100000 },
{project_id: 4, expense_item_cd: 10, expense_budget: 100000 },
{project_id: 4, expense_item_cd: 30, expense_budget: 100000 },
{project_id: 4, expense_item_cd: 99, expense_budget: 100000 },
{project_id: 5, expense_item_cd: 10, expense_budget: 100000 },
{project_id: 5, expense_item_cd: 30, expense_budget: 100000 },
{project_id: 5, expense_item_cd: 99, expense_budget: 100000 },
{project_id: 6, expense_item_cd: 10, expense_budget: 100000 },
{project_id: 6, expense_item_cd: 30, expense_budget: 100000 },
{project_id: 6, expense_item_cd: 99, expense_budget: 100000 },
])

UnitPrice.create([
{user_id: 1, start_date: '2012-04-01', unit_price: 9000.0 },
{user_id: 1, start_date: '2012-09-01', unit_price: 10000.0 },
{user_id: 2, start_date: '2012-04-01', unit_price: 9000.0 },
{user_id: 2, start_date: '2012-09-01', unit_price: 10000.0 },
{user_id: 3, start_date: '2012-04-01', unit_price: 9000.0 },
{user_id: 3, start_date: '2012-09-01', unit_price: 10000.0 },
{user_id: 4, start_date: '2012-04-01', unit_price: 8000.0 },
{user_id: 4, start_date: '2012-09-01', unit_price: 9000.0 },
{user_id: 5, start_date: '2012-04-01', unit_price: 8000.0 },
{user_id: 5, start_date: '2012-09-01', unit_price: 9000.0 },
{user_id: 6, start_date: '2012-04-01', unit_price: 8000.0 },
{user_id: 6, start_date: '2012-09-01', unit_price: 9000.0 },
{user_id: 7, start_date: '2012-04-01', unit_price: 8000.0 },
{user_id: 7, start_date: '2012-09-01', unit_price: 9000.0 },
])

PrjMember.create([
{ project_id: 1, user_id: 1, planned_man_days: 10 },
{ project_id: 1, user_id: 2, planned_man_days: 20 },
{ project_id: 1, user_id: 3, planned_man_days: 30 },
{ project_id: 1, user_id: 4, planned_man_days: 40 },
{ project_id: 1, user_id: 6, planned_man_days: 50 },
{ project_id: 2, user_id: 1, planned_man_days: 10 },
{ project_id: 2, user_id: 2, planned_man_days: 20 },
{ project_id: 2, user_id: 3, planned_man_days: 30 },
{ project_id: 2, user_id: 4, planned_man_days: 40 },
{ project_id: 2, user_id: 6, planned_man_days: 50 },
{ project_id: 3, user_id: 1, planned_man_days: 10 },
{ project_id: 3, user_id: 2, planned_man_days: 20 },
{ project_id: 3, user_id: 3, planned_man_days: 30 },
{ project_id: 3, user_id: 4, planned_man_days: 40 },
{ project_id: 3, user_id: 6, planned_man_days: 50 },
{ project_id: 4, user_id: 1, planned_man_days: 10 },
{ project_id: 4, user_id: 2, planned_man_days: 20 },
{ project_id: 4, user_id: 3, planned_man_days: 30 },
{ project_id: 4, user_id: 4, planned_man_days: 40 },
{ project_id: 4, user_id: 6, planned_man_days: 50 },
{ project_id: 5, user_id: 1, planned_man_days: 10 },
{ project_id: 5, user_id: 2, planned_man_days: 20 },
{ project_id: 5, user_id: 3, planned_man_days: 30 },
{ project_id: 5, user_id: 4, planned_man_days: 40 },
{ project_id: 5, user_id: 6, planned_man_days: 50 },
{ project_id: 6, user_id: 1, planned_man_days: 10 },
{ project_id: 6, user_id: 2, planned_man_days: 20 },
{ project_id: 6, user_id: 3, planned_man_days: 30 },
{ project_id: 6, user_id: 4, planned_man_days: 40 },
{ project_id: 6, user_id: 6, planned_man_days: 50 },
])

PrjWorkType.create([
{ project_id: 1, work_type_id: 1, planned_man_days: 10, presented_man_days: 15, progress_rate: 20.0 },
{ project_id: 1, work_type_id: 2, planned_man_days: 20, presented_man_days: 25, progress_rate: 20.0 },
{ project_id: 1, work_type_id: 3, planned_man_days: 30, presented_man_days: 35, progress_rate: 20.0 },
{ project_id: 1, work_type_id: 4, planned_man_days: 40, presented_man_days: 45, progress_rate: 20.0 },
{ project_id: 1, work_type_id: 5, planned_man_days: 50, presented_man_days: 55, progress_rate: 20.0 },
{ project_id: 2, work_type_id: 1, planned_man_days: 10, presented_man_days: 15, progress_rate: 20.0 },
{ project_id: 2, work_type_id: 2, planned_man_days: 20, presented_man_days: 25, progress_rate: 20.0 },
{ project_id: 2, work_type_id: 3, planned_man_days: 30, presented_man_days: 35, progress_rate: 20.0 },
{ project_id: 2, work_type_id: 4, planned_man_days: 40, presented_man_days: 45, progress_rate: 20.0 },
{ project_id: 2, work_type_id: 5, planned_man_days: 50, presented_man_days: 55, progress_rate: 20.0 },
{ project_id: 3, work_type_id: 1, planned_man_days: 10, presented_man_days: 15, progress_rate: 20.0 },
{ project_id: 3, work_type_id: 2, planned_man_days: 20, presented_man_days: 25, progress_rate: 20.0 },
{ project_id: 3, work_type_id: 3, planned_man_days: 30, presented_man_days: 35, progress_rate: 20.0 },
{ project_id: 3, work_type_id: 4, planned_man_days: 40, presented_man_days: 45, progress_rate: 20.0 },
{ project_id: 3, work_type_id: 5, planned_man_days: 50, presented_man_days: 55, progress_rate: 20.0 },
{ project_id: 4, work_type_id: 1, planned_man_days: 10, presented_man_days: 15, progress_rate: 20.0 },
{ project_id: 4, work_type_id: 2, planned_man_days: 20, presented_man_days: 25, progress_rate: 20.0 },
{ project_id: 4, work_type_id: 3, planned_man_days: 30, presented_man_days: 35, progress_rate: 20.0 },
{ project_id: 4, work_type_id: 4, planned_man_days: 40, presented_man_days: 45, progress_rate: 20.0 },
{ project_id: 4, work_type_id: 5, planned_man_days: 50, presented_man_days: 55, progress_rate: 20.0 },
{ project_id: 5, work_type_id: 1, planned_man_days: 10, presented_man_days: 15, progress_rate: 20.0 },
{ project_id: 5, work_type_id: 2, planned_man_days: 20, presented_man_days: 25, progress_rate: 20.0 },
{ project_id: 5, work_type_id: 3, planned_man_days: 30, presented_man_days: 35, progress_rate: 20.0 },
{ project_id: 5, work_type_id: 4, planned_man_days: 40, presented_man_days: 45, progress_rate: 20.0 },
{ project_id: 5, work_type_id: 5, planned_man_days: 50, presented_man_days: 55, progress_rate: 20.0 },
{ project_id: 6, work_type_id: 1, planned_man_days: 10, presented_man_days: 15, progress_rate: 20.0 },
{ project_id: 6, work_type_id: 2, planned_man_days: 20, presented_man_days: 25, progress_rate: 20.0 },
{ project_id: 6, work_type_id: 3, planned_man_days: 30, presented_man_days: 35, progress_rate: 20.0 },
{ project_id: 6, work_type_id: 4, planned_man_days: 40, presented_man_days: 45, progress_rate: 20.0 },
{ project_id: 6, work_type_id: 5, planned_man_days: 50, presented_man_days: 55, progress_rate: 20.0 },
])

PrjSalesCost.create([
{ project_id: 2, tax_division_id: 1, item_name: 'Webサーバ本体', price: 180000 },
{ project_id: 2, tax_division_id: 1, item_name: 'クライアントPC', price: 50000 },
{ project_id: 3, tax_division_id: 1, item_name: 'Webサーバ本体', price: 150000 },
{ project_id: 3, tax_division_id: 1, item_name: 'クライアントPC', price: 65000 },
])

PrjRelatedProject.create([
{ project_id: 1, related_project_id: 2 },
{ project_id: 1, related_project_id: 3 },
{ project_id: 2, related_project_id: 1 },
{ project_id: 2, related_project_id: 3 },
{ project_id: 3, related_project_id: 2 },
{ project_id: 3, related_project_id: 4 },
{ project_id: 4, related_project_id: 3 },
{ project_id: 4, related_project_id: 5 },
{ project_id: 5, related_project_id: 4 },
{ project_id: 5, related_project_id: 6 },
{ project_id: 6, related_project_id: 4 },
{ project_id: 6, related_project_id: 5 },
])

PrjDevLanguage.create([
{ project_id: 1, development_language_id: 1 },
{ project_id: 1, development_language_id: 2 },
{ project_id: 2, development_language_id: 1 },
{ project_id: 2, development_language_id: 2 },
{ project_id: 3, development_language_id: 1 },
{ project_id: 3, development_language_id: 2 },
{ project_id: 4, development_language_id: 1 },
{ project_id: 4, development_language_id: 2 },
{ project_id: 5, development_language_id: 1 },
{ project_id: 5, development_language_id: 2 },
{ project_id: 6, development_language_id: 1 },
{ project_id: 6, development_language_id: 2 },
])

PrjOperatingSystem.create([
{ project_id: 1, operating_system_id: 1 },
{ project_id: 1, operating_system_id: 2 },
{ project_id: 2, operating_system_id: 1 },
{ project_id: 2, operating_system_id: 2 },
{ project_id: 3, operating_system_id: 1 },
{ project_id: 3, operating_system_id: 2 },
{ project_id: 4, operating_system_id: 1 },
{ project_id: 4, operating_system_id: 2 },
{ project_id: 5, operating_system_id: 1 },
{ project_id: 5, operating_system_id: 2 },
{ project_id: 6, operating_system_id: 1 },
{ project_id: 6, operating_system_id: 2 },
])

PrjDatabase.create([
{ project_id: 1, database_id: 1 },
{ project_id: 1, database_id: 2 },
{ project_id: 2, database_id: 1 },
{ project_id: 2, database_id: 2 },
{ project_id: 3, database_id: 1 },
{ project_id: 3, database_id: 2 },
{ project_id: 4, database_id: 1 },
{ project_id: 4, database_id: 2 },
{ project_id: 5, database_id: 1 },
{ project_id: 5, database_id: 2 },
{ project_id: 6, database_id: 1 },
{ project_id: 6, database_id: 2 },
])
