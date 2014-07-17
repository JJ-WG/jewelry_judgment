# encoding: utf-8

require 'csv'
require 'kconv'

#
#= Prj::Projectsコントローラクラス
#
# Created:: 2012/10/4
#
class Prj::ProjectsController < Prj::PrjController
  # フィルター設定
  before_filter :require_system_admin_or_manager_or_employee

  # コントローラのメソッドをviewでも使えるように設定
  helper_method :creatable?, :viewable?, :editable?, :deletable?, :restorable?,
      :lockable?, :unlockable?, :statable?, :finishable?, :restartable?,
      :outputtable_man_days?
  
  ##
  # プロジェクト管理機能 一覧画面
  # GET /prj/projects
  #
  def index
    if params[:search].nil?
      # 検索条件をクリア
      params[:search] = Hash.new
      # プロジェクト状態の初期値を「準備中または進行中」に設定
      params[:search][:status_cd] = PROJECT_SEARCH_STATUS_CODE[:preparation_or_progress]
    end
    
    # 検索条件（プロジェクト名 部分一致）
    search_name_condition = {}
    if params[:search][:name].present?
      search_name_condition = "name LIKE '%" + params[:search][:name] + "%'"
    end
    
    # 検索条件（担当者）
    search_staff_condition = {}
    if params[:search][:staff_id].present?
      # 担当者がプロジェクトメンバーに選択されているプロジェクト
      search_staff_condition = 'EXISTS(' +
          'SELECT * FROM prj_members ' + 
          'WHERE projects.id = prj_members.project_id AND ' +
          'prj_members.user_id = ' + params[:search][:staff_id] + ')'
    end
    
    # 検索条件（プロジェクト状態）
    search_status_condition = 'deleted = ' + DB_FALSE_VALUE + ' AND ' +
        '(status_cd = ' + STATUS_CODE[:preparation].to_s +
        ' OR status_cd = ' + STATUS_CODE[:progress].to_s + ')'
    unless params[:search][:status_cd].blank?
      case params[:search][:status_cd]
        when PROJECT_SEARCH_STATUS_CODE[:not_include_deleted].to_s
          # 削除済み以外すべてのプロジェクト
          search_status_condition = {:deleted => false}
        when PROJECT_SEARCH_STATUS_CODE[:preparation_or_progress].to_s
          # プロジェクト状態が[準備中]、または[進行中]で論理削除されていないプロジェクト
          search_status_condition = 'deleted = ' + DB_FALSE_VALUE + ' AND ' +
              '(status_cd = ' + STATUS_CODE[:preparation].to_s +
              ' OR status_cd = ' + STATUS_CODE[:progress].to_s + ')'
        when PROJECT_SEARCH_STATUS_CODE[:preparation].to_s
          # プロジェクト状態が[準備中]で論理削除されていないプロジェクト
          search_status_condition =
              {:deleted => false, :status_cd => STATUS_CODE[:preparation]}
        when PROJECT_SEARCH_STATUS_CODE[:progress].to_s
          # プロジェクト状態が[進行中]で論理削除されていないプロジェクト
          search_status_condition =
              {:deleted => false, :status_cd => STATUS_CODE[:progress]}
        when PROJECT_SEARCH_STATUS_CODE[:completed].to_s
          # プロジェクト状態が[完了]で論理削除されていないプロジェクト
          search_status_condition =
              {:deleted => false, :status_cd => STATUS_CODE[:finished]}
        when PROJECT_SEARCH_STATUS_CODE[:deleted].to_s
          # 論理削除されたプロジェクト
          search_status_condition = {:deleted => true}
      end
    end
    
    # 検索条件（期間）
    search_term_start_condition = {}
    if params[:search][:term_start_year].present? || params[:search][:term_start_month].present?
      if params[:search][:term_start_year].blank?
        # 年リストが未選択の場合は当年
        start_date = db_date("#{Date.today.year}/#{params[:search][:term_start_month]}/01")
      elsif params[:search][:term_start_month].blank?
        # 月リストが未選択の場合は1月
        start_date = db_date("#{params[:search][:term_start_year]}/01/01")
      else
        start_date = db_date("#{params[:search][:term_start_year]}/#{params[:search][:term_start_month]}/01")
      end
      
      if start_date.present?
        search_term_start_condition = ["start_date >= ?", start_date]
      end
    end
    
    search_term_finish_condition = {}
    if params[:search][:term_finish_year].present? || params[:search][:term_finish_month].present?
      if params[:search][:term_finish_year].blank?
        # 年リストが未選択の場合は当年
        finish_date = db_date("#{Date.today.year}/#{params[:search][:term_finish_month]}/01")
      elsif params[:search][:term_finish_month].blank?
        # 月リストが未選択の場合は12月
        finish_date = db_date("#{params[:search][:term_finish_year]}/12/01")
      else
        finish_date = db_date("#{params[:search][:term_finish_year]}/#{params[:search][:term_finish_month]}/01")
      end
      
      # 月末日を取得
      if finish_date.present?
        month_last_day = get_month_last_day(finish_date)
        
        if month_last_day.present?
          search_term_finish_condition = ["finish_date <= ?", month_last_day]
        end
      end
    end
    
    # 検索条件（納期）
    search_finish_date_condition = {}
    if params[:search][:finish_date_year].present? || params[:search][:finish_date_month].present?
      if params[:search][:finish_date_year].blank?
        # 年リストが未選択の場合は当年
        finish_date = db_date("#{Date.today.year}/#{params[:search][:finish_date_month]}/01")
      elsif params[:search][:finish_date_month].blank?
        # 月リストが未選択の場合は12月
        finish_date = db_date("#{params[:search][:finish_date_year]}/12/01")
      else
        finish_date = db_date("#{params[:search][:finish_date_year]}/#{params[:search][:finish_date_month]}/01")
      end
      
      if finish_date.present?
        if params[:search][:finish_date_month].blank?
          # 月リストが未選択の場合は年内に終了予定年月日が含まれるもの
          year_start_day = db_date("#{params[:search][:finish_date_year]}/01/01")
          year_end_day = get_month_last_day(finish_date)
          if year_start_day.present? && year_end_day.present?
            search_finish_date_condition = 
                ["finish_date >= ? AND finish_date <= ?", year_start_day, year_end_day]
          end
        else
          month_last_day = get_month_last_day(finish_date)
          if month_last_day.present?
            search_finish_date_condition = 
                ["finish_date >= ? AND finish_date <= ?", finish_date, month_last_day]
          end
        end
      end
    end
    
    # 検索条件（開発言語）
    search_dev_languages_condition = {}
    if params[:search][:dev_language_id].present?
      # 開発言語がプロジェクト情報で選択されているプロジェクト
      search_staff_condition = 'EXISTS(' +
          'SELECT * FROM prj_dev_languages ' + 
          'WHERE projects.id = prj_dev_languages.project_id AND ' +
          'prj_dev_languages.development_language_id = ' + params[:search][:dev_language_id] + ')'
    end
    
    # 検索条件（OS）
    search_os_condition = {}
    if params[:search][:os_id].present?
      # OSがプロジェクト情報で選択されているプロジェクト
      search_os_condition = 'EXISTS(' +
          'SELECT * FROM prj_operating_systems ' + 
          'WHERE projects.id = prj_operating_systems.project_id AND ' +
          'prj_operating_systems.operating_system_id = ' + params[:search][:os_id] + ')'
    end
    
    # 検索条件（データベース）
    search_database_condition = {}
    if params[:search][:database_id].present?
      # データベースがプロジェクト情報で選択されているプロジェクト
      search_database_condition = 'EXISTS(' +
          'SELECT * FROM prj_databases ' + 
          'WHERE projects.id = prj_databases.project_id AND ' +
          'prj_databases.database_id = ' + params[:search][:database_id] + ')'
    end
    
    # 検索条件（注目プロジェクト）
    search_attention_condition = {}
    if params[:search][:attention].present? && params[:search][:attention] == '1'
      # 注目プロジェクトに設定されているプロジェクト
      search_attention_condition = {:attention => true}
    end
    
    # 検索条件（オーダー種別）
    search_order_condition = {}
    if params[:search][:order_id].present?
      case params[:search][:order_id].to_i
        when PROJECT_SEARCH_ORDER_CODE[:preorder]
          # 商談管理案件のステータスが[受注決定]より前のプロジェクト
          search_order_condition = 'deal_id IS NOT NULL AND EXISTS(' + 
              'SELECT * FROM projects, deals ' + 
              'WHERE projects.deal_id = deals.id AND ' +
              '(deals.order_type_cd < ' + DEAL_STATUS_CODE[:order_decision ].to_s + '))'
        when PROJECT_SEARCH_ORDER_CODE[:normal]
          # 商談管理案件のステータスが[受注決定]より前のプロジェクト
          search_order_condition = 'deal_id IS NOT NULL AND EXISTS(' + 
              'SELECT * FROM projects, deals ' + 
              'WHERE projects.deal_id = deals.id AND ' +
              '(deals.order_type_cd = ' + DEAL_STATUS_CODE[:order_decision].to_s + ' OR ' +
              'deals.order_type_cd = ' + DEAL_STATUS_CODE[:pj_progress].to_s + ' OR ' +
              'deals.order_type_cd = ' + DEAL_STATUS_CODE[:accepted].to_s + '))'
        when PROJECT_SEARCH_ORDER_CODE[:nothing]
          # 商談管理案件が未選択のプロジェクト
          search_order_condition = {:deal_id => nil}
      end
    end
    
    # ログインユーザーのユーザー区分が[システム管理者]以外、かつ、[マネージャー]以外の場合、 
    # 自分がプロジェクト参加メンバー、またはプロジェクトマネージャー、またはプロジェクトリーダーになっている
    # プロジェクトのみに絞り込む
    search_only_my_project_condition = {}
    if !(administrator? || manager?)
      search_only_my_project_condition =
          'manager_id = ' + current_user.id.to_s + ' OR ' +
          'leader_id = ' + current_user.id.to_s + ' OR EXISTS(' +
          'SELECT * FROM prj_members ' + 
          'WHERE projects.id = prj_members.project_id AND ' +
          'prj_members.user_id = ' + current_user.id.to_s + ')'
    end
    
    # 検索条件によりプロジェクトを検索
    @projects =
      Project.where(get_condition([:project_code, :customer_id, :manager_id, :leader_id]))
             .where(search_name_condition)
             .where(search_staff_condition)
             .where(search_status_condition)
             .where(search_term_start_condition)
             .where(search_term_finish_condition)
             .where(search_finish_date_condition)
             .where(search_dev_languages_condition)
             .where(search_os_condition)
             .where(search_database_condition)
             .where(search_attention_condition)
             .where(search_order_condition)
             .where(search_only_my_project_condition)
             .list_order
             .paginate(:page => params[:page], :per_page => PROJECT_ITEMS_PER_PAGE)
    
    # 検索条件をセッション変数に保存
    session[:project_condition] = params[:search]
  end
  
  ##
  # プロジェクト管理機能 閲覧画面
  # GET /prj/projects/1
  #
  def show
    # プロジェクト情報を取得
    id = params[:id]
    begin
      @project = Project.find(id)
    rescue
      add_error_message(t('errors.messages.no_data'))
      redirect_to prj_projects_path
      return
    end
    
    # 閲覧の権限チェック
    unless viewable?(@project)
      add_error_message(t('errors.messages.not_permitted'))
      redirect_to :top
      return
    end
    
    # 進捗率編集フラグ（進捗率のみ編集するか）
    @edit_progress_rate = @project.locked?
    
    # プロジェクトの全ての予算値と実績値を集計する
    @project.totalize_all
    
    # === 工数 ===
    # 社内業務でない作業工程
    @prj_work_types = PrjWorkType.where('project_id = ?', id)
    
    # プロジェクトの客先提示工数を集計する
    @project.totalize_presented_man_days
    
    # プロジェクト全体の進捗率を集計する
    @progress_rate_total = @project.totalize_progress_rate
    
    # プロジェクト全体のEVを集計する
    if (@project.totalize_planned_man_days == 0) || (@progress_rate_total == 0)
      @earned_value_total = 0.0
    else
      @earned_value_total =
          (@project.totalize_planned_man_days * @progress_rate_total / 100.0).round(2)
    end
    
    # === 経費実績(交通・宿泊費、外注費、その他) ===
    expenses = []
    EXPENSE_ITEM_CODE.each_value do |value|
      expenses << Expense
          .where('project_id = ? AND expense_types.expense_item_cd = ?',
              @project.id, value)
          .order('adjusted_date, expenses.created_at')
          .includes(:expense_type)
    end
    @transportation_and_stay_expenses = expenses[0]
    @subcontract_expenses = expenses[1]
    @other_expenses = expenses[2]
  end
  
  ##
  # プロジェクト情報 新規作成処理
  # GET /prj/projects/new
  #
  def new
    # 新規作成の権限チェック
    unless creatable?
      add_error_message(t('errors.messages.not_permitted'))
      redirect_to :top
      return
    end
    
    # プロジェクト情報を作成
    @project = Project.new
    
    # 進捗率編集フラグ（進捗率のみ編集するか）
    @edit_progress_rate = false
    
    # === ビュー表示用各種データ作成 ===
    @section_id = 0
    @related_project_status_cd = STATUS_CODE[:preparation]
    @deals_list = get_deals_list
    @customer_list = Customer.customers_list
    @managers_list = User.users_list(
        :include_deleted_user => false, :include_parttimer_user => false)
    @leaders_list = User.users_list(
        :include_deleted_user => false, :include_parttimer_user => false)
    @dev_languages = DevelopmentLanguage.find(:all)
    @operating_systems = OperatingSystem.find(:all)
    @databases = Database.find(:all)
    
    # === プロジェクトメンバー ===
    # プロジェクトメンバー選択用のユーザリスト
    @member_select_users = User.user_list_by_section_id(0)
    @member_select_users_list =
        @member_select_users.map{|user| [user.name, user.id]}
    
    # プロジェクトメンバー
    @project_prj_members = []
    
    # 工数の合計
    @prj_member_total = 0
    
    # セッション情報のプロジェクトメンバーIDをクリア
    session[:select_prj_members] = []
    
    # === 工数 ===
    office_job_work_types = WorkType.where('office_job = ?', false)
    @work_types = []
    office_job_work_types.each do |work_type_data|
      prj_work_type = PrjWorkType.new
      prj_work_type.work_type_id = work_type_data.id
      @work_types << prj_work_type
    end
    
    # 工数の合計
    @planned_man_days_total = 0
    @presented_man_days_total = 0
    
    # === 経費予算 ===
    @project_prj_expense_budgets = []
    EXPENSE_ITEM_CODE.each_value do |value|
      prj_expense_budget = PrjExpenseBudget.new
      prj_expense_budget.expense_item_cd = value
      @project_prj_expense_budgets << prj_expense_budget
    end
    
    # 経費予算の合計
    @expense_budget_total = 0
    
    # セッション情報の販売原価情報をクリア
    session[:edit_sales_costs] = []
    
    # === 販売原価 ===
    # 税種別が外税の税区分リストを取得し、最初の項目を税区分の初期値とする
    @sales_cost_tax_division_cd = TaxDivision.tax_exclusive_first_id
    
    # 販売原価の合計
    @sales_costs_total = 0
    
    # === 関連プロジェクト ===
    # 関連プロジェクト選択用のプロジェクトリスト
    @related_project_select_list =
        get_related_project_select_list(@related_project_status_cd)
    
    # セッション情報の関連プロジェクトIDをクリア
    session[:select_related_project_ids] = []
    @project_prj_related_projects = []
  end
  
  ##
  # プロジェクト管理機能 編集画面
  # GET /prj/projects/1/edit
  #
  def edit
    # プロジェクト情報を取得
    begin
      @project = Project.find(params[:id])
    rescue
      add_error_message(t('errors.messages.no_data'))
      redirect_to prj_projects_path
      return
    end
    
    # 編集の権限チェック
    unless editable?(@project)
      add_error_message(t('errors.messages.not_permitted'))
      redirect_to :top
      return
    end
    
    # 進捗率編集フラグ（進捗率のみ編集するか）
    @edit_progress_rate = @project.locked?
    
    # ユーザー区分が[マネージャー]で、プロジェクトのプロジェクトマネージャー、
    # プロジェクトリーダーのどちらでもない場合は要員変更画面へ遷移する
    # ただし、プロジェクトがロック中の場合はエラーメッセージを表示して遷移中止
    if manager? &&
        !(@project.project_leader?(current_user) || @project.project_manager?(current_user))
      # ロック状態のチェック
      if @project.locked?
        # エラーメッセージを表示して遷移中止
        add_error_message(t('errors.messages.model_is_locked',
                            :model => Project.model_name.human))
        redirect_to prj_project_path
        return
      else
        # 要員変更画面へ遷移
        redirect_to :action => 'edit_prj_members', :id => params[:id]
      end
    end
    
    # === ビュー表示用各種データ作成 ===
    @section_id = 0
    @related_project_status_cd = STATUS_CODE[:preparation]
    @customer_list = Customer.customers_list
    @work_types = WorkType.where('office_job = ?', false)
    @dev_languages = DevelopmentLanguage.find(:all)
    @operating_systems = OperatingSystem.find(:all)
    @databases = Database.find(:all)
    
    # 選択された商談情報を商談管理情報リストに追加
    @deals_list = get_deals_list_include_selected_deal
    
    # 論理削除されたユーザが選択されていた場合、プロジェクトマネージャーリストに追加
    @managers_list = get_managers_list_include_selected_user
    
    # 論理削除されたユーザが選択されていた場合、プロジェクトリーダーリストに追加
    @leaders_list = get_leaders_list_include_selected_user
    
    # DBからプロジェクトメンバー選択用データを取得
    create_prj_members_from_db
    
    # DBから工数編集用データを取得
    create_prj_work_types_from_db
    
    # DBから経費予算編集用データを取得
    @expense_budget_total = 0
    @project_prj_expense_budgets = @project.prj_expense_budgets
    @project.prj_expense_budgets.each do |expense_budget|
      @expense_budget_total += expense_budget.expense_budget
    end
    
    # DBから販売原価編集用データを取得
    create_prj_sales_costs_from_db
    
    # DBから関連プロジェクト編集用データを取得
    create_prj_related_projects_from_db
  end
  
  ##
  # プロジェクト管理機能 要員変更画面
  # GET /prj/projects/1/edit_prj_members
  #
  def edit_prj_members
    # プロジェクト情報を取得
    begin
      @project = Project.find(params[:id])
    rescue
      add_error_message(t('errors.messages.no_data'))
      redirect_to prj_projects_path
      return
    end
    
    # 編集の権限チェック
    unless editable?(@project)
      add_error_message(t('errors.messages.not_permitted'))
      redirect_to :top
      return
    end
    
    # ユーザー区分が[マネージャー]でない、またはプロジェクトのプロジェクトマネージャー、
    # またはプロジェクトリーダーのどちらかである場合はプロジェクト編集画面へ遷移する
    if !manager? ||
        @project.project_leader?(current_user) || @project.project_manager?(current_user)
      redirect_to edit_prj_project_path(@project)
      return
    end
    
    # === ビュー表示用各種データ作成 ===
    @section_id = 0
    
    # 論理削除されたユーザが選択されていた場合、プロジェクトマネージャーリストに追加
    @managers_list = get_managers_list_include_selected_user
    
    # 論理削除されたユーザが選択されていた場合、プロジェクトリーダーリストに追加
    @leaders_list = get_leaders_list_include_selected_user
    
    # DBからプロジェクトメンバー選択用データを取得
    create_prj_members_from_db
    
    # プロジェクトの予定工数を集計する
    @project.totalize_planned_man_days
  end
  
  ##
  # プロジェクト情報 新規作成処理
  # POST /prj/projects
  #
  def create
    # 新規作成の権限チェック
    unless creatable?
      add_error_message(t('errors.messages.not_permitted'))
      redirect_to :top
      return
    end
    
    # 進捗率編集フラグ（進捗率のみ編集するか）
    @edit_progress_rate = false
    
    begin
      # エラーメッセージリスト
      @error_messages_list = []
      
      # DB登録用attributes
      @project_attributes = params[:project]
      
      # === ビュー表示用各種データ作成 ===
      @section_id = 0
      @related_project_status_cd = STATUS_CODE[:preparation]
      @deals_list = get_deals_list
      @customer_list = Customer.customers_list
      @managers_list = User.users_list(
          :include_deleted_user => false, :include_parttimer_user => false)
      @leaders_list = User.users_list(
          :include_deleted_user => false, :include_parttimer_user => false)
      @work_types = WorkType.where('office_job = ?', false)
      @dev_languages = DevelopmentLanguage.find(:all)
      @operating_systems = OperatingSystem.find(:all)
      @databases = Database.find(:all)
      
      # プロジェクトメンバー選択用データを取得
      create_prj_members_from_attributes(params[:project][:prj_members_attributes])
      
      # 工数編集用データを取得
      create_prj_work_types_from_attributes(params[:project][:prj_work_types_attributes])
      
      # 経費予算編集用データを取得
      create_prj_expense_budgets_from_attributes(params[:project][:prj_expense_budgets_attributes])
      
      # 販売原価編集用データを取得
      create_prj_sales_costs_from_attributes(params[:project][:prj_sales_costs_attributes])
      
      # 関連プロジェクト編集用データを取得
      create_prj_related_projects_from_attributes(params[:project][:prj_related_projects_attributes])
      
      # 開発言語の選択チェック
      check_prj_dev_languages_from_attributes(params[:project][:development_language_ids])
      
      # OSの選択チェック
      check_prj_operating_systems_from_attributes(params[:project][:operating_system_ids])
      
      # データベースの選択チェック
      check_prj_databases_from_attributes(params[:project][:database_ids])
      
      ActiveRecord::Base.transaction do
        @project_attributes = @project_attributes.reject{|key, value|
          key == 'section_id' ||
          key == 'prj_member_size' ||
          key == 'prj_member_total' ||
          key == 'prj_work_type_size' ||
          key == 'planned_man_days_total' ||
          key == 'presented_man_days_total' ||
          key == 'progress_rate_total' ||
          key == 'expense_budget_total' ||
          key == 'sales_cost_item_name' ||
          key == 'sales_cost_price' ||
          key == 'sales_cost_tax_division_cd' ||
          key == 'related_project_status_cd'
        }
        # 状態コードを進行中に設定
        @project_attributes[:status_cd] = STATUS_CODE[:preparation].to_s
        
        # プロジェクト情報のDB登録
        @project = Project.new(@project_attributes)
        raise unless @project.save
        
        # プロジェクトメンバーが選択されているか
        if @project.prj_members.size == 0
          @error_messages_list << 'プロジェクトメンバーが選択されていません。'
        end
        
        # メンバー別予定工数の合計が、作業工程別社内予定工数の合計と一致するか
        if @prj_member_total.to_f != @planned_man_days_total.to_f
          @error_messages_list <<
              'プロジェクトメンバー別予定工数の合計と作業工程別社内予定工数の合計が一致しません。'
        end
        
        # エラーが発生していた場合、例外処理
        raise if @error_messages_list.size != 0
        
        # リーダーアサイン、マネージャーアサイン、メンバーアサインの各プロジェクト通知メッセージを登録
        Notice.create(@project, MESSAGE_CODE[:leader_assign])
        Notice.create(@project, MESSAGE_CODE[:manager_assign])
        @project.prj_members.each do |member|
          Notice.create(@project, MESSAGE_CODE[:assign_member], member.user_id)
        end
        
        redirect_to prj_project_path(@project),
            notice: t('common_label.model_was_created',
            :model => Project.model_name.human)
      end
    rescue => ex
      set_error(ex, :project, :save)
      if @error_messages_list.size != 0
        for i in 0..@error_messages_list.size-1
          add_error_message(@error_messages_list[i], true)
        end
      end
      render action: 'new'
      return
    end
  end
  
  ##
  # プロジェクト情報 更新処理
  # PUT /prj/projects/1
  #
  def update
    # プロジェクト情報を取得
    begin
      @project = Project.find(params[:id])
    rescue
      add_error_message(t('errors.messages.no_data'))
      redirect_to prj_projects_path
      return
    end
    
    # 編集の権限チェック
    unless editable?(@project)
      add_error_message(t('errors.messages.not_permitted'))
      redirect_to :top
      return
    end
    
    # 進捗率編集フラグ（進捗率のみ編集するか）
    @edit_progress_rate = @project.locked?
    
    begin
      # エラーメッセージリスト
      @error_messages_list = []
      
      # DB登録用attributes
      @project_attributes = params[:project]
      
      # === ビュー表示用各種データ作成 ===
      @section_id = 0
      @customer_list = Customer.customers_list
      @users_list = User.users_list(
          :include_deleted_user => false, :include_parttimer_user => false)
      @work_types = WorkType.where('office_job = ?', false)
      @dev_languages = DevelopmentLanguage.find(:all)
      @operating_systems = OperatingSystem.find(:all)
      @databases = Database.find(:all)
      
      # 選択された商談情報を商談管理情報リストに追加
      @deals_list = get_deals_list_include_selected_deal
      
      # 論理削除されたユーザが選択されていた場合、プロジェクトマネージャーリストに追加
      @managers_list = get_managers_list_include_selected_user
      
      # 新しいプロジェクトマネージャーの存在チェック
      check_manager_from_attributes(params[:project][:manager_id])
      
      # 論理削除されたユーザが選択されていた場合、プロジェクトリーダーリストに追加
      @leaders_list = get_leaders_list_include_selected_user
      
      # 新しいプロジェクトリーダーの存在チェック
      check_leader_from_attributes(params[:project][:leader_id])
      
      # プロジェクトメンバー選択用データを取得
      create_prj_members_from_attributes(params[:project][:prj_members_attributes])
      
      # 工数編集用データを取得
      create_prj_work_types_from_attributes(params[:project][:prj_work_types_attributes])
      
      # 経費予算編集用データを取得
      create_prj_expense_budgets_from_attributes(params[:project][:prj_expense_budgets_attributes])
      
      # 販売原価編集用データを取得
      create_prj_sales_costs_from_attributes(params[:project][:prj_sales_costs_attributes])
      
      # 関連プロジェクト編集用データを取得
      create_prj_related_projects_from_attributes(params[:project][:prj_related_projects_attributes])
      
      # 開発言語の選択チェック
      check_prj_dev_languages_from_attributes(params[:project][:development_language_ids])
      
      # OSの選択チェック
      check_prj_operating_systems_from_attributes(params[:project][:operating_system_ids])
      
      # データベースの選択チェック
      check_prj_databases_from_attributes(params[:project][:database_ids])
      
      ActiveRecord::Base.transaction do
        @project_attributes = @project_attributes.reject{|key, value|
          key == 'section_id' ||
          key == 'prj_member_size' ||
          key == 'prj_member_total' ||
          key == 'prj_work_type_size' ||
          key == 'planned_man_days_total' ||
          key == 'presented_man_days_total' ||
          key == 'progress_rate_total' ||
          key == 'expense_budget_total' ||
          key == 'sales_cost_item_name' ||
          key == 'sales_cost_price' ||
          key == 'sales_cost_tax_division_cd' ||
          key == 'related_project_status_cd'
        }
        
        # 要員変更で選択されたプロジェクトメンバーのIDリスト
        prj_member_ids = []
        @project_prj_members.each do |prj_member|
          prj_member_ids << prj_member.user_id
        end
        
        # プロジェクトマネージャーが変更された場合、変更フラグをセットし
        # ユーザーへアサイン解除のプロジェクト通知メッセージを登録
        is_changed_manager = false
        if @project.manager_id != params[:project][:manager_id].to_i
          is_changed_manager = true
          Notice.create(@project, MESSAGE_CODE[:relieve_manager])
        end
        
        # プロジェクトリーダーが変更された場合、変更フラグをセットし
        # ユーザーへアサイン解除のプロジェクト通知メッセージを登録
        is_changed_leader = false
        if @project.leader_id != params[:project][:leader_id].to_i
          is_changed_leader = true
          Notice.create(@project, MESSAGE_CODE[:relieve_leader])
        end
        
        # 要員変更により新規にメンバー追加されたユーザーリスト作成
        add_prj_member_ids =[]
        @project_prj_members.each do |prj_member|
          user = User.where(:id => prj_member.user_id).first
          if user.present?
            unless @project.project_member?(user)
              add_prj_member_ids << user.id
            end
          end
        end
        
        # プロジェクトメンバーから除外されたユーザーへ
        # メンバーアサイン解除のプロジェクト通知メッセージを登録
        @project.prj_members.each do |prj_member|
          user = User.where(:id => prj_member.user_id).first
          if user.present?
            unless prj_member_ids.include?(prj_member.user_id)
              # プロジェクトメンバーから除外されたユーザーへ
              # メンバーアサイン解除のプロジェクト通知メッセージを登録
              Notice.create(@project, MESSAGE_CODE[:relieve_member], prj_member.user_id)
              
              # === 不要データの削除 ===
              prj_member.destroy
            end
          end
        end
        
        # === 不要データの削除 ===
        # 工数
        new_prj_work_type_ids = []
        @project_prj_work_types.each do |work_type|
          new_prj_work_type_ids << work_type.work_type_id unless work_type.work_type_id.nil?
        end
        if new_prj_work_type_ids.blank?
          PrjWorkType.destroy_all("project_id = #{@project.id}")
        else
          PrjWorkType.destroy_all("project_id = #{@project.id} AND " +
                                  "work_type_id NOT IN (#{new_prj_work_type_ids.join(",")})")
        end
        
        # 販売原価
        new_prj_sales_cost_ids = []
        @project_prj_sales_costs.each do |sales_cost|
          new_prj_sales_cost_ids << sales_cost.id unless sales_cost.id.nil?
        end
        if new_prj_sales_cost_ids.blank?
          PrjSalesCost.destroy_all("project_id = #{@project.id}")
        else
          PrjSalesCost.destroy_all("project_id = #{@project.id} AND " +
                                   "id NOT IN (#{new_prj_sales_cost_ids.join(",")})")
        end
        
        # 関連プロジェクト
        new_prj_related_project_ids = []
        @project_prj_related_projects.each do |related_project|
          unless related_project.related_project_id .nil?
            new_prj_related_project_ids << related_project.related_project_id
          end
        end
        if new_prj_related_project_ids.blank?
          PrjRelatedProject.destroy_all("project_id = #{@project.id}")
        else
          PrjRelatedProject.destroy_all("project_id = #{@project.id} AND " +
                                        "related_project_id NOT IN (#{new_prj_related_project_ids.join(",")})")
        end
        
        # プロジェクト変更時自動ロックフラグがTrueの場合、進行中のプロジェクトをロックする
        if @project.in_progress? && SystemSetting.lock_project_after_editing
          @project_attributes[:locked] = 1
        end
        
        # === データ更新 ===
        @project.update_attributes!(@project_attributes)
        
        # プロジェクトメンバーが選択されているか
        if @project_prj_members.size == 0
          @error_messages_list << 'プロジェクトメンバーが選択されていません。'
        end
        
        # メンバー別予定工数の合計が、作業工程別社内予定工数の合計と一致するか
        if @prj_member_total.to_f != @planned_man_days_total
          @error_messages_list <<
              'プロジェクトメンバー別予定工数の合計と作業工程別社内予定工数の合計が一致しません。'
        end
        
        # エラーが発生していた場合、例外処理
        raise if @error_messages_list.size != 0
        
        # プロジェクトマネージャーが変更された場合、ユーザーへアサインのプロジェクト通知メッセージを登録
        if is_changed_manager
          Notice.create(@project, MESSAGE_CODE[:manager_assign])
        end
        
        # プロジェクトリーダーが変更された場合、ユーザーへアサインのプロジェクト通知メッセージを登録
        if is_changed_leader
          Notice.create(@project, MESSAGE_CODE[:leader_assign])
        end
        
        # 新規にメンバー追加されたユーザーへメンバーアサインのプロジェクト通知メッセージを登録
        add_prj_member_ids.each do |id|
          user = User.where(:id => id).first
          if user.present?
            Notice.create(@project, MESSAGE_CODE[:assign_member], id)
          end
        end
        
        redirect_to prj_project_path(@project),
            notice: t('common_label.model_was_updated',
            :model => Project.model_name.human)
      end
    rescue => ex
      set_error(ex, :project, :save)
      if @error_messages_list.size != 0
        for i in 0..@error_messages_list.size-1
          add_error_message(@error_messages_list[i], true)
        end
      end
      render action: 'edit'
      return
    end
  end
  
  ##
  # プロジェクト情報 更新処理
  # PUT /prj/projects/1/update_prj_members
  #
  def update_prj_members
    # プロジェクト情報を取得
    begin
      @project = Project.find(params[:id])
    rescue
      add_error_message(t('errors.messages.no_data'))
      redirect_to prj_projects_path
      return
    end
    
    # 編集の権限チェック
    unless editable?(@project)
      add_error_message(t('errors.messages.not_permitted'))
      redirect_to :top
      return
    end
    
    # ユーザー区分が[マネージャー]でない、またはプロジェクトのプロジェクトマネージャー、
    # またはプロジェクトリーダーのどちらかである場合はプロジェクト編集画面へ遷移する
    if !manager? ||
        @project.project_leader?(current_user) || @project.project_manager?(current_user)
      redirect_to edit_prj_project_path(@project)
      return
    end
    
    begin
      # エラーメッセージリスト
      @error_messages_list = []
      
      # DB登録用attributes
      @project_attributes = params[:project]
      
      # === ビュー表示用各種データ作成 ===
      @section_id = 0
      
      # 論理削除されたユーザが選択されていた場合、プロジェクトマネージャーリストに追加
      @managers_list = get_managers_list_include_selected_user
      
      # 新しいプロジェクトマネージャーの存在チェック
      check_manager_from_attributes(params[:project][:manager_id])
      
      # 論理削除されたユーザが選択されていた場合、プロジェクトリーダーリストに追加
      @leaders_list = get_leaders_list_include_selected_user
      
      # 新しいプロジェクトリーダーの存在チェック
      check_leader_from_attributes(params[:project][:leader_id])
      
      # プロジェクトメンバー選択用データを取得
      create_prj_members_from_attributes(params[:project][:prj_members_attributes])
      
      # プロジェクトの予定工数を集計する
      @project.totalize_planned_man_days
      
      ActiveRecord::Base.transaction do
        @project_attributes = @project_attributes.reject{|key, value|
          key == 'section_id' ||
          key == 'prj_member_size' ||
          key == 'prj_member_total'
        }
        
        # 要員変更で選択されたプロジェクトメンバーのIDリスト
        prj_member_ids = []
        @project_prj_members.each do |prj_member|
          prj_member_ids << prj_member.user_id
        end
        
        # プロジェクトマネージャーが変更された場合、変更フラグをセットし
        # ユーザーへアサイン解除のプロジェクト通知メッセージを登録
        is_changed_manager = false
        if @project.manager_id != params[:project][:manager_id]
          is_changed_manager = true
          Notice.create(@project, MESSAGE_CODE[:relieve_manager])
        end
        
        # プロジェクトリーダーが変更された場合、変更フラグをセットし
        # ユーザーへアサイン解除のプロジェクト通知メッセージを登録
        is_changed_leader = false
        if @project.leader_id != params[:project][:leader_id]
          is_changed_leader = true
          Notice.create(@project, MESSAGE_CODE[:relieve_leader])
        end
        
        # 要員変更により新規にメンバー追加されたユーザーリスト作成
        add_prj_member_ids =[]
        @project_prj_members.each do |prj_member|
          user = User.where(:id => prj_member.user_id).first
          if user.present?
            unless @project.project_member?(user)
              add_prj_member_ids << user.id
            end
          end
        end
        
        # プロジェクトメンバーから除外されたユーザーへ
        # メンバーアサイン解除のプロジェクト通知メッセージを登録
        @project.prj_members.each do |prj_member|
          user = User.where(:id => prj_member.user_id).first
          if user.present?
            unless prj_member_ids.include?(prj_member.user_id)
              # プロジェクトメンバーから除外されたユーザーへ
              # メンバーアサイン解除のプロジェクト通知メッセージを登録
              Notice.create(@project, MESSAGE_CODE[:relieve_member], prj_member.user_id)
              
              # === 不要データの削除 ===
              prj_member.destroy
            end
          end
        end
        
        # プロジェクト変更時自動ロックフラグがTrueの場合、進行中のプロジェクトをロックする
        if @project.in_progress? && SystemSetting.lock_project_after_editing
          @project_attributes[:locked] = 1
        end
        
        # === データ更新 ===
        @project.update_attributes!(@project_attributes)
        
        # プロジェクトメンバーが選択されているか
        if @project_prj_members.size == 0
          @error_messages_list << 'プロジェクトメンバーが選択されていません。'
        end
        
        # メンバー別予定工数の合計が、作業工程別社内予定工数の合計と一致するか
        if @prj_member_total.to_f != @project.planned_man_days
          @error_messages_list <<
              'プロジェクトメンバー別予定工数の合計と作業工程別社内予定工数の合計が一致しません。'
        end
        
        # エラーが発生していた場合、例外処理
        raise if @error_messages_list.size != 0
        
        # プロジェクトマネージャーが変更された場合、ユーザーへアサインのプロジェクト通知メッセージを登録
        if is_changed_manager
          Notice.create(@project, MESSAGE_CODE[:manager_assign])
        end
        
        # プロジェクトリーダーが変更された場合、ユーザーへアサインのプロジェクト通知メッセージを登録
        if is_changed_leader
          Notice.create(@project, MESSAGE_CODE[:leader_assign])
        end
        
        # 新規にメンバー追加されたユーザーへメンバーアサインのプロジェクト通知メッセージを登録
        add_prj_member_ids.each do |id|
          user = User.where(:id => id).first
          if user.present?
            Notice.create(@project, MESSAGE_CODE[:assign_member], id)
          end
        end
        
        redirect_to prj_project_path(@project),
            notice: t('common_label.model_was_updated',
            :model => Project.model_name.human)
      end
    rescue => ex
      set_error(ex, :project, :save)
      if @error_messages_list.size != 0
        for i in 0..@error_messages_list.size-1
          add_error_message(@error_messages_list[i], true)
        end
      end
      render action: 'edit_prj_members'
      return
    end
  end
  
  ##
  # プロジェクト ロック処理
  # put /prj/projects/1/lock
  #
  def lock
    # プロジェクト情報を取得
    begin
      project = Project.find(params[:id])
    rescue
      flash[:error] = t('errors.messages.no_data')
      redirect_to prj_projects_url
      return
    end
    
    # 権限チェック
    if !administrator? && !manager? &&
       !project.project_manager?(current_user)
      flash[:error] = t('errors.messages.not_permitted')
      redirect_to :top
      return
    end
    
    begin
      # 削除チェック
      if project.deleted?
        raise t('errors.messages.model_is_deleted',
                :model => Project.model_name.human)
      end
      
      # 状態チェック
      unless project.in_progress?
        raise t('プロジェクトが進行中ではありません。')
      end
      
      # プロジェクトをロック状態にする
      project.locked = true
      project.save!(:validate => false)
      
    rescue => ex
      set_error(ex, :project, :lock, project.name)
      redirect_to prj_project_path(project)
      return
    end

    # プロジェクト閲覧画面を再表示する
    redirect_to prj_project_path(project),
        notice: t('common_label.model_was_locked',
                  :model => Project.model_name.human)
  end
  
  ##
  # プロジェクト ロック解除処理
  # put /prj/projects/1/unlock
  #
  def unlock
    # プロジェクト情報を取得
    begin
      project = Project.find(params[:id])
    rescue
      flash[:error] = t('errors.messages.no_data')
      redirect_to prj_projects_url
      return
    end
    
    # 権限チェック
    if !administrator? && !manager? &&
       !project.project_manager?(current_user)
      flash[:error] = t('errors.messages.not_permitted')
      redirect_to :top
      return
    end
    
    begin
      # 削除チェック
      if project.deleted?
        raise t('errors.messages.model_is_deleted',
                :model => Project.model_name.human)
      end
      
      # 状態チェック
      unless project.in_progress?
        raise t('プロジェクトが進行中ではありません。')
      end
      
      # プロジェクトのロックを解除する
      project.locked = false
      project.save!(:validate => false)
      
    rescue => ex
      set_error(ex, :project, :unlock, project.name)
      redirect_to prj_project_path(project)
      return
    end

    # プロジェクト閲覧画面を再表示する
    redirect_to prj_project_path(project),
        notice: t('common_label.model_was_unlocked',
                  :model => Project.model_name.human)
  end
  
  ##
  # プロジェクト 開始処理
  # put /prj/projects/1/start
  #
  def start
    # プロジェクト情報を取得
    begin
      project = Project.find(params[:id])
    rescue
      flash[:error] = t('errors.messages.no_data')
      redirect_to prj_projects_url
      return
    end
    
    # 権限チェック
    if !administrator? &&
       !project.project_manager?(current_user)
      flash[:error] = t('errors.messages.not_permitted')
      redirect_to :top
      return
    end
    
    begin
      # 削除チェック
      if project.deleted?
        raise t('errors.messages.model_is_deleted',
                :model => Project.model_name.human)
      end
      
      # 状態チェック
      unless project.in_preparation?
        raise t('errors.messages.model_is_started',
                :model => Project.model_name.human)
      end
      
      # データ登録・更新処理      
      ActiveRecord::Base.transaction do
        # 商談管理案件の商談ステータスを[PJ進行中]に変更する
        if project.deal.present?
          deal = project.deal
          unless deal.update_attribute(
            :deal_status_cd, DEAL_STATUS_CODE[:pj_progress])
            raise '商談ステータスを更新できませんでした。'
          end
        end
        
        # プロジェクト開始日に当日の日付を設定する
        project.started_date = Date.today
        
        # プロジェクトの状態を[進行中]に変更し、ロック状態にする
        project.status_cd = STATUS_CODE[:progress]
        project.locked = true
        project.save!(:validate => false)
      end
    rescue => ex
      set_error(ex, :project, :start, project.name)
      redirect_to prj_project_path(project)
      return
    end

    # プロジェクト開始のプロジェクト通知メッセージを登録する
    unless Notice.create(project, MESSAGE_CODE[:start_project])
      add_error_message('通知メッセージを登録できませんでした。')
    end

    # プロジェクト閲覧画面を再表示する
    redirect_to prj_project_path(project),
        notice: t('common_label.model_was_started',
                  :model => Project.model_name.human)
  end
  
  ##
  # プロジェクト 完了処理
  # put /prj/projects/1/finish
  #
  def finish
    prj_reflection = nil
    deal = nil
    # プロジェクト情報を取得
    begin
      project = Project.find(params[:id])
    rescue
      flash[:error] = t('errors.messages.no_data')
      redirect_to prj_projects_url
      return
    end
    
    # 権限チェック
    if !administrator? &&
       !project.project_manager?(current_user) &&
       !project.project_leader?(current_user)
      flash[:error] = t('errors.messages.not_permitted')
      redirect_to :top
      return
    end
    
    begin
      # 削除チェック
      if project.deleted?
        raise t('errors.messages.model_is_deleted',
                :model => Project.model_name.human)
      end
      
      # 状態チェック
      if project.finished?
        raise t('errors.messages.model_is_finished',
                :model => Project.model_name.human)
      end
      
      # プロジェクト完了処理
      # プロジェクトの状態を[完了]に変更する
      project.status_cd = STATUS_CODE[:finished]

      # プロジェクト終了日に当日の日付を設定する
      project.finished_date = Date.today

      # 振り返り情報が未登録の場合は振り返り情報を新規登録する
      if project.prj_reflection.blank?
        prj_reflection = PrjReflection.new
      else
        prj_reflection = project.prj_reflection
      end
      if prj_reflection.blank?
        raise '振り返り情報を作成できませんでした。'
      end
      
      # プロジェクトの集計値を取得する
      unless project.restore_totalized_values(session[:totalized_values])
        project.totalize_all
        session[:totalized_values] = project.totalized_values
      end

      # 振り返り情報の終了年月日、各実績値、各評価ランクを更新する
      prj_reflection.update_project_results(project)
      
      # データ登録・更新処理      
      ActiveRecord::Base.transaction do
        # 商談管理案件の商談ステータスを[検収済み]に変更する
        if project.deal.present?
          deal = project.deal
          unless deal.update_attribute(
            :deal_status_cd, DEAL_STATUS_CODE[:accepted])
            raise '商談ステータスを更新できませんでした。'
          end
        end
        
        # プロジェクトの情報を更新する
        project.save!(:validate => false)

        # 振り返り情報を登録または更新する
        if prj_reflection.new_record?
          prj_reflection.project_id = project.id
        end
        prj_reflection.save!(:validate => false)
      end

    rescue => ex
      set_error(ex, :project, :finish, project.name)
      redirect_to prj_project_path(project)
      return
    end

    # プロジェクト終了のプロジェクト通知メッセージを登録する
    unless Notice.create(project, MESSAGE_CODE[:finish_project])
      add_error_message('通知メッセージを登録できませんでした。')
    end
    
    # 振り返り情報入力画面に遷移する
    redirect_to edit_prj_prj_reflection_path(prj_reflection),
        notice: t('common_label.model_was_finished',
                  :model => Project.model_name.human)
  end
  
  ##
  # プロジェクト 再開処理
  # put /prj/projects/1/restart
  #
  def restart
    # プロジェクト情報を取得
    begin
      project = Project.find(params[:id])
    rescue
      flash[:error] = t('errors.messages.no_data')
      redirect_to prj_projects_url
      return
    end
    
    # 権限チェック
    if !administrator? &&
       !project.project_manager?(current_user) &&
       !project.project_leader?(current_user)
      flash[:error] = t('errors.messages.not_permitted')
      redirect_to :top
      return
    end
    
    begin
      # 削除チェック
      if project.deleted?
        raise t('errors.messages.model_is_deleted',
                :model => Project.model_name.human)
      end
      
      # 状態チェック
      unless project.finished?
        raise t('errors.messages.model_is_uncompleted',
                :model => Project.model_name.human)
      end
      
      # データ登録・更新処理      
      ActiveRecord::Base.transaction do
        # 商談管理案件の商談ステータスを[PJ進行中]に変更する
        if project.deal.present?
          deal = project.deal
          unless deal.update_attribute(
            :deal_status_cd, DEAL_STATUS_CODE[:pj_progress])
            raise '商談ステータスを更新できませんでした。'
          end
        end
        
        # プロジェクトの状態を[進行中]に変更し、ロック状態にする
        project.status_cd = STATUS_CODE[:progress]
        project.locked = true
        project.finished_date = nil
        project.save!(:validate => false)
      end
    rescue => ex
      set_error(ex, :project, :start, project.name)
      redirect_to prj_project_path(project)
      return
    end

    # プロジェクト再開のプロジェクト通知メッセージを登録する
    unless Notice.create(project, MESSAGE_CODE[:restart_project])
      add_error_message('通知メッセージを登録できませんでした。')
    end

    # プロジェクト閲覧画面を再表示する
    redirect_to prj_project_path(project),
        notice: t('common_label.model_was_started',
                  :model => Project.model_name.human)
  end
  
  ##
  # プロジェクト情報 復活処理
  # put /prj/projects/1/restore
  #
  def restore
    # プロジェクト情報を取得
    begin
      project = Project.find(params[:id])
    rescue
      flash[:error] = t('errors.messages.no_data')
      redirect_to prj_projects_url
      return
    end
    
    # 権限チェック
    if !administrator? && !manager? &&
       !project.project_manager?(current_user)
      flash[:error] = t('errors.messages.not_permitted')
      redirect_to :top
      return
    end
    
    begin
      # 削除チェック
      unless project.deleted?
        raise t('errors.messages.model_is_alive',
                :model => Project.model_name.human)
      end
      
      # プロジェクトの削除状態を変更する
      project.deleted = false
      project.save!(:validate => false)
      
    rescue => ex
      set_error(ex, :project, :restore, project.name)
      redirect_to prj_project_path(project)
      return
    end

    # プロジェクト復活のプロジェクト通知メッセージを登録する
    unless Notice.create(project, MESSAGE_CODE[:restore_project])
      add_error_message('通知メッセージを登録できませんでした。')
    end

    # プロジェクト閲覧画面を再表示する
    redirect_to prj_project_path(project),
        notice: t('common_label.model_was_restored',
                  :model => Project.model_name.human)
  end
  
  ##
  # プロジェクト情報 削除処理
  # DELETE /prj/projects/1
  #
  def destroy
    # プロジェクト情報を取得
    begin
      project = Project.find(params[:id])
    rescue
      flash[:error] = t('errors.messages.no_data')
      redirect_to prj_projects_url
      return
    end
    
    # 権限チェック
    if !administrator? && !manager? &&
       !project.project_manager?(current_user)
      flash[:error] = t('errors.messages.not_permitted')
      redirect_to :top
      return
    end
    
    begin
      # 削除チェック
      if project.deleted?
        raise t('errors.messages.model_is_deleted',
                :model => Project.model_name.human)
      end
      
      # プロジェクトの削除状態を変更する
      project.deleted = true
      project.save!(:validate => false)
      
    rescue => ex
      set_error(ex, :project, :delete, project.name)
      redirect_to prj_project_path(project)
      return
    end

    # プロジェクト削除のプロジェクト通知メッセージを登録する
    unless Notice.create(project, MESSAGE_CODE[:delete_project])
      add_error_message('通知メッセージを登録できませんでした。')
    end

    # プロジェクト閲覧画面を再表示する
    redirect_to prj_project_path(project),
        notice: t('common_label.model_was_deleted',
                  :model => Project.model_name.human)
  end
  
  ##
  # プロジェクト管理機能 工数集計出力画面
  # GET /prj/projects/output_man_days
  #
  def output_man_days
    # 権限チェック
    if !administrator? && !manager?
      add_error_message(t('errors.messages.not_permitted'))
      redirect_to :top
      return
    end
  end
  
  ##
  # プロジェクト管理機能 工数集計CSV出力処理
  # PUT /prj/projects/send_man_days
  #
  def send_man_days
    # 権限チェック
    if !administrator? && !manager?
      add_error_message(t('errors.messages.not_permitted'))
      redirect_to :top
      return
    end
    
    # パラメータチェック
    if params[:output].blank? || params[:output][:total_up_date].blank?
      add_error_message(t('label.project.output_man_days.total_up_date') +
                        t('errors.messages.blank'))
      redirect_to output_man_days_prj_projects_path
      return
    end
    
    # 集計日時点で進行中のプロジェクトの工数を集計する
    total_up_date = db_date(params[:output][:total_up_date])
    data = Project.started
                  .alive
                  .where('projects.start_date <= ? AND' +
                    ' (projects.finished_date IS NULL OR' +
                    ' projects.finished_date >= ?)',
                    total_up_date, total_up_date)
                  .joins(:results => :user)
                  .where('results.result_date <= ?', total_up_date)
                  .where('results.deleted = ?', DB_FALSE_VALUE)
                  .group('projects.id, results.user_id')
                  .select('projects.name as project_name,' +
                    ' users.name as user_name,' +
                    ' sum(UNIX_TIMESTAMP(results.end_at) - UNIX_TIMESTAMP(results.start_at)) as work_hours')
                  .order('projects.finish_date, projects.id, users.name_ruby')
    
    csv_string = 
      CSV.generate({:quote_char => '"', :row_sep => "\r\n"}) do |csv|
        # CSVヘッダ行を生成
        csv << ['プロジェクト名', '担当者名', '作業時間', '工数(人日)']
        
        # CSVデータ行を生成
        data.each do |row|
          man_hours = row.work_hours.to_f / 3600.0
          decimal_man_hours = BigDecimal(man_hours.to_s).round(2)
          man_days = man_hours / WORK_HOURS_PER_DAY
          decimal_man_days = BigDecimal(man_days.to_s).round(2)
          csv << [row.project_name, row.user_name, decimal_man_hours,
                  decimal_man_days]
        end
      end
    
    # CSVデータを送信
    date_string = total_up_date.scan(/\d/).join(nil)
    send_data(csv_string.kconv(Kconv::SJIS, Kconv::UTF8),
      :type => 'text/csv; charset=SHIFT_JIS',
      :disposition => 'attachment',
      :filename => "result_#{date_string}.csv")
  end
  
  ##
  # プロジェクト管理機能 登録・編集（商談管理案件選択）
  # GET /prj/projects/on_change_deal_list
  #
  def on_change_deal_list
    # プロジェクト情報を取得
    if params[:project_id].present? && params[:project_id] != ''
      begin
        @project = Project.find(params[:project_id])
      rescue
        add_error_message(t('errors.messages.no_data'))
        redirect_to prj_projects_path
        return
      end
    else
      @project = Project.new
    end
    
    @customer_list = Customer.customers_list
    
    # 選択された案件によって、顧客名、受注形態、受注額を更新
    @project.customer_id = 0
    @project.order_type_cd = ORDER_TYPE_CODE[:contract]
    @project.order_volume = 0
    if params[:deal_id].present?
      deal = Deal.where('id = ?', params[:deal_id]).first
      if deal.present?
        @project.customer_id = deal.customer_id
        @project.order_type_cd = deal.order_type_cd
        @project.order_volume = deal.order_volume
      end
    end
    render
  end
  
  ##
  # プロジェクト管理機能 登録・編集（プロジェクトメンバー 部署選択）
  # GET /prj/projects/on_change_section_list
  #
  def on_change_section_list
    # プロジェクト情報を取得
    if params[:project_id].present? && params[:project_id] != ''
      begin
        @project = Project.find(params[:project_id])
      rescue
        add_error_message(t('errors.messages.no_data'))
        redirect_to prj_projects_path
        return
      end
    else
      @project = Project.new
    end
    
    # プロジェクトメンバー選択コントロールの表示
    set_prj_member_select_control
    render
  end
  
  ##
  # プロジェクト管理機能 登録・編集（プロジェクトメンバー選択）
  # GET /prj/projects/on_click_prj_member_add
  #
  def on_click_prj_member_add
    # プロジェクト情報を取得
    if params[:project_id].present? && params[:project_id] != ''
      begin
        @project = Project.find(params[:project_id])
      rescue
        add_error_message(t('errors.messages.no_data'))
        redirect_to prj_projects_path
        return
      end
    else
      @project = Project.new
    end
    
    @project_member_list_error = ''
    
    # 指定されたユーザをプロジェクトメンバーリストに追加
    if params[:user_id].present?
      if params[:user_id] == 'null'
        @project_member_list_error = 'ユーザーが選択されていません。'
      else
        user = User.where('id = ?', params[:user_id]).first
        if user.present?
          if user.deleted?
            if @project.new_record? || !@project.project_member?(user)
              @project_member_list_error =
                  "選択されたユーザー(id=#{params[:user_id]})" + t('errors.messages.deleted')
            else
              # 削除されているユーザーでも既にメンバーにDB登録済みの場合、
              # セッション情報に現在選択中のプロジェクトメンバーIDを保存
              session[:select_prj_members] << [user.id, 0.0]
              session[:select_prj_members].uniq
            end
          else
            # セッション情報に現在選択中のプロジェクトメンバーIDを保存
            session[:select_prj_members] << [user.id, 0.0]
            session[:select_prj_members].uniq
          end
        else
          @project_member_list_error =
              "選択されたユーザー(id=#{params[:user_id]})" + t('errors.messages.not_exist')
        end
      end
      # プロジェクトメンバー選択コントロールの表示
      set_prj_member_select_control
      render
    end
  end
  
  ##
  # プロジェクト管理機能 登録・編集（プロジェクトメンバー選択解除）
  # GET /prj/projects/on_click_prj_member_delete
  #
  def on_click_prj_member_delete
    # プロジェクト情報を取得
    if params[:project_id].present? && params[:project_id] != ''
      begin
        @project = Project.find(params[:project_id])
      rescue
        add_error_message(t('errors.messages.no_data'))
        redirect_to prj_projects_path
        return
      end
    else
      @project = Project.new
    end
    
    @project_member_list_error = ''
    
    # 指定されたユーザをプロジェクトメンバーリストから削除
    if params[:user_id].present?
      user = User.where('id = ?', params[:user_id]).first
      if user.present?
        # セッション情報から指定されたプロジェクトメンバーIDを削除
        session[:select_prj_members].delete_if{|id, planned_man_days|
          id == params[:user_id].to_i
        }
        session[:select_prj_members].uniq
        
        # プロジェクトメンバー選択コントロールの表示
        set_prj_member_select_control
        render
      end
    end
  end
  
  ##
  # プロジェクト管理機能 登録・編集（プロジェクトメンバー予定工数合計表示）
  # GET /prj/projects/on_click_prj_member_total
  #
  def on_click_prj_member_total
    # プロジェクト情報を取得
    if params[:project_id].present? && params[:project_id] != ''
      begin
        @project = Project.find(params[:project_id])
      rescue
        add_error_message(t('errors.messages.no_data'))
        redirect_to prj_projects_path
        return
      end
    else
      @project = Project.new
    end
    
    @project_member_list_error = ''
    
    # プロジェクトメンバー選択コントロールの表示
    set_prj_member_select_control
    render
  end
  
  ##
  # プロジェクト管理機能 登録・編集（プロジェクトメンバー予定工数値保存）
  # GET /prj/projects/on_change_prj_member_planned_man_days
  #
  def on_change_prj_member_planned_man_days
    # プロジェクト情報を取得
    if params[:project_id].present? && params[:project_id] != ''
      begin
        @project = Project.find(params[:project_id])
      rescue
        add_error_message(t('errors.messages.no_data'))
        redirect_to prj_projects_path
        return
      end
    else
      @project = Project.new
    end
    
    # セッション情報の予定工数を更新
    if params[:index].present? && params[:value].present?
      session[:select_prj_members][params[:index].to_i][1] = params[:value].to_f
    end
    
    # プロジェクトメンバー選択コントロールの表示
    set_prj_member_select_control
    render
  end
  
  ##
  # プロジェクト管理機能 登録・編集（工数合計表示）
  # GET /prj/projects/on_click_work_type_total
  #
  def on_click_work_type_total
    # プロジェクト情報を取得
    if params[:project_id].present? && params[:project_id] != ''
      begin
        @project = Project.find(params[:project_id])
      rescue
        add_error_message(t('errors.messages.no_data'))
        redirect_to prj_projects_path
        return
      end
    else
      @project = Project.new
    end
    
    @planned_man_days_total = 0
    @presented_man_days_total = 0
    @progress_rate_total = 0
    if params[:planned_man_days_total].present?
      @planned_man_days_total = params[:planned_man_days_total]
    end
    if params[:presented_man_days_total].present?
      @presented_man_days_total = params[:presented_man_days_total]
    end
    if params[:progress_rate_total].present?
      @progress_rate_total = params[:progress_rate_total].to_f.round(2)
    end
    render
  end
  
  ##
  # プロジェクト管理機能 登録・編集（関連プロジェクト 状態選択）
  # GET /prj/projects/on_change_status_list
  #
  def on_change_status_list
    # プロジェクト情報を取得
    if params[:project_id].present? && params[:project_id] != ''
      begin
        @project = Project.find(params[:project_id])
      rescue
        add_error_message(t('errors.messages.no_data'))
        redirect_to prj_projects_path
        return
      end
    else
      @project = Project.new
    end
    
    # 関連プロジェクト選択コントロールの表示
    set_related_project_select_control
    render
  end
  
  ##
  # プロジェクト管理機能 登録・編集（関連プロジェクト選択）
  # GET /prj/projects/on_click_related_project_add
  #
  def on_click_related_project_add
    # プロジェクト情報を取得
    if params[:project_id].present? && params[:project_id] != ''
      begin
        @project = Project.find(params[:project_id])
      rescue
        add_error_message(t('errors.messages.no_data'))
        redirect_to prj_projects_path
        return
      end
    else
      @project = Project.new
    end
    
    @related_project_select_list_error = ''
    
    # 指定されたプロジェクトを関連プロジェクトリストに追加
    if params[:related_project_id].present?
      if params[:related_project_id] == 'null'
        @related_project_select_list_error = 'プロジェクトが選択されていません。'
      else
        related_project = Project.where('id = ?', params[:related_project_id]).first
        
        if related_project.present?
          if related_project.deleted?
            if @project.new_record? || !@project.related_project?(related_project)
              @related_project_select_list_error =
                  "選択されたプロジェクト(id=#{params[:related_project_id]})" +
                  t('errors.messages.deleted')
            else
              # 削除されているプロジェクトでも既に関連プロジェクトにDB登録済みの場合、
              # セッション情報に現在選択中の関連プロジェクトIDを保存
              session[:select_related_project_ids] << related_project.id
              session[:select_related_project_ids].uniq
            end
          else
            # セッション情報に現在選択中の関連プロジェクトIDを保存
            session[:select_related_project_ids] << related_project.id
            session[:select_related_project_ids].uniq
          end
        else
          @related_project_select_list_error = 
              "選択されたプロジェクト(id=#{params[:related_project_id]})" + 
              t('errors.messages.not_exist')
        end
      end
      # 関連プロジェクト選択コントロールの表示
      set_related_project_select_control
      render
    end
  end
  
  ##
  # プロジェクト管理機能 登録・編集（関連プロジェクト選択解除）
  # GET /prj/projects/on_click_related_project_delete
  #
  def on_click_related_project_delete
    # プロジェクト情報を取得
    if params[:project_id].present? && params[:project_id] != ''
      begin
        @project = Project.find(params[:project_id])
      rescue
        add_error_message(t('errors.messages.no_data'))
        redirect_to prj_projects_path
        return
      end
    else
      @project = Project.new
    end
    
    @related_project_select_list_error = ''
    
    # 指定されたプロジェクトを関連プロジェクトリストから削除
    if params[:related_project_id].present?
      project = Project.where('id = ?', params[:related_project_id]).first
      if project.present?
        # セッション情報から指定された関連プロジェクトIDを削除
        session[:select_related_project_ids].delete(params[:related_project_id].to_i)
        session[:select_related_project_ids].uniq
      end
    end
    
    # 関連プロジェクト選択コントロールの表示
    set_related_project_select_control
    render
  end
  
  ##
  # プロジェクト管理機能 登録・編集（経費予算合計表示）
  # GET /prj/projects/on_click_expense_budget_total
  #
  def on_click_expense_budget_total
    # プロジェクト情報を取得
    if params[:project_id].present? && params[:project_id] != ''
      begin
        @project = Project.find(params[:project_id])
      rescue
        add_error_message(t('errors.messages.no_data'))
        redirect_to prj_projects_path
        return
      end
    else
      @project = Project.new
    end
    
    @related_project_select_list_error = ''
    
    @expense_budget_total = 0
    if params[:expense_budget_total].present?
      @expense_budget_total = params[:expense_budget_total]
    end
    
    render
  end
  
  ##
  # プロジェクト管理機能 登録・編集（販売原価追加）
  # GET /prj/projects/on_click_sales_cost_add
  #
  def on_click_sales_cost_add
    # プロジェクト情報を取得
    if params[:project_id].present? && params[:project_id] != ''
      begin
        @project = Project.find(params[:project_id])
      rescue
        add_error_message(t('errors.messages.no_data'))
        redirect_to prj_projects_path
        return
      end
    else
      @project = Project.new
    end
    
    # 販売原価の入力チェック
    if is_valid_sales_cost
      # セッション情報に現在編集中の販売原価情報を保存
      session[:edit_sales_costs] << ['', params[:sales_cost_item_name],
          params[:sales_cost_price], params[:sales_cost_tax_division_cd]]
    end
    
    # 販売原価編集コントロールの表示
    set_sales_cost_select_control
    render
  end
  
  ##
  # プロジェクト管理機能 登録・編集（販売原価削除）
  # GET /prj/projects/on_click_sales_cost_delete
  #
  def on_click_sales_cost_delete
    # プロジェクト情報を取得
    if params[:project_id].present? && params[:project_id] != ''
      begin
        @project = Project.find(params[:project_id])
      rescue
        add_error_message(t('errors.messages.no_data'))
        redirect_to prj_projects_path
        return
      end
    else
      @project = Project.new
    end
    
    # 指定された販売原価を販売原価リストから削除
    if params[:sales_cost_index].present?
      # セッション情報から指定された販売原価を削除
      session[:edit_sales_costs].delete_at(params[:sales_cost_index].to_i)
      
      # 販売原価入力エラーメッセージのリセット
      reset_sales_cost_valid_error
    end
    
    # 販売原価編集コントロールの表示
    set_sales_cost_select_control
    render
  end
  
  # 以下、プライベートメソッド
private
  
  ##
  # ログインユーザが新規作成可能か
  #
  # 戻り値::
  #   ログインユーザがシステム管理者かマネージャーの場合、trueを返す。
  # 
  def creatable?
    return administrator? || manager?
  end
  
  ##
  # ログインユーザが閲覧可能か
  #
  # project:
  #   対象プロジェクトのARインスタンス
  # 戻り値::
  #   ログインユーザがシステム管理者かマネージャー、または、
  #   対象プロジェクトのメンバー、プロジェクトリーダー、または
  #   プロジェクトマネージャーの場合、trueを返す。
  # 
  def viewable?(project)
    return true if (administrator? || manager?)
    return (project.project_member?(current_user) ||
            project.project_leader?(current_user) ||
            project.project_manager?(current_user))
  end
  
  ##
  # ログインユーザが編集可能か
  #
  # project:
  #   対象プロジェクトのARインスタンス
  # 戻り値::
  #   対象プロジェクトの状態が完了、かつ、論理削除されてなく、
  #   ログインユーザがシステム管理者またはマネージャか、
  #   対象プロジェクトのプロジェクトリーダー、または
  #   プロジェクトマネージャーの場合、trueを返す。
  # 
  def editable?(project)
    return false if project.deleted? || project.finished?
    return (administrator? || manager? ||
            project.project_leader?(current_user) ||
            project.project_manager?(current_user))
  end
  
  ##
  # ログインユーザが削除可能か
  #
  # project:
  #   対象プロジェクトのARインスタンス
  # 戻り値::
  #   対象プロジェクトが論理削除されてなく、
  #   ログインユーザがシステム管理者か、またはマネージャー、または
  #   対象プロジェクトのプロジェクトマネージャーの場合、trueを返す。
  # 
  def deletable?(project)
    return false if project.deleted?
    return (administrator? || manager? ||
            project.project_manager?(current_user))
  end
  
  ##
  # ログインユーザが復活可能か
  #
  # project:
  #   対象プロジェクトのARインスタンス
  # 戻り値::
  #   対象プロジェクトが論理削除されていて、
  #   ログインユーザがシステム管理者か、またはマネージャー、または
  #   対象プロジェクトのプロジェクトマネージャーの場合、trueを返す。
  # 
  def restorable?(project)
    return false unless project.deleted?
    return (administrator? || manager? ||
            project.project_manager?(current_user))
  end
  
  ##
  # ログインユーザがロック可能か
  #
  # project:
  #   対象プロジェクトのARインスタンス
  # 戻り値::
  #   対象プロジェクトの状態が進行中以外、かつ、論理削除されてなく、
  #   ロック解除された状態で、
  #   ログインユーザがシステム管理者か、またはマネージャー、または
  #   対象プロジェクトのプロジェクトマネージャーの場合、trueを返す。
  # 
  def lockable?(project)
    return false if project.locked?
    return false if project.deleted? || !project.in_progress?
    return (administrator? || manager? ||
            project.project_manager?(current_user))
  end
  
  ##
  # ログインユーザがロック解除可能か
  #
  # project:
  #   対象プロジェクトのARインスタンス
  # 戻り値::
  #   対象プロジェクトの状態が進行中以外、かつ、論理削除されてなく、
  #   ロックされた状態で、
  #   ログインユーザがシステム管理者か、またはマネージャー、または
  #   対象プロジェクトのプロジェクトマネージャーの場合、trueを返す。
  # 
  def unlockable?(project)
    return false unless project.locked?
    return false if project.deleted? || !project.in_progress?
    return (administrator? || manager? ||
            project.project_manager?(current_user))
  end
  
  ##
  # ログインユーザが開始可能か
  #
  # project:
  #   対象プロジェクトのARインスタンス
  # 戻り値::
  #   対象プロジェクトの状態が準備中、かつ、論理削除されてなく、
  #   ログインユーザがシステム管理者か、
  #   対象プロジェクトのプロジェクトマネージャーの場合、trueを返す。
  # 
  def statable?(project)
    return false if project.deleted? || !project.in_preparation?
    return (administrator? ||
            project.project_manager?(current_user))
  end
  
  ##
  # ログインユーザが完了可能か
  #
  # project:
  #   対象プロジェクトのARインスタンス
  # 戻り値::
  #   対象プロジェクトの状態が進行中、かつ、論理削除されてなく、
  #   ログインユーザがシステム管理者か、
  #   対象プロジェクトのプロジェクトマネージャーの場合、trueを返す。
  # 
  def finishable?(project)
    return false if project.deleted? || !project.in_progress?
    return (administrator? ||
            project.project_manager?(current_user) ||
            project.project_leader?(current_user))
  end
  
  ##
  # ログインユーザが再開可能か
  #
  # project:
  #   対象プロジェクトのARインスタンス
  # 戻り値::
  #   対象プロジェクトの状態が完了中、かつ、論理削除されてなく、
  #   ログインユーザがシステム管理者か、
  #   対象プロジェクトのプロジェクトマネージャーの場合、trueを返す。
  # 
  def restartable?(project)
    return false if project.deleted? || !project.finished?
    return (administrator? ||
            project.project_manager?(current_user) ||
            project.project_leader?(current_user))
  end
  
  ##
  # 工数集計出力が可能か
  #
  # 戻り値::
  #   ログインユーザがシステム管理者かマネージャーの場合、trueを返す。
  # 
  def outputtable_man_days?
    return administrator? || manager?
  end
  
  ## 
  # セッション情報から現在選択中のリストを取得する
  #
  # 戻り値::
  #   セッション情報から取得したリストを返す
  #
  def get_select_list_from_session(session, model)
    lists = []
    unless session.blank?
      session.each do |id|
        object = model.where('id = ?', id).first
        if object.present?
          lists << object
        end
      end
    end
    return lists
  end
  
  ## 
  # プロジェクトメンバー選択コントロールの表示
  #
  def set_prj_member_select_control
    # 部署ユーザリストを取得
    @section_id = 0
    @member_select_users = []
    if params[:section_id].present? && params[:section_id] != '0'
      @section_id = params[:section_id].to_i
      
      section = Section.where('id = ?', @section_id).first
      if section.present?
        @member_select_users = User.user_list_by_section_id(section.id)
      end
    else
      @member_select_users = User.user_list_by_section_id(@section_id)
    end
    
    # 削除されているユーザでも既にメンバーにDB登録済みの場合、リストに追加
    unless @project.new_record?
      members = PrjMember
          .where('project_id = ? AND users.deleted = ? AND users.section_id = ?',
              @project.id, true, ((@section_id == 0)? nil : @section_id))
          .includes(:user)
      if members.present?
        members.each do |member|
          user = User.where('id = ?', member.user_id).first
          @member_select_users << user if user.present?
        end
      end
    end
    
    # セッション情報から現在選択中のプロジェクトメンバーリストを作成
    prj_member_users = []
    @project_prj_members = []
    @prj_member_total = 0
    @direct_labor_cost_budget = 0
    unless session[:select_prj_members].blank?
      session[:select_prj_members].each do |item|
        user = User.where('id = ?', item[0]).first
        if user.present?
          prj_member= nil
          if @project.new_record?
            prj_member = PrjMember.new
          else
            if @project.project_member?(user)
              prj_member = PrjMember.where(:project_id => @project.id, :user_id => item[0])
                                    .first
              prj_member.project_id = @project.id
            else
              prj_member = PrjMember.new
              prj_member.user_id = item[0].to_i 
              prj_member.project_id = @project.id
            end
          end
          prj_member_users << user
          
          prj_member.user_id = item[0]
          prj_member.planned_man_days = item[1]
          @project_prj_members << prj_member
          
          @prj_member_total += item[1].to_f
          @direct_labor_cost_budget += (item[1].to_f * UnitPrice.unit_price(item[0]))
        end
      end
    end
    
    # 部署ユーザリストから現在選択中のプロジェクトメンバーを削除
    @member_select_users = get_diff_arrays(@member_select_users, prj_member_users)
    @member_select_users_list =
        @member_select_users.map{|user| [user.name, user.id]}
  end
  
  ## 
  # 関連プロジェクト選択コントロールの表示
  #
  def set_related_project_select_control
    # プロジェクトリストを取得
    @related_project_status_cd = STATUS_CODE[:preparation]
    @related_project_select_list = []
    if params[:related_project_status_cd].present?
      @related_project_status_cd = params[:related_project_status_cd].to_i
      
      @related_project_select_list =
          get_related_project_select_list(@related_project_status_cd)
    end
    
    # セッション情報から現在選択中のプロジェクトメンバーリストを作成
    related_projects =
        get_select_list_from_session(session[:select_related_project_ids], Project)
    
    @project_prj_related_projects = []
    related_projects.each{|related_project|
      prj_related_project = nil
      if @project.id.present?
        prj_related_project =
            PrjRelatedProject.where(:project_id => @project.id,
                                    :related_project_id => related_project.id)
                             .first
      end
      if prj_related_project.nil?
        prj_related_project = PrjRelatedProject.new
        prj_related_project.project_id = @project.id
        prj_related_project.related_project_id = related_project.id
      end
      
      @project_prj_related_projects << prj_related_project
    }
    
    # プロジェクトリストから現在選択中の関連プロジェクトを削除
    related_projects_list = []
    related_projects.each do |related_project|
      related_projects_list << [related_project.name, related_project.id]
    end
    @related_project_select_list =
        get_diff_arrays(@related_project_select_list, related_projects_list)
  end
  
  ## 
  # 関連プロジェクト選択用プロジェクトリストを取得する
  #
  # 戻り値::
  #   関連プロジェクト選択用プロジェクトリストを返す
  #
  def get_related_project_select_list(status_cd)
    project_list = []
    project_list = Project.projects_list({:include_deleted_project => false,
        :include_finished_project => false, :status_cd => status_cd})
    
    # 編集中の場合
    unless !@project.present? || @project.new_record?
      # そのプロジェクトは除外する
      project_list.delete_if {|name, id| id == @project.id}
      
      # 削除済みプロジェクトが関連プロジェクトに登録されていた場合、そのプロジェクトをリストに含める
      @project.prj_related_projects.each do |prj_related_project|
        projects = Project.where('id = ?', prj_related_project.related_project_id)
        projects.each do |project|
          if project.present? && project.deleted && project.status_cd == status_cd
            Project.add_to_list(project_list, prj_related_project.related_project_id)
          end
        end
      end
    end
    return project_list
  end
  
  ## 
  # 販売原価編集コントロールの表示
  #
  def set_sales_cost_select_control
    # セッション情報から現在編集中の販売原価リストを作成
    prj_sales_costs = []
    if session[:edit_sales_costs].present?
      prj_sales_costs = session[:edit_sales_costs]
    end
    
    @project_prj_sales_costs = []
    prj_sales_costs.each{|sales_cost|
      if sales_cost[0].present?
        prj_sales_cost = PrjSalesCost.find(sales_cost[0])
      else
        prj_sales_cost = PrjSalesCost.new
      end
      prj_sales_cost.item_name = sales_cost[1]
      prj_sales_cost.price = sales_cost[2].to_i
      prj_sales_cost.tax_division_id = sales_cost[3].to_i
      @project_prj_sales_costs << prj_sales_cost
    }
    
    # 販売原価の合計
    @sales_costs_total =
        PrjWorkType.totalize_tax_excluded_sales_cost(@project_prj_sales_costs)
  end
  
  ## 
  # 販売原価入力エラーメッセージのリセット
  #
  def reset_sales_cost_valid_error
    @sales_cost_item_name_error = ''
    @sales_cost_price_error = ''
    @sales_cost_tax_division_cd_error = ''
  end
  
  ## 
  # 販売原価追加時の入力チェック
  #
  # 戻り値::
  #   入力チェックの結果を返す（True=エラーなし/False=エラーあり）
  #
  def is_valid_sales_cost
    error_flag = true
    
    # 販売原価入力エラーメッセージのリセット
    reset_sales_cost_valid_error
    
    # == 入力チェック ==
    # 品目名
    if params[:sales_cost_item_name].present?
      if params[:sales_cost_item_name].bytesize > 40
        error_flag = false
        @sales_cost_item_name_error = '品目名は40文字以内で入力してください。'
      end
    else
      error_flag = false
      @sales_cost_item_name_error = '品目名を入力してください。'
    end
    # 価格
    if params[:sales_cost_price].present?
      unless params[:sales_cost_price] =~ /^[0-9]+$/
        error_flag = false
        @sales_cost_price_error = '価格は数値で入力してください。'
      end
    else
      error_flag = false
      @sales_cost_price_error = '価格を入力してください。'
    end
    # 税区分
    if params[:sales_cost_tax_division_cd].present?
      unless TaxDivision.where(:id => params[:sales_cost_tax_division_cd]).exists?
        error_flag = false
        @sales_cost_tax_division_cd_error =
            "税区分(code=#{params[:sales_cost_tax_division_cd]})" + 
            t('errors.messages.not_exist')
      end
    else
      error_flag = false
      @sales_cost_tax_division_cd_error = '税区分を選択してください。'
    end
    
    return error_flag
  end
  
  ## 
  # 商談管理案件リストを取得する
  #
  # 戻り値::
  #   商談管理案件リストを返す
  #
  def get_deals_list(project_id = nil)
    deals_list = []
    
    # 受注決定以前の商談管理案件リスト
    before_order_decision_deal =
        Deal.deals_list({:only_before_order_decision_deal => true,
                         :only_prj_managed_deal => true})
    
    # 他プロジェクトに登録済みの商談管理案件を除外
    before_order_decision_deal.each do |deal|
      unless Project.exist_deal_id(project_id, deal[1])
        deals_list << deal
      end
    end
    
    return deals_list
  end
  
  ## 
  # DBからプロジェクトメンバー選択用データを取得する（プロジェクト編集画面、要員変更画面用）
  #   メソッド内で下記の変数を更新
  #     @member_select_users::
  #       プロジェクトメンバー選択用のユーザリスト
  #     @project_prj_members::
  #       現在選択中のプロジェクトメンバーリスト
  #     @prj_member_total::
  #       予定工数合計値
  #     @direct_labor_cost_budget::
  #       直接労務費予算
  #
  def create_prj_members_from_db
    # プロジェクトメンバー選択用のユーザリスト
    @member_select_users = User.user_list_by_section_id(0)
    @member_select_users_list =
        @member_select_users.map{|user| [user.name, user.id]}
    
    # 現在選択中のプロジェクトメンバーIDをセッション情報に保存
    session[:select_prj_members] = []
    prj_member_users = []
    @project_prj_members = @project.prj_members
    @prj_member_total = 0
    @direct_labor_cost_budget = 0
    @project.prj_members.each{|member|
      user = User.where('id = ?', member.user_id).first
      if user.present?
        session[:select_prj_members] << [user.id, member.planned_man_days.to_f]
        prj_member_users << user
        
        @prj_member_total += member.planned_man_days
        @direct_labor_cost_budget +=
            UnitPrice.unit_price(member.user_id) * member.planned_man_days
      end
    }
    session[:select_prj_members].uniq
    
    # プロジェクトメンバー選択用のユーザリストから現在選択中のプロジェクトメンバーを削除
    @member_select_users = get_diff_arrays(@member_select_users, prj_member_users)
    @member_select_users_list =
        @member_select_users.map{|user| [user.name, user.id]}
  end
  
  ## 
  # DBから工数編集用データを取得する（プロジェクト編集画面用）
  #   メソッド内で下記の変数を更新
  #     @work_types::
  #       ビュー表示用工数リスト
  #     @project_prj_work_types::
  #       プロジェクト作業工程リスト
  #     @planned_man_days_total::
  #       社内工数合計値
  #     @presented_man_days_total::
  #       客先工数合計値
  #     @progress_rate_total::
  #       プロジェクト全体の進捗率
  #
  def create_prj_work_types_from_db
    office_job_work_types = WorkType.where('office_job = ?', false)
    @work_types = []
    office_job_work_types.each_with_index do |work_types_data, index|
      prj_work_type = nil
      @project.prj_work_types.each do |work_type|
        if work_types_data.id == work_type.work_type_id
          prj_work_type =  work_type
          prj_work_type.work_type_check = index.to_s
          break
        end
      end
      unless prj_work_type.present?
        prj_work_type = PrjWorkType.new
        prj_work_type.work_type_id = work_types_data.id
        prj_work_type.work_type_check = nil
      end
      @work_types << prj_work_type
    end
    
    # 工数の合計
    @planned_man_days_total = @project.totalize_planned_man_days
    @presented_man_days_total = @project.totalize_presented_man_days
    @progress_rate_total = @project.totalize_progress_rate
  end
  
  ## 
  # DBから販売原価編集用データを取得する（プロジェクト編集画面用）
  #   メソッド内で下記の変数を更新
  #     @project_prj_sales_costs::
  #       販売原価リスト
  #     @sales_costs_total::
  #       販売原価合計値
  #
  def create_prj_sales_costs_from_db
    # 税種別が外税の税区分リストを取得し、最初の項目を税区分の初期値とする
    @sales_cost_tax_division_cd = TaxDivision.tax_exclusive_first_id
    
    # 現在編集中の販売原価をセッション情報に保存
    @project_prj_sales_costs = @project.prj_sales_costs
    session[:edit_sales_costs] = []
    @project.prj_sales_costs.each{|sales_cost|
      session[:edit_sales_costs] << [sales_cost.id,
                                     sales_cost.item_name,
                                     sales_cost.price,
                                     sales_cost.tax_division_id]
    }
    
    # 販売原価の合計
    @sales_costs_total =
        PrjWorkType.totalize_tax_excluded_sales_cost(@project.prj_sales_costs)
  end
  
  ## 
  # DBから関連プロジェクト編集用データを取得する（プロジェクト編集画面用）
  #   メソッド内で下記の変数を更新
  #     @related_project_select_list::
  #       関連プロジェクト選択用のプロジェクトリスト
  #     @project_prj_sales_costs::
  #       関連プロジェクトリスト
  #
  def create_prj_related_projects_from_db
    # 関連プロジェクト選択用のプロジェクトリスト
    @related_project_select_list =
        get_related_project_select_list(@related_project_status_cd)
    
    # 現在選択中の関連プロジェクトIDをセッション情報に保存
    session[:select_related_project_ids] = []
    related_projects_list = []
    @project_prj_related_projects = @project.prj_related_projects
    @project_prj_related_projects.each{|related_project|
      project = Project.where('id = ?', related_project.related_project_id).first
      if project.present?
        session[:select_related_project_ids] << project.id
        related_projects_list << [project.name, project.id]
      end
    }
    session[:select_related_project_ids].uniq
    
    # プロジェクトリストから現在選択中の関連プロジェクトを削除
    @related_project_select_list =
        get_diff_arrays(@related_project_select_list, related_projects_list)
  end
  
  ## 
  # attributesからプロジェクトメンバー選択用データを取得する
  #   メソッド内で下記の変数を更新
  #     @project_attributes::
  #       DB作成/更新用attributes
  #     @member_select_users::
  #       プロジェクトメンバー選択用のユーザリスト
  #     @project_prj_members::
  #       現在選択中のプロジェクトメンバーリスト
  #     @prj_member_total::
  #       予定工数合計値
  #     @error_messages_list
  #       エラーメッセージリスト
  #
  # attributes::
  #   プロジェクトメンバーPOSTデータ
  # 
  def create_prj_members_from_attributes(attributes)
    # プロジェクトメンバー選択用のユーザリスト
    @member_select_users = User.user_list_by_section_id(0)
    @member_select_users_list =
        @member_select_users.map{|user| [user.name, user.id]}
    
    # 現在選択中のプロジェクトメンバーリストを作成
    @project_prj_members = []
    prj_member_users = []
    @prj_member_total = 0
    if attributes.present?
      attributes.each do |prj_members_attribute|
        member_param = attributes.fetch(prj_members_attribute[0])
        
        user = User.where('id = ?', member_param[:user_id]).first
        if user.present?
          is_user_include = true
          if user.deleted?
            if action_name == 'create'
              # 新規作成処理の場合、プロジェクトメンバーリストに含めない
              is_user_include = false
              
              # 新規作成処理で選択されたユーザーが削除されていた場合、@project_attributesから除去
              prj_members_attributes =
                  @project_attributes[:prj_members_attributes].reject{|value|
                value == index.to_s
              }
              @project_attributes[:prj_members_attributes] = prj_members_attributes
            else
              unless @project.project_member?(user)
                # 新規作成処理以外で、選択されたユーザーが削除されていた場合、
                # そのユーザーが元プロジェクトメンバーでなければプロジェクトメンバーリストに含めない
                is_user_include = false
              end
            end
          end
          
          # 入力チェック
          is_valid_essential_number(member_param[:planned_man_days],
              t('activerecord.attributes.prj_members.planned_man_days'), false)
          
          if is_user_include
            prj_member = nil
            if member_param[:project_id].present? && member_param[:user_id].present?
              prj_member = PrjMember.where(:project_id => member_param[:project_id],
                                           :user_id => member_param[:user_id])
                                    .first
            end
            if prj_member.nil?
              prj_member = PrjMember.new
              prj_member.project_id = member_param[:project_id]
              prj_member.user_id = member_param[:user_id]
            end
            prj_member.planned_man_days = member_param[:planned_man_days]
            @project_prj_members << prj_member
            prj_member_users << user
            
            @prj_member_total += member_param[:planned_man_days].to_f
          else
            @error_messages_list << 
                "選択されたプロジェクトメンバー(id=#{member_param[:user_id]})" + 
                t('errors.messages.deleted')
          end
        else
          if action_name == 'create'
            # 新規作成処理で選択されたユーザーが存在しない場合、@project_attributesから除去
            prj_members_attributes =
                @project_attributes[:prj_members_attributes].reject{|value|
              value == index.to_s
            }
            @project_attributes[:prj_members_attributes] = prj_members_attributes
          end
          
          @error_messages_list << 
              "選択されたプロジェクトメンバー(id=#{member_param[:project_id]})" + 
              t('errors.messages.not_exist')
        end
      end
    end
    
    # プロジェクトメンバー選択用のユーザリストから現在選択中のプロジェクトメンバーを削除
    @member_select_users = get_diff_arrays(@member_select_users, prj_member_users)
    @member_select_users_list =
        @member_select_users.map{|user| [user.name, user.id]}
  end
  
  ## 
  # attributesから工数編集用データを取得する
  #   メソッド内で下記の変数を更新
  #     @project_attributes::
  #       DB作成/更新用attributes
  #     @work_types::
  #       ビュー表示用工数リスト
  #     @project_prj_work_types::
  #       プロジェクト作業工程リスト
  #     @planned_man_days_total::
  #       社内工数合計値
  #     @presented_man_days_total::
  #       客先工数合計値
  #     @progress_rate_total::
  #       プロジェクト全体の進捗率
  #     @error_messages_list
  #       エラーメッセージリスト
  # 
  # attributes::
  #   工数POSTデータ
  # 
  def create_prj_work_types_from_attributes(attributes)
    office_job_work_types = WorkType.where('office_job = ?', false)
    @work_types = []
    @project_prj_work_types = []
    @planned_man_days_total = 0
    @presented_man_days_total = 0
    @progress_rate_total = 0
    progress_rate = []
    office_job_work_types.each_with_index do |work_types_data, index|
      if attributes.present?
        for i in 0..office_job_work_types.size-1 do
          if attributes[i.to_s].present?
            work_type_param = attributes.fetch(i.to_s)
            
            prj_work_type = nil
            if work_type_param[:project_id].present? && work_type_param[:work_type_id].present?
              prj_work_type = PrjWorkType.where(:project_id => work_type_param[:project_id],
                                                :work_type_id => work_type_param[:work_type_id])
                                         .first
            end
            if prj_work_type.nil?
              prj_work_type = PrjWorkType.new
              prj_work_type.work_type_id = work_types_data.id
            end
            
            if work_types_data.id == work_type_param[:work_type_id].to_i
              is_valid_essential_number(work_type_param[:planned_man_days],
                  t('activerecord.attributes.prj_work_types.planned_man_days'), false)
              is_valid_essential_number(work_type_param[:presented_man_days],
                  t('activerecord.attributes.prj_work_types.presented_man_days'), false)
              if action_name == 'update'
                is_valid_essential_number(work_type_param[:progress_rate],
                    t('activerecord.attributes.prj_work_types.progress_rate'), false)
              end
              
              # 工程の有無チェックがOn,または社内予定工数、客先提示工数が０以上の場合、管理対象とする
              if work_type_param[:work_type_check].present? ||
                  work_type_param[:planned_man_days].to_f > 0 ||
                  work_type_param[:presented_man_days].to_f > 0
                prj_work_type.planned_man_days =
                    work_type_param[:planned_man_days]
                prj_work_type.presented_man_days =
                    work_type_param[:presented_man_days]
                if action_name == 'update'
                  prj_work_type.progress_rate =
                    work_type_param[:progress_rate]
                end
                prj_work_type.work_type_check = index.to_s
                @project_prj_work_types << prj_work_type
                
                @planned_man_days_total += work_type_param[:planned_man_days].to_f
                @presented_man_days_total += work_type_param[:presented_man_days].to_f
                if action_name == 'update'
                  if work_type_param[:planned_man_days].to_f == 0 &&
                      work_type_param[:progress_rate].to_f != 0
                    @error_messages_list <<
                        "#{t('activerecord.attributes.prj_work_types.planned_man_days')}が0の工程に進捗率は入力できません。"
                  else
                    progress_rate << work_type_param[:planned_man_days].to_f * work_type_param[:progress_rate].to_f
                  end
                end
              else
                # 管理対象でない場合、@project_attributesから除去
                @project_attributes[:prj_work_types_attributes].delete(i.to_s)
              end
              break
            end
            
            # 工程の有無を@project_attributesから除去
            @project_attributes[:prj_work_types_attributes][i.to_s].delete('work_type_check')
          end
        end
      end
      @work_types << prj_work_type
      
      # プロジェクト全体の進捗率
      if action_name == 'update'
        progress_rate.each do |rate|
          @progress_rate_total += rate / @planned_man_days_total if rate != 0
        end
      end
    end
    
    # 作業工程の存在チェック
    if attributes.present?
      for i in 0..params[:project][:prj_work_type_size].to_i-1
        if attributes[i.to_s].present?
          work_type_param = attributes.fetch(i.to_s)
          
          work_type = WorkType.where('id = ? AND office_job = ?',
              work_type_param[:work_type_id].to_i, false).first
          unless work_type.present?
            if action_name == 'create'
              # 選択された作業工程が存在しない場合、@project_attributesから除去
              @project_attributes[:prj_work_types_attributes].delete(i.to_s)
            end
            
            @error_messages_list <<
                "選択された作業工程(id=#{work_type_param[:work_type_id]})" +
                t('errors.messages.not_exist')
          end
        end
      end
    end
  end
  
  ## 
  # attributesから経費予算編集用データを取得する
  #   メソッド内で下記の変数を更新
  #     @project_prj_expense_budgets::
  #       経費予算リスト
  #     @expense_budget_total::
  #       経費予算合計値
  #     @error_messages_list
  #       エラーメッセージリスト
  # 
  # attributes::
  #   経費予算POSTデータ
  # 
  def create_prj_expense_budgets_from_attributes(attributes)
    @expense_budget_total = 0
    @project_prj_expense_budgets = []
    if attributes.present?
      attributes.each_with_index do |expense_budget, index|
        expense_budget_param = attributes.fetch(index.to_s)
        
        # 入力チェック
        is_valid_essential_number(expense_budget_param[:expense_budget],
            t('activerecord.attributes.prj_expense_budgets.expense_budget'), true)
        
        prj_expense_budget = nil
        if expense_budget_param[:project_id].present? &&
            expense_budget_param[:expense_item_cd].present?
          prj_expense_budget =
              PrjExpenseBudget.where(:project_id => expense_budget_param[:project_id],
                                     :expense_item_cd => expense_budget_param[:expense_item_cd])
                              .first
        end
        if prj_expense_budget.nil?
          prj_expense_budget = PrjExpenseBudget.new
        end
        prj_expense_budget.project_id = expense_budget_param[:project_id]
        prj_expense_budget.expense_item_cd = expense_budget_param[:expense_item_cd]
        prj_expense_budget.expense_budget = expense_budget_param[:expense_budget]
        @project_prj_expense_budgets << prj_expense_budget
        @expense_budget_total += expense_budget_param[:expense_budget].to_i
      end
    end
  end
  
  ## 
  # attributesから販売原価編集用データを取得する
  #   メソッド内で下記の変数を更新
  #     @project_prj_sales_costs::
  #       販売原価リスト
  #     @sales_costs_total::
  #       販売原価合計値
  #     @sales_cost_tax_division_cd::
  #       税区分ID
  #     @error_messages_list
  #       エラーメッセージリスト
  # 
  # attributes::
  #   販売原価POSTデータ
  # 
  def create_prj_sales_costs_from_attributes(attributes)
    # 税種別が外税の税区分リストを取得し、最初の項目を税区分の初期値とする
    @sales_cost_tax_division_cd = TaxDivision.tax_exclusive_first_id
    
    @project_prj_sales_costs = []
    if attributes.present?
      attributes.each_with_index do |sales_cost_data, index|
        sales_cost_param = attributes.fetch(index.to_s)
        
        tax_division = TaxDivision
            .where('id = ?', sales_cost_param[:tax_division_id]).first
        if tax_division.present?
          sales_cost = nil
          if sales_cost_param[:id].present?
            sales_cost = PrjSalesCost.where(:id => sales_cost_param[:id]).first
          end
          if sales_cost.present?
            sales_cost.item_name = sales_cost_param[:item_name]
            sales_cost.price = sales_cost_param[:price]
            sales_cost.tax_division_id = sales_cost_param[:tax_division_id]
          else
            sales_cost = PrjSalesCost.new
            sales_cost.project_id = sales_cost_param[:project_id]
            sales_cost.item_name = sales_cost_param[:item_name]
            sales_cost.price = sales_cost_param[:price]
            sales_cost.tax_division_id = sales_cost_param[:tax_division_id]
          end
          @project_prj_sales_costs << sales_cost
        else
          # 選択された税区分が存在しない場合、@project_attributesから除去
          prj_sales_costs_attributes =
              @project_attributes[:prj_sales_costs_attributes].reject{|value|
            value == index.to_s
          }
          @project_attributes[:prj_sales_costs_attributes] = prj_sales_costs_attributes
          
          @error_messages_list << 
              "選択された税区分(id=#{sales_cost_param[:tax_division_id]})" + 
              t('errors.messages.not_exist')
        end
      end
    end
    
    # 販売原価の合計
    @sales_costs_total =
        PrjWorkType.totalize_tax_excluded_sales_cost(@project_prj_sales_costs)
  end
  
  ## 
  # attributesから関連プロジェクト編集用データを取得する
  #   メソッド内で下記の変数を更新
  #     @related_project_select_list::
  #       関連プロジェクト選択用プロジェクトリスト
  #     @project_prj_related_projects::
  #       関連プロジェクトリスト
  #     @error_messages_list
  #       エラーメッセージリスト
  # 
  # attributes::
  #   関連プロジェクトPOSTデータ
  # 
  def create_prj_related_projects_from_attributes(attributes)
    # 関連プロジェクト選択用のプロジェクトリスト
    @related_project_select_list =
        get_related_project_select_list(@related_project_status_cd)
    
    # 現在選択中の関連プロジェクトリストを作成
    @project_prj_related_projects = []
    related_projects_list = []
    if attributes.present?
      attributes.each_with_index do |related_project_data, index|
        related_project_param = attributes.fetch(index.to_s)
        
        project = Project
            .where('id = ?', related_project_param[:related_project_id])
            .first
        if project.present?
          related_project = nil
          if related_project_param[:project_id].present? &&
              related_project_param[:related_project_id].present?
            related_project =
                PrjRelatedProject.where(:project_id => related_project_param[:project_id],
                                        :related_project_id => related_project_param[:related_project_id])
                                 .first
          end
          if related_project.nil?
            related_project = PrjRelatedProject.new
            related_project.project_id = related_project_param[:project_id]
            related_project.related_project_id =
                related_project_param[:related_project_id]
          end
          
          @project_prj_related_projects << related_project
          
          related_projects_list << [project.name, project.id]
        else
          @error_messages_list <<
              "選択されたプロジェクト(id=#{related_project_param[:related_project_id]})" + 
              t('errors.messages.not_exist')
        end
      end
    end
    
    # プロジェクトリストから現在選択中の関連プロジェクトを削除
    @related_project_select_list =
        get_diff_arrays(@related_project_select_list, related_projects_list)
  end
  
  ## 
  # attributesからプロジェクトマネージャーデータをチェックする
  #   メソッド内で下記の変数を更新
  #     @error_messages_list
  #       エラーメッセージリスト
  # 
  # attributes::
  #   プロジェクトマネージャーPOSTデータ
  # 
  def check_manager_from_attributes(attributes)
    if attributes.present?
      manager = User.where(:id => params[:project][:manager_id]).first
      if manager.present?
        if manager.deleted? && !@project.project_manager?(manager)
          @error_messages_list <<
              "選択されたプロジェクトマネージャー(id=#{attributes})" + 
              t('errors.messages.deleted')
        end
      else
        @error_messages_list <<
            "選択されたプロジェクトマネージャー(id=#{attributes})" + 
            t('errors.messages.not_exist')
      end
    end
  end
  
  ## 
  # attributesからプロジェクトリーダーデータをチェックする
  #   メソッド内で下記の変数を更新
  #     @error_messages_list
  #       エラーメッセージリスト
  # 
  # attributes::
  #   プロジェクトリーダーPOSTデータ
  # 
  def check_leader_from_attributes(attributes)
    if attributes.present?
      leader = User.where(:id => params[:project][:leader_id]).first
      if leader.present?
        if leader.deleted? && !@project.project_leader?(leader)
          @error_messages_list <<
              "選択されたプロジェクトリーダー(id=#{attributes})" + 
              t('errors.messages.deleted')
        end
      else
        @error_messages_list <<
            "選択されたプロジェクトリーダー(id=#{attributes})" + 
            t('errors.messages.not_exist')
      end
    end
  end
  
  ## 
  # attributesから開発言語データをチェックする
  #   メソッド内で下記の変数を更新
  #     @project_attributes::
  #       DB作成/更新用attributes
  #     @error_messages_list
  #       エラーメッセージリスト
  # 
  # attributes::
  #   開発言語POSTデータ
  # 
  def check_prj_dev_languages_from_attributes(attributes)
    if attributes.present?
      attributes.each do |dev_language_id|
        dev_language =
            DevelopmentLanguage.where('id = ?', dev_language_id.to_i).first
        unless dev_language.present?
          if action_name == 'create'
            # 選択された開発言語が存在しない場合、@project_attributesから除去
            dev_language_attributes =
                @project_attributes[:development_language_ids].reject{|value|
              value == dev_language_id
            }
            @project_attributes[:development_language_ids] = dev_language_attributes
          end
          
          @error_messages_list <<
              "選択された開発言語(id=#{dev_language_id})" + t('errors.messages.not_exist')
        end
      end
    else
      # 全く選択されていない場合は空データにする
      @project_attributes[:development_language_ids] = []
    end
  end
  
  ## 
  # attributesからOSデータをチェックする
  #   メソッド内で下記の変数を更新
  #     @project_attributes::
  #       DB作成/更新用attributes
  #     @error_messages_list
  #       エラーメッセージリスト
  # 
  # attributes::
  #   OS POSTデータ
  # 
  def check_prj_operating_systems_from_attributes(attributes)
    if attributes.present?
      attributes.each do |os_id|
        os = OperatingSystem.where('id = ?', os_id.to_i).first
        unless os.present?
          if action_name == 'create'
            # 選択されたOSが存在しない場合、@project_attributesから除去
            os_attributes =
                @project_attributes[:operating_system_ids].reject{|value|
              value == os_id
            }
            @project_attributes[:operating_system_ids] = os_attributes
          end
          
          @error_messages_list << 
              "選択されたOS(id=#{os_id})" + t('errors.messages.not_exist')
        end
      end
    else
      # 全く選択されていない場合は空データにする
      @project_attributes[:operating_system_ids] = []
    end
  end
  
  ## 
  # attributesからデータベースデータをチェックする
  #   メソッド内で下記の変数を更新
  #     @project_attributes::
  #       DB作成/更新用attributes
  #     @error_messages_list
  #       エラーメッセージリスト
  # 
  # attributes::
  #   データベースPOSTデータ
  # 
  def check_prj_databases_from_attributes(attributes)
    if attributes.present?
      attributes.each do |database_id|
        database = Database.where('id = ?', database_id.to_i).first
        unless database.present?
          if action_name == 'create'
            # 選択されたデータベースが存在しない場合、@project_attributesから除去
            database_attributes = @project_attributes[:database_ids].reject{|value|
              value == database_id
            }
            @project_attributes[:database_ids] = database_attributes
          end
          
          @error_messages_list << 
              "選択されたデータベース(id=#{database_id})" + t('errors.messages.not_exist')
        end
      end
    else
      # 全く選択されていない場合は空データにする
      @project_attributes[:database_ids] = []
    end
  end
  
  ## 
  # 商談管理案件リストを取得
  #   現在選択されている商談管理案件も商談管理案件リストに追加
  # 
  # 戻り値::
  #   商談管理案件リスト
  # 
  def get_deals_list_include_selected_deal
    deals_list = get_deals_list
    if @project.deal_id.present?
      Deal.add_to_list(@deals_list, @project.deal_id)
    end
    return deals_list
  end
  
  ## 
  # プロジェクトマネージャーリストを取得
  #   論理削除されたユーザが選択されていた場合、プロジェクトマネージャーリストに追加
  # 
  # 戻り値::
  #   プロジェクトマネージャーリスト
  # 
  def get_managers_list_include_selected_user
    managers_list = User.users_list(
        :include_deleted_user => false, :include_parttimer_user => false)
    user = User.where('id = ?', @project.manager_id).first
    if user.present? && user.deleted && @project.project_manager?(user)
      User.add_to_list(managers_list, @project.manager_id)
    end
    return managers_list
  end
  
  ## 
  # プロジェクトリーダーリストを取得
  #   論理削除されたユーザが選択されていた場合、プロジェクトリーダーリストに追加
  # 
  # 戻り値::
  #   プロジェクトリーダーリスト
  # 
  def get_leaders_list_include_selected_user
    leaders_list = User.users_list(
        :include_deleted_user => false, :include_parttimer_user => false)
    user = User.where('id = ?', @project.leader_id).first
    if user.present? && user.deleted && @project.project_leader?(user)
      User.add_to_list(leaders_list, @project.leader_id)
    end
    return leaders_list
  end
  
  ## 
  # 必須入力数値のチェック
  #   メソッド内で下記の変数を更新
  #     @error_messages_list
  #       エラーメッセージリスト
  # 
  # value::
  #   入力チェック対象値
  # name::
  #   入力チェック対象項目名
  # is_integer::
  #   整数値かどうか
  # 
  # 戻り値::
  #   エラーがあるかどうか(true/false)
  # 
  def is_valid_essential_number(value, name, is_integer=true)
    is_error = false
    unless value.present?
      is_error = true
      @error_messages_list << (name + t('errors.messages.blank'))
      return is_error
    end
    
    if is_integer && !(value =~ /^[+-]?[0-9]*[\.]?[0]+$/)
      is_error = true
      @error_messages_list << (name + t('errors.messages.not_an_integer'))
      return is_error
    end
    
    if !is_integer && !(value =~ /^[+-]?[0-9]*[\.]?[0-9]+$/)
      is_error = true
        @error_messages_list << (name + t('errors.messages.not_a_number'))
      return is_error
    end
  end
end
