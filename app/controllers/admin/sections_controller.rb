# encoding: utf-8

#
#= Admin::Sectionsコントローラクラス
#
# Authors:: 青山 ひろ子
# Created:: 2012/10/4
#
class Admin::SectionsController < Admin::AdminController
  ##
  # 部署管理機能 一覧画面
  # GET /admin/sections
  #
  def index
    # 検索する削除状態の初期値を未削除に設定
    if params[:search].nil?
      params[:search] = Hash.new
      params[:search][:deleted] = '0'
    end
    
    # 検索条件により部署を検索
    if params[:search][:deleted] == '1'
      @sections = Section.order(:view_order)
          .deleted
          .paginate(:page => params[:page], :per_page => ITEMS_PER_PAGE)
    else
      @sections = Section.order(:view_order)
          .alive
          .paginate(:page => params[:page], :per_page => ITEMS_PER_PAGE)
    end
    
    # 検索条件をセッション変数に保存
    session[:section_condition] = params[:search]
  end
  
  ##
  # 部署管理機能 閲覧画面
  # GET /admin/sections/1
  #
  def show
    begin
      @section = Section.find(params[:id])
    rescue
      add_error_message(t('errors.messages.no_data'))
      redirect_to admin_sections_url
      return
    end
  end
  
  ##
  # 部署情報 新規作成処理
  # GET /admin/sections/new
  #
  def new
    @section = Section.new
  end
  
  ##
  # 部署管理機能 編集画面
  # GET /admin/sections/1/edit
  #
  def edit
    begin
      @section = Section.find(params[:id])
    rescue
      add_error_message(t('errors.messages.no_data'))
      redirect_to admin_sections_url
      return
    end
  end
  
  ##
  # 部署情報 新規作成処理
  # POST /admin/sections
  #
  def create
    begin
      @section = Section.new(params[:section])
      @section.save!
      redirect_to admin_section_path(@section),
          notice: t('common_label.model_was_created', :model => Section.model_name.human)
    rescue => ex
      set_error(ex, :section, :save)
      render action: 'new'
      return
    end
  end
  
  ##
  # 部署情報 更新処理
  # PUT /admin/sections/1
  #
  def update
    begin
      @section = Section.find(params[:id])
      @section.update_attributes!(params[:section])
      redirect_to admin_section_path(@section),
          notice: t('common_label.model_was_updated', :model => Section.model_name.human)
    rescue => ex
      set_error(ex, :section, :save)
      render action: 'edit'
      return
    end
  end
  
  ##
  # 部署情報 復活処理
  # put /admin/sections/1/restore
  #
  def restore
    # 直前のURL
    http_referer = request.env["HTTP_REFERER"]
    
    begin
      @section = Section.find(params[:id])
      
      # 削除チェック
      unless @section.deleted?
        raise t('errors.messages.model_is_alive',
                :model => Section.model_name.human)
      end
      
      # 部署の削除状態を変更する
      @section.deleted = false
      @section.save!(:validate => false)
      
      redirect_to((http_referer.present?)? http_referer : admin_sections_url)
    rescue => ex
      set_error(ex, :section, :restore)
      redirect_to((http_referer.present?)? http_referer : admin_sections_url)
      return
    end
  end
  
  ##
  # 部署情報 削除処理
  # DELETE /admin/sections/1
  #
  def destroy
    # 直前のURL
    http_referer = request.env["HTTP_REFERER"]
    
    begin
      @section = Section.find(params[:id])
      
      # 削除チェック
      if @section.deleted?
        raise t('errors.messages.model_is_deleted',
                :model => Section.model_name.human)
      end
      
      if Section.user_section?(@section)
        add_error_message(t('errors.messages.inoperable_restriction',
            :model => t('activerecord.models.section'),
            :associations => t('activerecord.models.user')))
      else
        # 部署の削除状態を変更する
        @section.deleted = true
        @section.save!(:validate => false)
      end
      redirect_to((http_referer.present?)? http_referer : admin_sections_url)
    rescue => ex
      set_error(ex, :section, :delete)
      redirect_to((http_referer.present?)? http_referer : admin_sections_url)
      return
    end
  end
end
