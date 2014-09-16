# encoding: utf-8

#
#= PrjMemberモデルクラス
#
# Authors:: 青山 ひろ子
# Created:: 2012/10/5
#
class PrjMember < ActiveRecord::Base
  # アクセサ定義
  attr_accessible :project_id, :user_id, :planned_man_days, :unit_price
  
  # アソシエーション
  belongs_to :project
  belongs_to :user
  
  # バリデーション設定
  validates(:planned_man_days, :presence => true, :numericality =>
      {:greater_than_or_equal_to => 0, :less_than_or_equal_to => 9999.99})
end
