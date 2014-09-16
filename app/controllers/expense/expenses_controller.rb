# encoding: utf-8

#
#= Expense::Expensesコントローラクラス
#
# Authors:: 青山 ひろ子
# Created:: 2012/10/4
#
class Expense::ExpensesController < Expense::ExpenseController
  # フィルター設定
  before_filter :require_system_admin_or_manager_or_employee

  # コントローラのメソッドをviewでも使えるように設定
  helper_method :deputy_operable?

  ##
  # 経費管理機能 一覧画面
  # GET /expense/expenses
  #
  def index
    # 精算者の初期値をログインユーザに設定
    if params[:search].nil?
      params[:search] = Hash.new
      params[:search][:user_id] = current_user.id
      # プロジェクト状態の初期値を「準備中または進行中」に設定
      params[:search][:project_status_cd] =
          PROJECT_SEARCH_STATUS_CODE[:preparation_or_progress]
    end
    
    # 検索条件（プロジェクト名 部分一致）
    search_project_name_condition = {}
    if params[:search][:project_name].present?
      search_project_name_condition =
          "projects.name LIKE '%" + params[:search][:project_name] + "%'"
    end
    
    # 検索条件（プロジェクト状態）
    search_project_status_condition_base =
        'EXISTS(SELECT * FROM projects WHERE projects.id = expenses.project_id AND '
    search_project_status_condition = search_project_status_condition_base + 
        'deleted = ' + DB_FALSE_VALUE + ' AND ' +
        '(status_cd = ' + STATUS_CODE[:preparation].to_s +
        ' OR status_cd = ' + STATUS_CODE[:progress].to_s + '))'
    unless params[:search][:project_status_cd].blank?
      case params[:search][:project_status_cd]
        when PROJECT_SEARCH_STATUS_CODE[:not_include_deleted].to_s
          # 削除済み以外すべてのプロジェクト
          search_project_status_condition = search_project_status_condition_base + 
              'deleted = ' + DB_FALSE_VALUE + ')'
        when PROJECT_SEARCH_STATUS_CODE[:preparation_or_progress].to_s
          # プロジェクト状態が[準備中]、または[進行中]で論理削除されていないプロジェクト
          search_project_status_condition = search_project_status_condition_base + 
              'deleted = ' + DB_FALSE_VALUE + ' AND ' +
              '(status_cd = ' + STATUS_CODE[:preparation].to_s +
              ' OR status_cd = ' + STATUS_CODE[:progress].to_s + '))'
        when PROJECT_SEARCH_STATUS_CODE[:preparation].to_s
          # プロジェクト状態が[準備中]で論理削除されていないプロジェクト
          search_project_status_condition = search_project_status_condition_base + 
              'deleted = ' + DB_FALSE_VALUE + ' AND ' +
              'status_cd = ' + STATUS_CODE[:preparation].to_s + ')'
        when PROJECT_SEARCH_STATUS_CODE[:progress].to_s
          # プロジェクト状態が[進行中]で論理削除されていないプロジェクト
          search_project_status_condition = search_project_status_condition_base + 
              'deleted = ' + DB_FALSE_VALUE + ' AND ' +
              'status_cd = ' + STATUS_CODE[:progress].to_s + ')'
        when PROJECT_SEARCH_STATUS_CODE[:completed].to_s
          # プロジェクト状態が[完了]で論理削除されていないプロジェクト
          search_project_status_condition = search_project_status_condition_base + 
              'deleted = ' + DB_FALSE_VALUE + ' AND ' +
              'status_cd = ' + STATUS_CODE[:finished].to_s + ')'
        when PROJECT_SEARCH_STATUS_CODE[:deleted].to_s
          # 論理削除されたプロジェクト
          search_project_status_condition = search_project_status_condition_base + 
              'deleted = ' + DB_TRUE_VALUE + ')'
      end
    end
    
    # 期間検索用の条件配列を作成
    start_date = {}
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
        start_date = ["adjusted_date >= ?", start_date]
      end
    end
    
    end_date = {}
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
          end_date = ["adjusted_date <= ?", month_last_day]
        end
      end
    end
    
    # 代行入力時の表示制限用の検索条件配列を作成
    if !(administrator? || manager?) && params[:search][:user_id] != current_user.id
      only_my_project = [
        'expenses.user_id = ? OR ' +
        'EXISTS(SELECT * FROM projects' +
        ' WHERE projects.id = expenses.project_id' +
        ' AND (projects.leader_id = ? OR projects.manager_id = ?))',
        current_user.id, current_user.id, current_user.id]
    end
    
    # 検索条件により経費を検索
    @expenses =
      Expense.where(get_condition([:user_id, :expense_type_id]))
             .where(search_project_name_condition)
             .where(search_project_status_condition)
             .where(start_date)
             .where(end_date)
             .where(only_my_project)
             .includes(:project)
             .list_order
             .paginate(:page => params[:page], :per_page => EXPENSE_ITEMS_PER_PAGE)
    
    # 検索条件をセッション変数に保存
    session[:expense_condition] = params[:search]
  end
  
  ##
  # 経費管理機能 閲覧画面
  # GET /expense/expenses/1
  #
  def show
    begin
      @expense = Expense.find(params[:id])
    rescue
      add_error_message(t('errors.messages.no_data'))
      redirect_to expense_expenses_url
      return
    end
  end
  
  ##
  # 経費情報 新規作成処理
  # GET /expense/expenses/new
  #
  def new
    @expense = Expense.new
    # 各項目の初期値を設定
    @expense.user_id = current_user.id
    @expense.adjusted_date = Date.today
    # 税区分の初期値の取得
    expense_type = ExpenseType.order(:view_order).first
    if expense_type.present?
      @expense.tax_division_id = expense_type.tax_division_id
    end
  end
  
  ##
  # 経費管理機能 編集画面
  # GET /expense/expenses/1/edit
  #
  def edit
    begin
      @expense = Expense.find(params[:id])
    rescue
      add_error_message(t('errors.messages.no_data'))
      redirect_to expense_expenses_url
      return
    end
    # 代行入力時の権限チェック
    unless deputy_operable?(@expense)
      add_error_message(t('errors.messages.not_permitted'))
      redirect_to :top
      return
    end
    # 完了プロジェクトチェック
    if @expense.project_finished?
      add_error_message(finished_project_error_message(:expense, :edit))
      redirect_back_or_default(expense_expenses_url)
      return
    end
  end
  
  ##
  # 経費情報 新規作成処理
  # POST /expense/expenses
  #
  def create
    begin
      @expense = Expense.new(params[:expense])
      # 権限チェック
      unless deputy_operable?(@expense)
        raise t('errors.messages.not_permitted')
      end
      # 状態チェック
      if @expense.project_finished?
        raise(finished_project_error_message(:expense, :new))
      end
      @expense.save!
      redirect_to expense_expense_path(@expense),
          notice: t('common_label.model_was_created',
                    :model => Expense.model_name.human)
    rescue => ex
      set_error(ex, :expense, :save)
      render action: 'new'
      return
    end
  end
  
  ##
  # 経費情報 更新処理
  # PUT /expense/expenses/1
  #
  def update
    begin
      @expense = Expense.find(params[:id])
      # 権限チェック
      unless deputy_operable?(@expense)
        raise t('errors.messages.not_permitted')
      end
      # 状態チェック
      if @expense.project_finished?
        raise(finished_project_error_message(:expense, :edit))
      end
      @expense.update_attributes!(params[:expense])
      redirect_to expense_expense_path(@expense),
          notice: t('common_label.model_was_updated',
                    :model => Expense.model_name.human)
    rescue => ex
      set_error(ex, :expense, :save)
      render action: 'edit'
      return
    end
  end
  
  ##
  # 経費情報 削除処理
  # DELETE /expense/expenses/1
  #
  def destroy
    begin
      @expense = Expense.find(params[:id])
      # 権限チェック
      unless deputy_operable?(@expense)
        raise t('errors.messages.not_permitted')
      end
      # 状態チェック
      if @expense.project_finished?
        raise finished_project_error_message(:expense, :delete)
      end
      @expense.destroy
    rescue => ex
      set_error(ex, :expense, :delete, @expense.to_str)
    end
    redirect_to expense_expenses_url
  end
  
  ##
  # 経費種類変更時の処理
  # GET /expense/on_change_expense_type
  #
  def on_change_expense_type
    # デフォルト税区分IDを取得する
    @default_tax_division_id = nil
    if params[:expense_type_id].present?
      expense_type = ExpenseType.find(params[:expense_type_id])
      if expense_type.present?
        @default_tax_division_id = expense_type.tax_division_id
      end
    end
    render 
  end
  
  # 以下、プライベートメソッド
private

  ##
  # ログインユーザが代行入力可能か
  #
  # expense:
  #   経費のインスタンス
  # 戻り値::
  #   ログインユーザが精算者本人または代行入力可能な場合、trueを返す。
  # 
  def deputy_operable?(expense)
    return true if expense.user_id == current_user.id
    return true if (administrator? || manager?)
    project = expense.project
    return false if project.nil?
    return (project.project_leader?(current_user) ||
            project.project_manager?(current_user))
  end 

end
