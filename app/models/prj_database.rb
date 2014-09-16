# encoding: utf-8

#
#= PrjDatabaseモデルクラス
#
# Authors:: 青山 ひろ子
# Created:: 2012/10/5
#
class PrjDatabase < ActiveRecord::Base
  # アクセサ定義
  attr_accessible :database_id, :project_id
  
  # アソシエーション
  belongs_to :project
  belongs_to :database
end
