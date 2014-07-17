# encoding: utf-8

#
#= PrjReflectionモデルクラス
#
# Created:: 2012/10/5
#
class PrjReflection < ActiveRecord::Base
  # アクセサ定義
  attr_accessible :delay_days, :development_cost, :direct_labor_cost, :exceeded_expense, :exceeded_man_days, :expense, :expense_budget, :expense_rank, :failed_things, :finished_date, :gross_profit, :improvable_things, :indirect_labor_cost, :learned_skills, :man_day, :man_days_rank, :next_actions, :order_volume, :overall_rank, :planned_finish_date, :planned_man_days, :profit_ratio, :project_id, :reasons_for_dalay, :reasons_for_over_budget, :reasons_for_overtime, :reasons_for_termination, :sales_cost, :schedule_rank, :self_evaluation, :subcontract_cost, :successful_things
  
  # アソシエーション
  belongs_to :project
  
  # バリデーション設定
  validates(:finished_date, :presence => true)
  validate :is_valid

  # 以下、プライベートメソッド
  private
  ##
  # バリデーションメソッド
  # 
  def is_valid
    # プロジェクト
    if project_id.present? && Project.where(:id => project_id).exists?
      # 削除チェック
      if project.deleted?
        errors.add(:project_id, I18n.t('errors.messages.deleted'))
      end
      # プロジェクト終了日
      if self.finished_date.present? && project.started_date.present?
        started_date = I18n.l(project.started_date)
        errors.add(:finished_date, "にプロジェクト開始日(#{started_date})以後の日付を指定してください。") if project.started_date > self.finished_date
      end
    else
      errors.add(:project_id, I18n.t('errors.messages.not_exist'))
    end
  end

  # 以下、パブリックメソッド
  public
  
  ##
  # プロジェクトの計画値と実績値を収集し、
  # 振り返り情報の対応する計画値、実績値を更新する。
  # また、各評価ランクを計算し、更新する。
  # 事前にプロジェクトの集計処理を実行しておく必要がある。
  # 
  # project::
  #   対象プロジェクトのARインスタンス
  #
  def update_project_results(project)
    # 計画値と実績値を更新する
    if project.present?
      self.order_volume        = project.order_volume
      self.sales_cost          = project.sales_cost
      self.man_day             = project.result_man_days
      self.direct_labor_cost   = project.direct_labor_cost_result
      self.subcontract_cost    = project.subcontract_cost_result
      self.expense             = project.direct_expense_result
      self.indirect_labor_cost = project.indirect_labor_cost_result
      self.development_cost    = project.development_cost_result
      self.gross_profit        = project.gross_profit_result
      self.profit_ratio        = project.profit_ratio_result
      self.finished_date       = project.finished_date
      self.planned_finish_date = project.finish_date
      self.planned_man_days    = project.planned_man_days
      self.exceeded_man_days   = self.man_day - self.planned_man_days
      self.expense_budget      = project.direct_expense_budget
      self.exceeded_expense    = self.expense - self.expense_budget
      # 以下はローカル変数
      profit_budget = project.gross_profit_budget
    end
    
    # 総合評価ランクを更新する
    if self.gross_profit < 0
      self.overall_rank = 4
    else
      if self.gross_profit >= profit_budget * 1.1
        self.overall_rank = 1
      elsif self.gross_profit >= profit_budget * 0.9
        self.overall_rank = 2
      else
        self.overall_rank = 3
      end
    end
    
    # 遅れ日数、スケジュール評価ランクを更新する
    update_schedule_rank
    
    # 工数評価ランクを更新する
    if self.exceeded_man_days <= self.planned_man_days * (-0.1)
      self.man_days_rank = 1
    elsif self.exceeded_man_days <= self.planned_man_days * 0.1
      self.man_days_rank = 2
    elsif self.exceeded_man_days <= self.planned_man_days * 0.5
      self.man_days_rank = 3
    else
      self.man_days_rank = 4
    end
    
    # 経費評価ランクを更新する
    if self.exceeded_expense <= self.expense_budget * (-0.1)
      self.expense_rank = 1
    elsif self.exceeded_expense <= self.expense_budget * 0.1
      self.expense_rank = 2
    elsif self.exceeded_expense <= self.expense_budget * 0.5
      self.expense_rank = 3
    else
      self.expense_rank = 4
    end
  end
  
  ##
  # 振り返り情報の遅れ日数、および、スケジュール評価ランクを更新する。
  # 
  def update_schedule_rank
    # 遅れ日数を更新する
    delay = self.finished_date - self.planned_finish_date
    self.delay_days = delay.to_i
    
    # スケジュール評価ランクを更新する
    if self.delay_days <= -7
      self.schedule_rank = 1
    elsif self.delay_days <= 0
      self.schedule_rank = 2
    elsif self.delay_days <= 7
      self.schedule_rank = 3
    else
      self.schedule_rank = 4
    end
  end
end
