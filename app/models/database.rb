# encoding: utf-8

#
#= Databaseモデルクラス
#
# Authors:: 青山 ひろ子
# Created:: 2012/10/5
#
class Database < ActiveRecord::Base
  # アクセサ定義
  attr_accessible :name, :view_order
  
  # アソシエーション
  has_many :prj_databases
  has_many :projects, :through => :prj_databases

  # バリデーション設定
  validates(:view_order, :presence => true, :numericality =>
      {:only_integer => true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 999999999})
  validates(:name, :presence => true, :length => {:maximum => 20})
  
  ##
  # データベースリストを取得する
  # 
  # 戻り値::
  #   データベースリスト
  #
  def self.databases_list()
    return Database.select('name, id').order('id').collect{|s| [s.name, s.id]}
  end

  ##
  # プロジェクト情報で選択されているデータベースかどうか？
  # 
  # database_id::
  #   対象データベースID
  # 戻り値::
  #   データベースがプロジェクトで選択されている場合、trueを返す
  #
  def self.project_database?(database_id)
    return PrjDatabase.where(:database_id => database_id).exists?
  end
end
