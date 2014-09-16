# encoding: utf-8

#
#= Pwd::Usersコントローラクラス
#
# Authors:: 青山 ひろ子
# Created:: 2012/10/4
#
class Pwd::UsersController < Pwd::PwdController
  ##
  # パスワード変更機能 変更画面
  # PUT /pwd/user/edit
  #
  def edit
    # 現在ログイン中のユーザーを取得
    @user = current_user
  end
  
  ##
  # パスワード変更機能 更新処理
  # PUT /pwd/user/1
  #
  def update
    begin
      # 現在ログイン中のユーザーを取得
      @user = current_user
      
      raise unless is_valid?(params[:user])
      
      user_attributes = params[:user].reject{|key, value|
        key == 'now_password'
      }
            
      @user.update_attributes!(user_attributes)
      redirect_to edit_pwd_user_url,
          notice: t('common_label.model_was_updated', :model => User.model_name.human)
    rescue => ex
      set_error(ex, :user, :save)
      render action: 'edit'
      return
    end
  end
  
  ##
  # パスワード変更バリデーション
  # 
  # attributes::
  #   パスワード情報POSTデータ
  # 戻り値::
  #   入力チェックの結果を返す（True=エラーなし/False=エラーあり）
  # 
  def is_valid?(attributes)
    # 現在のパスワード
    if attributes[:now_password].blank?
      @user.errors.add(:now_password, 'を入力してください。')
    else
      if Authlogic::CryptoProviders::Sha512.encrypt(
          attributes[:now_password] + @user.password_salt) != @user.crypted_password
        @user.errors.add(:now_password, 'が登録されているパスワードと一致しません。')
      end
      
      if attributes[:now_password].length < 6
        @user.errors.add(:now_password, 'は6文字以上で入力してください。')
      end
      
      if attributes[:now_password].length > 20
        @user.errors.add(:now_password, 'は20文字以内で入力してください。')
      end
      
      if !(/^[0-9A-Za-z!"#\$%&'()*+,-.\/;;<=>?@_]+$/ =~ attributes[:now_password])
        @user.errors.add(:now_password, 'は半角英数字、または記号を入力してください。')
      end
    end
    
    # パスワード
    if attributes[:password].blank?
      @user.errors.add(:password, 'を入力してください。')
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
      if attributes[:password].present?
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
end
