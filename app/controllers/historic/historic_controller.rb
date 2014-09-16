# encoding: utf-8

#
#= Historicコントローラクラス
#
# Authors:: 代　如剛
# Created:: 2013/01/07
#
class Historic::HistoricController < ApplicationController
  # フィルター設定
  before_filter :require_user
end
