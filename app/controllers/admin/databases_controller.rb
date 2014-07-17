# encoding: utf-8

#
#= Admin::Databasesコントローラクラス
#
# Created:: 2012/10/4
#
class Admin::DatabasesController < Admin::AdminController
  ##
  # データベース管理機能 一覧画面
  # GET /admin/databases
  #
  def index
    @databases = Database.order(:view_order)
        .paginate(:page => params[:page], :per_page => ITEMS_PER_PAGE)
  end
  
  ##
  # データベース管理機能 閲覧画面
  # GET /admin/databases/1
  #
  def show
    begin
      @database = Database.find(params[:id])
    rescue
      add_error_message(t('errors.messages.no_data'))
      redirect_to admin_deatabases_url
      return
    end
  end
  
  ##
  # データベース情報 新規作成処理
  # GET /admin/databases/new
  #
  def new
    @database = Database.new
  end
  
  ##
  # データベース管理機能 編集画面
  # GET /admin/databases/1/edit
  #
  def edit
    begin
      @database = Database.find(params[:id])
    rescue
      add_error_message(t('errors.messages.no_data'))
      redirect_to admin_databases_url
      return
    end
  end
  
  ##
  # データベース情報 新規作成処理
  # POST /admin/databases
  #
  def create
    begin
      @database = Database.new(params[:database])
      @database.save!
      redirect_to admin_database_path(@database),
          notice: t('common_label.model_was_created', :model => Database.model_name.human)
    rescue => ex
      set_error(ex, :database, :save)
      render action: 'new'
      return
    end
  end
  
  ##
  # データベース情報 更新処理
  # PUT /admin/databases/1
  #
  def update
    begin
      @database = Database.find(params[:id])
      @database.update_attributes!(params[:database])
      redirect_to admin_database_path(@database),
          notice: t('common_label.model_was_updated', :model => Database.model_name.human)
    rescue => ex
      set_error(ex, :database, :save)
      render action: 'edit'
      return
    end
  end
  
  ##
  # データベース情報 削除処理
  # DELETE /admin/databases/1
  #
  def destroy
    begin
      # 直前のURL
      http_referer = request.env["HTTP_REFERER"]
      
      @database = Database.find(params[:id])
      if @database.projects.present?
        add_error_message(t('errors.messages.inoperable_restriction',
            :model => t('activerecord.models.database'),
            :associations => t('activerecord.models.project')))
        redirect_to((http_referer.present?)? http_referer : admin_databases_url)
      else
        @database.destroy
        redirect_to admin_databases_url
      end
    rescue => ex
      set_error(ex, :database, :delete)
      redirect_to((http_referer.present?)? http_referer : admin_databases_url)
    end
  end
end
