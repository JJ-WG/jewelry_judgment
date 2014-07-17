# encoding: utf-8

#
#= Expenseモデルクラス
#
# Created:: 2012/10/5
#
class Expense < ActiveRecord::Base
  # アクセサ定義
  attr_accessible :adjusted_date, :amount_paid, :expense_type_id, :item_name, :project_id, :tax_division_id, :user_id
  
  # アソシエーション
  belongs_to :user
  belongs_to :project
  belongs_to :expense_type
  belongs_to :tax_division

  # バリデーション設定
  validates(:user_id, :presence => true)
  validates(:project_id, :presence => true)
  validates(:expense_type_id, :presence => true)
  validates(:tax_division_id, :presence => true)
  validates(:adjusted_date, :presence => true)
  validates(:item_name, :presence => true, :length => {:maximum => 40})
  validates(:amount_paid, :presence => true, :numericality =>
      {:only_integer => true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 9999999999})
  validate :is_valid

  # スコープ定義
  scope :list_order, order('expenses.adjusted_date DESC, expenses.id DESC')
  
  # 以下、プライベートメソッド
  private
  ##
  # バリデーションメソッド
  # 
  def is_valid
    # 精算者
    if user_id.present?
      if User.where(:id => user_id).exists?
        if new_record? && user.deleted?
          errors.add(:user_id, I18n.t('errors.messages.deleted'))
        end
      else
        errors.add(:user_id, I18n.t('errors.messages.not_exist'))
      end
    end
    # プロジェクト
    if project_id.present?
      if Project.where(:id => project_id).exists?
        if new_record? && project.deleted?
          errors.add(:project_id, I18n.t('errors.messages.deleted'))
        end
        if project_finished?
          errors.add(:project_id, I18n.t('errors.messages.finished'))
        end
      else
        errors.add(:project_id, I18n.t('errors.messages.not_exist'))
      end
    end
    # 経費種類
    if expense_type_id.present?
      unless ExpenseType.where(:id => expense_type_id).exists?
        errors.add(:expense_type_id, I18n.t('errors.messages.not_exist'))
      end
    end
    # 経費種類
    if tax_division_id.present?
      unless TaxDivision.where(:id => tax_division_id).exists?
        errors.add(:tax_division_id, I18n.t('errors.messages.not_exist'))
      end
    end
  end

  # 以下、パブリックメソッド
  public
  ##
  # 経費のデータを識別する文字列を返す
  #
  def to_str
    if adjusted_date.present?
      return I18n.l(adjusted_date) + ' ' + item_name
    else
      return item_name
    end
  end

  ##
  # プロジェクトが完了しているか
  #
  # 戻り値::
  #   経費に関連するプロジェクトが完了している場合、trueを返す。
  # 
  def project_finished?
    return (project.present? && project.finished?)
  end
end
