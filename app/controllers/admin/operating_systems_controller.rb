# encoding: utf-8

#
#= Admin::OperatingSystemsコントローラクラス
#
# Authors:: 青山 ひろ子
# Created:: 2012/10/4
#
class Admin::OperatingSystemsController < Admin::AdminController
  ##
  # OS管理機能 一覧画面
  # GET /admin/operating_systems
  #
  def index
    @operating_systems = OperatingSystem.order(:view_order)
        .paginate(:page => params[:page], :per_page => ITEMS_PER_PAGE)
  end
  
  ##
  # OS管理機能 閲覧画面
  # GET /admin/operating_systems/1
  #
  def show
    begin
      @operating_system = OperatingSystem.find(params[:id])
    rescue
      add_error_message(t('errors.messages.no_data'))
      redirect_to admin_operating_systems_url
      return
    end
  end
  
  ##
  # OS情報 新規作成処理
  # GET /admin/operating_systems/new
  #
  def new
    @operating_system = OperatingSystem.new
  end
  
  ##
  # OS管理機能 編集画面
  # GET /admin/operating_systems/1/edit
  #
  def edit
    begin
      @operating_system = OperatingSystem.find(params[:id])
    rescue
      add_error_message(t('errors.messages.no_data'))
      redirect_to admin_operating_systems_url
      return
    end
  end
  
  ##
  # OS情報 新規作成処理
  # POST /admin/operating_systems
  #
  def create
    begin
      @operating_system = OperatingSystem.new(params[:operating_system])
      @operating_system.save!
      redirect_to admin_operating_system_path(@operating_system),
          notice: t('common_label.model_was_created', :model => OperatingSystem.model_name.human)
    rescue => ex
      set_error(ex, :operating_system, :save)
      render action: 'new'
      return
    end
  end
  
  ##
  # OS情報 更新処理
  # PUT /admin/operating_systems/1
  #
  def update
    begin
      @operating_system = OperatingSystem.find(params[:id])
      @operating_system.update_attributes!(params[:operating_system])
      redirect_to admin_operating_system_path(@operating_system),
          notice: t('common_label.model_was_updated', :model => OperatingSystem.model_name.human)
    rescue => ex
      set_error(ex, :operating_system, :save)
      render action: 'edit'
      return
    end
  end
  
  ##
  # OS情報 削除処理
  # DELETE /admin/operating_systems/1
  #
  def destroy
    begin
      # 直前のURL
      http_referer = request.env["HTTP_REFERER"]
      
      @operating_system = OperatingSystem.find(params[:id])
      if @operating_system.projects.present?
        add_error_message(t('errors.messages.inoperable_restriction',
            :model => t('activerecord.models.operating_system'),
            :associations => t('activerecord.models.project')))
        redirect_to((http_referer.present?)? http_referer : admin_operating_systems_url)
      else
        @operating_system.destroy
        redirect_to admin_operating_systems_url
      end
    rescue => ex
      set_error(ex, :operating_system, :delete)
      redirect_to((http_referer.present?)? http_referer : admin_operating_systems_url)
    end
  end
end
