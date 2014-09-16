# encoding: utf-8

#
#= Noticeコントローラクラス
#
# Authors:: 青山 ひろ子
# Created:: 2012/10/4
#
class Notice::NoticeController < ApplicationController
  # フィルター設定
  before_filter :require_user 
end
