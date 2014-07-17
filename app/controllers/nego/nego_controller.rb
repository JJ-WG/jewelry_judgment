# encoding: utf-8

#
#= Negoコントローラクラス
#
# Created:: 2013/01/07
#
class Nego::NegoController < ApplicationController
  # フィルター設定
  before_filter :require_user 
end
