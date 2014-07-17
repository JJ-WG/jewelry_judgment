# encoding: utf-8

#
#= Adminコントローラクラス
#
# Created:: 2012/10/4
#
class Admin::AdminController < ApplicationController
  # フィルター設定
  before_filter :require_user
  before_filter :check_authorization_for_admin_menu
end
