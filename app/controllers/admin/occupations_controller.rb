# encoding: utf-8

#
#= Admin::Occupationsコントローラクラス
#
# Authors:: 青山 ひろ子
# Created:: 2012/10/4
#
class Admin::OccupationsController < Admin::AdminController
  ##
  # 職種管理機能 一覧画面
  # GET /admin/occupations
  #
  def index
    @occupations = Occupation.order(:view_order)
        .paginate(:page => params[:page], :per_page => ITEMS_PER_PAGE)
  end
  
  ##
  # 職種管理機能 閲覧画面
  # GET /admin/occupations/1
  #
  def show
    begin
      @occupation = Occupation.find(params[:id])
    rescue
      add_error_message(t('errors.messages.no_data'))
      redirect_to admin_occupations_url
      return
    end
  end
  
  ##
  # 職種情報 新規作成処理
  # GET /admin/occupations/new
  #
  def new
    @occupation = Occupation.new
  end
  
  ##
  # 職種管理機能 編集画面
  # GET /admin/occupations/1/edit
  #
  def edit
    begin
      @occupation = Occupation.find(params[:id])
    rescue
      add_error_message(t('errors.messages.no_data'))
      redirect_to admin_occupations_url
      return
    end
  end
  
  ##
  # 職種情報 新規作成処理
  # POST /admin/occupations
  #
  def create
    begin
      @occupation = Occupation.new(params[:occupation])
      @occupation.save!
      redirect_to admin_occupation_path(@occupation),
          notice: t('common_label.model_was_created', :model => Occupation.model_name.human)
    rescue => ex
      set_error(ex, :occupation, :save)
      render action: 'new'
      return
    end
  end
  
  ##
  # 職種情報 更新処理
  # PUT /admin/occupations/1
  #
  def update
    begin
      @occupation = Occupation.find(params[:id])
      @occupation.update_attributes!(params[:occupation])
      redirect_to admin_occupation_path(@occupation),
          notice: t('common_label.model_was_updated', :model => Occupation.model_name.human)
    rescue => ex
      set_error(ex, :occupation, :save)
      render action: 'edit'
      return
    end
  end
  
  ##
  # 職種情報 削除処理
  # DELETE /admin/occupations/1
  #
  def destroy
    begin
      # 直前のURL
      http_referer = request.env["HTTP_REFERER"]
    
      @occupation = Occupation.find(params[:id])
      if Occupation.user_occupation?(@occupation)
        add_error_message(t('errors.messages.inoperable_restriction',
            :model => t('activerecord.models.occupation'),
            :associations => t('activerecord.models.user')))
        redirect_to((http_referer.present?)? http_referer : admin_occupations_url)
      else
        @occupation.destroy
        redirect_to admin_occupations_url
      end
    rescue => ex
      set_error(ex, :occupation, :delete)
      redirect_to((http_referer.present?)? http_referer : admin_occupations_url)
    end
  end
end
