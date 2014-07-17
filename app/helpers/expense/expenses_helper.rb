# encoding: utf-8

#
#= Expense::Expensesヘルパークラス
#
# Created:: 2012/10/5
#
module Expense::ExpensesHelper
  ##
  # 検索用期間年リストを取得する
  # 
  # 戻り値::
  #   期間年リスト
  #
  def expense_term_year_list
    today_year = Date.today.year
    expense_minimum = Expense.minimum('adjusted_date')
    expense_maximum = Expense.maximum('adjusted_date')
    
    if expense_minimum.blank? || expense_maximum.blank?
      return numeric_list(today_year, today_year)
    end
    
    return numeric_list(expense_minimum.year, expense_maximum.year)
  end
end
