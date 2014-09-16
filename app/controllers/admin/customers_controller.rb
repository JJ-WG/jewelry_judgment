# encoding: utf-8

#
#= Admin::Customersコントローラクラス
#
# Authors:: 青山 ひろ子
# Created:: 2012/10/4
#
class Admin::CustomersController < Admin::AdminController
  ##
  # 顧客管理機能 一覧画面
  # GET /admin/customers
  #
  def index
    if params[:search].nil?
      # 検索条件をクリア
      params[:search] = Hash.new
    end
    
    # 検索条件（顧客名 部分一致）
    search_name_condition = {}
    if params[:search][:name].present?
      search_name_condition = "name LIKE '%" + params[:search][:name] + "%'"
    end
    
    # 検索条件により顧客を検索
    @customers = Customer.where(get_condition([:code]))
        .where(search_name_condition)
        .order(:name_ruby)
        .paginate(:page => params[:page], :per_page => ITEMS_PER_PAGE)
    
    # 検索条件をセッション変数に保存
    session[:customer_condition] = params[:search]
  end
  
  ##
  # 顧客管理機能 閲覧画面
  # GET /admin/customers/1
  #
  def show
    begin
      @customer = Customer.find(params[:id])
    rescue
      add_error_message(t('errors.messages.no_data'))
      redirect_to admin_customers_url
      return
    end
  end
  
  ##
  # 顧客情報 新規作成処理
  # GET /admin/customers/new
  #
  def new
    @customer = Customer.new
  end
  
  ##
  # 顧客管理機能 編集画面
  # GET /admin/customers/1/edit
  #
  def edit
    begin
      @customer = Customer.find(params[:id])
    rescue
      add_error_message(t('errors.messages.no_data'))
      redirect_to admin_customers_url
      return
    end
  end
  
  ##
  # 顧客情報 新規作成処理
  # POST /admin/customers
  #
  def create
    begin
      @customer = Customer.new(params[:customer])
      
      # 全角スペースを半角スペースに変換
      @customer.name_ruby = em_space_to_an_space(@customer.name_ruby)
      
      @customer.save!
      redirect_to admin_customer_path(@customer),
          notice: t('common_label.model_was_created', :model => Customer.model_name.human)
    rescue => ex
      set_error(ex, :customer, :save)
      render action: 'new'
      return
    end
  end
  
  ##
  # 顧客情報 更新処理
  # PUT /admin/customers/1
  #
  def update
    begin
      @customer = Customer.find(params[:id])
      
      # 全角スペースを半角スペースに変換
      params[:customer][:name_ruby] = em_space_to_an_space(params[:customer][:name_ruby])
      
      @customer.update_attributes!(params[:customer])
      redirect_to admin_customer_path(@customer),
          notice: t('common_label.model_was_updated', :model => Customer.model_name.human)
    rescue => ex
      set_error(ex, :customer, :save)
      render action: 'edit'
      return
    end
  end
  
  ##
  # 顧客情報 削除処理
  # DELETE /admin/customers/1
  #
  def destroy
    begin
      # 直前のURL
      http_referer = request.env["HTTP_REFERER"]
      
      @customer = Customer.find(params[:id])
      if Customer.project_customer?(@customer) || Customer.deal_customer?(@customer)
        if Customer.project_customer?(@customer)
          add_error_message(t('errors.messages.inoperable_restriction',
              :model => t('activerecord.models.customer'),
              :associations => t('activerecord.models.project')))
        end
        if Customer.deal_customer?(@customer)
          add_error_message(t('errors.messages.inoperable_restriction',
              :model => t('activerecord.models.customer'),
              :associations => t('activerecord.models.deal')))
        end
        redirect_to((http_referer.present?)? http_referer : admin_customers_url)
      else
        @customer.destroy
        redirect_to admin_customers_url
      end
    rescue => ex
      set_error(ex, :customer, :delete)
      redirect_to((http_referer.present?)? http_referer : admin_customers_url)
    end
  end
end
