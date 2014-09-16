# encoding: utf-8

#
#= ExpenseTypeモデルクラス
#
# Authors:: 青山 ひろ子
# Created:: 2012/10/5
#
class ExpenseType < ActiveRecord::Base
  # アクセサ定義
  attr_accessible :expense_item_cd, :name, :tax_division_id, :view_order
  
  # アソシエーション
  belongs_to :tax_division
  has_many :expenses
  
  # バリデーション設定
  validates(:view_order, :presence => true, :numericality =>
      {:only_integer => true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 999999999})
  validates(:expense_item_cd, :presence => true)
  validates(:name, :presence => true, :length => {:maximum => 20})
  validates(:tax_division_id, :presence => true)
  validate :is_valid

  # 以下、プライベートメソッド
private
  ##
  # バリデーションメソッド
  # 
  def is_valid
    # 税区分
    if tax_division_id.present?
      unless TaxDivision.where(:id => tax_division_id).exists?
        errors.add(:tax_division_id, I18n.t('errors.messages.not_exist'))
      end
    end
  end
  
  # 以下、パブリックメソッド
public
  
  ##
  # 経費種類IDに対応する経費種類名を取得する
  #
  # id::
  #   対象経費種類ID
  # 戻り値::
  #   経費種類名を返す
  #
  def self.get_name(id)
    begin
      expense_type = self.find(id)
      return expense_type.name
    rescue
      return ''
    end
  end
  
  ##
  # 経費種類リストを取得する
  # 
  # 戻り値::
  #   経費種類リスト
  #
  def self.expense_types_list()
    return ExpenseType.select('name, id').order('view_order').collect{|s| [s.name, s.id]}
  end

  ##
  # 経費情報で選択されている経費種類かどうか？
  # 
  # expense_type_id::
  #   対象経費種類ID
  # 戻り値::
  #   経費種類が経費情報で選択されている場合、trueを返す
  #
  def self.expense_expense_type?(expense_type_id)
    return Expense.where(:expense_type_id => expense_type_id).exists?
  end
end
