# encoding: utf-8

#
#= PrjOperatingSystemモデルクラス
#
# Created:: 2012/10/5
#
class PrjOperatingSystem < ActiveRecord::Base
  # アクセサ定義
  attr_accessible :operating_system_id, :project_id
  
  # アソシエーション
  belongs_to :project
  belongs_to :operating_system
end
