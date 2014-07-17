# encoding: utf-8

#
#= CsvSchMemberモデルクラス
#
# Created:: 2012/10/24
#
class CsvSchMember < ActiveRecord::Base
  # アクセサ定義
  attr_accessible :csv_schedule_id, :user_id, :deleted
  
  # アソシエーション
  belongs_to :csv_schedule
  belongs_to :user

  # デフォルトスコープ
  default_scope where({deleted: 0}).order(:user_id)
end
