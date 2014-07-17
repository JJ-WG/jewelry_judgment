# encoding: utf-8

#
#= Admin::ExpenseTypesコントローラクラス
#
# Created:: 2012/10/4
#
class Admin::ExpenseTypesController < Admin::AdminController
  ##
  # 経費種類管理機能 一覧画面
  # GET /admin/expense_types
  #
  def index
    @expense_types = ExpenseType.order(:view_order)
        .paginate(:page => params[:page], :per_page => ITEMS_PER_PAGE)
  end
  
  ##
  # 経費種類管理機能 閲覧画面
  # GET /admin/expense_types/1
  #
  def show
    begin
      @expense_type = ExpenseType.find(params[:id])
    rescue
      add_error_message(t('errors.messages.no_data'))
      redirect_to admin_expense_types_url
      return
    end
  end
  
  ##
  # 経費種類情報 新規作成処理
  # GET /admin/expense_types/new
  #
  def new
    @expense_type = ExpenseType.new
  end
  
  ##
  # 経費種類管理機能 編集画面
  # GET /admin/expense_types/1/edit
  #
  def edit
    begin
      @expense_type = ExpenseType.find(params[:id])
    rescue
      add_error_message(t('errors.messages.no_data'))
      redirect_to admin_expense_types_url
      return
    end
  end
  
  ##
  # 経費種類情報 新規作成処理
  # POST /admin/expense_types
  #
  def create
    begin
      @expense_type = ExpenseType.new(params[:expense_type])
      @expense_type.save!
      redirect_to admin_expense_type_path(@expense_type),
          notice: t('common_label.model_was_created', :model => ExpenseType.model_name.human)
    rescue => ex
      set_error(ex, :expense_type, :save)
      render action: 'new'
      return
    end
  end
  
  ##
  # 経費種類情報 更新処理
  # PUT /admin/expense_types/1
  #
  def update
    begin
      @expense_type = ExpenseType.find(params[:id])
      @expense_type.update_attributes!(params[:expense_type])
      redirect_to admin_expense_type_path(@expense_type),
          notice: t('common_label.model_was_updated', :model => ExpenseType.model_name.human)
    rescue => ex
      set_error(ex, :expense_type, :save)
      render action: 'edit'
      return
    end
  end
  
  ##
  # 経費種類情報 削除処理
  # DELETE /admin/expense_types/1
  #
  def destroy
    begin
      # 直前のURL
      http_referer = request.env["HTTP_REFERER"]
      
      @expense_type = ExpenseType.find(params[:id])
      if ExpenseType.expense_expense_type?(@expense_type)
        add_error_message(t('errors.messages.inoperable_restriction',
            :model => t('activerecord.models.expense_type'),
            :associations => t('activerecord.models.expense')))
        redirect_to((http_referer.present?)? http_referer : admin_expense_types_url)
      else
        @expense_type.destroy
        redirect_to admin_expense_types_url
      end
    rescue => ex
      set_error(ex, :expense_type, :delete)
      redirect_to((http_referer.present?)? http_referer : admin_expense_types_url)
    end
  end
end
