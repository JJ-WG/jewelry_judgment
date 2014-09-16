# encoding: utf-8

#
#= Admin::Usersコントローラクラス
#
# Authors:: 青山 ひろ子
# Created:: 2012/10/4
#
class Admin::UsersController < Admin::AdminController
  ##
  # ユーザー管理機能 一覧画面
  # GET /admin/users
  #
  def index
    # 検索する削除状態の初期値を未削除に設定
    if params[:search].nil?
      params[:search] = Hash.new
      params[:search][:deleted] = '0'
    end
    
    # 検索条件（ユーザー名 部分一致）
    search_name_condition = {}
    if params[:search][:name].present?
      search_name_condition = "name LIKE '%" + params[:search][:name] + "%'"
    end
    
    # 検索条件（削除状態）
    if params[:search][:deleted] == '1'
      deleted = true
    else
      deleted = false
    end
    
    # 検索条件によりユーザーを検索
    @users = User.where(get_condition([:section_id, :user_code]))
        .where(search_name_condition)
        .where(:deleted => deleted)
        .order(:name_ruby)
        .paginate(:page => params[:page], :per_page => ITEMS_PER_PAGE)
    
    # 検索条件をセッション変数に保存
    session[:user_condition] = params[:search]
  end
  
  ##
  # ユーザー管理機能 閲覧画面
  # GET /admin/users/1
  #
  def show
    begin
      @user = User.find(params[:id])
      @unit_prices = @user.unit_prices.order('start_date DESC')
    rescue
      add_error_message(t('errors.messages.no_data'))
      redirect_to admin_users_url
      return
    end
  end
  
  ##
  # ユーザー情報 新規作成処理
  # GET /admin/users/new
  #
  def new
    @user = User.new
    
    # === ビュー表示用各種データ作成 ===
    # 部署リストの作成
    @sections_list = Section.sections_list
    
    # セッション情報の工数単価情報をクリア
    session[:edit_unit_prices] = []
  end
  
  ##
  # ユーザー管理機能 編集画面
  # GET /admin/users/1/edit
  #
  def edit
    begin
      @user = User.find(params[:id])
      
      # 全角スペースを半角スペースに変換
      @user.name_ruby = em_space_to_an_space(@user.name_ruby)
      
      # === ビュー表示用各種データ作成 ===
      # 部署リストの作成
      @sections_list = Section.sections_list
      
      unless @user.section_id.blank? then
        @section = Section.find(:first, :conditions => ['id = ?', @user.section_id])
        # 部署が削除済みである場合、部署名をリストに追加
        if @section.deleted
          @sections_list.unshift([@section.name, @section.id])
        end
      end
      
      # DBから工数単価編集用データを取得
      create_unit_prices_from_db
    rescue
      add_error_message(t('errors.messages.no_data'))
      redirect_to admin_users_url
      return
    end
  end
  
  ##
  # ユーザー情報 新規作成処理
  # POST /admin/users
  #
  def create
    begin
      user_attributes = params[:user].reject{|key, value|
        key == 'unit_price_start_date' ||
        key == 'unit_price_unit_price' ||
        key == 'unit_prices'
      }
      @user = User.new(user_attributes)
      
      # 全角スペースを半角スペースに変換
      user_attributes[:name_ruby] = em_space_to_an_space(user_attributes[:name_ruby])
      
      # === ビュー表示用各種データ作成 ===
      @sections_list = Section.sections_list
      
      # 工数単価編集用データを取得
      create_unit_prices_from_attributes(params[:user][:unit_prices_attributes])
      
      raise unless is_valid?(user_attributes)
      
      @user.save!
      
      redirect_to admin_user_path(@user),
          notice: t('common_label.model_was_created', :model => User.model_name.human)
    rescue => ex
      set_error(ex, :user, :save)
      render action: 'new'
      return
    end
  end
  
  ##
  # ユーザー情報 更新処理
  # PUT /admin/users/1
  #
  def update
    begin
      @user = User.find(params[:id])
      
      # === ビュー表示用各種データ作成 ===
      @sections_list = Section.sections_list
      
      user_attributes = params[:user].reject{|key, value|
        key == 'unit_price_start_date' ||
        key == 'unit_price_unit_price'
      }
      
      # 全角スペースを半角スペースに変換
      user_attributes[:name_ruby] = em_space_to_an_space(user_attributes[:name_ruby])
      
      # 工数単価編集用データを取得
      create_unit_prices_from_attributes(params[:user][:unit_prices_attributes])
      
      ActiveRecord::Base.transaction do
        raise unless is_valid?(user_attributes, 'update')
        
        # === 不要データの削除 ===
        # 工数単価
        new_unit_price_ids = []
        @user_unit_prices.each do |unit_price|
          new_unit_price_ids << unit_price.id unless unit_price.id.nil?
        end
        if new_unit_price_ids.blank?
          UnitPrice.destroy_all("user_id = #{@user.id}")
        else
          UnitPrice.destroy_all("user_id = #{@user.id} AND id NOT IN (#{new_unit_price_ids.join(",")})")
        end
        
        # === データ更新 ===
        @user.update_attributes!(user_attributes)
        
        redirect_to admin_user_path(@user),
            notice: t('common_label.model_was_updated', :model => User.model_name.human)
      end
    rescue => ex
      set_error(ex, :user, :save)
      render action: 'edit'
      return
    end
  end
  
  ##
  # ユーザー情報 バリデーション
  #
  # attributes::
  #   ユーザ情報POSTデータ
  # 戻り値::
  #   入力チェックの結果を返す（True=エラーなし/False=エラーあり）
  #
  def is_valid?(attributes, action = 'create')
    # 入力されたデータの保存
    @user.user_rank_cd = attributes[:user_rank_cd]
    @user.section = attributes[:section]
    @user.official_position = attributes[:official_position]
    @user.name = attributes[:name]
    @user.name_ruby = attributes[:name_ruby]
    @user.user_code = attributes[:user_code]
    @user.home_phome_no = attributes[:home_phome_no]
    @user.mobile_phone_no = attributes[:mobile_phone_no]
    @user.mail_address1 = attributes[:mail_address1]
    @user.mail_address2 = attributes[:mail_address2]
    @user.mail_address3 = attributes[:mail_address3]
    @user.login = attributes[:login]
    
    # ユーザー区分
    if attributes[:user_rank_cd].blank?
      @user.errors.add(:user_rank_cd, 'を入力してください。')
    end
    
    # 役職
    if attributes[:official_position].present?
      if attributes[:official_position].length > 20
        @user.errors.add(:official_position, 'は20文字以内で入力してください。')
      end
    end
    
    # 氏名
    if attributes[:name].blank?
      @user.errors.add(:name, 'を入力してください。')
    else
      if attributes[:name].length > 20
        @user.errors.add(:name, 'は20文字以内で入力してください。')
      end
    end
    
    # フリガナ
    if attributes[:name_ruby].blank?
      @user.errors.add(:name_ruby, 'を入力してください。')
    else
      if attributes[:name_ruby].length > 40
        @user.errors.add(:name_ruby, 'は40文字以内で入力してください。')
      end
      
      if !(/^[0-9A-Za-zァ-ヶー 　]+$/ =~ attributes[:name_ruby])
        @user.errors.add(:name_ruby, 'は半角英数字、または半角スペース、または全角カタカナ、または全角スペースを入力してください。')
      end
    end
    
    # ユーザーコード
    if attributes[:user_code].blank?
      @user.errors.add(:user_code, 'を入力してください。')
    else
      if attributes[:user_code].length > 10
        @user.errors.add(:user_code, 'は10文字以内で入力してください。')
      end
      
      if !(/^[0-9A-Za-z]+$/ =~ attributes[:user_code])
        @user.errors.add(:user_code, 'は半角英数字を入力してください。')
      end
      
      if User.exist_user_code(attributes[:id], attributes[:user_code])
        @user.errors.add(:user_code, 'が他ユーザーで使用済みです。')
      end
    end
    
    # 自宅電話番号
    if attributes[:home_phome_no].present?
      if attributes[:home_phome_no].length > 20
        @user.errors.add(:home_phome_no, 'は20文字以内で入力してください。')
      end
      
      if !(/^[0-9-]+$/ =~ attributes[:home_phome_no])
        @user.errors.add(:home_phome_no, 'は半角数字、またはハイフンを入力してください。')
      end
    end
    
    # 携帯番号
    if attributes[:mobile_phone_no].present?
      if attributes[:mobile_phone_no].length > 20
        @user.errors.add(:mobile_phone_no, 'は20文字以内で入力してください。')
      end
      
      if !(/^[0-9-]+$/ =~ attributes[:mobile_phone_no])
        @user.errors.add(:mobile_phone_no, 'は半角数字、またはハイフンを入力してください。')
      end
    end
    
    # メールアドレス1
    if attributes[:mail_address1].blank?
      @user.errors.add(:mail_address1, 'を入力してください。')
    else
      if attributes[:mail_address1].length > 40
        @user.errors.add(:mail_address1, 'は40文字以内で入力してください。')
      end
      
      if !(/^[0-9A-Za-z!"#\$%&'()*+,-.\/;;<=>?@_]+$/ =~ attributes[:mail_address1])
        @user.errors.add(:mail_address1, 'は半角英数字、または記号を入力してください。')
      end
    end
    
    # メールアドレス2
    if attributes[:mail_address2].present?
      if attributes[:mail_address2].length > 40
        @user.errors.add(:mail_address2, 'は40文字以内で入力してください。')
      end
      
      if !(/^[0-9A-Za-z!"#\$%&'()*+,-.\/;;<=>?@_]+$/ =~ attributes[:mail_address2])
        @user.errors.add(:mail_address2, 'は半角英数字、または記号を入力してください。')
      end
    end
    
    # メールアドレス3
    if attributes[:mail_address3].present?
      if attributes[:mail_address3].length > 40
        @user.errors.add(:mail_address3, 'は40文字以内で入力してください。')
      end
      
      if !(/^[0-9A-Za-z!"#\$%&'()*+,-.\/;;<=>?@_]+$/ =~ attributes[:mail_address3])
        @user.errors.add(:mail_address3, 'は半角英数字、または記号を入力してください。')
      end
    end
    
    # ログインID
    if attributes[:login].blank?
      @user.errors.add(:login, 'を入力してください。')
    else
      if attributes[:login].length > 20
        @user.errors.add(:login, 'は20文字以内で入力してください。')
      end
      
      if !(/^[0-9A-Za-z!"#\$%&'()*+,-.\/;;<=>?@_]+$/ =~ attributes[:login])
        @user.errors.add(:login, 'は半角英数字、または記号を入力してください。')
      end
      
      if User.exist_login(attributes[:id], attributes[:login])
        @user.errors.add(:login, 'が他ユーザーで使用済みです。')
      end
    end
    
    # パスワード
    if attributes[:password].blank?
      if action == 'create'
        @user.errors.add(:password, 'を入力してください。')
      end
    else
      if attributes[:password].length < 6
        @user.errors.add(:password, 'は6文字以上で入力してください。')
      end
      
      if attributes[:password].length > 20
        @user.errors.add(:password, 'は20文字以内で入力してください。')
      end
      
      if !(/^[0-9A-Za-z!"#\$%&'()*+,-.\/;;<=>?@_]+$/ =~ attributes[:password])
        @user.errors.add(:password, 'は半角英数字、または記号を入力してください。')
      end
    end
    
    # パスワード（再入力）
    if attributes[:password_confirmation].blank?
      if action == 'create' || attributes[:password].present?
        @user.errors.add(:password_confirmation, 'を入力してください。')
      end
    else
      if attributes[:password_confirmation].length < 6
        @user.errors.add(:password_confirmation, 'は6文字以上で入力してください。')
      end
      
      if attributes[:password_confirmation].length > 20
        @user.errors.add(:password_confirmation, 'は20文字以内で入力してください。')
      end
      
      if !(/^[0-9A-Za-z!"#\$%&'()*+,-.\/;;<=>?@_]+$/ =~ attributes[:password_confirmation])
        @user.errors.add(:password_confirmation, 'は半角英数字、または記号を入力してください。')
      end
      
      if attributes[:password] != attributes[:password_confirmation]
        @user.errors.add(:password, 'が一致しません。')
      end
    end
    
    if @user.errors.blank?
      return true
    else
      return false
    end
  end
  
  ##
  # ユーザー情報 削除処理
  # DELETE /admin/users/1
  #
  def destroy
    # 直前のURL
    http_referer = request.env["HTTP_REFERER"]
    
    begin
      @user = User.find(params[:id])
      
      # 削除チェック
      if @user.deleted?
        raise t('errors.messages.model_is_deleted',
                :model => User.model_name.human)
      end
      
      # ユーザーの削除状態を変更する
      @user.deleted = true
      @user.save!(:validate => false)
      
      redirect_to((http_referer.present?)? http_referer : admin_users_url)
    rescue => ex
      set_error(ex, :user, :delete)
      redirect_to((http_referer.present?)? http_referer : admin_users_url)
      return
    end
  end
  
  ##
  # ユーザー情報 復活処理
  # put /admin/users/1/restore
  #
  def restore
    # 直前のURL
    http_referer = request.env["HTTP_REFERER"]
    
    begin
      @user = User.find(params[:id])
      
      # 削除チェック
      unless @user.deleted?
        raise t('errors.messages.model_is_alive',
                :model => User.model_name.human)
      end
      
      # ユーザーの削除状態を変更する
      @user.deleted = false
      @user.save!(:validate => false)
      
      redirect_to((http_referer.present?)? http_referer : admin_users_url)
    rescue => ex
      set_error(ex, :user, :restore)
      redirect_to((http_referer.present?)? http_referer : admin_users_url)
      return
    end
  end
  
  ##
  # ユーザ管理機能 登録・編集（1日あたりの工数単価追加）
  # GET /admin/users/on_click_unit_price_add
  #
  def on_click_unit_price_add
    # ユーザ情報を取得
    if params[:user_id].present? && params[:user_id] != ''
      begin
        @user = User.find(params[:user_id])
      rescue
        add_error_message(t('errors.messages.no_data'))
        redirect_to admin_users_path
        return
      end
    else
      @user = User.new
    end
    
    # 工数単価の入力チェック
    unless is_valid_unit_price
      # セッション情報に現在編集中の工数単価情報を保存
      session[:edit_unit_prices] << ['', params[:unit_price_start_date].to_date,
          params[:unit_price_unit_price]]
      
      # 適用開始日を昇順にソート
      session[:edit_unit_prices].sort{|p, q| p[1]<=>q[1]}
      session[:edit_unit_prices].reverse!
    end
    
    # 工数単価編集コントロールの表示
    set_unit_price_select_control
    render
  end
  
  ##
  # ユーザ管理機能 登録・編集（1日あたりの工数単価削除）
  # GET /admin/users/on_click_unit_price_delete
  #
  def on_click_unit_price_delete
    # ユーザ情報を取得
    if params[:user_id].present? && params[:user_id] != ''
      begin
        @user = User.find(params[:user_id])
      rescue
        add_error_message(t('errors.messages.no_data'))
        redirect_to admin_users_path
        return
      end
    else
      @user = User.new
    end
    
    # 適用開始日が最新の工数単価を工数単価リストから削除
    if session[:edit_unit_prices].size != 0
      # セッション情報から工数単価を削除
      session[:edit_unit_prices].delete_at(0)
      
      # 工数単価入力エラーメッセージのリセット
      reset_unit_price_valid_error
    end
    
    # 工数単価編集コントロールの表示
    set_unit_price_select_control
    render
  end
  
  # 以下、プライベートメソッド
private
  
  ## 
  # 工数単価編集コントロールの表示
  #
  def set_unit_price_select_control
    # セッション情報から現在編集中の工数単価リストを作成
    unit_prices = []
    if session[:edit_unit_prices].present?
      unit_prices = session[:edit_unit_prices]
    end
    
    @user_unit_prices = []
    unit_prices.each do |unit_price|
      user_unit_price = nil
      if unit_price[0].present? && unit_price[1].present?
        user_unit_price = UnitPrice.where(:user_id => unit_price[0],
                                          :start_date => unit_price[1])
                                   .first
      end
      if user_unit_price.nil?
        user_unit_price = UnitPrice.new
        user_unit_price.user_id = unit_price[0]
        user_unit_price.start_date = unit_price[1]
      end
      user_unit_price.unit_price = unit_price[2]
      @user_unit_prices << user_unit_price
    end
  end
  
  ## 
  # 工数単価入力エラーメッセージのリセット
  #
  def reset_unit_price_valid_error
    @unit_price_start_date_error = ''
    @unit_price_unit_price_error = ''
  end
  
  ## 
  # 工数単価追加時の入力チェック
  #
  # 戻り値::
  #   入力チェックの結果を返す（True=エラーあり/False=エラーなし）
  #
  def is_valid_unit_price
    error_flag = false
    
    # 工数単価入力エラーメッセージのリセット
    reset_unit_price_valid_error
    
    # == 入力チェック ==
    # 適用開始日
    if params[:unit_price_start_date].present?
      begin
        start_date = params[:unit_price_start_date].to_date
      rescue
        error_flag = true
        @unit_price_start_date_error = '適用開始日は不正な値です。'
      end
      if !error_flag && !latest_unit_price_start_date
        error_flag = true
        @unit_price_start_date_error = '他の適用開始日より後の日付を入力してください。'
      end
    else
      error_flag = true
      @unit_price_start_date_error = '適用開始日を入力してください。'
    end
    # 工数単価
    if params[:unit_price_unit_price].present?
      if !(params[:unit_price_unit_price] =~ /^[+-]?[0-9]+$/)
        error_flag = true
        @unit_price_unit_price_error = '工数単価は整数で入力してください。'
      elsif params[:unit_price_unit_price].to_i > 9999999999
        error_flag = true
        @unit_price_unit_price_error = '工数単価は9999999999以下で入力してください。'
      elsif params[:unit_price_unit_price].to_i < 0
        error_flag = true
        @unit_price_unit_price_error = '工数単価は0以上で入力してください。'
      end
    else
      error_flag = true
      @unit_price_unit_price_error = '工数単価を入力してください。'
    end
    
    return error_flag
  end
  
  ##
  # 入力された工数単価の適用開始日が他の適用開始日より後か
  # 
  # 戻り値::
  #   true:後 / false:後ではない
  #
  def latest_unit_price_start_date
    flag = true
    session[:edit_unit_prices].each do |edit_unit_price|
      # セッション情報と比較
      if params[:unit_price_start_date].to_date <= edit_unit_price[1]
        flag = false
      end
    end
    return flag
  end
  
  ## 
  # DBから工数単価編集用データを取得する（ユーザー編集画面用）
  #   メソッド内で下記の変数を更新
  #     @user_unit_prices::
  #       工数単価リスト
  #
  def create_unit_prices_from_db
    # 現在編集中の工数単価をセッション情報に保存
    @user_unit_prices = UnitPrice.where(:user_id => @user.id)
    session[:edit_unit_prices] = []
    @user_unit_prices.each{|unit_price|
      session[:edit_unit_prices] <<
          [unit_price.id, unit_price.start_date, unit_price.unit_price]
    }
  end
  
  ## 
  # attributesから工数単価編集用データを取得する
  #   メソッド内で下記の変数を更新
  #     @user_unit_price::
  #       工数単価リスト
  #     @error_messages_list
  #       エラーメッセージリスト
  # 
  # attributes::
  #   工数単価POSTデータ
  # 
  def create_unit_prices_from_attributes(attributes)
    @user_unit_prices = []
    if attributes.present?
      attributes.each_with_index do |unit_price_data, index|
        unit_price_param = attributes.fetch(index.to_s)
        
        unit_price = nil
        if unit_price_param[:user_id].present? && unit_price_param[:start_date].present?
          unit_price = UnitPrice.where(:user_id => unit_price_param[:user_id],
                                       :start_date => unit_price_param[:start_date])
                                .first
        end
        if unit_price.nil?
          unit_price = UnitPrice.new
          unit_price.user_id = unit_price_param[:user_id]
          unit_price.start_date = unit_price_param[:start_date]
        end
        
        unit_price.unit_price = unit_price_param[:unit_price]
        @user_unit_prices << unit_price
      end
    end
  end
end
