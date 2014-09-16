# encoding: utf-8

#
#= TaxDivisionモデルクラス
#
# Authors:: 青山 ひろ子
# Created:: 2012/10/5
#
class TaxDivision < ActiveRecord::Base
  # アクセサ定義
  attr_accessible :name, :tax_rate, :view_order, :tax_type_cd
  
  # アソシエーション
  has_many :expenses
  has_many :expense_types
  has_many :prj_sales_costs

  # バリデーション設定
  validates(:view_order, :presence => true, :numericality =>
      {:only_integer => true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 999999999})
  validates(:name, :presence => true, :length => {:maximum => 20})
  validates(:tax_type_cd, :presence => true)
  validates(:tax_rate, :presence => true, :numericality =>
      {:greater_than_or_equal_to => 0.00, :less_than_or_equal_to => 100.00})
  
  # 以下、パブリックメソッド
public
  
  ##
  # 税区分リストを取得する
  # 
  # 戻り値::
  #   税区分リスト
  #
  def self.tax_divisions_list()
    return TaxDivision.select('name, id').order('view_order').collect{|s| [s.name, s.id]}
  end
  
  ##
  # 税種別ごとの税区分データを取得する
  # 
  # tax_type_cd::
  #   取得対象税種別 
  # 戻り値::
  #   税区分データ
  #
  def self.tax_divisions_by_tax_type_cd(tax_type_cd)
    return tax_divisions = TaxDivision.where('tax_type_cd = ?', tax_type_cd)
  end
  
  ##
  # 税抜き価格を取得する
  #
  # price::
  #   税込価格
  # tax_division_id::
  #   税区分ID
  # 戻り値::
  #   税抜き価格
  #
  def self.without_tax_price(price, tax_division_id)
    without_tax_price = price
    
    tax_division = TaxDivision.where(:id => tax_division_id).first
    if tax_division.present?
      if tax_division.tax_type_cd == TAX_TYPE_CODE[:tax_inclusive]
        # 内税の場合、消費税を控除する
        tax = (price * tax_division.tax_rate / 100.0).round
        without_tax_price = price - tax
      end
    end
    return without_tax_price
  end
  
  ##
  # 税種別が外税の税区分リストを取得し、最初の項目の税区分IDを取得する
  # 
  # 戻り値::
  #   税区分ID
  #
  def self.tax_exclusive_first_id
    tax_division_id = nil
    tax_divisions =
        TaxDivision.tax_divisions_by_tax_type_cd(TAX_TYPE_CODE[:tax_exclusive])
    if tax_divisions.present?
      tax_division_id = tax_divisions.first.id
    end
    return tax_division_id
  end
  
  ##
  # プロジェクト情報で選択されている税区分かどうか？
  # 
  # tax_division_id::
  #   対象税区分ID
  # 戻り値::
  #   税区分がプロジェクトで選択されている場合、trueを返す
  #
  def self.project_tax_division_id?(tax_division_id)
    return PrjSalesCost.where(:tax_division_id => tax_division_id).exists?
  end
  
  ##
  # 経費種類情報で選択されている税区分かどうか？
  # 
  # tax_division_id::
  #   対象税区分ID
  # 戻り値::
  #   税区分が経費種類情報で選択されている場合、trueを返す
  #
  def self.expense_type_tax_division_id?(tax_division_id)
    return ExpenseType.where(:tax_division_id => tax_division_id).exists?
  end
  
  ##
  # 経費情報で選択されている税区分かどうか？
  # 
  # tax_division_id::
  #   対象税区分ID
  # 戻り値::
  #   税区分が経費情報で選択されている場合、trueを返す
  #
  def self.expense_tax_division_id?(tax_division_id)
    return Expense.where(:tax_division_id => tax_division_id).exists?
  end
end
