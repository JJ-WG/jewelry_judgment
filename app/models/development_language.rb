# encoding: utf-8

#
#= DevelopmentLanguageモデルクラス
#
# Authors:: 青山 ひろ子
# Created:: 2012/10/5
#
class DevelopmentLanguage < ActiveRecord::Base
  # アクセサ定義
  attr_accessible :name, :view_order
  
  # アソシエーション
  has_many :prj_dev_languages
  has_many :projects, :through => :prj_dev_languages
  
  # バリデーション設定
  validates(:view_order, :presence => true, :numericality =>
      {:only_integer => true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 999999999})
  validates(:name, :presence => true, :length => {:maximum => 20})
  
  ##
  # 開発言語リストを取得する
  # 
  # 戻り値::
  #   開発言語リスト
  #
  def self.development_languages_list()
    return DevelopmentLanguage.select('name, id').order('id').collect{|s| [s.name, s.id]}
  end
  
  ##
  # プロジェクト情報で選択されている開発言語かどうか？
  # 
  # dev_language_id::
  #   対象開発言語ID
  # 戻り値::
  #   開発言語がプロジェクトで選択されている場合、trueを返す
  #
  def self.project_dev_language?(dev_language_id)
    return PrjDevLanguage.where(:development_language_id => dev_language_id).exists?
  end
end
