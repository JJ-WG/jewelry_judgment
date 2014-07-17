# encoding: utf-8

#
#= PrjDevLanguageモデルクラス
#
# Created:: 2012/10/5
#
class PrjDevLanguage < ActiveRecord::Base
  # アクセサ定義
  attr_accessible :development_language_id, :project_id
  
  # アソシエーション
  belongs_to :project
  belongs_to :development_language
end
