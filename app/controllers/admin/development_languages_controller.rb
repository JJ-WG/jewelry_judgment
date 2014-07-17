# encoding: utf-8

#
#= Admin::DevelopmentLanguagesコントローラクラス
#
# Created:: 2012/10/4
#
class Admin::DevelopmentLanguagesController < Admin::AdminController
  ##
  # 開発言語管理機能 一覧画面
  # GET /admin/development_languages
  #
  def index
    @development_languages = DevelopmentLanguage.order(:view_order)
        .paginate(:page => params[:page], :per_page => ITEMS_PER_PAGE)
  end
  
  ##
  # 開発言語管理機能 閲覧画面
  # GET /admin/development_languages/1
  #
  def show
    begin
      @development_language = DevelopmentLanguage.find(params[:id])
    rescue
      add_error_message(t('errors.messages.no_data'))
      redirect_to admin_development_languages_url
      return
    end
  end
  
  ##
  # 開発言語情報 新規作成処理
  # GET /admin/development_languages/new
  #
  def new
    @development_language = DevelopmentLanguage.new
  end
  
  ##
  # 開発言語管理機能 編集画面
  # GET /admin/development_languages/1/edit
  #
  def edit
    begin
      @development_language = DevelopmentLanguage.find(params[:id])
    rescue
      add_error_message(t('errors.messages.no_data'))
      redirect_to admin_development_languages_url
      return
    end
  end
  
  ##
  # 開発言語情報 新規作成処理
  # POST /admin/development_languages
  #
  def create
    begin
      @development_language = DevelopmentLanguage.new(params[:development_language])
      @development_language.save!
      redirect_to admin_development_language_path(@development_language),
          notice: t('common_label.model_was_created', :model => DevelopmentLanguage.model_name.human)
    rescue => ex
      set_error(ex, :development_language, :save)
      render action: 'new'
      return
    end
  end
  
  ##
  # 開発言語情報 更新処理
  # PUT /admin/development_languages/1
  #
  def update
    begin
      @development_language = DevelopmentLanguage.find(params[:id])
      @development_language.update_attributes!(params[:development_language])
      redirect_to admin_development_language_path(@development_language),
          notice: t('common_label.model_was_updated', :model => DevelopmentLanguage.model_name.human)
    rescue => ex
      set_error(ex, :development_language, :save)
      render action: 'edit'
      return
    end
  end
  
  ##
  # 開発言語情報 削除処理
  # DELETE /admin/development_languages/1
  #
  def destroy
    begin
      # 直前のURL
      http_referer = request.env["HTTP_REFERER"]
      
      @development_language = DevelopmentLanguage.find(params[:id])
      if @development_language.projects.present?
        add_error_message(t('errors.messages.inoperable_restriction',
            :model => t('activerecord.models.development_language'),
            :associations => t('activerecord.models.project')))
        redirect_to((http_referer.present?)? http_referer : admin_development_languages_url)
      else
        @development_language.destroy
        redirect_to admin_development_languages_url
      end
    rescue => ex
      set_error(ex, :development_language, :delete)
      redirect_to((http_referer.present?)? http_referer : admin_development_languages_url)
    end
  end
end
