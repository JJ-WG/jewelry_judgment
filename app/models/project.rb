# encoding: utf-8

#
#= Projectモデルクラス
#
# Authors:: 青山 ひろ子
# Created:: 2012/10/5
#
class Project < ActiveRecord::Base
  # アクセサ定義
  attr_accessible :attention, :customer_id, :deal_id, :deleted, :finish_date,
      :finished_date, :leader_id, :name, :order_type_cd, :remarks, :start_date,
      :started_date, :status_cd, :manager_id, :order_volume, :locked, :project_code,
      :development_language_ids, :operating_system_ids, :database_ids,
      :prj_members_attributes, :prj_work_types_attributes, :prj_expense_budgets_attributes, 
      :prj_sales_costs_attributes, :prj_related_projects_attributes
  attr_accessor :section_id, :prj_member_user_id, :prj_member_size, :prj_member_total,
      :prj_work_type_size,
      :planned_man_days_total, :presented_man_days_total, :progress_rate_total,
      :related_project_status_cd, :related_project_id,
      :sales_cost_price, :sales_cost_item_name, :sales_cost_tax_division_cd


  # 社内業務プロジェクト情報
  INTERNAL_BUSSINESS_PRJ = { id: 0,
                             name: '社内業務',
                             project_code: 'PRJ0' }

  # アソシエーション
  belongs_to :customer
  belongs_to :deal
  has_many :results
  has_many :csv_results
  has_many :csv_schedules
  has_many :expenses
  has_many :notices
  has_many :schedules
  has_many :prj_members
  has_many :users, :through => :prj_members
  has_many :prj_work_types
  has_many :work_types, :through => :prj_work_types
  has_many :prj_dev_languages
  has_many :development_languages, :through => :prj_dev_languages
  has_many :prj_operating_systems
  has_many :operating_systems, :through => :prj_operating_systems
  has_many :prj_databases
  has_many :databases, :through => :prj_databases
  has_many :prj_related_projects
  has_many :prj_sales_costs
  has_many :prj_expense_budgets
  has_one  :prj_reflection
  accepts_nested_attributes_for :prj_members
  accepts_nested_attributes_for :prj_work_types
  accepts_nested_attributes_for :prj_expense_budgets
  accepts_nested_attributes_for :prj_sales_costs
  accepts_nested_attributes_for :prj_related_projects
  
  # 属性定義
  attr_reader :planned_man_days, :result_man_days
  attr_reader :presented_man_days
  attr_reader :direct_labor_cost_budget, :direct_labor_cost_result
  attr_reader :direct_expense_budget, :direct_expense_result
  attr_reader :subcontract_cost_budget, :subcontract_cost_result
  attr_reader :sales_cost
  attr_reader :indirect_labor_cost_budget, :indirect_labor_cost_result
  attr_reader :development_cost_budget, :development_cost_result
  attr_reader :gross_profit_budget, :gross_profit_result
  attr_reader :profit_ratio_budget, :profit_ratio_result
  
  # バリデーション設定
  validates(:project_code, :presence => true)
  validates(:name, :presence => true, :length => {:maximum => 40})
  validates(:customer_id, :presence => true)
  validates(:order_type_cd, :presence => true)
  validates(:order_volume, :presence => true, :numericality =>
      {:only_integer => true, :greater_than_or_equal_to => 0,
      :less_than_or_equal_to => 9999999999})
  validates(:manager_id, :presence => true)
  validates(:leader_id, :presence => true)
  validates(:start_date, :presence => true)
  validates(:finish_date, :presence => true)
  validate :is_valid
  
  # スコープ定義
  scope :deleted, where(:deleted => true)
  scope :alive, where(:deleted => false)
  scope :finished, where(:status_cd => STATUS_CODE[:finished])
  scope :in_preparation, where(:status_cd => STATUS_CODE[:preparation])
  scope :in_progress, where(:status_cd => STATUS_CODE[:progress])
  scope :uncompleted, where(:status_cd => [STATUS_CODE[:preparation], STATUS_CODE[:progress]])
  scope :started, where(:status_cd => [STATUS_CODE[:progress], STATUS_CODE[:finished]])
  scope :list_order, order('finish_date DESC, projects.id DESC')
  scope :list_order_from_name, order('projects.name ASC, projects.id DESC')
  
  # 以下、プロテクテッドメソッド
protected
  
  ##
  # バリデーションメソッド
  # 
  def is_valid
    # プロジェクトコード
    if self.project_code.present?
      if !(/^[0-9A-Za-z]+$/ =~ self.project_code)
        errors.add(:project_code, 'は半角英数字を入力してください。')
      end
      
      if Project.exist_project_code(self.id, self.project_code)
        errors.add(:project_code, 'が他プロジェクトで使用済みです。')
      end
    end
    # 商談管理案件
    if self.deal_id.present?
      unless Deal.where(:id => self.deal_id).exists?
        errors.add(:deal_id, I18n.t('errors.messages.not_exist'))
      end
      
      if Project.exist_deal_id(self.id, self.deal_id)
        errors.add(:deal_id, 'が他プロジェクトで選択済みです。')
      end
    end
    # 顧客
    if self.customer_id.present?
      unless Customer.where(:id => self.customer_id).exists?
        errors.add(:customer_id, I18n.t('errors.messages.not_exist'))
      end
    end
    # 受注額
    if self.order_volume.present?
      unless self.order_volume.is_a?(Integer)
        errors.add(:order_volume, I18n.t('errors.messages.not_an_integer'))
      end
    end
    # プロジェクトマネージャー
    if self.manager_id.present?
      user = User.where('id = ?', self.manager_id).first
      if user.present?
        if new_record? && user.deleted?
          errors.add(:manager_id, I18n.t('errors.messages.deleted'))
        end
      else
        errors.add(:manager_id, I18n.t('errors.messages.not_exist'))
      end
    end
    # プロジェクトリーダー
    if self.leader_id.present?
      user = User.where(:id => self.leader_id).first
      if user.present?
        if new_record? && user.deleted?
          errors.add(:leader_id, I18n.t('errors.messages.deleted'))
        end
      else
        errors.add(:leader_id, I18n.t('errors.messages.not_exist'))
      end
    end
    # 期間
    if self.start_date.present? && self.finish_date.present?
      errors.add(:start_date, 'を正しく指定してください。') if self.start_date > self.finish_date
      errors.add(:finish_date, 'を正しく指定してください。') if self.start_date > self.finish_date
    end
  end
  
  # 以下、パブリックメソッド
public
  ##
  # プロジェクトの状態が[完了]かどうか
  # 
  # 戻り値::
  #   プロジェクトの状態が[完了]の場合、trueを返す
  #
  def finished?
    return status_cd == STATUS_CODE[:finished]
  end
  
  ##
  # プロジェクトの状態が[準備中]かどうか
  # 
  # 戻り値::
  #   プロジェクトの状態が[準備中]の場合、trueを返す
  #
  def in_preparation?
    return status_cd == STATUS_CODE[:preparation]
  end
  
  ##
  # プロジェクトの状態が[進行中]かどうか
  # 
  # 戻り値::
  #   プロジェクトの状態が[進行中]の場合、trueを返す
  #
  def in_progress?
    return status_cd == STATUS_CODE[:progress]
  end
  
  ##
  # プロジェクトの状態が[準備中]または[進行中]かどうか
  # 
  # 戻り値::
  #   プロジェクトの状態が[準備中]または[進行中]の場合、trueを返す
  #
  def uncompleted?
    return (in_preparation? || in_progress?)
  end
  
  ##
  # プロジェクトリストを取得する
  # リストには論理削除されたプロジェクトを含まない
  # 
  # option::
  #    ハッシュにより下記のオプションを指定可能
  #    - :include_deleted_project
  #       リストに論理削除されたプロジェクトを含めるかどうか(true/false)
  #    - :include_finished_project
  #       リストに完了プロジェクトを含めるかどうか(true/false)
  #    - :status_cd
  #       状態コード
  # 戻り値::
  #   プロジェクトリスト
  #
  def self.projects_list(option = {})
    return Project.select('name, id')
                  .where(option[:include_deleted_project] ? nil
                    : {:deleted => false})
                  .where(option[:include_finished_project] ? nil
                    : {:status_cd => [STATUS_CODE[:preparation],
                                      STATUS_CODE[:progress]]})
                  .where(option[:status_cd].present? ?
                      {:status_cd => option[:status_cd]} : nil)
                  .list_order_from_name
                  .collect{|project| [project.name, project.id]}
  end
  
  ##
  # 指定されたプロジェクトがプロジェクトに無い場合、
  # プロジェクトリストの最後にプロジェクトを追加する
  # 論理削除されたプロジェクトもリストに追加する
  # 
  # list::
  #   プロジェクトリスト
  # user_id::
  #   リストに追加するプロジェクトのプロジェクトID 
  # 戻り値::
  #   プロジェクトリスト
  #
  def self.add_to_list(list, project_id)
    if list.nil?
      list = []
    else
      list.each do |item|
        if item.last == project_id
          return list
        end
      end
    end
    return list << [self.get_name(project_id), project_id]
  end
  
  ##
  # プロジェクトIDに対応するプロジェクトの名称を取得する
  #
  # id::
  #   対象プロジェクトのプロジェクトID
  # 戻り値::
  #   プロジェクトの名称を返す
  #
  def self.get_name(id)
    begin
      project = Project.find(id)
      return project.name
    rescue
      return ''
    end
  end
  
  ##
  # プロジェクトコードが他データで使用済みか
  # 
  # 戻り値::
  #   true:使用済み / false:未使用
  #
  def self.exist_project_code(id, code)
    if id.present?
      count = Project.count(:project_code,
          :conditions => ['id != ? AND project_code = ?', id, code])
    else
      count = Project.count(:project_code,
          :conditions => ['project_code = ?', code])
    end
    return (count > 0)? true : false
  end
  
  ##
  # 商談管理案件が他データで選択済みか
  # 
  # 戻り値::
  #   true:選択済み / false:未選択
  #
  def self.exist_deal_id(id, deal_id)
    if deal_id.present?
      if id.present?
        count = Project.count(:deal_id,
            :conditions => ['id != ? AND deal_id = ?', id, deal_id])
      else
        count = Project.count(:deal_id,
            :conditions => ['deal_id = ?', deal_id])
      end
      return (count > 0)? true : false
    end
    return false
  end
  
  ##
  # プロジェクトの全ての予算値と実績値を集計する
  # 下記の属性値を更新する
  # [planned_man_days] 予定工数
  # [result_man_days] 実績工数
  # [direct_labor_cost_budget] 直接労務費予算
  # [direct_labor_cost_result] 直接労務費実績
  # [direct_expense_budget] 直接経費予算
  # [direct_expense_result] 直接経費実績
  # [subcontract_cost_budget] 外注費予算
  # [subcontract_cost_result] 外注費実績
  # [sales_cost] プロジェクトの販売原価
  # [indirect_labor_cost_budget] 間接労務費予算
  # [indirect_labor_cost_result] 間接労務費実績
  # [development_cost_budget] 開発原価予算
  # [development_cost_result] 開発原価実績
  # [gross_profit_budget] 粗利予算
  # [gross_profit_result] 粗利実績
  # [profit_ratio_budget] 粗利率予算
  # [profit_ratio_result] 粗利率実績
  #
  def totalize_all
    # 各予算値と実績値を集計
    totalize_planned_man_days
    totalize_result_man_days
    totalize_direct_labor_cost
    totalize_direct_expense_budget
    totalize_direct_expense_result
    totalize_subcontract_cost_budget
    totalize_subcontract_cost_result
    totalize_sales_cost
    totalize_indirect_labor_cost
    # 開発原価の予算値を計算
    @development_cost_budget =
      @direct_labor_cost_budget +
      @subcontract_cost_budget +
      @direct_expense_budget +
      @indirect_labor_cost_budget
    # 開発原価の実績値を計算
    @development_cost_result =
      @direct_labor_cost_result +
      @subcontract_cost_result +
      @direct_expense_result +
      @indirect_labor_cost_result
    # 粗利予算を計算
    @gross_profit_budget =
      order_volume - @sales_cost - @development_cost_budget
    # 粗利実績を計算
    @gross_profit_result =
      order_volume - @sales_cost - @development_cost_result
    # 粗利率の予算値と実績値を計算
    if order_volume == 0
      @profit_ratio_budget = 0.0
      @profit_ratio_result = 0.0
    else
      @profit_ratio_budget = 
        (@gross_profit_budget / order_volume * 100.0).round(2)
      @profit_ratio_result = 
        (@gross_profit_result / order_volume * 100.0).round(2)
    end
    @totalized = true
  end
  
  ##
  # プロジェクトの全ての予算値と実績値の集計が完了しているか
  #
  # 戻り値::
  #   true:集計済み / nil:未集計
  #
  def totalized?
    return @totalized
  end
  
  ##
  # プロジェクトの予定工数を集計する
  # 下記の属性値を更新する
  # [planned_man_days] 予定工数
  #
  def totalize_planned_man_days
    @planned_man_days = PrjWorkType.where(:project_id => id).sum(:planned_man_days)
  end
  
  ##
  # プロジェクトの客先提示工数を集計する
  # 下記の属性値を更新する
  # [presented_man_days] 客先提示工数
  #
  def totalize_presented_man_days
    @presented_man_days = PrjWorkType.where(:project_id => id).sum(:presented_man_days)
  end
  
  ##
  # プロジェクトの実績工数を集計する
  # 下記の属性値を更新する
  # [result_man_days] 実績工数
  #
  def totalize_result_man_days
    @result_man_days = 0.0
    results = Result.where(:project_id => id)
    results.each do |result|
      @result_man_days += result.work_hours
    end
  end
  
  ##
  # プロジェクトの直接労務費の予算値と実績値を集計する
  # 下記の属性値を更新する
  # [direct_labor_cost_budget] 直接労務費予算
  # [direct_labor_cost_result] 直接労務費実績
  #
  def totalize_direct_labor_cost
    @direct_labor_cost_budget = BigDecimal('0', PRICE_MAX_DIGITS)
    @direct_labor_cost_result = BigDecimal('0', PRICE_MAX_DIGITS)
    members = PrjMember.where(:project_id => id)
    return if members.blank?
    members.each do |member|
      unit_price = member_unit_price(member.user_id)
      man_days = member_man_days(member.user_id)
      @direct_labor_cost_budget = 
        @direct_labor_cost_budget + (unit_price * member.planned_man_days).round
      @direct_labor_cost_result = 
        @direct_labor_cost_result + (unit_price * man_days).round
    end
  end
  
  ##
  # プロジェクトメンバーの工数単価を取得する
  #
  # user_id::
  #   対象メンバーのユーザーID
  # 戻り値::
  #   プロジェクトメンバーの工数単価を返す
  #
  def member_unit_price(user_id)
    # 工数単価マスタから対象ユーザの工数単価を取得する
    return UnitPrice.unit_price(user_id, base_date)
  end
  
  ##
  # プロジェクトメンバーの実績工数を取得する
  #
  # user_id::
  #   対象メンバーのユーザーID
  # 戻り値::
  #   プロジェクトメンバーの実績工数を返す
  #
  def member_man_days(user_id)
    member_work_hours = 0.0
    results = Result.where(:project_id => id, :user_id => user_id)
    results.each do |result|
      member_work_hours += result.work_hours
    end
    return member_work_hours
  end
  
  ##
  # プロジェクトの直接経費予算を集計する
  # 下記の属性値を更新する
  # [direct_expense_budget] 直接経費予算（経費科目が交通宿泊費、その他の経費）
  #
  def totalize_direct_expense_budget
    @direct_expense_budget =
      expense_budget([EXPENSE_ITEM_CODE[:transportation_and_stay],
                      EXPENSE_ITEM_CODE[:other]])
  end
  
  ##
  # プロジェクトの直接経費実績を集計する
  # 下記の属性値を更新する
  # [direct_expense_result] 直接経費実績（経費科目が交通宿泊費、その他の経費）
  #
  def totalize_direct_expense_result
    @direct_expense_result =
      expense_result([EXPENSE_ITEM_CODE[:transportation_and_stay],
                      EXPENSE_ITEM_CODE[:other]])
  end
  
  ##
  # プロジェクトの外注費予算を集計する
  # 下記の属性値を更新する
  # [subcontract_cost_budget] 外注費予算
  #
  def totalize_subcontract_cost_budget
    @subcontract_cost_budget = expense_budget(EXPENSE_ITEM_CODE[:subcontract])
  end
  
  ##
  # プロジェクトの外注費実績を集計する
  # 下記の属性値を更新する
  # [subcontract_cost_result] 外注費実績
  #
  def totalize_subcontract_cost_result
    @subcontract_cost_result = expense_result(EXPENSE_ITEM_CODE[:subcontract])
  end
  
  ##
  # プロジェクトの経費予算を集計する
  #
  # expense_item_cd::
  #   集計対象の経費科目コード、または、経費科目コードの配列
  # 戻り値::
  #   プロジェクトの指定された経費科目の経費予算を返す
  #
  def expense_budget(expense_item_cd)
    return PrjExpenseBudget.where(:project_id => id,
                                  :expense_item_cd => expense_item_cd)
                           .sum(:expense_budget)
  end
  
  ##
  # プロジェクトの経費実績を集計する
  #
  # expense_item_cd::
  #   集計対象の経費科目コード、または、経費科目コードの配列
  # 戻り値::
  #   プロジェクトの指定された経費科目の経費実績を返す
  #
  def expense_result(expense_item_cd)
    total_expense = BigDecimal('0', PRICE_MAX_DIGITS)
    # 経費種類マスタから対象経費科目の経費種類を抽出
    expense_types = ExpenseType.where(:expense_item_cd => expense_item_cd)
                               .select(:id)
    return total_expense if expense_types.blank?
    expense_type_ids = expense_types.collect{|expense_type| expense_type.id}
    # 対象プロジェクトの対象経費科目の経費を抽出
    expenses = Expense.where(:project_id => id,
                             :expense_type_id => expense_type_ids)
                      .includes(:tax_division)
    return total_expense if expenses.blank?
    # 税抜きの経費金額を集計する
    expenses.each do |expense|
      # 内税の場合、消費税を控除する
      without_tax_price =
          TaxDivision.without_tax_price(expense.amount_paid, expense.tax_division_id)
      total_expense += without_tax_price
    end
    return total_expense
  end
  
  ##
  # プロジェクトの販売原価を集計する
  # 下記の属性値を更新する
  # [sales_cost] プロジェクトの販売原価
  #
  def totalize_sales_cost
    @sales_cost = BigDecimal('0', PRICE_MAX_DIGITS)
    # 対象プロジェクトの販売原価を抽出
    sales_costs = PrjSalesCost.where(:project_id => id)
                              .includes(:tax_division)
    return if sales_costs.blank?
    # 税抜きの販売原価を集計する
    @sales_cost = PrjWorkType.totalize_tax_excluded_sales_cost(sales_costs)
  end
  
  ##
  # プロジェクトの間接労務費の予算値と実績値を集計する
  # 下記の属性値を更新する
  # [indirect_labor_cost_budget] 間接労務費予算
  # [indirect_labor_cost_result] 間接労務費実績
  #
  # 注意) 本メソッドを実行する前に、下記の各メソッドを実行しておく必要があります
  # - totalize_direct_labor_cost
  # - totalize_subcontract_cost_budget
  # - totalize_subcontract_cost_result
  #
  def totalize_indirect_labor_cost
    @indirect_labor_cost_budget = BigDecimal('0', PRICE_MAX_DIGITS)
    @indirect_labor_cost_result = BigDecimal('0', PRICE_MAX_DIGITS)
    # 間接労務費マスタから基準日時点での間接労務費計算方式コードを取得する
    indirect_cost = IndirectCost.where('start_date <= ?', base_date)
                                .order(:start_date)
                                .last
    # 間接労務費計算方式コードに対応する計算方法で間接労務費を計算する
    return if indirect_cost.blank?
    case indirect_cost.indirect_cost_method_cd
      when INDIRECT_COST_METHOD_CODE[:method1]
        # 間接労務費を0とする
        return
      when INDIRECT_COST_METHOD_CODE[:method2]
        # 受注額に間接労務費率を掛ける
        ratio = indirect_cost.ratio(order_type_cd)
        @indirect_labor_cost_budget = (order_volume * ratio / 100.0).round
        @indirect_labor_cost_result = @indirect_labor_cost_budget
      when INDIRECT_COST_METHOD_CODE[:method3]
        # 直接労務費、外注費に間接労務費率を掛ける
        employee_ratio =
          indirect_cost.ratio(self.order_type_cd,
                              INDIRECT_COST_SUBJECT_CODE[:employee])
        cooperative_ratio =
          indirect_cost.ratio(self.order_type_cd,
                              INDIRECT_COST_SUBJECT_CODE[:cooperative])
        @indirect_labor_cost_budget =
          (@direct_labor_cost_budget * employee_ratio / 100.0 +
           @subcontract_cost_budget * cooperative_ratio / 100.0).round
        @indirect_labor_cost_result =
          (@direct_labor_cost_result * employee_ratio / 100.0 +
           @subcontract_cost_result * cooperative_ratio / 100.0).round
    end
  end
  
  ##
  # プロジェクトの集計値を格納した配列を返す
  #
  # 戻り値::
  #   プロジェクト集計値データ配列
  #
  def totalized_values
    return [id,
      @planned_man_days, @result_man_days,
      @direct_labor_cost_budget, @direct_labor_cost_result,
      @direct_expense_budget, @direct_expense_result,
      @subcontract_cost_budget, @subcontract_cost_result, @sales_cost,
      @indirect_labor_cost_budget, @indirect_labor_cost_result,
      @development_cost_budget, @development_cost_result,
      @gross_profit_budget, @gross_profit_result,
      @profit_ratio_budget, @profit_ratio_result]
  end
  
  ##
  # プロジェクトの集計値を取り込む
  #
  # totalized_values::
  #   プロジェクト集計値データ配列
  #   （totalized_valuesメソッドで取得したもの）
  #
  # 戻り値::
  #   true: 成功
  #   false: データ配列が空、または、プロジェクトIDが異なる
  #
  def restore_totalized_values(totalized_values)
    return false if totalized_values.blank?
    return false unless totalized_values[0] == id
    @planned_man_days           = totalized_values[1]
    @result_man_days            = totalized_values[2]
    @direct_labor_cost_budget   = totalized_values[3]
    @direct_labor_cost_result   = totalized_values[4]
    @direct_expense_budget      = totalized_values[5]
    @direct_expense_result      = totalized_values[6]
    @subcontract_cost_budget    = totalized_values[7]
    @subcontract_cost_result    = totalized_values[8]
    @sales_cost                 = totalized_values[9]
    @indirect_labor_cost_budget = totalized_values[10]
    @indirect_labor_cost_result = totalized_values[11]
    @development_cost_budget    = totalized_values[12]
    @development_cost_result    = totalized_values[13]
    @gross_profit_budget        = totalized_values[14]
    @gross_profit_result        = totalized_values[15]
    @profit_ratio_budget        = totalized_values[16]
    @profit_ratio_result        = totalized_values[17]
    return true
  end
  
  ##
  # プロジェクト全体の進捗率を集計する
  #
  def totalize_progress_rate
    # 社内工数合計
    total_planned_man_days = 0
    prj_work_types.each do |work_type|
      total_planned_man_days += work_type.planned_man_days
    end
    
    total_rate = 0.0
    prj_work_types.each do |work_type|
      unless work_type.progress_rate == 0
        rate =
            (work_type.planned_man_days * work_type.progress_rate / total_planned_man_days).round(2)
        total_rate += rate
      end
    end
    return total_rate
  end
  
  ##
  # プロジェクトの基準日を取得する
  #
  # 戻り値::
  #   プロジェクトの状態が[準備中]以前の場合は当日日付を返す。
  #   それ以外の場合、プロジェクト開始年月日を返す。
  def base_date
    if status_cd < STATUS_CODE[:progress]
      return Date.today
    end
    return started_date
  end
  
  ##
  # プロジェクトリーダーの氏名を取得する
  #
  # 戻り値::
  #   プロジェクトリーダーの氏名を返す
  #
  def leader_name
    return User.get_name(leader_id)
  end
  
  ##
  # プロジェクトマネージャーの氏名を取得する
  #
  # 戻り値::
  #   プロジェクトマネージャーの氏名を返す
  #
  def manager_name
    return User.get_name(manager_id)
  end
  
  ##
  # ユーザーがプロジェクトリーダーかどうか？
  #
  # user::
  #   対象ユーザーのARインスタンス
  # 戻り値::
  #   ユーザーがプロジェクトリーダーの場合、trueを返す
  #
  def project_leader?(user)
    return user && (leader_id == user.id)
  end

  ##
  # ユーザーがプロジェクトマネージャーかどうか？
  #
  # user::
  #   対象ユーザーのARインスタンス
  # 戻り値::
  #   ユーザーがプロジェクトマネージャーの場合、trueを返す
  #
  def project_manager?(user)
    return user && (manager_id == user.id)
  end

  ##
  # ユーザーがプロジェクトのメンバーかどうか？
  #
  # user::
  #   対象ユーザーのARインスタンス
  # 戻り値::
  #   ユーザーがプロジェクトのメンバーの場合、trueを返す
  #
  def project_member?(user)
    return user &&
           PrjMember.where(:project_id => id, :user_id => user.id)
                    .exists?
  end
  
  ##
  # 顧客名を取得する
  #
  # 戻り値::
  #   プロジェクトの顧客名を返す
  #
  def customer_name
    if customer.present?
      return customer.name
    end
    return ''
  end
  
  ##
  # プロジェクトがプロジェクトの関連プロジェクトかどうか？
  #
  # project::
  #   対象プロジェクトのARインスタンス
  # 戻り値::
  #   プロジェクトがプロジェクトの関連プロジェクトの場合、trueを返す
  #
  def related_project?(project)
    return project &&
           PrjRelatedProject.where(:project_id => id, :related_project_id => project.id)
                    .exists?
  end
  
  ##
  # プロジェクトの作業工程別実績工数を取得する
  #
  # work_type_id::
  #   作業工程ID
  # 戻り値::
  #   実績工数（人日）
  #
  def result_man_days_by_work_type(work_type_id)
    results = Result
        .where('project_id = ? AND work_type_id = ?', id, work_type_id)
    
    work_hour_total = 0.0
    results.each do |result|
      work_hour_total += result.work_hours
    end
    return work_hour_total
  end

  ##
  # プロジェクトのプロジェクトメンバー別実績工数を取得する
  #
  # member_id::
  #   プロジェクトメンバーID
  # 戻り値::
  #   実績工数（人日）
  #
  def result_man_days_by_prj_member(member_id)
    results = Result
        .where('project_id = ? AND user_id = ?', id, member_id)
    
    work_hour_total = 0.0
    results.each do |result|
      work_hour_total += result.work_hours
    end
    return work_hour_total
  end
  
  ##
  # プロジェクトのプロジェクトメンバー作業工程別実績工数を取得する
  #
  # member_id::
  #   プロジェクトメンバーID
  # work_type_id::
  #   作業工程ID
  # 戻り値::
  #   実績工数（人日）
  #
  def result_man_days_by_prj_member_and_work_type(member_id, work_type_id)
    results = Result
        .where('project_id = ? AND user_id = ? AND work_type_id = ?',
            id, member_id, work_type_id)
    
    work_hour_total = 0.0
    results.each do |result|
      work_hour_total += result.work_hours
    end
    return work_hour_total
  end

  # CSVヘッダー項目
  CSV_HEADERS = %W!プロジェクトコード プロジェクト 顧客名 マネージャ名 リーダ名 参加人数 参加者 状態
                   開始予定日 終了予定日 受注額 販売原価 開発工数(予) 開発工数(実) 直労費(予) 直労費(実)
                   外注費(予) 外注費(実) 直接経費(予) 直接経費(実) 間労費(予) 間労費(実)
                   開発原価(予) 開発原価(実) 粗利(予) 粗利(実) 粗利率(予) 粗利率(実)!
  # CSV出力日付フォーマット
  CSV_DATE_FORMAT = '%Y-%m-%d'

  # CSV レコード作成
  def to_csv_arr
    [
      project_code,
      name,
      customer_name,
      manager_name,
      leader_name,
      ApplicationController.helpers.get_prj_member_count(id),
      get_membars(id),
      ApplicationController.helpers.status_indication(status_cd),
      start_date.strftime(CSV_DATE_FORMAT),
      finish_date.strftime(CSV_DATE_FORMAT),
      ApplicationController.helpers.unit_thousand_yen(order_volume),
      ApplicationController.helpers.unit_thousand_yen(sales_cost),
      planned_man_days,
      result_man_days.round(2),
      ApplicationController.helpers.unit_thousand_yen(direct_labor_cost_budget),
      ApplicationController.helpers.unit_thousand_yen(direct_labor_cost_result),
      ApplicationController.helpers.unit_thousand_yen(subcontract_cost_budget),
      ApplicationController.helpers.unit_thousand_yen(subcontract_cost_result),
      ApplicationController.helpers.unit_thousand_yen(direct_expense_budget),
      ApplicationController.helpers.unit_thousand_yen(direct_expense_result),
      ApplicationController.helpers.unit_thousand_yen(indirect_labor_cost_budget),
      ApplicationController.helpers.unit_thousand_yen(indirect_labor_cost_result),
      ApplicationController.helpers.unit_thousand_yen(development_cost_budget),
      ApplicationController.helpers.unit_thousand_yen(development_cost_result),
      ApplicationController.helpers.unit_thousand_yen(gross_profit_budget),
      ApplicationController.helpers.unit_thousand_yen(gross_profit_result),
      profit_ratio_budget,
      profit_ratio_result
    ]
  end

  # CSVファイルの作成
  def self.csv_content_for(objs)
    CSV.generate("", {:row_sep => "\r\n"}) do |csv|
      csv << CSV_HEADERS
      objs.each do |record|
        record.totalize_all
        csv << record.to_csv_arr
      end
    end
  end

  # 参加者取得
  def get_membars(id)
    ret = []
    members = PrjMember.where(:project_id => id)
    members.each do |member|
      ret << User.find(member.user_id).name
    end
    return ret.join(",")
  end
end
