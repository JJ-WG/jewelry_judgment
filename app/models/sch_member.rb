# encoding: utf-8

#
#= SchMemberモデルクラス
#
# Created:: 2012/10/24
#
class SchMember < ActiveRecord::Base
  # アクセサ定義
  attr_accessible :schedule_id, :user_id, :deleted
  
  # アソシエーション
  belongs_to :schedule
  belongs_to :user

  # デフォルトスコープ
  default_scope where({deleted: 0}).order(:user_id)
end
