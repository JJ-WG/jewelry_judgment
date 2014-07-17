# encoding: utf-8

#
#= Prjコントローラクラス
#
# Created:: 2012/10/4
#
class Prj::PrjController < ApplicationController
  # フィルター設定
  before_filter :require_user 
end
