# encoding: UTF-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.create([
{ login: 'admin', name: 'システム管理者', name_ruby: 'システムカンリシャ',  user_rank_cd: User::USER_RANK_CODE[:system_admin], password: 'password', password_confirmation: 'password', mail_address1: 'admin@example.com', user_code: 'admin' },
])

SystemSetting.create([
{ id: 1, notice_indication_days: 30, default_unit_price: 0.0, lock_project_after_editing: 1 },
])
