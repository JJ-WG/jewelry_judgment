# encoding: utf-8

#
#= Customerモデルクラス
#
# Authors:: 青山 ひろ子
# Created:: 2012/10/5
#
class Customer < ActiveRecord::Base
  # アクセサ定義
  attr_accessible :code, :name, :name_ruby, :pref_cd, :location
  
  # アソシエーション
  has_many :projects
  
  # バリデーション設定
  validates(:code, :length => {:maximum => 10})
  validates(:name, :presence => true, :length => {:maximum => 20})
  validates(:name_ruby, :presence => true, :length => {:maximum => 40})
  validates(:pref_cd, :presence => true)
  validates(:location, :length => {:maximum => 100})
  validate :is_valid
  
  # スコープ定義
  scope :deleted, where(:deleted => true)
  scope :alive, where(:deleted => false)

  # 以下、プライベートメソッド
private
  ##
  # バリデーションメソッド
  # 
  def is_valid
    # 顧客コード(半角英数字、記号(!"#$%&'()*+,-./;;<=>?))
    if self.code.present?
      if !(/^[0-9A-Za-z!"#\$%&'()*+,-.\/;;<=>?]+$/ =~ self.code)
        errors.add(:code, 'は半角英数字、または記号を入力してください。')
      end
      
      if Customer.exist_code(id, code)
        errors.add(:code, 'が他顧客で使用済みです。')
      end
    end
    
    # 顧客名ふりがな(半角英数、半角スペース、全角カタカナ、全角スペース)
    if self.name_ruby.present?
      if !(/^[0-9A-Za-zァ-ヶー 　]+$/ =~ self.name_ruby)
        errors.add(:name_ruby, 'は半角英数字、または半角スペース、または全角カタカナ、または全角スペースを入力してください。')
      end
    end
  end

  # 以下、パブリックメソッド
public
  ##
  # 顧客コードが他データで使用済みか
  # 
  # 戻り値::
  #   true:使用済み / false:未使用
  #
  def self.exist_code(id, code)
    if id.present?
      count = Customer.count(:code,
          :conditions => ['id != ? AND code = ?', id, code])
    else
      count = Customer.count(:code,
          :conditions => ['code = ?', code])
    end
    return (count > 0)? true : false
  end
  
  ##
  # 顧客リストを取得する
  # 
  # 戻り値::
  #   顧客リスト
  #
  def self.customers_list()
    return Customer
        .select('name, id')
        .order('name_ruby ASC')
        .collect{|s| [s.name, s.id]}
  end
  
  ##
  # プロジェクト情報で選択されている顧客かどうか？
  # 
  # customer_id::
  #   対象顧客ID
  # 戻り値::
  #   顧客がプロジェクト情報で選択されている場合、trueを返す
  #
  def self.project_customer?(customer_id)
    return Project.where(:customer_id => customer_id).exists?
  end
  
  ##
  # 商談情報で選択されている顧客かどうか？
  # 
  # customer_id::
  #   対象顧客ID
  # 戻り値::
  #   顧客が商談情報で選択されている場合、trueを返す
  #
  def self.deal_customer?(customer_id)
    return Deal.where(:customer_id => customer_id).exists?
  end
end
