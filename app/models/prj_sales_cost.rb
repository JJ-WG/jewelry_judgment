# encoding: utf-8

#
#= PrjSalesCostモデルクラス
#
# Authors:: 青山 ひろ子
# Created:: 2012/10/5
#
class PrjSalesCost < ActiveRecord::Base
  # アクセサ定義
  attr_accessible :item_name, :price, :project_id, :tax_division_id
  
  # アソシエーション
  belongs_to :project
  belongs_to :tax_division
  
  # バリデーション設定
  validates(:item_name, :presence => true, :length => {:maximum => 40})
  validates(:tax_division_id, :presence => true)
  validates(:price, :presence => true, :numericality =>
      {:greater_than_or_equal_to => 0, :less_than_or_equal_to => 9999999999})
end
