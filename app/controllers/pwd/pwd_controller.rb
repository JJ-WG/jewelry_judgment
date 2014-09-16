# encoding: utf-8

#
#= Pwdコントローラクラス
#
# Authors:: 青山 ひろ子
# Created:: 2012/10/4
#
class Pwd::PwdController < ApplicationController
  # フィルター設定
  before_filter :require_user
end
