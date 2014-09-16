# encoding: utf-8

#
#= Admin::TaxDivisionsコントローラクラス
#
# Authors:: 青山 ひろ子
# Created:: 2012/10/4
#
class Admin::TaxDivisionsController < Admin::AdminController
  ##
  # 税区分管理機能 一覧画面
  # GET /admin/tax_divisions
  #
  def index
    @tax_divisions = TaxDivision.order(:view_order)
        .paginate(:page => params[:page], :per_page => ITEMS_PER_PAGE)
  end
  
  ##
  # 税区分管理機能 閲覧画面
  # GET /admin/tax_divisions/1
  #
  def show
    begin
      @tax_division = TaxDivision.find(params[:id])
    rescue
      add_error_message(t('errors.messages.no_data'))
      redirect_to admin_tax_divisions_url
      return
    end
  end
  
  ##
  # 税区分情報 新規作成処理
  # GET /admin/tax_divisions/new
  #
  def new
    @tax_division = TaxDivision.new
  end
  
  ##
  # 税区分管理機能 編集画面
  # GET /admin/tax_divisions/1/edit
  #
  def edit
    begin
      @tax_division = TaxDivision.find(params[:id])
    rescue
      add_error_message(t('errors.messages.no_data'))
      redirect_to admin_tax_divisions_url
      return
    end
  end
  
  ##
  # 税区分情報 新規作成処理
  # POST /admin/tax_divisions
  #
  def create
    begin
      @tax_division = TaxDivision.new(params[:tax_division])
      @tax_division.save
      redirect_to admin_tax_division_path(@tax_division),
          notice: t('common_label.model_was_created', :model => TaxDivision.model_name.human)
    rescue => ex
      set_error(ex, :tax_division, :save)
      render action: 'new'
      return
    end
  end
  
  ##
  # 税区分情報 更新処理
  # PUT /admin/tax_divisions/1
  #
  def update
    begin
      @tax_division = TaxDivision.find(params[:id])
      @tax_division.update_attributes!(params[:tax_division])
      redirect_to admin_tax_division_path(@tax_division),
          notice: t('common_label.model_was_updated', :model => TaxDivision.model_name.human)
    rescue => ex
      set_error(ex, :tax_division, :save)
      render action: 'edit'
      return
    end
  end
  
  ##
  # 税区分情報 削除処理
  # DELETE /admin/tax_divisions/1
  #
  def destroy
    begin
      # 直前のURL
      http_referer = request.env["HTTP_REFERER"]
      
      @tax_division = TaxDivision.find(params[:id])
      if TaxDivision.project_tax_division_id?(@tax_division) ||
          TaxDivision.expense_type_tax_division_id?(@tax_division) ||
          TaxDivision.expense_tax_division_id?(@tax_division)
        if TaxDivision.project_tax_division_id?(@tax_division)
          add_error_message(t('errors.messages.inoperable_restriction',
              :model => t('activerecord.models.tax_division'),
              :associations => t('activerecord.models.project')))
        end
        if TaxDivision.expense_type_tax_division_id?(@tax_division)
          add_error_message(t('errors.messages.inoperable_restriction',
              :model => t('activerecord.models.tax_division'),
              :associations => t('activerecord.models.expense_type')))
        end
        if TaxDivision.expense_tax_division_id?(@tax_division)
          add_error_message(t('errors.messages.inoperable_restriction',
              :model => t('activerecord.models.tax_division'),
              :associations => t('activerecord.models.expense')))
        end
        redirect_to((http_referer.present?)? http_referer : admin_tax_divisions_url)
      else
        @tax_division.destroy
        redirect_to admin_tax_divisions_url
      end
    rescue => ex
      set_error(ex, :tax_division, :delete)
      redirect_to((http_referer.present?)? http_referer : admin_tax_divisions_url)
    end
  end
end
