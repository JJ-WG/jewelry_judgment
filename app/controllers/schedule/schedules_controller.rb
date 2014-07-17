# encoding: utf-8

#
#= Schedule::Schedulesコントローラクラス
#
# Created:: 2012/12/11
#
class Schedule::SchedulesController < Schedule::ScheduleController

  # コントローラのメソッドをviewでも使えるように設定
  helper_method :can_modified_schedule?, :can_show_schedule?, :can_add_schedule_for_user?

  ##
  # スケジュール管理機能 一覧画面
  # GET /schedule/schedules
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
  # スケジュール情報 新規作成処理
  # GET /schedule/schedules/new
  #
  def new
    @schedule = Schedule.new
    @schedule.schedule_date = params[:schedule_date].blank? ? Date.today : Date.parse(params[:schedule_date])
    @schedule.project_id = params[:project_id] unless params[:project_id].blank?
    # 作業工程コントロールの設定
    set_work_type_select_control(params[:project_id])
    # すでに選択した参加者のIDSに対して、セッションからクリアする
    session[:select_schedule_member_ids] = []
    session[:select_schedule_member_ids] << params[:user_id].to_i unless params[:user_id].blank?
    set_schedule_member_select_control(@schedule.project_id)
  end

  ##
  # スケジュール管理機能 閲覧画面
  # GET /schedule/schedules/1
  #
  def show
    @schedule = Schedule.find_by_id(params[:id])
    render(:file => File.join(Rails.root, 'public', '403'), :status => 403, :layout => false) unless can_show_schedule?(@schedule)
    # 参加者リスト情報の取得処理、構成：{ user_info: user, has_reflected: true, result_info: result, can_show_reflect: true }
    @member_list_info = []
    @schedule.sch_members.each do |sch_member|
      user_info = User.find_by_id(sch_member.user_id) 
      @member_list_info << { user_info: user_info,
                             result_info: @schedule.get_result_for_user(sch_member.user_id),
                             can_show_reflect: can_show_reflect?(@schedule, user_info) }
    end
  end

  ##
  # スケジュール管理機能 反映
  # PUT /schedule/schedules/1/reflect?user_id=1
  #
  def reflect
    begin
      @schedule = Schedule.find(params[:id])
      @schedule.reflect_to_result_by_user(params[:user_id]) unless params[:user_id].blank?
      flash[:notice] = I18n.t('label.schedule_reflection.label.result_reflect_success')
    rescue Exception => e
      flash[:warning] = I18n.t('label.schedule_reflection.errors.result_reflect_error')
      logger.error(e.message)
    end
    redirect_to schedule_schedule_path(@schedule)
  end

  ##
  # スケジュール管理機能 日付選択してから、閲覧画面
  # GET /schedule/schedules/show_by_date?select_date=
  #
  def show_by_date
    select_date = Date.today
    select_date = Date.parse(params[:select_date]) unless params[:select_date].blank?
    @schedule = Schedule.by_user_id(current_user.id).where(:schedule_date => select_date).order('start_at ASC, end_at ASC').first
    unless @schedule.blank?
      redirect_to :action => 'show', :id => @schedule.id 
      return
    end
    @schedule = Schedule.new(:schedule_date => select_date)
    render 'show'
  end

  ##
  # スケジュール管理機能 編集画面
  # GET /schedule/schedules/1/edit
  #
  def edit
    @schedule = Schedule.find_by_id(params[:id])
    render(:file => File.join(Rails.root, 'public', '403'), :status => 403, :layout => false) unless can_modified_schedule?(@schedule)

    # 作業工程コントロールの設定
    set_work_type_select_control(@schedule.project_id)

    # 現在選択中のスケジュールメンバーIDをセッション情報に保存
    session[:select_schedule_member_ids] = []
    @schedule.sch_members.each{|member|
      user = User.find_by_id(member.user_id)
      if user.present?
        session[:select_schedule_member_ids] << user.id
      end
    }
    session[:select_schedule_member_ids].uniq

    set_schedule_member_select_control(@schedule.project_id)
  end

  ##
  # スケジュール情報 新規作成処理
  # POST /schedule/schedules
  #
  def create
    begin
      # == 参加者リスト ==
      # セッション情報から現在選択中の参加者リストを作成
      selected_schedule_member_users =
          get_select_list_from_session(session[:select_schedule_member_ids], User)
      schedule_members = []
      selected_schedule_member_users.each do |user|
        sch_member = SchMember.new
        sch_member.user_id = user.id
        schedule_members << sch_member
      end
      
      ActiveRecord::Base.transaction do
        schedule_attributes = params[:schedule].reject{|key, value|
          key == 'schedule_member_user_id' || key == 'sch_members'
        }
        # もし、時間または分が選択されてない場合、開始時間・終了時間をNULLに設定して、Validationを行う
        if schedule_attributes["start_at(4i)"].blank? || schedule_attributes["start_at(5i)"].blank?
          schedule_attributes.delete_if {|key, value| /start_at\([1-6]i\)/ =~ key}
          schedule_attributes[:start_at] = nil
        end
        if schedule_attributes["end_at(4i)"].blank? || schedule_attributes["end_at(5i)"].blank?
          schedule_attributes.delete_if {|key, value| /end_at\([1-6]i\)/ =~ key}
          schedule_attributes[:end_at] = nil
        end
        
        # プロジェクト情報のDB登録
        @schedule = Schedule.new(schedule_attributes)
        # プロジェクトメンバー情報のDB登録
        @schedule.sch_members = schedule_members

        validate_success = @schedule.valid?
        if @schedule.errors[:sch_members].blank?
          if schedule_members.length > 0
            validate_success = validate_selected_members(selected_schedule_member_users)
          else
            # 参加者必須入力チェック
            @schedule.errors[:sch_members] << I18n.t('errors.messages.blank')
            validate_success = false
          end
        end

        if validate_success
          @schedule.save!
          redirect_to schedule_schedule_path(@schedule),
              notice: t('common_label.model_was_created', :model => Schedule.model_name.human)
        else
          raise 'validate error!'
        end
      end
    rescue Exception => e
      flash[:warning] = I18n.t('errors.messages.create_error', :model => Schedule.model_name.human)
      logger.error(e.message)
      # 作業工程コントロールの設定
      set_work_type_select_control(params[:schedule][:project_id])
      # 失敗の場合、登録画面に戻るので、参加者リストの設定が必要です。
      set_schedule_member_select_control(params[:schedule][:project_id])
      render :new
    end
  end

  ##
  # スケジュール情報 更新処理
  # PUT /schedule/schedules/1
  #
  def update
    begin
      @schedule = Schedule.find(params[:id])

      # == 参加者リスト ==
      # セッション情報から現在選択中の参加者リストを作成
      selected_schedule_member_users =
          get_select_list_from_session(session[:select_schedule_member_ids], User)
      schedule_members = []
      selected_schedule_member_users.each do |user|
        sch_member = SchMember.new
        sch_member.user_id = user.id
        schedule_members << sch_member
      end
      
      ActiveRecord::Base.transaction do
        schedule_attributes = params[:schedule].reject{|key, value|
          key == 'schedule_member_user_id' || key == 'sch_members'
        }

        # もし、時間または分が選択されてない場合、開始時間・終了時間をNULLに設定して、Validationを行う
        if schedule_attributes["start_at(4i)"].blank? || schedule_attributes["start_at(5i)"].blank?
          schedule_attributes.delete_if {|key, value| /start_at\([1-6]i\)/ =~ key}
          schedule_attributes[:start_at] = nil
        end
        if schedule_attributes["end_at(4i)"].blank? || schedule_attributes["end_at(5i)"].blank?
          schedule_attributes.delete_if {|key, value| /end_at\([1-6]i\)/ =~ key}
          schedule_attributes[:end_at] = nil
        end
 
        @schedule.attributes = schedule_attributes
        validate_success = @schedule.valid?
        if @schedule.errors[:sch_members].blank?
          if schedule_members.length > 0
            validate_success = validate_selected_members(selected_schedule_member_users)
          else
            # 参加者必須入力チェック
            @schedule.errors[:sch_members] << I18n.t('errors.messages.blank')
            validate_success = false
          end
        end
        if validate_success
          # 既存の参加者のリレーションを削除
          @schedule.sch_members.each { |member| member.update_attributes!({deleted: 1}) }
          # スケジュール情報のDB更新
          @schedule.sch_members = schedule_members
          @schedule.update_attributes!(schedule_attributes)
          
          redirect_to schedule_schedule_path(@schedule),
              notice: t('common_label.model_was_updated',
              :model => Schedule.model_name.human)
        else
          raise 'validate error!'
        end
      end
    rescue Exception => e
      flash[:warning] = I18n.t('errors.messages.update_error', :model => Schedule.model_name.human)
      logger.error(e.message)
      # 作業工程コントロールの設定
      set_work_type_select_control(params[:schedule][:project_id])
      # 失敗の場合、編集画面に戻るので、参加者リストの設定が必要です。
      set_schedule_member_select_control(params[:schedule][:project_id])
      render :edit
    end
  end

  ##
  # スケジュール情報 更新処理
  # DELETE /schedule/schedules/1
  #
  def destroy
    @schedule = Schedule.find_by_id(params[:id])
    if can_modified_schedule?(@schedule)
      begin
        ActiveRecord::Base.transaction do
          # 参加者の削除
          @schedule.sch_members.each { |member| member.update_attributes!(deleted: 1) }
          @schedule.update_attributes!(deleted: 1)
        end
        flash[:notice] = I18n.t('common_label.model_was_deleted', :model => Schedule.model_name.human)
      rescue Exception => e
        flash[:warning] = I18n.t('errors.messages.delete_error', :model => Schedule.model_name.human)
        logger.error(e.message)
      end
    else
      flash[:warning] = I18n.t('errors.messages.not_permitted')
    end
    redirect_to schedule_schedules_path
  end

  ##
  # 工数一括反映
  # POST /schedule/schedules/bundle_reflect
  #
  def bundle_reflect
    if request.post?
      unless params[:select_ids].blank?
        # スケジュール毎に対して、反映の時、エラー(工程作業が空白)あるかどうか
        has_validation_error = false
        begin
          ActiveRecord::Base.transaction do
            params[:select_ids].each do |id|
              sch = Schedule.find_by_id(id.to_i)
              if sch.present?
                sch.sch_members.each do |member|
                  if can_show_reflect?(sch, User.find_by_id(member.user_id))
                    sch.reflect_to_result_by_user(member.user_id)
                  else
                    has_validation_error = true
                  end
                end
              end
            end
            @schedules = Schedule.where('`schedules`.id in (?)', params[:select_ids]).list
          end
          if has_validation_error
            flash.now[:warning] = I18n.t('label.schedule_reflection.errors.result_bundle_reflect_validation_error')
          else
            flash.now[:notice] = I18n.t('label.schedule_reflection.label.result_bundle_reflect_success')
          end
          render 'bundle_reflect'
        rescue Exception => e
          flash[:warning] = I18n.t('label.schedule_reflection.errors.result_bundle_reflect_error')
          logger.error(e.message)
          redirect_to schedule_schedules_path
        end
      else
        flash[:warning] = I18n.t('errors.messages.selected_zero_error')
        redirect_to schedule_schedules_path
      end
    elsif request.get?
      @schedules = Schedule.where('`schedules`.id in (?)', params[:select_ids]).list
      render 'bundle_reflect'
    end
  end

  ##
  # スケジュール管理機能 登録・編集（プロジェクトメンバー選択）
  # GET /schedule/schedules/on_change_project_list
  #
  def on_change_project_list
    @schedule = Schedule.new
    
    # 作業工程コントロールの設定
    set_work_type_select_control(params[:project_id])

    if params[:project_id].present?
      if params[:project_id].to_i == Project::INTERNAL_BUSSINESS_PRJ[:id]
        # 社内業務プロジェクトの場合
        session[:select_schedule_member_ids].delete_if {|user_id| User.alive.find_by_id(user_id).blank? } unless session[:select_schedule_member_ids].blank?
      else
        if Project.find_by_id(params[:project_id]).present?
          session[:select_schedule_member_ids].delete_if {|user_id| PrjMember.where(project_id: params[:project_id].to_i, user_id: user_id).blank? } unless session[:select_schedule_member_ids].blank?
        else
          session[:select_schedule_member_ids] = []
        end
      end
    else
      session[:select_schedule_member_ids] = []
    end

    # スケジュールメンバー選択コントロールの表示
    set_schedule_member_select_control(params[:project_id])
    respond_to do |format|
      format.js { render :content_type => 'text/javascript' }
    end
  end

  ##
  # スケジュール管理機能 登録・編集（スケジュールメンバー選択）
  # GET /schedule/schedules/on_click_schedule_member_add
  #
  def on_click_schedule_member_add
    @schedule = Schedule.new
    
    # 指定されたユーザをスケジュール参加者リストに追加
    if params[:user_ids].present?
      user_ids = params[:user_ids].split(':').map {|id| id.to_i}
      render_flag = false
      user_ids.each do |id|
        user = User.find_by_id(id)
        if user.present?
          # セッション情報に現在選択中のスケジュール参加者IDを保存
          session[:select_schedule_member_ids] << user.id
          session[:select_schedule_member_ids].uniq
          render_flag = true
        end
      end
      if render_flag
        # スケジュールメンバー選択コントロールの表示
        set_schedule_member_select_control(params[:project_id])
        render 'on_change_project_list'
      end
    end
  end

  ##
  # スケジュール管理機能 登録・編集（スケジュールメンバーの削除）
  # GET /schedule/schedules/on_click_schedule_member_remove
  #
  def on_click_schedule_member_remove
    @schedule = Schedule.new
    
    # 指定されたユーザを選択した参加者リストから削除
    if params[:user_ids].present?
      user_ids = params[:user_ids].split(':').map {|id| id.to_i}
      # セッション情報に現在選択中のプロジェクトメンバーIDを保存
      session[:select_schedule_member_ids] -= user_ids unless session[:select_schedule_member_ids].blank?
 
      # スケジュールメンバー選択コントロールの表示
      set_schedule_member_select_control(params[:project_id])
      render 'on_change_project_list'
    end
  end

  ##
  # スケジュール管理機能 登録・編集（指定日付のスケジュールの取得）
  # GET /schedule/schedules/get_schedules_by_day
  #
  def get_schedules_by_day
    @schedules = Schedule.by_user_id(current_user.id).where( "start_at >= ? and end_at <= ?", Time.at(params['start'].to_i), Time.at(params['end'].to_i) );
    schedules = []
    @schedules.each do |schedule|
      schedules << { :id => schedule.id, 
                      :title => schedule.project.name || '',
                      :start => "#{schedule.start_at.iso8601}",
                      :end => "#{schedule.end_at.iso8601}",
                      :allDay => false, 
                      :color => schedule.reflected?(current_user.id) ? '#C672A7' : '#7985C5', 
                      :recurring => false
                  }
    end
    render :text => schedules.to_json
  end

  ##
  # スケジュール管理機能 プロジェクト別一覧画面
  # GET /schedule/schedules/list_by_project
  #
  def list_by_project
    create_search_detail_separate_by_project
  end

  ##
  # スケジュール管理機能 グループ別一覧画面
  # GET /schedule/schedules/list_by_group
  #
  def list_by_group
    create_search_detail_separate_by_group
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
    relation  = Schedule
    unless params[:search][:start_at].blank?
      start_at = Date.civil(params[:search][:start_at][:year].to_i, params[:search][:start_at][:month].to_i).beginning_of_month
      relation = relation.where('`schedules`.schedule_date >= (?)', "#{start_at}")
    end
    unless params[:search][:end_at].blank?
      end_at = Date.civil(params[:search][:end_at][:year].to_i, params[:search][:end_at][:month].to_i).end_of_month
      relation = relation.where('`schedules`.schedule_date <= (?)', "#{end_at}")
    end
    unless params[:search][:project_id].blank?
      relation = relation.where(:project_id => params[:search][:project_id])
    end
    unless params[:search][:work_type_id].blank?
      relation = relation.where(:work_type_id => params[:search][:work_type_id])
    end
    if params[:search][:member_id].blank?
      # すべての場合
      if !administrator? && !manager?
        accessable_member_ids = []
        if project_manager?
          current_user.my_relation_members_list.each { |member| accessable_member_ids << member[1] }
        else
          # 一般社員または外注
          accessable_member_ids << current_user.id unless current_user.blank?
        end
        relation = relation.joins(:sch_members).where('`sch_members`.user_id in (?) and `sch_members`.deleted = 0', accessable_member_ids)
      end
    else
      relation = relation.joins(:sch_members).where('`sch_members`.user_id = (?) and `sch_members`.deleted = 0', params[:search][:member_id])
    end
    if need_paginate
      @schedules = relation.list.paginate(:page => params[:page], :per_page => SCHEDULE_ITEMS_PER_PAGE)
    else
      @schedules = relation.list
    end
  end

  ##
  # CSV出力処理
  #
  def csv_export
    file_name = Rails.configuration.schedule_csv_file_name + "_#{Time.now.strftime('%Y%m%d%H%M%S')}.csv"
    send_data(
      Schedule.csv_content_for(@schedules).encode(Encoding::SJIS),
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
  # スケジュールメンバー選択コントロールの表示
  #
  def set_schedule_member_select_control(project_id=nil)
    @member_select_users = []
    @selected_schedule_members = []

    if !project_id.blank?
      if project_id.to_i == 0
        # 社内業務の場合
        @member_select_users = User.alive.order('user_code ASC')
      else
        project = Project.find_by_id(project_id.to_i)
        if project.present?
          @member_select_users = project.users
        end
      end
    end
    
    # セッション情報から現在選択中の参加者リストを作成
    schedule_member_users = get_select_list_from_session(session[:select_schedule_member_ids], User)
    schedule_member_users.each{ |user| @selected_schedule_members << user }
    
    # 部署ユーザリストから現在選択中のプロジェクトメンバーを削除
    @member_select_users = get_diff_arrays(@member_select_users, schedule_member_users)
  end

  ##
  # ログインユーザーが指定ユーザに対して、スケジュールを登録できるかどうか
  # 
  # user::
  #    指定ユーザ（NULLを許さない）
  # 戻り値::
  #   (true/false)
  #
  def can_add_schedule_for_user?(user)
    return false if user.blank?
    return false if current_user.blank?
    return true if administrator? || manager?
    return current_user.my_relation_members_list.collect {|item| item[1]}.include?(user.id)
  end

  ##
  # ユーザーが指定スケジュールが変更・削除できるかどうか
  # 
  # schedule::
  #    指定スケジュール（NULLを許さない）
  # 戻り値::
  #   (true/false)
  #
  def can_modified_schedule?(schedule)
    return false if schedule.blank?
    administrator? || manager? || current_user.project_manager?({project_id: schedule.project_id}) || schedule.has_member?(current_user.id)
  end

  ##
  # ユーザーが指定スケジュールが表示できるかどうか
  # 
  # schedule::
  #    指定スケジュール（NULLを許さない）
  #
  # 戻り値::
  #   (true/false)
  #
  def can_show_schedule?(schedule)
    return false if schedule.blank?
    return true if administrator? || manager?
    if schedule.project_id == Project::INTERNAL_BUSSINESS_PRJ[:id]
      # 社内業務プロジェクトの場合
      User.alive.where(id: current_user.id).length > 0
    else
      current_user.project_manager?({project_id: schedule.project_id}) || schedule.project.project_member?(current_user)
    end
  end

  ##
  # ログインユーザーが指定ユーザのスケジュールを反映できるかどうか
  # 
  # schedule::
  #    指定スケジュール（NULLを許さない）
  #
  # user::
  #    指定ユーザ（NULLを許さない）
  #
  # 戻り値::
  #   (true/false)
  #
  def can_show_reflect?(schedule, user)
    return false if user.blank? || schedule.blank?
    return false if schedule.work_type_id.blank?
    return true if administrator? || manager?
    # ログインユーザが指定のスケジュールのプロジェクト(社内業務プロジェクト除く)のマネージャまたはリーダの場合
    return true if schedule.project_id != Project::INTERNAL_BUSSINESS_PRJ[:id] && current_user && (current_user.id == schedule.project.manager_id || current_user.id == schedule.project.leader_id)
    return true if current_user && employee? && schedule.has_member?(current_user.id) && (user.id == current_user.id || user.user_rank_cd == USER_RANK_CODE[:parttimer])
    return true if current_user && parttimer? && schedule.has_member?(current_user.id) && user.id == current_user.id
    return false
  end

  ##
  # 検索処理(別々) プロジェクト別
  #
  def create_search_detail_separate_by_project
    params[:search] ||= { }
    params[:search][:start_date] ||= l(Date.today)
    @week_schedules = {
        first_day: Date.parse(params[:search][:start_date]),
        users: []
    }
    accessable_project_ids = []
    get_current_user_can_acccess_projects.each { |project| accessable_project_ids << project[1] }
    unless params[:search][:project_id].blank?
      if params[:search][:project_id].to_i == Project::INTERNAL_BUSSINESS_PRJ[:id]
        users = User.alive.order('user_code ASC')
      else
        users = User.includes(:prj_members)
                    .where("`prj_members`.project_id = ?", params[:search][:project_id])
                    .order('user_code ASC')
      end
      users.each do |user|
        user_schedules = Schedule.by_user_id(user.id)
                              .where('schedule_date >= (?) and schedule_date <= (?)', @week_schedules[:first_day], @week_schedules[:first_day]+6)
                              .order('schedule_date ASC, project_id ASC,  start_at ASC, end_at ASC')
        user_week_schedules = []
        # 週スケジュールの初期化
        7.times {user_week_schedules << []}
        # スケジュールを日付によって設定する
        user_schedules.each do |sch|
          if administrator? || manager? || accessable_project_ids.include?(sch.project_id) 
            user_week_schedules[(sch.schedule_date - @week_schedules[:first_day]).to_i] << { schedule: sch, can_show_detail: true }
          else
            user_week_schedules[(sch.schedule_date - @week_schedules[:first_day]).to_i] << { schedule: sch, can_show_detail: false }
          end
        end
        @week_schedules[:users] << {
            user_info: user,
            user_week_schedules: user_week_schedules
          }
      end
    end
  end

  ##
  # 検索処理(別々) グループ別
  #
  def create_search_detail_separate_by_group
    params[:search] ||= { }
    params[:search][:start_date] ||= l(Date.today)
    @week_schedules = {
        first_day: Date.parse(params[:search][:start_date]),
        users: []
    }
    accessable_project_ids = []
    get_current_user_can_acccess_projects.each { |project| accessable_project_ids << project[1] }
    unless params[:search][:group_id].blank?
      users = User.where("section_id = ?", params[:search][:group_id]).order('user_code ASC')
      users.each do |user|
        user_schedules = Schedule.by_user_id(user.id)
                              .where('schedule_date >= (?) and schedule_date <= (?)', @week_schedules[:first_day], @week_schedules[:first_day]+6)
                              .order('schedule_date ASC, project_id ASC,  start_at ASC, end_at ASC')
        user_week_schedules = []
        # 週スケジュールの初期化
        7.times {user_week_schedules << []}
        # スケジュールを日付によって設定する
        user_schedules.each do |sch|
          if administrator? || manager? || accessable_project_ids.include?(sch.project_id) 
            user_week_schedules[(sch.schedule_date - @week_schedules[:first_day]).to_i] << { schedule: sch, can_show_detail: true }
          else
            user_week_schedules[(sch.schedule_date - @week_schedules[:first_day]).to_i] << { schedule: sch, can_show_detail: false }
          end
        end
        @week_schedules[:users] << {
            user_info: user,
            user_week_schedules: user_week_schedules
          }
      end
    end
  end

  ##
  # 選択した参加者の業務チェック
  #
  # 戻り値::
  #   (true/false)
  #
  def validate_selected_members(selected_users)
    return true if administrator? || manager?
    # 社内業務じゃない、且つ、プロジェクトマネージャである場合
    return true if @schedule.project_id != Project::INTERNAL_BUSSINESS_PRJ[:id] && @schedule.project.project_manager?(current_user)
    result = true
    selected_user_ids = selected_users.collect {|user| user.id} || []
    if employee?
      # 一般社員の場合
      if !selected_user_ids.include?(current_user.id)
        # 自身が参加者リストに入ってない場合
        selected_users.each do |user|
          if user.user_rank_cd != USER_RANK_CODE[:parttimer]
            @schedule.errors[:sch_members] << I18n.t('label.schedule_reflection.errors.employee_member_list_error')
            return false
          end
        end
      end
    else
      # 外注の場合、自分が参加者リストに入ってない場合、エラーとする
      if !selected_user_ids.include?(current_user.id)
        @schedule.errors[:sch_members] << I18n.t('label.schedule_reflection.errors.parttimer_member_list_error')
        result = false
      end
    end
    return result
  end
end
