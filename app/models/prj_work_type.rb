# encoding: utf-8

#
#= PrjWorkTypeモデルクラス
#
# Authors:: 青山 ひろ子
# Created:: 2012/10/5
#
class PrjWorkType < ActiveRecord::Base
  # アクセサ定義
  attr_accessible :planned_man_days, :presented_man_days, :progress_rate, :project_id, :work_type_id, :work_type_check
  attr_accessor :work_type_check
  
  # アソシエーション
  belongs_to :project
  belongs_to :work_type
  
  # バリデーション設定
  validates(:planned_man_days, :presence => true, :numericality =>
      {:greater_than_or_equal_to => 0, :less_than_or_equal_to => 9999.99})
  validates(:presented_man_days, :presence => true, :numericality =>
      {:greater_than_or_equal_to => 0, :less_than_or_equal_to => 9999.99})
  validates(:progress_rate, :presence => true, :numericality =>
      {:greater_than_or_equal_to => 0, :less_than_or_equal_to => 100.00})

  # 以下、パブリックメソッド
public
  
  ##
  # 販売原価の税抜き合計値を取得する
  #
  # sales_costs::
  #   販売原価データ
  # 戻り値::
  #   税抜き合計値
  #
  def self.totalize_tax_excluded_sales_cost(sales_costs)
    total = BigDecimal('0', PRICE_MAX_DIGITS)
    sales_costs.each do |sales_cost|
      # 内税の場合、消費税を控除する
      without_tax_price =
          TaxDivision.without_tax_price(sales_cost.price, sales_cost.tax_division_id)
      total += without_tax_price
    end
    
    return total
  end
end
