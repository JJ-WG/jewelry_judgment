# encoding: utf-8

#
#= Admin::Usersヘルパークラス
#
# Created:: 2012/10/5
#
module Admin::UsersHelper
  ##
  # ユーザー区分リストを取得する
  # 
  # 戻り値::
  #   ユーザー区分リスト
  #
  def user_ranks_list
    list = []
    USER_RANK_CODE.each_value { |cd|
      list << [user_rank_indication(cd), cd]
    }
    return list
  end
  
  ##
  # ユーザー区分の表示文字列を取得する
  # 
  # 戻り値::
  #   ユーザー区分の表示文字列
  #
  def user_rank_indication(user_rank_cd)
    scope = 'user_rank'
    case user_rank_cd
      when USER_RANK_CODE[:parttimer]
        return t('parttimer', :scope => scope, :default=>'Parttimer')
      when USER_RANK_CODE[:employee]
        return t('employee', :scope => scope, :default=>'Employee')
      when USER_RANK_CODE[:manager]
        return t('manager', :scope => scope, :default=>'Manager')
      when USER_RANK_CODE[:system_admin]
        return t('system_admin', :scope => scope, :default=>'System Administrator')
    end
  end
  
  ##
  # ユーザー名を取得
  # 
  # id::
  #   ユーザーID
  # 戻り値::
  #   ユーザー名
  #
  def get_user_name(id)
    user = User.find(id)
    return user.name
  end
end
