# encoding: utf-8

#
#= Sectionモデルクラス
#
# Created:: 2012/10/5
#
class Section < ActiveRecord::Base
  # アクセサ定義
  attr_accessible :deleted, :name, :view_order
  
  # アソシエーション
  has_many :users
  
  # バリデーション設定
  validates(:view_order, :presence => true, :numericality =>
      {:only_integer => true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 999999999})
  validates(:name, :presence => true, :length => {:maximum => 40})
  

  # スコープ定義
  scope :deleted, where(:deleted => true)
  scope :alive, where(:deleted => false)
  
  ##
  # 部署リストを取得する
  # 
  # all::
  #   全てのデータを取得するか（省略時False）
  # 戻り値::
  #   all=Trueの場合は全ての部署リストを取得し、
  #   all=Falseの場合は削除フラグがFalseの部署リストを取得する。
  #
  def self.sections_list(all=false)
    if all
      return Section.select('name, id').order('deleted asc, view_order').collect{|s| [s.name, s.id]}
    else
      sections = Section.where('deleted = ?', false).order(:view_order)
      return sections.map{|s| [s.name, s.id]}
    end
  end
  
  ##
  # ユーザー情報で選択されている部署かどうか？
  # 
  # section_id::
  #   対象部署ID
  # 戻り値::
  #   部署がユーザー情報で選択されている場合、trueを返す
  #
  def self.user_section?(section_id)
    return User.where(:section_id => section_id).exists?
  end
end
