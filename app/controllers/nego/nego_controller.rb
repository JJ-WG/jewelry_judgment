# encoding: utf-8

#
#= Negoコントローラクラス
#
# Authors:: 代　如剛
# Created:: 2013/01/07
#
class Nego::NegoController < ApplicationController
  # フィルター設定
  before_filter :require_user

  # コントローラのメソッドをviewでも使えるように設定
  helper_method :creatable?, :viewable?, :editable?, :deletable?
  

  private

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
  #   また、ユーザ権限が「マネージャ以上」の場合もtrueを返す。
  # 
  def editable?(deal)
    return false unless current_user
    return true if current_user.user_rank_cd >= USER_RANK_CODE[:manager]
    return true if current_user.user_rank_cd >= USER_RANK_CODE[:employee] && current_user.id.eql?(deal.staff_user_id)
    return false
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
    return current_user && (current_user.user_rank_cd >= USER_RANK_CODE[:employee])
  end

  ##
  # ログインユーザが削除可能か
  #
  # deal:
  #   対象商談情報
  # 
  # 戻り値::
  #   商談のプロジェクトが存在する場合にはfalseを返す。
  #   ログインユーザのユーザ権限が「一般社員以上」かつロール権限が「営業担当」の場合、trueを返す。
  #   また、ユーザ権限が「マネージャ以上」の場合もtrueを返す。
  #
  def deletable?(deal)
    return false if deal && deal.project.present?
    return editable?(deal)
  end
end
