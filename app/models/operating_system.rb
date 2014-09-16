# encoding: utf-8

#
#= OperatingSystemモデルクラス
#
# Authors:: 青山 ひろ子
# Created:: 2012/10/5
#
class OperatingSystem < ActiveRecord::Base
  # アクセサ定義
  attr_accessible :name, :view_order
  
  # アソシエーション
  has_many :prj_operating_systems
  has_many :projects, :through => :prj_operating_systems
  
  # バリデーション設定
  validates(:view_order, :presence => true, :numericality =>
      {:only_integer => true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 999999999})
  validates(:name, :presence => true, :length => {:maximum => 20})
  
  ##
  # OSリストを取得する
  # 
  # 戻り値::
  #   OSリスト
  #
  def self.operating_systems_list()
    return OperatingSystem.select('name, id').order('id').collect{|s| [s.name, s.id]}
  end
  
  ##
  # プロジェクト情報で選択されているOSかどうか？
  # 
  # operating_system_id::
  #   対象OSID
  # 戻り値::
  #   OSがプロジェクトで選択されている場合、trueを返す
  #
  def self.project_operating_system?(operating_system_id)
    return PrjOperatingSystem.where(:operating_system_id => operating_system_id).exists?
  end
end
