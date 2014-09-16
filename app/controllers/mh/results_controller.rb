# encoding: utf-8

#
#= Mh::Resultsコントローラクラス
#
# Authors:: 兪　春芳
# Created:: 2012/12/11
#
class Mh::ResultsController < Mh::MhController

  # コントローラのメソッドをviewでも使えるように設定
  helper_method :can_modified_result?, :can_show_result?, :can_add_result_for_user?, :can_show_result_sum?

  ##
  # 工数実績管理機能 一覧画面
  # GET /mh/results
  #
  def index
    if params[:submit] == t('web-app-theme.csv_export')
      # CSV出力
      create_search_detail(false)
      csv_export
    else
      create_search_detail
    end
  end

  ##
  # 工数実績情報 新規作成処理
  # GET /mh/results/new
  #
  def new
    @result = Result.new
    @result.result_date = params[:result_date].blank? ? Date.today : Date.parse(params[:result_date])
    @result.project_id = params[:project_id] unless params[:project_id].blank?
    if administrator? || manager?
      @select_project_list = get_current_user_can_acccess_projects
    else
      @select_project_list = get_current_user_can_acccess_projects(include_internal: false)
    end
    @select_user_list = select_user_list
    if !administrator? && !manager? && project_manager?
      @select_user_list = current_user.my_relation_members_list
    end
    # 作業工程コントロールの設定
    set_work_type_select_control(params[:project_id])
    set_result_user_select_control(@result.project_id)

    # 当月の工数実績入力日リストを取得
    @result_date_list = Result.result_date_list(@current_user.id, @result.result_date)
  end

  ##
  # 工数実績管理機能 閲覧画面
  # GET /mh/results/1
  #
  def show
    @result = Result.find_by_id(params[:id])
    render(:file => File.join(Rails.root, 'public', '403'), :status => 403, :layout => false) unless can_show_result?(@result)
    
    # 当月の工数実績入力日リストを取得
    @result_date_list = Result.result_date_list(@current_user.id, @result.result_date)
  end

  ##
  # 工数実績管理機能 日付選択してから、閲覧画面
  # GET /mh/results/show_by_date?select_date=
  #
  def show_by_date
    select_date = Date.today
    select_date = Date.parse(params[:select_date]) unless params[:select_date].blank?
    user_id = current_user.id
    user_id = params[:user_id] unless params[:user_id].blank? 
    @result = Result.where(:user_id => user_id)
    .where(:result_date => select_date)
    .order('start_at ASC, end_at ASC').first
    unless @result.blank?
      redirect_to :action => 'show', :id => @result.id 
      return
    end
    @result = Result.new(:result_date => select_date)
    
    # 当月の工数実績入力日リストを取得
    @result_date_list = Result.result_date_list(@current_user.id, @result.result_date)
    render 'show'
  end

  ##
  # 工数実績管理機能 編集画面
  # GET /mh/results/1/edit
  #
  def edit
    p "================="
    p params[:from] && params[:from]
    @result = Result.find_by_id(params[:id])
    render(:file => File.join(Rails.root, 'public', '403'), :status => 403, :layout => false) unless can_modified_result?(@result)
    if administrator? || manager?
      @select_project_list = get_current_user_can_acccess_projects
    else
      @select_project_list = get_current_user_can_acccess_projects(include_internal: false)
    end
    
    # 作業開始時間と作業終了時間の初期値設定
    unless @result.start_at.blank?
      @result.start_at_hour = @result.start_at.strftime('%H')
      @result.start_at_minute = @result.start_at.strftime('%M')
    end
    unless @result.end_at.blank?
      @result.end_at_hour = @result.end_at.strftime('%H')
      @result.end_at_minute = @result.end_at.strftime('%M')
    end
    
    @select_user_list = select_user_list
    if !administrator? && !manager? && project_manager?
      @select_user_list = current_user.my_relation_members_list
    end

    # 作業工程コントロールの設定
    set_work_type_select_control(@result.project_id)

    set_result_user_select_control(@result.project_id)

    # 当月の工数実績入力日リストを取得
    @result_date_list = Result.result_date_list(@current_user.id, @result.result_date)
  end

  ##
  # 工数実績情報 新規作成処理
  # POST /mh/results
  #
  def create
    begin
      result_attributes = params[:result]
      
      # 開始時間と終了時間のデータ作成
      result_date = DateTime.parse(result_attributes[:result_date])
      if result_date.present?
        if result_attributes["start_at_hour"].present? && result_attributes["start_at_minute"].present?
          start_at = DateTime.new(result_date.year, result_date.month, result_date.day,
              result_attributes["start_at_hour"].to_i, result_attributes["start_at_minute"].to_i, 0)
          result_attributes[:start_at] = start_at.strftime('%Y%m%d%H%M%S')
        end
        if result_attributes["end_at_hour"].present? && result_attributes["end_at_minute"].present?
          end_at = DateTime.new(result_date.year, result_date.month, result_date.day,
              result_attributes["end_at_hour"].to_i, result_attributes["end_at_minute"].to_i, 0)
          result_attributes[:end_at] = end_at.strftime('%Y%m%d%H%M%S')
        end
        
        # 当月の工数実績入力日リストを取得
        @result_date_list = Result.result_date_list(@current_user.id, result_date)
      end
      
      # 工数実績情報のDB登録
      @result = Result.new(result_attributes)
      validate_success = @result.valid?
      validate_success = validate_selected_users(@result.user_id)
      if validate_success
        @result.save!
        
        if administrator? || manager?
          @select_project_list = get_current_user_can_acccess_projects
        else
          @select_project_list = get_current_user_can_acccess_projects(include_internal: false)
        end
        
        @select_user_list = select_user_list
        if !administrator? && !manager? && project_manager?
          @select_user_list = current_user.my_relation_members_list
        end
        redirect_to new_mh_result_path(:result_date => @result.result_date),
          notice: t('common_label.model_was_created', :model => Result.model_name.human)
      else
        raise 'validate error!' 
      end 
    end
  rescue Exception => e
    flash[:warning] = I18n.t('errors.messages.create_error', :model => Result.model_name.human)
    logger.error(e.message)
        
    if administrator? || manager?
      @select_project_list = get_current_user_can_acccess_projects
    else
      @select_project_list = get_current_user_can_acccess_projects(include_internal: false)
    end
    
    @select_user_list = select_user_list
    if !administrator? && !manager? && project_manager?
      @select_user_list = current_user.my_relation_members_list
    end
    # 作業工程コントロールの設定
    set_work_type_select_control(params[:result][:project_id])
    # ユーザーコントロールの設定
    set_result_user_select_control(params[:result][:project_id])
    render :new
  end
  ##
  # 工数実績情報 更新処理
  # PUT /mh/results/1
  #
  def update
    begin
      if administrator? || manager?
        @select_project_list = get_current_user_can_acccess_projects
      else
        @select_project_list = get_current_user_can_acccess_projects(include_internal: false)
      end
      
      @select_user_list = select_user_list
      if !administrator? && !manager? && project_manager?
        @select_user_list = current_user.my_relation_members_list
      end
      @result = Result.find(params[:id])
      result_attributes = params[:result]
      
      # 開始時間と終了時間のデータを一旦クリアし再度作成
      result_attributes[:start_at] = ""
      result_attributes[:end_at] = ""
      result_date = DateTime.parse(result_attributes[:result_date])
      if result_date.present?
        if result_attributes["start_at_hour"].present? && result_attributes["start_at_minute"].present?
          start_at = DateTime.new(result_date.year, result_date.month, result_date.day,
              result_attributes["start_at_hour"].to_i, result_attributes["start_at_minute"].to_i, 0)
          result_attributes[:start_at] = start_at.strftime('%Y%m%d%H%M%S')
        end
        if result_attributes["end_at_hour"].present? && result_attributes["end_at_minute"].present?
          end_at = DateTime.new(result_date.year, result_date.month, result_date.day,
              result_attributes["end_at_hour"].to_i, result_attributes["end_at_minute"].to_i, 0)
          result_attributes[:end_at] = end_at.strftime('%Y%m%d%H%M%S')
        end
        
        # 当月の工数実績入力日リストを取得
        @result_date_list = Result.result_date_list(@current_user.id, result_date)
      end
      
      @result.attributes = result_attributes
      validate_success = @result.valid?
      validate_success = validate_selected_users(@result.user_id)
      if validate_success
        @result.update_attributes!(result_attributes)
        redirect_to mh_result_path(@result),
          notice: t('common_label.model_was_updated',
          :model => Result.model_name.human)
      else
        raise 'validate error!'
      end
    rescue Exception => e
      flash[:warning] = I18n.t('errors.messages.update_error', :model => Result.model_name.human)
      logger.error(e.message)
      # 失敗の場合、登録画面に戻る
      if administrator? || manager?
        @select_project_list = get_current_user_can_acccess_projects
      else
        @select_project_list = get_current_user_can_acccess_projects(include_internal: false)
      end
    
      @select_user_list = select_user_list
      if !administrator? && !manager? && project_manager?
        @select_user_list = current_user.my_relation_members_list
      end
      # 作業工程コントロールの設定
      set_work_type_select_control(params[:result][:project_id])
      # ユーザーコントロールの設定
      set_result_user_select_control(params[:result][:project_id])
      
      render :edit
    end
  end

  ##
  # 工数実績情報 削除処理
  # DELETE /mh/results/1
  #
  def destroy
    @result = Result.find_by_id(params[:id])
    
    if can_modified_result?(@result)
      begin
        # 削除フラグのみ更新するとバリデーションエラーが発生するため、
        # 時間選択セレクトボックスの値（start_at_hour ～ end_at_minute）も渡して
        # 削除フラグを変更
        @result.update_attributes!(deleted: 1,
                                   start_at_hour: @result.start_at.strftime("%H"),
                                   start_at_minute: @result.start_at.strftime("%M"),
                                   end_at_hour: @result.end_at.strftime("%H"),
                                   end_at_minute: @result.end_at.strftime("%M"))
        flash[:notice] = I18n.t('common_label.model_was_deleted', :model => Result.model_name.human)
      rescue Exception => e
        flash[:warning] = I18n.t('errors.messages.delete_error', :model => Result.model_name.human)
        logger.error(e.message)
      end
    else
      flash[:warning] = I18n.t('errors.messages.not_permitted')
    end
    if Rails.application.routes.recognize_path(request.referrer)[:action] == 'index'
      redirect_to mh_results_path
    else
      redirect_to new_mh_result_path(:result_date => @result.result_date)
    end
  end

  ##
  # 工数実績管理機能 登録・編集（プロジェクトメンバー選択）
  # GET /mh/results/on_change_project_list
  #
  def on_change_project_list
    @result = Result.new
    @result.user_id = current_user.id

    # 作業工程コントロールの設定
    set_work_type_select_control(params[:project_id])
    
    # 工数実績グループ選択コントロールの表示
    #set_result_group_select_control(params[:project_id])
    
    # 工数実績ユーザー選択コントロールの表示
    set_result_user_select_control(params[:project_id])
   
    respond_to do |format|
      format.js { render :content_type => 'text/javascript' }
    end
  end

  ##
  # 工数実績管理機能 登録・編集（指定日付の工数実績の取得）
  # GET /mh/results/get_results_by_day
  #
  def get_results_by_day
    user_id = current_user.id
    user_id = @result.user_id unless @result.blank?
    select_date = Date.today
    select_date = Date.parse(params[:select_date]) unless params[:select_date].blank?
    @results = Result.where(:user_id => user_id)
    .where( "start_at >= ? and end_at <= ?", Time.at(params['start'].to_i), Time.at(params['end'].to_i) )
    .order('start_at ASC, end_at ASC').all;
    results = []
    @results.each do |result|
      results << { :id => result.id, 
        :title => result.project.name || '',
        :start => "#{result.start_at.iso8601}",
        :end => "#{result.end_at.iso8601}",
        :allDay => false, 
        :color => '#7985C5', 
        :recurring => false
      }
    end
    render :text => results.to_json
  end
  
  ##
  # 工数実績管理機能 個別集計（指定ユーザ、日付の工数実績の取得）
  # GET /mh/results/get_results_by_user_and_day
  #
  def get_results_by_user_and_day
    user_id = params[:user_id] unless params[:user_id].blank?
    select_date = Time.at(params['start'].to_i).strftime("%Y/%m/%d")
    @results = Result.where(:user_id => user_id)
    .where(:result_date => select_date)
    .order('start_at ASC, end_at ASC').all;
    results = []
    @results.each do |result|
      title = ""
      # 工程、備考も表示する
      if result.project.present?
        title = result.project.name + "(" + result.work_type_name
        title += ":" + result.notes if result.notes.present?
        title += ")"
      end
      # ツールチップ表示内容
      tooltip = "#{result.start_at.strftime("%H:%M")}～#{result.end_at.strftime("%H:%M")} #{title}"
      
      results << { :id => result.id, 
        :title => title,
        :tooltip => tooltip,
        :start => "#{result.start_at.iso8601}",
        :end => "#{result.end_at.iso8601}",
        :allDay => false,
        :color => '#7985C5',
        :recurring => false
      }
    end
    render :text => results.to_json
  end
  ##
  # 工数実績管理機能 集計画面
  # GET /mh/results/sum_by_group
  #
  def sum_by_group
    render(:file => File.join(Rails.root, 'public', '403'), :status => 403, :layout => false) unless can_show_result_sum?
    create_search_detail_sum_by_group
  end

  ##
  # 工数実績管理機能 個別集計画面
  # GET /mh/results/sum_by_user
  #
  def sum_by_user
    render(:file => File.join(Rails.root, 'public', '403'), :status => 403, :layout => false) unless can_show_result_sum?
    create_search_detail_sum_by_user
  end
  
  private
  ##
  # 検索処理
  # 
  # need_paginate::
  #  (true/false) 
  #
  def create_search_detail(need_paginate = true)
    # 初期の日付の設定
    params[:search] ||= { start_at: {year: Date.today.year, month: Date.today.month }, 
      end_at: {year: Date.today.year, month: Date.today.month } }
   
    relation  = Result
    if !administrator? && !manager?
      accessable_member_ids = []
      if project_manager?
        current_user.my_relation_members_list.each { |member| accessable_member_ids << member[1] }
      else
        # 一般社員または外注
        accessable_member_ids << current_user.id unless current_user.blank?
      end
      relation = relation.where('`results`.user_id in (?) ', accessable_member_ids)
    end
  
    unless params[:search][:start_at].blank?
      start_at = Date.civil(params[:search][:start_at][:year].to_i, params[:search][:start_at][:month].to_i).beginning_of_month
      relation = relation.where('`results`.result_date >= (?)', "#{start_at}")
    end
    unless params[:search][:end_at].blank?
      end_at = Date.civil(params[:search][:end_at][:year].to_i, params[:search][:end_at][:month].to_i).end_of_month
      relation = relation.where('`results`.result_date <= (?)', "#{end_at}")
    end
    unless params[:search][:project_id].blank?
      relation = relation.where(:project_id => params[:search][:project_id])
    end
    unless params[:search][:work_type_id].blank?
      relation = relation.where(:work_type_id => params[:search][:work_type_id])
    end
    unless params[:search][:member_id].blank?
      relation = relation.where(:user_id => params[:search][:member_id])
      .where(:deleted => '0')
    end
    if need_paginate
      @results = relation.list.paginate(:page => params[:page], :per_page => RESULT_ITEMS_PER_PAGE)
    else
      @results = relation.list
    end
  end

  ##
  # CSV出力処理
  #
  def csv_export
    file_name = Rails.configuration.result_csv_file_name + "_#{Time.now.strftime('%Y%m%d%H%M%S')}.csv"
    send_data(
      Result.csv_content_for(@results).encode(Encoding::SJIS),
      disposition: 'attachment',
      type: "text/csv;charset=shift_jis;header=present",
      filename: ERB::Util.url_encode(file_name)
    )
  end

  ## 
  # 作業工程選択コントロールの表示
  #
  def set_work_type_select_control(project_id=nil)
    @work_type_select_list = []
    if !project_id.blank?
      if project_id.to_i == Project::INTERNAL_BUSSINESS_PRJ[:id]
        # 社内業務の場合
        @work_type_select_list = WorkType.office_jobs.list_order
      else
        result_work_type_ids = PrjWorkType.select(:work_type_id).where(project_id: project_id).collect {|item| item.work_type_id}
        @work_type_select_list = WorkType.where('id in (?)', result_work_type_ids).list_order if result_work_type_ids.length > 0
      end
    end
  end

  ## 
  # 工数実績ユーザー選択コントロールの表示
  # * 自身にシステム管理者またはマネージャの権限がある場合
  #   ⇒ 社内業務では全メンバを、それ以外のプロジェクトでは全参加メンバをセット
  # * 社内業務以外で、かつ自身(一般ユーザ)がプロジェクトマネージャとなっている場合
  #   ⇒ 該当プロジェクトは全参加メンバをセット
  # * 上記以外の場合
  #   ⇒ 自身のみを選択肢としてセット
  #
  def set_result_user_select_control(project_id = nil)
    @user_select_list = []
    return if project_id.blank?

    if project_id.to_i == Project::INTERNAL_BUSSINESS_PRJ[:id]
      if administrator? || manager?
        @user_select_list = User.where(:deleted => 0).order('user_code ASC')
      end
    else
      project = Project.find_by_id(project_id.to_i)
      if project.present? && (administrator? || manager? || current_user.project_manager?({:project_id => project_id}))
        @user_select_list = project.users
      end
    end

    @user_select_list << current_user if @user_select_list.blank?
  end

  ## 
  # 工数実績グループ選択コントロールの表示
  #
  def set_result_group_select_control(project_id=nil)
    @group_select_list = []
    if !project_id.blank?
      if project_id.to_i == Project::INTERNAL_BUSSINESS_PRJ[:id]
        # 社内業務の場合
        #@user_select_list = Section.alive.order('user_code ASC')
        @group_select_list = Section.where(:deleted => 0).order('view_order ASC')
      else
        project = Project.find_by_id(project_id.to_i)
        if project.present?
          user_ids = []
          project.users.each { |user| user_ids << user[0] }
          @group_select_list = User.include(:sections).select('`sections`.id, `sections`.name')
          .where('`users`.id in (?)', user_ids).uniq
          .order('`sections`.id ASC')
        end
      end
    end
  end
  
  ##
  # ログインユーザーが指定ユーザに対して、工数実績を登録できるかどうか
  # 
  # user::
  #    指定ユーザ（NULLを許さない）
  # 戻り値::
  #   (true/false)
  #
  def can_add_result_for_user?(user)
    return false if user.blank?
    return false if current_user.blank?
    return true if administrator? || manager?
    return current_user.my_relation_members_list.collect {|item| item[1]}.include?(user.id)
  end

  ##
  # ユーザーが指定工数実績が変更・削除できるかどうか
  # 
  # result::
  #    指定工数実績（NULLを許さない）
  # 戻り値::
  #   (true/false)
  #
  def can_modified_result?(result)
    return false if result.blank?
    administrator? || manager? || current_user.project_manager?({project_id: result.project_id}) || result.has_member?(current_user.id)
  end

  ##
  # ユーザーが指定工数実績が表示できるかどうか
  # 
  # result::
  #    指定工数実績（NULLを許さない）
  #
  # 戻り値::
  #   (true/false)
  #
  def can_show_result?(result)
    return false if result.blank?
    return true if administrator? || manager?
    if result.project_id == Project::INTERNAL_BUSSINESS_PRJ[:id]
      # 社内業務プロジェクトの場合
      User.alive.where(id: current_user.id).length > 0
    else
      current_user.project_manager?({project_id: result.project_id}) || result.project.project_member?(current_user)
    end
  end
  
  ##
  # ユーザーが指定工数実績集計が表示できるかどうか
  # 
  # result::
  #    指定工数実績集計（NULLを許さない）
  #
  # 戻り値::
  #   (true/false)
  #
  def can_show_result_sum?
    return true if administrator? || manager? || project_manager?
    return false
  end

  ##
  # ログインユーザーが指定ユーザの工数実績を反映できるかどうか
  # 
  # result::
  #    指定工数実績（NULLを許さない）
  #
  # user::
  #    指定ユーザ（NULLを許さない）
  #
  # 戻り値::
  #   (true/false)
  #
  def can_show_reflect?(result, user)
    return false if user.blank? || result.blank?
    return false if result.work_type_id.blank?
    return true if administrator? || manager?
    # ログインユーザが指定の工数実績のプロジェクト(社内業務プロジェクト除く)のマネージャまたはリーダの場合
    return true if result.project_id != Project::INTERNAL_BUSSINESS_PRJ[:id] && current_user && (current_user.id == result.project.manager_id || current_user.id == result.project.leader_id)
    return true if current_user && employee? && result.has_member?(current_user.id) && (user.id == current_user.id || user.user_rank_cd == USER_RANK_CODE[:parttimer])
    return true if current_user && parttimer? && result.has_member?(current_user.id) && user.id == current_user.id
    return false
  end
  
  ##
  # ①ログインユーザーがシステム管理者またはマネージャーの場合、
  # すべてプロジェクトのリストを取得する
  # ②ログインユーザーがプロジェクトマネージャーの場合、
  # プロジェクトリーダまたはプロジェクトマネージャーになっている
  # プロジェクトのリストを取得する。
  # 
  # 戻り値::
  #   プロジェクトリスト
  #
  def select_project_list
    projects = []
    if administrator? || manager?
      projects = Project.projects_list({include_finished_project: true})
      projects.insert(0, [Project::INTERNAL_BUSSINESS_PRJ[:name], Project::INTERNAL_BUSSINESS_PRJ[:id]])
    else
      temp_prjs = []
      temp_prjs = current_user.my_project_list({include_finished_project: true})
      if project_manager?
        temp_prjs.each do |project|
          projects << project if current_user.project_manager?({project_id: project[1]})
        end
      else
        temp_prjs.each {|project| projects << project} 
      end
    end
    return projects
  end
  
  def select_work_type_list
    project_ids = select_project_list.collect { |project| project[1] }
    work_type_ids = PrjWorkType.select(:work_type_id).where("project_id in (?)", project_ids).collect {|item| item.work_type_id}
    return WorkType.select('name, id').where('id in (?)', work_type_ids).list_order.collect{|work_type| [work_type.name, work_type.id]} if work_type_ids.length > 0
  end
  
  def select_user_list
    users_list = []
    project_ids = select_project_list.collect { |project| project[1] }
    user_ids = PrjMember.select(:user_id).where('project_id in (?)', project_ids).uniq.collect { |user| user.user_id }
    if !project_manager? && employee? 
      users = User.select('users.name, users.id').where('users.id in (?)', user_ids)
      .where(:user_rank_cd => USER_RANK_CODE[:parttimer]).list_order.collect{|user| [user.name, user.id]} 
      users.each {|user| users_list << user }
      users << [current_user.name, current_user.id]
    else 
      users_list = User.select('users.name, users.id').where('users.id in (?)', user_ids).list_order.collect{|user| [user.name, user.id]}
    end
    return users_list
  end
  
  def select_group_list
    project_ids = select_project_list.collect { |project| project[1] }
    user_ids = PrjMember.select(:user_id).where('project_id in (?)', project_ids).uniq.collect { |user| user.user_id }
    section_ids = User.select(:section_id).where('users.id in (?)', user_ids).collect{|item| item.section_id}
    return Section.select('id, name').where('id in (?)', section_ids).collect{|section| [section.name, section.id]}
  end
  
  ##
  # 集計画面・検索処理 
  #
  def create_search_detail_sum_by_group
    params[:search] ||= { start_at: {year: Date.today.year, month: Date.today.month } }
    start_date = Date.civil(params[:search][:start_at][:year].to_i, params[:search][:start_at][:month].to_i)
    @month_results = {
      first_day: start_date.beginning_of_month, 
      month_days: (start_date.end_of_month - start_date.beginning_of_month).to_i + 1 , 
      user_results: Hash::new
    }

    rst_conditions = []
    project_ids = []
    if administrator? || manager?
      projects = Project.projects_list({include_finished_project: true})
      projects.insert(0, [Project::INTERNAL_BUSSINESS_PRJ[:name], Project::INTERNAL_BUSSINESS_PRJ[:id]])
      projects.each do |project|
        project_ids << project[1]
      end
      #ログインユーザーがプロジェクトマネージャーの場合、自身が管理しているプロジェクトID抽出
    elsif project_manager?
      @manage_project_list = select_project_list
      @manage_work_types_list = select_work_type_list
      @manage_user_list = select_user_list
      @manage_section_list = select_group_list
    end
    rst_conditions << " results.project_id in ( " + project_ids.join(',') + " ) " unless project_ids.blank? 
    
    #集計画面・検索条件設定
    unless params[:search][:start_at].blank?
      rst_conditions << " results.result_date >= '" + "#{start_date.beginning_of_month}" + "' and result_date <= '" + "#{start_date.end_of_month}" + "'"
    end
    unless params[:search][:project_id].blank?
      rst_conditions << " results.project_id = '" + "#{params[:search][:project_id]}" + "'"
    end
    unless params[:search][:work_type_id].blank?
      rst_conditions << " results.work_type_id = '" + "#{params[:search][:work_type_id]}" + "'"
    end
    unless params[:search][:group_id].blank?
      users = User.where("section_id = ? AND deleted = ? ", params[:search][:group_id], 0)
      user_ids = []
      users.each {|user| user_ids << user.id }
      rst_conditions << " results.user_id in (" + user_ids.join(',') + ")" unless user_ids.blank?
    end
    unless params[:search][:member_id].blank?
      rst_conditions << " results.user_id = '" + "#{params[:search][:member_id]}" + "'"
    end
    
    #集計画面・検索処理
    rst_where = ""
    rst_where = rst_conditions.join(" AND ") unless rst_conditions.blank?
    # .select('results.user_id, sum((to_seconds(results.end_at) - to_seconds(results.start_at))/3600.0) as day_work_hours')
    user_prjs_month_results = Result.where(rst_where)
    .select('results.user_id, sum(timestampdiff(minute, results.start_at, results.end_at)/60.0) as day_work_hours')
    .joins(:user)
    .group('results.user_id')
    .order('users.section_id ASC', 'users.user_code ASC')
    
    user_prjs_month_results.each do |rst|
      # .select('result_date, sum((to_seconds(results.end_at) - to_seconds(results.start_at))/3600.0) as day_work_hours')
      result_details = Result.where(rst_where).where(:user_id => rst.user_id)
      .where('result_date >= (?) and result_date <= (?)', "#{start_date.beginning_of_month}", "#{start_date.end_of_month}")
      .select('result_date, sum(timestampdiff(minute, results.start_at, results.end_at)/60.0) as day_work_hours')
      .group('result_date')
      .order('result_date ASC')
      .all
      @month_results[:user_results].store(rst,result_details)
    end
    
  end

  ##
  # 個別集計画面・検索処理
  #
  def create_search_detail_sum_by_user
    # 集計画面から引き渡したパラメタ
    @user = User.find_by_id(params[:user_id])
    start_date = Date.civil(params[:search][:start_at][:year].to_i, params[:search][:start_at][:month].to_i)
    
    #結果表示用変数
    @user_month_results = {
      first_day: start_date.beginning_of_month, 
      month_days: (start_date.end_of_month - start_date.beginning_of_month).to_i + 1,
      user_results: Hash::new,
      day_results: []
    }
    
    #検索条件の設定
    rst_conditions = []
    project_ids = []
    if administrator? || manager?
      projects = Project.projects_list({include_finished_project: true})
      projects.insert(0, [Project::INTERNAL_BUSSINESS_PRJ[:name], Project::INTERNAL_BUSSINESS_PRJ[:id]])
      projects.each do |project|
        project_ids << project[1]
      end
      #ログインユーザーがプロジェクトマネージャーの場合、自身が管理しているプロジェクトID抽出
    elsif project_manager?
      @manage_project_list = select_project_list
      @manage_work_types_list = select_work_type_list
      @manage_user_list = select_user_list
      @manage_section_list = select_group_list
    end
    rst_conditions << " results.project_id in ("+ project_ids.join(',') + ")" unless project_ids.blank? 
    rst_conditions << " results.user_id = '" + "#{params[:user_id]}" + "'"
    rst_conditions << " results.result_date >= '" + "#{start_date.beginning_of_month}" + "' and results.result_date <= '" + "#{start_date.end_of_month}" + "'"
    unless params[:search][:project_id].blank?
      rst_conditions << " results.project_id = '" + "#{params[:search][:project_id]}" + "'"
    end
    unless params[:search][:work_type_id].blank?
      rst_conditions << " results.work_type_id = '" + "#{params[:search][:work_type_id]}" + "'"
    end
    rst_where = ""
    rst_where = rst_conditions.join(" AND ") unless rst_conditions.blank?
    
    user_prjs_month_results = Result.where(rst_where).select('project_id').uniq.order('project_id DESC').all
    total_project_ids = []
    user_prjs_month_results.each do |rst|
      # .select('result_date, sum((to_seconds(results.end_at) - to_seconds(results.start_at))/3600.0) as day_work_hours')
      result_details = Result.where(:user_id => params[:user_id])
      .where(:project_id => rst.project_id)
      .where('result_date >= (?) and result_date <= (?)', "#{start_date.beginning_of_month}", "#{start_date.end_of_month}")
      .select('result_date, sum(timestampdiff(minute, results.start_at, results.end_at)/60.0) as day_work_hours')
      .group('result_date')
      .order('result_date ASC')
      .all
      @user_month_results[:user_results].store(rst,result_details)
      total_project_ids << rst.project_id
    end
    
    # .select('result_date, sum((to_seconds(results.end_at) - to_seconds(results.start_at))/3600.0) as day_work_hours')
    user_day_results = Result.where(:user_id => params[:user_id])
    .where(" project_id in (?) ", total_project_ids)
    .where('result_date >= (?) and result_date <= (?)', "#{start_date.beginning_of_month}", "#{start_date.end_of_month}")
    .select('result_date, sum(timestampdiff(minute, results.start_at, results.end_at)/60.0) as day_work_hours')
    .group('result_date')
    .order('result_date ASC')
    .all
    @user_month_results[:month_days].times { @user_month_results[:day_results] << []}
    user_day_results.each do |rst|
      @user_month_results[:day_results][(rst.result_date - start_date.beginning_of_month).to_i] << rst
    end
    #カレンダーに設定します
    params[:first_result_date] = user_day_results[0].result_date.strftime("%Y-%m-%d") unless user_day_results.blank?
  end

  ##
  # 選択した参加者の業務チェック
  #
  # 戻り値::
  #   (true/false)
  #
  def validate_selected_users(selected_user_id)
    return true if administrator? || manager?
    # 社内業務じゃない、且つ、プロジェクトマネージャである場合
    return true if @result.project_id != Project::INTERNAL_BUSSINESS_PRJ[:id] && @result.project.project_manager?(current_user)
    return true if selected_user_id == current_user.id
    confirm = true
    if employee?
      # 一般社員の場合
      selected_user = User.find_by_id(selected_user_id)
      if selected_user.user_rank_cd != USER_RANK_CODE[:parttimer]
        @result.errors[:user_id] << I18n.t('label.result_reflection.errors.employee_member_list_error')
        confirm = false
      end
    else
      # 外注の場合、自分が参加者リストに入ってない場合、エラーとする
      @result.errors[:user_id] << I18n.t('label.result_reflection.errors.parttimer_member_list_error')
      confirm = false
    end
    return confirm
  end
end
