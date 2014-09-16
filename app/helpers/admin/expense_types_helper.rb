# encoding: utf-8

#
#= Admin::ExpenseTypesヘルパークラス
#
# Authors:: 青山 ひろ子
# Created:: 2012/10/5
#
module Admin::ExpenseTypesHelper
  ##
  # 経費科目リストを取得する
  # 
  # 戻り値::
  #   経費科目リスト
  #
  def expense_items_list
    list = []
    EXPENSE_ITEM_CODE.each_value { |cd|
      list << [expense_item_indication(cd), cd]
    }
    return list
  end
  
  ##
  # 経費科目の表示文字列を取得する
  # 
  # 戻り値::
  #   経費科目リスト
  #
  def expense_item_indication(expense_item_cd)
    scope = 'expense_item'
    case expense_item_cd
      when EXPENSE_ITEM_CODE[:transportation_and_stay]
        return t('transportation_and_stay', :scope => scope, :default=>'Transportation and Stay')
      when EXPENSE_ITEM_CODE[:subcontract]
        return t('subcontract', :scope => scope, :default=>'Subcontract')
      when EXPENSE_ITEM_CODE[:other]
        return t('other', :scope => scope, :default=>'Other')
    end
  end
end
