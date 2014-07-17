# encoding: utf-8

#
#= IndirectCostRatioモデルクラス
#
# Created:: 2012/10/5
#
class IndirectCostRatio < ActiveRecord::Base
  # アクセサ定義
  attr_accessible :indirect_cost_id, :indirect_cost_subject_cd, :order_type_cd, :ratio
  
  # アソシエーション
  belongs_to :indirect_cost
  
  # バリデーション設定
  validates(:ratio, :presence => true, :numericality =>
      {:greater_than_or_equal_to => 0, :less_than_or_equal_to => 100})
end
