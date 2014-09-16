# encoding: utf-8

#
#= Scheduleコントローラクラス
#
# Authors:: 代　如剛
# Created:: 2012/12/11
#
class Schedule::ScheduleController < ApplicationController
  # フィルター設定
  before_filter :require_user 
end
