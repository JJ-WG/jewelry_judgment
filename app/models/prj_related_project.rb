# encoding: utf-8

#
#= PrjRelatedProjectモデルクラス
#
# Authors:: 青山 ひろ子
# Created:: 2012/10/5
#
class PrjRelatedProject < ActiveRecord::Base
  # アクセサ定義
  attr_accessible :project_id, :related_project_id
  
  # アソシエーション
  belongs_to :project
end
