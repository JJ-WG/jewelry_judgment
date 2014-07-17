# encoding: utf-8

#
#= Nego::Dealsコントローラクラス
#
# Created:: 2013/02/22
#
class Nego::SalesReportsController < Nego::NegoController
  ##
  # 商談報告情報 新規作成処理
  # GET /nego/deals/1/sales_reports/new
  #
  def new
    # 商談情報を取得
    begin
      @deal = Deal.find(params[:deal_id])
    rescue
      add_error_message(t('errors.messages.no_data'), true)
      render partial: 'close_dialog', :locals => {:has_opened_dialog => false}
      return
    end
    @sales_report = @deal.sales_reports.build

    respond_to do |format|
      format.js { render partial: 'show_dialog' }
    end
  end

  ##
  # 商談報告情報 新規作成処理
  # POST /nego/sales_reports
  #
  def create
    # 商談情報を取得
    begin
      @deal = Deal.find(params[:deal_id])
    rescue
      add_error_message(t('errors.messages.no_data'), true)
      render partial: 'close_dialog', :locals => {:has_opened_dialog => true}
      return
    end

    begin
      # エラーメッセージリスト
      @error_messages_list = []
      
      ActiveRecord::Base.transaction do
        @sales_report = @deal.sales_reports.build(params[:sales_report])
        @sales_report.save!

        render partial: 'close_dialog', :content_type => 'text/javascript'
      end
    rescue => ex
      set_error(ex, :sales_report, :save)

      if @error_messages_list.size != 0
        for i in 0..@error_messages_list.size-1
          add_error_message(@error_messages_list[i], true)
        end
      end
      render partial: 'show_dialog'
      return
    end
  end

  ##
  # 商談情報管理機能 編集画面
  # GET /nego/deals/1/sales_reports/1/edit
  #
  def edit
    # 商談情報を取得
    begin
      @deal = Deal.find(params[:deal_id])
      @sales_report = SalesReport.find(params[:id])
    rescue
      add_error_message(t('errors.messages.no_data'))
      render partial: 'close_dialog', :locals => {:has_opened_dialog => true}
      return
    end

    respond_to do |format|
      format.js { render partial: 'show_dialog' }
    end
  end

  ##
  # 商談情報 更新処理
  # PUT /nego/deals/1/sales_reports/1
  #
  def update
    # 商談情報を取得
    begin
      @deal = Deal.find(params[:deal_id])
      @sales_report = SalesReport.find(params[:id])
    rescue
      add_error_message(t('errors.messages.no_data'))
      render partial: 'close_dialog', :locals => {:has_opened_dialog => true}
      return
    end

    begin
      # エラーメッセージリスト
      @error_messages_list = []
      
      ActiveRecord::Base.transaction do
        @sales_report.update_attributes!(params[:sales_report])

        render partial: 'close_dialog', :content_type => 'text/javascript'
      end
    rescue => ex
      set_error(ex, :sales_report, :save)

      if @error_messages_list.size != 0
        for i in 0..@error_messages_list.size-1
          add_error_message(@error_messages_list[i], true)
        end
      end
      render partial: 'show_dialog'
      return
    end
  end
    
  ##
  # 商談報告 管理機能 閲覧画面
  # GET /nego/deals/1/sales_reports/1
  #
  def show
    begin
      @deal = Deal.find(params[:deal_id])
      @sales_report = SalesReport.find(params[:id])
    rescue
      add_error_message(t('errors.messages.no_data'))
      render partial: 'close_dialog', :locals => {:has_opened_dialog => false}
      return
    end

    respond_to do |format|
      format.js { render partial: 'show_dialog' }
    end
  end

  ##
  # 商談情報 削除処理
  # DELETE /nego/deals/1/sales_reports/1
  #
  def destroy
    begin
      @deal = Deal.find(params[:deal_id])
      @sales_report = SalesReport.find(params[:id])
    rescue
      add_error_message(t('errors.messages.no_data'))
      render partial: 'close_dialog', :locals => {:has_opened_dialog => true}
      return
    end

    begin
      SalesReport.logic_delete(@sales_report)
      render partial: 'close_dialog', :content_type => 'text/javascript'
    rescue => ex
      set_error(ex, :sales_report, :delete)
      render partial: 'show_dialog'
    end
  end
end
