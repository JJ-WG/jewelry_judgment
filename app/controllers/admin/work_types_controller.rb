# encoding: utf-8

#
#= Admin::WorkTypesコントローラクラス
#
# Authors:: 青山 ひろ子
# Created:: 2012/10/4
#
class Admin::WorkTypesController < Admin::AdminController
  ##
  # 工程管理機能 一覧画面
  # GET /admin/work_types
  #
  def index
    # 検索する業務区分の初期値を開発業務に設定
    if params[:search].nil?
      params[:search] = Hash.new
      params[:search][:office_job] = OFFICE_JOB_CODE[:development]
    end
    
    if params[:search][:office_job].to_i == OFFICE_JOB_CODE[:development]
      office_job = false
    else
      office_job = true
    end
    
    # 検索条件により工程を検索    
    @work_types = WorkType.where(:office_job => office_job)
        .order(:view_order)
        .paginate(:page => params[:page], :per_page => ITEMS_PER_PAGE)
    
    
    # 検索条件をセッション変数に保存
    session[:work_type_condition] = params[:search]
  end
  
  ##
  # 工程管理機能 閲覧画面
  # GET /admin/work_types/1
  #
  def show
    begin
      @work_type = WorkType.find(params[:id])
    rescue
      add_error_message(t('errors.messages.no_data'))
      redirect_to admin_work_types_url
      return
    end
  end
  
  ##
  # 工程情報 新規作成処理
  # GET /admin/work_types/new
  #
  def new
    @work_type = WorkType.new
  end
  
  ##
  # 工程管理機能 編集画面
  # GET /admin/work_types/1/edit
  #
  def edit
    begin
      @work_type = WorkType.find(params[:id])
    rescue
      add_error_message(t('errors.messages.no_data'))
      redirect_to admin_work_types_url
      return
    end
  end
  
  ##
  # 工程情報 新規作成処理
  # POST /admin/work_types
  #
  def create
    begin
      @work_type = WorkType.new(params[:work_type])
      @work_type.office_job = (params[:work_type][:office_job] == '1') ? true : false
      
      @work_type.save!
      redirect_to admin_work_type_path(@work_type),
          notice: t('common_label.model_was_created', :model => WorkType.model_name.human)
    rescue => ex
      set_error(ex, :work_type, :save)
      render action: 'new'
      return
    end
  end
  
  ##
  # 工程情報 更新処理
  # PUT /admin/work_types/1
  #
  def update
    begin
      @work_type = WorkType.find(params[:id])
      params[:work_type][:office_job] =
          (params[:work_type][:office_job] == '1') ? true : false
      
      @work_type.update_attributes!(params[:work_type])
      redirect_to admin_work_type_path(@work_type),
          notice: t('common_label.model_was_updated', :model => WorkType.model_name.human)
    rescue => ex
      set_error(ex, :work_type, :save)
      render action: 'edit'
      return
    end
  end
  
  ##
  # 工程情報 削除処理
  # DELETE /admin/work_types/1
  #
  def destroy
    begin
      # 直前のURL
      http_referer = request.env["HTTP_REFERER"]
      
      @work_type = WorkType.find(params[:id])
      if WorkType.project_work_type?(@work_type)
        add_error_message(t('errors.messages.inoperable_restriction',
            :model => t('activerecord.models.work_type'),
            :associations => t('activerecord.models.project')))
        redirect_to((http_referer.present?)? http_referer : admin_work_types_url)
      else
        @work_type.destroy
        redirect_to admin_work_types_url
      end
    rescue => ex
      set_error(ex, :work_type, :delete)
      redirect_to((http_referer.present?)? http_referer : admin_work_types_url)
    end
  end
end
