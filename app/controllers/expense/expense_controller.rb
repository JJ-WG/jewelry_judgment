# encoding: utf-8

#
#= Expenseコントローラクラス
#
# Created:: 2012/10/4
#
class Expense::ExpenseController < ApplicationController
  # フィルター設定
  before_filter :require_user
end
