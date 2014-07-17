# encoding: utf-8

#
#= UserSessionsコントローラクラス
#
# Created:: 2012/10/4
#
class UserSessionsController < ApplicationController
  # フィルター設定
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => :destroy
  
  # レイアウト設定
  layout 'login'
  
  ##
  # ユーザーセッション情報 新規作成処理
  #
  def new
    @user_session = UserSession.new
  end
  
  ##
  # ログイン処理
  #
  def create
    UserSession.with_scope(:find_options => { :conditions =>{ :deleted => false } }) do
      @user_session = UserSession.new(params[:user_session])
    end
    if @user_session.save
      #flash[:notice] = t('authlogic.logged_in')
      redirect_back_or_default top_url
      # セッション・フィクセーション対策のため、セッションをリセットする
      reset_session
    else
      flash[:notice] = t('authlogic.login_failed')
      # エラーを表示する事によりヒントを与えないために、エラーをクリアする
      @user_session.errors.clear
      render :action => :new
    end
  end
  
  ##
  # ログアウト処理
  #
  def destroy
    current_user_session.destroy
    flash[:notice] = t('authlogic.logged_out')
    redirect_back_or_default login_url
  end
end
