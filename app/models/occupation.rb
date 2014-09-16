# encoding: utf-8

#
#= Occupationモデルクラス
#
# Authors:: 青山 ひろ子
# Created:: 2012/10/5
#
class Occupation < ActiveRecord::Base
  # アクセサ定義
  attr_accessible :name, :view_order
  
  # アソシエーション
  has_many :users
  
  # バリデーション設定
  validates(:view_order, :presence => true, :numericality =>
      {:only_integer => true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 999999999})
  validates(:name, :presence => true, :length => {:maximum => 20})
  
  ##
  # 職種リストを取得する
  # 
  # 戻り値::
  #   職種リスト
  #
  def self.occupations_list()
    return Occupation.select('name, id').order('view_order').collect{|s| [s.name, s.id]}
  end
  
  ##
  # ユーザ情報で選択されている職種かどうか？
  # 
  # occupation_id::
  #   対象職種ID
  # 戻り値::
  #   職種がユーザ情報で選択されている場合、trueを返す
  #
  def self.user_occupation?(occupation_id)
    return User.where(:occupation_id => occupation_id).exists?
  end
end
