# encoding: utf-8

#
#= Messageモデルクラス
#
# Authors:: 青山 ひろ子
# Created:: 2012/10/5
#
class Message < ActiveRecord::Base
  # アクセサ定義
  attr_accessible :message, :title
  
  # バリデーション設定
  validates(:title, :presence => true, :length => {:maximum => 50})
  validates(:message, :presence => true)
end
