# encoding: utf-8

#
#= Nego::Dealsヘルパークラス
#
# Authors:: 青山 ひろ子
# Created:: 2012/10/5
#
module Nego::DealsHelper
  
  include ::CodeIndicationModule

  ##
  # 商談ステータスコードリストを取得する
  # 
  # 戻り値::
  #   商談ステータスコードリスト
  #
  def deal_status_list
    list = []
    DEAL_STATUS_CODE.each_pair {|key, value|
      list << [deal_status_indication(value), value]
    }
    return list
  end

  ##
  # 受注確度コードリストを取得する
  # 
  # 戻り値::
  #   受注確度コードリスト
  #
  def reliability_list
    list = []
    RELIABILITY_CODE.each_pair {|key, value|
      list << [reliability_indication(value), value]
    }
    return list
  end

  ##
  # PJ管理対象のラベル表示
  # 
  # 戻り値::
  #   PJ管理対象のラベル
  #     true: 対象
  #     false: 対象外
  #
  def prj_managed_label(prj_managed)
    prj_managed ? t('label.target') : t('label.target_out')
  end

  ##
  # 営業担当者リストを取得する
  # 
  # 戻り値::
  #   営業担当者リスト
  #
  def deal_staff_user_list
    return User.select('name, id')
               .where({deleted: false, user_rank_cd: [USER_RANK_CODE[:employee], USER_RANK_CODE[:manager], USER_RANK_CODE[:system_admin]]})
               .list_order
               .collect{|user| [user.name, user.id]}
  end

  ##
  # 営業方法の表示文字列を取得する
  # 
  # activity_method_cd::
  #   営業方法コード
  # 戻り値::
  #   営業方法の表示文字列
  #
  def activity_method_indication(activity_method_cd)
    scope = 'activity_method'
    case activity_method_cd
      when ACTIVITY_METHOD_CODE[:visit]
        return t('visit', :scope => scope, :default=>'Visit')
      when ACTIVITY_METHOD_CODE[:telephone]
        return t('telephone', :scope => scope, :default=>'Telephone')
      when ACTIVITY_METHOD_CODE[:mail]
        return t('mail', :scope => scope, :default=>'Mail')
      when ACTIVITY_METHOD_CODE[:other]
        return t('other', :scope => scope, :default=>'Other')
    end
  end

  ##
  # 営業方法リストを取得する
  # 
  # 戻り値::
  #   営業方法コードリスト
  #
  def activity_method_list
    list = []
    ACTIVITY_METHOD_CODE.each_pair {|key, value|
      list << [activity_method_indication(value), value]
    }
    return list
  end
end
