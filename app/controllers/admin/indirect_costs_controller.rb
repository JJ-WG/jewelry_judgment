# encoding: utf-8

#
#= Admin::IndirectCostsコントローラクラス
#
# Created:: 2012/10/4
#
class Admin::IndirectCostsController < Admin::AdminController
  ##
  # 間接労務費管理機能 一覧画面
  # GET /admin/indirect_costs
  #
  def index
    @indirect_costs = IndirectCost.order('start_date DESC')
        .paginate(:page => params[:page], :per_page => ITEMS_PER_PAGE)
  end
  
  ##
  # 間接労務費管理機能 閲覧画面
  # GET /admin/indirect_costs/1
  #
  def show
    begin
      @indirect_cost = IndirectCost.find(params[:id])
    rescue
      add_error_message(t('errors.messages.no_data'))
      redirect_to admin_indirect_costs_url
      return
    end
  end
  
  ##
  # 顧客情報 新規作成処理
  # GET /admin/indirect_costs/new
  #
  def new
    @indirect_cost = IndirectCost.new
    @indirect_cost_method_cd = ''
    
    # 間接労務費の計算方法の初期値
    indirect_cost_data = IndirectCost.order('start_date DESC').first
    if indirect_cost_data.present?
      @indirect_cost.indirect_cost_method_cd = indirect_cost_data.indirect_cost_method_cd
    else
      @indirect_cost.indirect_cost_method_cd = INDIRECT_COST_METHOD_CODE[:method1]
    end
    
    # 適用開始日の初期値
    @start_date = (@indirect_cost.start_date.blank?)?
        Time.now.strftime(DB_DATE_FORMAT) : @indirect_cost.start_date.strftime(DB_DATE_FORMAT)
    
    # 間接労務費率
    @indirect_cost_ratios = []
    INDIRECT_COST_SUBJECT_CODE.each_value do |subject_cd|
      ORDER_TYPE_CODE.each_value do |order_type_cd|
        indirect_cost_ratio = IndirectCostRatio.new
        indirect_cost_ratio.indirect_cost_subject_cd = subject_cd
        indirect_cost_ratio.order_type_cd = order_type_cd
        @indirect_cost_ratios << indirect_cost_ratio
      end
    end
  end
  
  ##
  # 間接労務費管理機能 編集画面
  # GET /admin/indirect_costs/1/edit
  #
  def edit
    begin
      @indirect_cost = IndirectCost.find(params[:id])
      @start_date = @indirect_cost.start_date.strftime(DB_DATE_FORMAT)
      
      # DBから間接労務費率編集用データを取得
      @indirect_cost_ratios = @indirect_cost.indirect_cost_ratios
    rescue
      add_error_message(t('errors.messages.no_data'))
      redirect_to admin_indirect_costs_url
      return
    end
  end
  
  ##
  # 間接労務費情報 新規作成処理
  # POST /admin/indirect_costs
  #
  def create
    begin
      # エラーメッセージリスト
      @error_messages_list = []
      
      indirect_cost_attributes = params[:indirect_cost]
      @indirect_cost = IndirectCost.new(indirect_cost_attributes)
      @start_date = indirect_cost_attributes[:start_date]
      
      # 間接労務比率編集用データを取得
      create_indirect_cost_ratios_from_attributes(
          indirect_cost_attributes[:indirect_cost_ratios_attributes])
      
      ActiveRecord::Base.transaction do
        # エラーが発生していた場合、例外処理
        raise if @error_messages_list.size != 0
        
        @indirect_cost.save!
        redirect_to admin_indirect_cost_path(@indirect_cost),
            notice: t('common_label.model_was_created', :model => IndirectCost.model_name.human)
      end
    rescue => ex
      set_error(ex, :indirect_cost, :save)
      if @error_messages_list.size != 0
        @error_messages_list.uniq!
        for i in 0..@error_messages_list.size-1
          add_error_message(@error_messages_list[i], true)
        end
      end
      render action: 'new'
      return
    end
  end
  
  ##
  # 間接労務費情報 更新処理
  # PUT /admin/indirect_costs/1
  #
  def update
    begin
      # エラーメッセージリスト
      @error_messages_list = []
      
      indirect_cost_attributes = params[:indirect_cost]
      
      @indirect_cost = IndirectCost.find(params[:id])
      @start_date = indirect_cost_attributes[:start_date]
      
      # 間接労務比率編集用データを取得
      create_indirect_cost_ratios_from_attributes(
          indirect_cost_attributes[:indirect_cost_ratios_attributes])
            
      ActiveRecord::Base.transaction do
        # エラーが発生していた場合、例外処理
        raise if @error_messages_list.size != 0
        
        # === 不要データの削除 ===
        # 工数単価
        new_indirect_cost_ids = []
        @indirect_cost_ratios.each do |indirect_cost|
          new_indirect_cost_ids << indirect_cost.id unless indirect_cost.id.nil?
        end
        if new_indirect_cost_ids.blank?
          IndirectCostRatio.destroy_all("indirect_cost_id = #{@indirect_cost.id}")
        else
          IndirectCostRatio.destroy_all("indirect_cost_id = #{@indirect_cost.id} AND id NOT IN (#{new_indirect_cost_ids.join(",")})")
        end
        
        # === データ更新 ===
        @indirect_cost.update_attributes!(indirect_cost_attributes)
        redirect_to admin_indirect_cost_path(@indirect_cost),
            notice: t('common_label.model_was_updated', :model => IndirectCost.model_name.human)
      end
    rescue => ex
      set_error(ex, :indirect_cost, :save)
      if @error_messages_list.size != 0
        @error_messages_list.uniq!
        for i in 0..@error_messages_list.size-1
          add_error_message(@error_messages_list[i], true)
        end
      end
      render action: 'edit'
      return
    end
  end
  
  ##
  # 間接労務費情報 削除処理
  # DELETE /admin/indirect_costs/1
  #
  def destroy
    begin
      # 直前のURL
      http_referer = request.env["HTTP_REFERER"]
      
      @indirect_cost = IndirectCost.find(params[:id])
      
      ActiveRecord::Base.transaction do
        # 間接労務費率を削除
        @indirect_cost.indirect_cost_ratios.each do |indirect_cost_ratio|
            indirect_cost_ratio.destroy
        end
        
        @indirect_cost.destroy
        redirect_to admin_indirect_costs_url
      end
    rescue => ex
      set_error(ex, :indirect_cost, :delete)
      redirect_to((http_referer.present?)? http_referer : admin_indirect_costs_url)
    end
  end
  
  ## 
  # attributesから間接労務費率編集用データを取得する
  #   メソッド内で下記の変数を更新
  #     @indirect_cost_ratios::
  #       間接労務費率リスト
  #     @error_messages_list::
  #       エラーメッセージリスト 
  #
  # attributes::
  #   間接労務費率POSTデータ
  # 
  def create_indirect_cost_ratios_from_attributes(attributes)
    @indirect_cost_ratios = []
    if attributes.present?
      attributes.each_with_index do |indirect_cost_ratio, index|
        indirect_cost_ratio_param = attributes.fetch(index.to_s)
        
        # 入力チェック
        is_valid_essential_number(indirect_cost_ratio_param[:ratio],
            t('activerecord.attributes.indirect_cost_ratio.ratio'))
        
        indirect_cost_ratio = nil
        if indirect_cost_ratio_param[:indirect_cost_id].present? &&
            indirect_cost_ratio_param[:indirect_cost_subject_cd].present? &&
            indirect_cost_ratio_param[:order_type_cd].present?
          indirect_cost_ratio =
              IndirectCostRatio.where(:indirect_cost_id => indirect_cost_ratio_param[:indirect_cost_id],
                                      :indirect_cost_subject_cd => indirect_cost_ratio_param[:indirect_cost_subject_cd],
                                      :order_type_cd => indirect_cost_ratio_param[:order_type_cd])
                               .first
        end
        if indirect_cost_ratio.nil? 
          indirect_cost_ratio = IndirectCostRatio.new
          indirect_cost_ratio.indirect_cost_id =
              indirect_cost_ratio_param[:indirect_cost_id]
          indirect_cost_ratio.indirect_cost_subject_cd =
              indirect_cost_ratio_param[:indirect_cost_subject_cd]
          indirect_cost_ratio.order_type_cd =
              indirect_cost_ratio_param[:order_type_cd]
        end
        indirect_cost_ratio.ratio = indirect_cost_ratio_param[:ratio]
        @indirect_cost_ratios << indirect_cost_ratio
      end
    end
  end
  
  ##
  # 計算方法変更時の処理
  # GET /indirect_cost/on_change_indirect_cost_method
  #
  def on_click_indirect_cost_method
    if params[:indirect_cost_id].present? && params[:indirect_cost_id] != ''
      begin
        @indirect_cost = IndirectCost.find(params[:indirect_cost_id])
        # DBから間接労務費率編集用データを取得
        @indirect_cost_ratios = @indirect_cost.indirect_cost_ratios
      rescue
        add_error_message(t('errors.messages.no_data'))
        redirect_to admin_indirect_costs_path
        return
      end
    else
      @indirect_cost = IndirectCost.new
    end
    
    @indirect_cost.indirect_cost_method_cd = nil
    if params[:indirect_cost_method_cd].present?
      if INDIRECT_COST_METHOD_CODE.value?(params[:indirect_cost_method_cd].to_i)
        @indirect_cost.indirect_cost_method_cd = params[:indirect_cost_method_cd]
      end
    end
    
    # 間接労務費率
    @indirect_cost_ratios = []
    if @indirect_cost.indirect_cost_method_cd == INDIRECT_COST_METHOD_CODE[:method2]
      ORDER_TYPE_CODE.each_value do |order_type_cd|
        indirect_cost_ratio = nil
        unless @indirect_cost.new_record?
          indirect_cost_ratio =
              IndirectCostRatio.where(:indirect_cost_id => @indirect_cost.id,
                                      :indirect_cost_subject_cd => INDIRECT_COST_SUBJECT_CODE[:employee],
                                      :order_type_cd => order_type_cd)
                               .first
        end
        if indirect_cost_ratio.nil?
          indirect_cost_ratio = IndirectCostRatio.new
          indirect_cost_ratio.indirect_cost_subject_cd = INDIRECT_COST_SUBJECT_CODE[:employee]
          indirect_cost_ratio.order_type_cd = order_type_cd
        end
        
        @indirect_cost_ratios << indirect_cost_ratio
      end
    elsif @indirect_cost.indirect_cost_method_cd == INDIRECT_COST_METHOD_CODE[:method3]
      INDIRECT_COST_SUBJECT_CODE.each_value do |subject_cd|
        ORDER_TYPE_CODE.each_value do |order_type_cd|
          indirect_cost_ratio = nil
          unless @indirect_cost.new_record?
            indirect_cost_ratio =
                IndirectCostRatio.where(:indirect_cost_id => @indirect_cost.id,
                                        :indirect_cost_subject_cd => subject_cd,
                                        :order_type_cd => order_type_cd)
                                 .first
          end
          if indirect_cost_ratio.nil?
            indirect_cost_ratio = IndirectCostRatio.new
            indirect_cost_ratio.indirect_cost_subject_cd = subject_cd
            indirect_cost_ratio.order_type_cd = order_type_cd
          end
          
          @indirect_cost_ratios << indirect_cost_ratio
        end
      end
    end
    render    
  end
  
  ## 
  # 必須入力数値のチェック
  #   メソッド内で下記の変数を更新
  #     @error_messages_list
  #       エラーメッセージリスト
  # 
  # value::
  #   入力チェック対象値
  # name::
  #   入力チェック対象項目名
  # 
  # 戻り値::
  #   エラーがあるかどうか(true/false)
  # 
  def is_valid_essential_number(value, name)
    is_error = false
    if value.blank?
      is_error = true
      @error_messages_list << (name + t('errors.messages.blank'))
    elsif !(value =~ /^[+-]?[0-9]*[\.]?[0-9]+$/)
      is_error = true
      @error_messages_list << (name + t('errors.messages.not_a_number'))
    end
    
    if value.to_f < 0
      is_error = true
      @error_messages_list << (name + t('errors.messages.greater_than_or_equal_to', :count => 0))
    end
    
    if value.to_f > 100
      is_error = true
      @error_messages_list << (name + t('errors.messages.less_than_or_equal_to', :count => 100))
    end
    
    return is_error
  end
end
