# encoding: utf-8

#
#= Nego::Dealsコントローラクラス
#
# Created:: 2013/01/07
#
class Nego::DealsController < Nego::NegoController

  # コントローラのメソッドをviewでも使えるように設定
  helper_method :creatable?, :viewable?, :editable?, :deletable?

  ##
  # 商談管理機能 一覧画面
  # GET /nego/deals
  #
  def index
    create_search_detail
    @deals = @deals.paginate(:page => params[:page], :per_page => DEAL_ITEMS_PER_PAGE)
  end

  ##
  # 商談情報 管理機能 閲覧画面
  # GET /nego/deals/1
  #
  def show
    # 商談情報を取得
    begin
      @deal = Deal.find(params[:id])
    rescue
      add_error_message(t('errors.messages.no_data'))
      redirect_to nego_deals_path
      return
    end

    # 閲覧の権限チェック
    unless viewable?(@deal)
      add_error_message(t('errors.messages.not_permitted'))
      redirect_to :top
      return
    end
  end

  ##
  # 商談情報 新規作成処理
  # GET /nego/deals/new
  #
  def new
    # 新規作成の権限チェック
    unless creatable?
      add_error_message(t('errors.messages.not_permitted'))
      redirect_to :top
      return
    end

    # プロジェクト情報を作成
    @deal = Deal.new({prj_managed: true,
                      reliability_cd: RELIABILITY_CODE[:start_deal],
                      deal_status_cd: DEAL_STATUS_CODE[:under_negotiation] })
  end

  ##
  # 商談情報管理機能 編集画面
  # GET /nego/deals/1/edit
  #
  def edit
    # 商談情報を取得
    begin
      @deal = Deal.find(params[:id])
    rescue
      add_error_message(t('errors.messages.no_data'))
      redirect_to nego_deals_path
      return
    end

    # 編集の権限チェック
    unless editable?(@deal)
      add_error_message(t('errors.messages.not_permitted'))
      redirect_to :top
      return
    end
  end

  ##
  # 商談情報 新規作成処理
  # POST /nego/deals
  #
  def create
    # 新規作成の権限チェック
    unless creatable?
      add_error_message(t('errors.messages.not_permitted'))
      redirect_to :top
      return
    end

    begin
      # エラーメッセージリスト
      @error_messages_list = []
      
      # DB登録用attributes
      @deal_attributes = params[:deal].dup
      
      ActiveRecord::Base.transaction do
        @deal_attributes = @deal_attributes.reject{|key, value|
          key == 'adoption_period' || key == 'delivery_period'
        }

        # 選定時期
        unless params[:deal][:adoption_period][:year].blank? || params[:deal][:adoption_period][:month].blank?
          @deal_attributes[:adoption_period] = Date.new(params[:deal][:adoption_period][:year].to_i, 
                                                        params[:deal][:adoption_period][:month].to_i).strftime(Deal::PERIOD_DATE_FORMAT)
        end

        # 導入時期
        unless params[:deal][:delivery_period][:year].blank? || params[:deal][:delivery_period][:month].blank?
          @deal_attributes[:delivery_period] = Date.new(params[:deal][:delivery_period][:year].to_i, 
                                                        params[:deal][:delivery_period][:month].to_i).strftime(Deal::PERIOD_DATE_FORMAT)
        end

        # 商談情報のDB登録
        @deal = Deal.new(@deal_attributes)
        @deal.save!

        upload_files(@deal)
        
        redirect_to nego_deal_path(@deal),
            notice: t('common_label.model_was_created',
            :model => Deal.model_name.human)
      end
    rescue => ex
      set_error(ex, :deal, :save)

      if @error_messages_list.size != 0
        for i in 0..@error_messages_list.size-1
          add_error_message(@error_messages_list[i], true)
        end
      end
      render action: 'new'
      return
    end
  end

  ##
  # 商談情報 更新処理
  # PUT /nego/deals/1
  #
  def update
    # 商談情報を取得
    begin
      @deal = Deal.find(params[:id])
    rescue
      add_error_message(t('errors.messages.no_data'))
      redirect_to nego_deals_path
      return
    end
    
    # 編集の権限チェック
    unless editable?(@deal)
      add_error_message(t('errors.messages.not_permitted'))
      redirect_to :top
      return
    end

    begin
      # エラーメッセージリスト
      @error_messages_list = []
      
      # DB登録用attributes
      @deal_attributes = params[:deal].dup
      
      ActiveRecord::Base.transaction do
        @deal_attributes = @deal_attributes.reject{|key, value|
          key == 'adoption_period' || key == 'delivery_period'
        }

        # 選定時期
        unless params[:deal][:adoption_period][:year].blank? || params[:deal][:adoption_period][:month].blank?
          @deal_attributes[:adoption_period] = Date.new(params[:deal][:adoption_period][:year].to_i, 
                                                        params[:deal][:adoption_period][:month].to_i).strftime(Deal::PERIOD_DATE_FORMAT)
        end

        # 導入時期
        unless params[:deal][:delivery_period][:year].blank? || params[:deal][:delivery_period][:month].blank?
          @deal_attributes[:delivery_period] = Date.new(params[:deal][:delivery_period][:year].to_i, 
                                                        params[:deal][:delivery_period][:month].to_i).strftime(Deal::PERIOD_DATE_FORMAT)
        end

        # === データ更新 ===
        @deal.update_attributes!(@deal_attributes)

        upload_files(@deal)

        redirect_to nego_deal_path(@deal),
            notice: t('common_label.model_was_updated',
            :model => Deal.model_name.human)
      end
    rescue => ex
      set_error(ex, :deal, :save)
      if @error_messages_list.size != 0
        for i in 0..@error_messages_list.size-1
          add_error_message(@error_messages_list[i], true)
        end
      end
      render action: 'edit'
      return
    end
  end

  ##
  # 商談情報 削除処理
  # DELETE /nego/deals/1
  #
  def destroy
    # 商談情報を取得
    begin
      deal = Deal.find(params[:id])
    rescue
      flash[:error] = t('errors.messages.no_data')
      redirect_to nego_deals_path
      return
    end
    
    # 権限チェック
    if !deletable?(deal)
      flash[:error] = t('errors.messages.not_permitted')
      redirect_to :top
      return
    end
    
    begin
      ActiveRecord::Base.transaction do
        # 商談報告情報の削除
        deal.sales_reports.each {|report| SalesReport.logic_delete(report) }

        deal.deleted = true
        deal.save!(:validate => false)

        # 削除関連ファイルディレクトリ
        FileUtils.remove_dir(deal.related_file_path, true)
      end
    rescue => ex
      set_error(ex, :deal, :delete, deal.name)
      redirect_to nego_deal_path(deal)
      return
    end

    # 一覧画面を表示する
    redirect_to nego_deals_path,
        notice: t('common_label.model_was_deleted',
                  :model => Deal.model_name.human)
  end

  ##
  # 商談情報 CSV出力処理
  # GET /nego/deals/csv_export
  #
  def csv_export
    create_search_detail
    file_name = Rails.configuration.deal_csv_file_name + "_#{Time.now.strftime('%Y%m%d%H%M%S')}.csv"
    send_data(
      Deal.csv_content_for(@deals).encode(Encoding::SJIS),
      disposition: 'attachment',
      type: "text/csv;charset=shift_jis;header=present",
      filename: ERB::Util.url_encode(file_name)
    )
  end

  ##
  # 商談情報関連資料 削除処理
  # DELETE /nego/deals/1/delete_related_file
  #
  def delete_related_file
    # 商談情報を取得
    begin
      @deal = Deal.find(params[:id])
    rescue
      add_error_message(t('errors.messages.no_data'))
      redirect_to nego_deals_path
      return
    end

    @deal_delete_file_error_message = []
    begin
      @deal.delete_related_file(params[:filename])
    rescue
      @deal_delete_file_error_message << t('errors.messages.delete_error', model: t('label.deal_reflection.label.related_file'))
    end

    respond_to do |format|
      format.js { render partial: 'show_related_file_list', :content_type => 'text/javascript' }
    end
  end

  ##
  # 商談情報関連資料 ダウンロード処理
  # GET /nego/deals/1/download_related_file
  #
  def download_related_file
    # 商談情報を取得
    begin
      @deal = Deal.find(params[:id])
    rescue
      add_error_message(t('errors.messages.no_data'))
      redirect_to nego_deals_path
      return
    end

    begin
      send_file(@deal.related_file_path(params[:filename]), :filename => ERB::Util.url_encode(params[:filename]))
    rescue
      add_error_message(t('errors.messages.download_error'))
      if params[:src_action] && params[:src_action] == 'show'
        redirect_to nego_deal_path(@deal)
      else
        redirect_to edit_nego_deal_path(@deal)
      end
    end
  end

private
  ##
  # 検索処理
  #
  def create_search_detail
    params[:search] ||= {}
    relation  = Deal
    unless params[:search][:name].blank?
      relation = relation.where("deals.name LIKE ?", "%#{params[:search][:name].strip}%")
    end
    unless params[:search][:customer_id].blank?
      relation = relation.where(:customer_id => params[:search][:customer_id])
    end
    unless params[:search][:staff_user_name].blank?
      relation = relation.joins(:staff_user).where("users.name LIKE ?", "%#{params[:search][:staff_user_name].strip}%")
    end
    unless params[:search][:pref_code].blank?
      relation = relation.joins(:customer).where(:customers => {pref_cd: params[:search][:pref_code]})
    end
    unless params[:search][:deal_status_cd].blank?
      relation = relation.where(:deal_status_cd => params[:search][:deal_status_cd])
    end
    unless params[:search][:reliability_cd].blank?
      relation = relation.where(:reliability_cd => params[:search][:reliability_cd])
    end
    @deals = relation.list
  end

  ##
  # ログインユーザが新規作成可能か
  #
  # 戻り値::
  #   ログインユーザのユーザ権限が「一般社員以上」かつロール権限が「営業担当」の場合、trueを返す。
  # 
  def creatable?
    # TODO dairg QA7 保留 営業担当の判断
    current_user && (current_user.user_rank_cd >= USER_RANK_CODE[:employee])
  end

  ##
  # ログインユーザが編集可能か
  #
  # deal:
  #   対象商談情報
  #
  # 戻り値::
  #   ログインユーザのユーザ権限が「一般社員以上」かつロール権限が「営業担当」の場合、trueを返す。
  # 
  def editable?(deal)
    # TODO dairg QA7 保留 営業担当の判断
    current_user && (current_user.user_rank_cd >= USER_RANK_CODE[:employee])
  end

  ##
  # ログインユーザが閲覧可能か
  #
  # deal:
  #   対象商談情報
  #
  # 戻り値::
  #   ログインユーザのユーザ権限が「一般社員以上」かつロール権限が「営業担当」の場合、または
  #   ログインユーザのユーザ権限が「マネージャー」以上の場合、trueを返す。
  # 
  def viewable?(deal)
    return true if (administrator? || manager?)
    # TODO dairg QA7 保留 営業担当の判断
    return current_user && (current_user.user_rank_cd >= USER_RANK_CODE[:employee])
  end

  ##
  # ログインユーザが削除可能か
  #
  # deal:
  #   対象商談情報
  #
  def deletable?(deal)
    return false if deal && deal.project.present?
    current_user && (current_user.user_rank_cd >= USER_RANK_CODE[:employee])
  end

  ##
  # ファイルのアップロード処理
  #
  # deal:
  #   対象商談情報
  #
  # 戻り値::
  #   なし
  # 
  def upload_files(deal)
    filenames = []
    dirpath = deal.related_file_path

    5.times do |i|
      if params["file#{i}"].present?
        if deal.exist_file?(params["file#{i}"].original_filename)
          # 同じファイルが存在している場合
          raise t('label.deal_reflection.errors.related_file_server_exist_error', :filename => params["file#{i}"].original_filename)
        end
        if params["file#{i}"].size > DEAL_FILE_SIZE_LIMIT
          # ファイルサイズ制限エラー
          raise t('label.deal_reflection.errors.related_file_size_error', :filename => params["file#{i}"].original_filename, :size => (DEAL_FILE_SIZE_LIMIT/(1024*1024)))
        end
        if filenames.include?(params["file#{i}"].original_filename)
          # 同じなファイル名選択エラー
          raise t('label.deal_reflection.errors.related_file_duplication_select_error', :filename => params["file#{i}"].original_filename)
        end
        filenames << params["file#{i}"].original_filename
      end
    end

    begin
      FileUtils.mkdir_p(dirpath) unless File.exist?(dirpath)

      5.times do |i|
        if params["file#{i}"].present?
          File.open(deal.related_file_path(params["file#{i}"].original_filename), 'w+b') { |file| file.write(params["file#{i}"].read) }
        end
      end
    rescue => ex
      # ファイルアップロード失敗
      raise 'ファイル書き込み失敗しました。'
    end
  end
end
