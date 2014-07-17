# encoding: utf-8

#
#= Mhコントローラクラス
#
# Created:: 2012/12/11
#
class Mh::MhController < ApplicationController
  # フィルター設定
  before_filter :require_user 
end
