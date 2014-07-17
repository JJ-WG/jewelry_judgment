# encoding: utf-8

#
#= Applicationコントローラクラス
#
# Created:: 2012/10/4
#
class ApplicationController < ActionController::Base
  # CSRF対策
  protect_from_forgery
  
  # コントローラのメソッドをviewでも使えるように設定
  helper_method :current_user_session, :current_user
  helper_method :administrator?, :manager?, :employee?, :parttimer?, :project_manager?
  helper_method :get_current_user_can_acccess_projects, :get_current_user_can_acccess_groups
  
  private
  ##
  # カレントユーザーのセッション情報を取得する
  #
  # 戻り値::
  #   カレントユーザーのセッション情報
  #
  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    return @current_user_session = UserSession.find
  end
  
  ##
  # カレントユーザー情報を取得する
  #
  # 戻り値::
  #   カレントユーザー情報
  #
  def current_user
    return @current_user if defined?(@current_user)
    return @current_user = current_user_session && current_user_session.user
  end
  
  ##
  # カレントユーザーがシステム管理者かどうか？
  #
  # 戻り値::
  #   カレントユーザーがシステム管理者の場合、trueを返す
  #
  def administrator?
    return current_user && (current_user.user_rank_cd == USER_RANK_CODE[:system_admin])
  end
  
  ##
  # カレントユーザーがマネージャーかどうか？
  #
  # 戻り値::
  #   カレントユーザーがマネージャーの場合、trueを返す
  #
  def manager?
    return current_user && (current_user.user_rank_cd == USER_RANK_CODE[:manager])
  end

  ##
  # カレントユーザーがプロジェクトマネージャーかどうか？
  #
  # 戻り値::
  #   カレントユーザーがプロジェクトマネージャーの場合、trueを返す
  #
  def project_manager?
    return current_user && (current_user.project_manager?)
  end
  
  ##
  # カレントユーザーが一般社員かどうか？
  #
  # 戻り値::
  #   カレントユーザーが一般社員の場合、trueを返す
  #
  def employee?
    return current_user && (current_user.user_rank_cd == USER_RANK_CODE[:employee])
  end
  
  ##
  # カレントユーザーが外注・アルバイトかどうか？
  #
  # 戻り値::
  #   カレントユーザーが外注・アルバイトの場合、trueを返す
  #
  def parttimer?
    return current_user && (current_user.user_rank_cd == USER_RANK_CODE[:parttimer])
  end
  
  ##
  # 戻り用URLをセッションに保持する
  #
  def store_location
    # undefined method `request_uri'...が表示される場合があるため、修正
    #session[:return_to] = request.request_uri
    session[:return_to] = request.url
  end
  
  ##
  # 戻り用URLもしくは指定されたデフォルトのページへ遷移する
  #
  # default::
  #   デフォルトページURL
  #
  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end
  
  ##
  # ログイン状態でない場合、ログイン画面へ強制遷移する
  #
  def require_user
    unless current_user
      store_location
      redirect_to login_url
      return false
    end
  end
  
  ##
  # システム管理者、またはマネージャーでない場合、トップ画面へ強制遷移する
  #
  def require_system_admin_or_manager
    unless current_user.user_rank_cd == USER_RANK_CODE[:system_admin] ||
        current_user.user_rank_cd == USER_RANK_CODE[:manager]
      flash[:notice] = t('errors.messages.not_permitted')
      redirect_to :top
      return false
    end
  end

  ##
  # システム管理者、マネージャー、または一般社員でない場合、トップ画面へ強制遷移する
  #
  def require_system_admin_or_manager_or_employee
    unless administrator? || manager? || employee?
      flash[:notice] = t('errors.messages.not_permitted')
      redirect_to :top
      return false
    end
  end
  
  ##
  # ログアウト状態でなければエラーとし、ログイン画面へ強制遷移する
  #
  def require_no_user
    if current_user
      store_location
      flash[:notice] = t('authlogic.please_logout')
      redirect_to top_url
      return false
    end
  end
  
  ##
  # アクセス権限がない場合、トップ画面へ強制遷移する（システム管理機能用）
  # ただし、マネージャーの場合は顧客管理画面へ強制遷移する
  #
  def check_authorization_for_admin_menu
    unless administrator?
      if manager?
        unless controller_name == 'customers'
          add_error_message(t('errors.messages.not_permitted'))
          redirect_to admin_customers_url
          return
        end
      else
        add_error_message(t('errors.messages.not_permitted'))
        redirect_to :top
        return
      end
    end
  end
  
  
  ##
  # パラメータから検索用のハッシュを作成する
  # 
  # item_keys::
  #   対象とする検索条件の識別キーの配列
  #
  # 戻り値::
  #   検索用のハッシュを返す
  #
  def get_condition(item_keys)
    conditions = Hash.new
    search = params[:search]
    if search.present? && item_keys.present?
      item_keys.each do |key|
        conditions[key] = search[key] if search[key].present?
      end
    end
    return conditions
  end

  ##
  # 日付値をデータベース格納用に正規化する
  # 
  # date_string::
  #   日付を表す文字列
  #
  # 戻り値::
  #   正規化後の日付文字列を返す。
  #   date_stringが日付として解析できなかった場合はnilを返す。
  #
  def db_date(date_string)
    begin
      return Date.parse(date_string).strftime(DB_DATE_FORMAT)
    rescue
      return nil
    end
  end

  ##
  # エラーメッセージの設定とログ保存
  # 
  # ex:
  #   例外オブジェクト
  # model:
  #   対象モデルを識別するシンボル
  # action:
  #   実行したアクションを識別するシンボル
  #   - :save 保存
  #   - :delete 削除
  #   - :restore 復活
  #   - :finish 完了
  #   - :start 開始
  #   - :lock ロック
  #   - :unlock ロック解除
  # item::
  #   対象データの名称を示す文字列（省略可）
  #
  def set_error(ex, model, action, item_name = nil)
      title = set_error_title(model, action, item_name)
      if ex.message.present?
        logger.error(title + ': ' + ex.message)
        add_error_message(ex.message, true) if ex.class == RuntimeError
      else
        logger.error(title)
      end
      logger.debug(ex) if ex.class != RuntimeError
  end

  ##
  # バリデーションエラーメッセージの設定とログ保存
  # 
  # models:
  #   対象モデルのARインスタンスの配列
  #
  def add_validation_errors(models)
    models = [models] unless models.is_a?(Enumerable)
    models.each do |model|
      if model.present? && model.errors.any?
        model.errors.full_messages.each do |msg|
          add_error_message(msg, true)
          logger.error(msg)
        end
      end
    end
  end

  ##
  # エラーメッセージのタイトルを設定する
  # 
  # model::
  #   対象モデルを識別するシンボル
  # action::
  #   実行したアクションを識別するシンボル
  #   - :save 保存
  #   - :delete 削除
  #   - :restore 復活
  #   - :finish 完了
  #   - :start 開始
  #   - :lock ロック
  #   - :unlock ロック解除
  # item::
  #   対象データの名称を示す文字列（省略可）
  #  
  # 戻り値:
  #   設定したタイトルメッセージを返す
  def set_error_title(model, action, item_name = nil)
    model_name = t(model, :scope => [:activerecord, :models])
    action_name = t(action, :scope => 'web-app-theme')
    if item_name.present?
      message =
        t('errors.template.header.original1',
          :default => 'Could not %{action} the %{model} [%{item}]',
          :action => action_name,
          :model => model_name,
          :item => item_name)
    else
      message =
        t('errors.template.header.original2',
          :default => 'Could not %{action} the %{model}',
          :action => action_name,
          :model => model_name)
    end
    return flash.now[:error_title] = message
  end

  ##
  # 全てのエラーメッセージを消去する
  #
  def clear_error_messages
    flash[:error_messages] = nil
  end
 
  ## 
  # エラーメッセージを追加する
  #
  # message::
  #   エラーメッセージ文字列
  # flash_now::
  #   true=flash.now[:error_messages]を使用する / false=flash[:error_messages]を使用する
  #
  def add_error_message(message, flash_now=false)
    if flash_now
      flash.now[:error_messages] = [] if flash[:error_messages].blank?
      flash.now[:error_messages] << message
    else
      flash[:error_messages] = [] if flash[:error_messages].blank?
      flash[:error_messages] << message
    end
  end

  ##
  # 関連性制約のエラーメッセージを追加する
  #
  # model::
  #   対象モデルを識別するシンボルまたは文字列
  # restrictions::
  #   対象モデルに対して関連性制約が設定されているモデルの配列を
  #   ユーザ操作による回避可能性によって分類化されたハッシュとして指定する。
  #   - :operable => 対象モデルに対してユーザ操作により回避可能な関連性制約が設定されているモデルの配列
  #   - :inoperable => 対象モデルに対してユーザ操作により回避不可能な関連性制約が設定されているモデルの配列
  #
  def add_restriction_error_messages(model, restrictions)
    model_name = t(model, :scope => [:activerecord, :models])
    # ユーザが操作可能な制約のメッセージを追加する
    operables = restrictions[:operable]
    if !operables.nil? && !operables.empty?
      associations = operables.inject('') { |assoc, mdl|
        assoc = assoc + ', ' if assoc.present?
        assoc + t(mdl, :scope => [:activerecord, :models])
      }
      add_error_message(
        t('errors.messages.operable_restriction',
          :default => 'If any data of %{associations} associated with the %{model} are present, please delete them before.',
          :model => model_name,
          :associations => associations), true)
    end
    
    # ユーザが操作できない制約のメッセージを追加する
    inoperables = restrictions[:inoperable]
    if !inoperables.nil? && !inoperables.empty?
      associations = inoperables.inject('') { |assoc, mdl|
        assoc = assoc + ', ' if assoc.present?
        assoc + I18n.t(mdl, :scope => [:activerecord, :models])
      }
      add_error_message(
        t('errors.messages.inoperable_restriction',
          :default => 'If any data of %{associations} associated with the %{model} are present, it can\'t be deleted.',
          :model => model_name,
          :associations => associations), true)
    end
  end

  ## 
  # 完了プロジェクト制約のエラーメッセージを返す
  #
  # model::
  #   対象モデルを識別するシンボル
  # action::
  #   実行したアクションを識別するシンボル
  #   - :new 登録
  #   - :edit 変更
  #   - :delete 削除
  # 戻り値::
  #   エラーメッセージの文字列を返す 
  #
  def finished_project_error_message(model, action)
    model_name = t(model, :scope => [:activerecord, :models])
    action_name = t(action, :scope => 'web-app-theme')
    message =
      t('errors.messages.project_finished',
        :default => 'Could not %{action} the %{model} of finished project',
        :action => action_name,
        :model => model_name)
    return message
  end
  
  ## 
  # 配列データの差分値を取得する
  #
  # src::
  #   元配列データ
  # ｄst::
  #   差し引く配列データ
  # 戻り値::
  #   配列データの差分値を返す
  #
  def get_diff_arrays(src, dst)
    ret = []
    src.each {|s|
      ret << s unless dst.include?(s)
    }
    return ret
  end
  
  ## 
  # 全角スペースを半角スペースに変換する
  #
  # value::
  #   変換対象文字列
  # 戻り値::
  #   半角スペース変換後の文字列を返す
  #
  def em_space_to_an_space(value)
    return value.gsub('　', ' ')
  end
  
  ## 
  # 月末日を取得する
  #
  # date_string::
  #   日付を表す文字列
  # 戻り値::
  #   date_stringの月末日を返す
  #
  def get_month_last_day(date_string)
    dt = db_date(date_string)
    if dt.present?
      last_day = date_string.to_date + 1.month - 1.day
      return db_date(last_day.to_s)
    end
    return nil
  end
  
  ## 
  # セッション情報から現在選択中のリストを取得する
  #
  # 戻り値::
  #   セッション情報から取得したリストを返す
  #
  def get_select_list_from_session(session, model)
    lists = []
    unless session.blank?
      session.each do |id|
        object = model.find(id)
        if object.present?
          lists << object
        end
      end
    end
    return lists
  end
  
  ## 
  # ログインしているユーザーがアクセスできるプロジェクトの取得
  # 
  # options:: 
  #   include_internal: 社内業務も含むかどうか(ディフォルト：含む)
  #     (true/false)
  #
  # 戻り値::
  #   SELECT用アクセスできるプロジェクトリスト([project.name, project.id]の形式で)
  #
  def get_current_user_can_acccess_projects(options = {include_internal: true})
    projects = []
    if current_user
      if administrator? || manager?
        projects = Project.projects_list({include_finished_project: true})
      else
        projects = current_user.my_project_list({include_finished_project: true})
      end
      if options && options[:include_internal]
        projects.insert(0, [Project::INTERNAL_BUSSINESS_PRJ[:name], Project::INTERNAL_BUSSINESS_PRJ[:id]])
      end
    end
    return projects
  end

  ## 
  # ログインしているユーザーがアクセスできるグループの取得
  # 
  # 戻り値::
  #   SELECT用アクセスできるグループリスト([name, id]の形式で)
  #
  def get_current_user_can_acccess_groups
    groups = []
    if current_user
      if administrator? || manager? || project_manager?
        groups = Section.sections_list
      else
        groups << [current_user.section.name, current_user.section.id]
      end
    end
    return groups
  end
end
