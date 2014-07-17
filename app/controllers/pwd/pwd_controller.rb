# encoding: utf-8

#
#= Pwdコントローラクラス
#
# Created:: 2012/10/4
#
class Pwd::PwdController < ApplicationController
  # フィルター設定
  before_filter :require_user
end
