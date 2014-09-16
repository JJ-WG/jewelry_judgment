# encoding: utf-8

#
#= Prjコントローラクラス
#
# Authors:: 青山 ひろ子
# Created:: 2012/10/4
#
class Prj::PrjController < ApplicationController
  # フィルター設定
  before_filter :require_user 
end
