# encoding: utf-8

#
#= Noticeコントローラクラス
#
# Created:: 2012/10/4
#
class Notice::NoticeController < ApplicationController
  # フィルター設定
  before_filter :require_user 
end
