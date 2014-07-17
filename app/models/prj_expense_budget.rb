# encoding: utf-8

#
#= PrjExpenseBudgetモデルクラス
#
# Created:: 2012/10/5
#
class PrjExpenseBudget < ActiveRecord::Base
  # アクセサ定義
  attr_accessible :project_id, :expense_item_cd, :expense_budget
  
  # アソシエーション
  belongs_to :project
  
  # バリデーション設定（子モデルの場合、エラーメッセージは全て「…は不正な値です。」）  
  validates(:expense_budget, :presence => true, :numericality =>
      {:greater_than_or_equal_to => 0, :less_than_or_equal_to => 9999999999})
  
  # 以下、パブリックメソッド
public

  ##
  # プロジェクトの経費予算を取得する
  #
  # project_id::
  #   対象プロジェクトのプロジェクトID
  # expense_item_cd::
  #   対象経費科目コード
  # 戻り値::
  #   プロジェクトの経費予算を返す
  #
  def self.expense_budget(project_id, expense_item_cd)
    expense_budget = self
        .where('project_id = ? AND expense_item_cd = ?', project_id, expense_item_cd)
        .first
    return 0 if expense_budget.blank?
    return expense_budget.expense_budget
  end
end
