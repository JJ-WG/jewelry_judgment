# encoding: utf-8

#
#= WorkTypeモデルクラス
#
# Authors:: 青山 ひろ子
# Created:: 2012/10/5
#
class WorkType < ActiveRecord::Base
  # アクセサ定義
  attr_accessible :name, :view_order, :office_job, :work_type_code
  
  # アソシエーション
  has_many :results
  has_many :csv_results
  has_many :csv_schedules
  has_many :schedules
  has_many :prj_work_types
  has_many :projects, :through => :prj_work_types

  scope :list_order, order('view_order ASC')
  # 社内作業工程
  scope :office_jobs, where(office_job: true)
  # 開発作業工程
  scope :develop_jobs, where(office_job: false)

  # バリデーション設定
  validates(:view_order, :presence => true, :numericality =>
      {:only_integer => true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 999999999})
  validates(:name, :presence => true, :length => {:maximum => 20})
  # office_jobは、「:presence => true」の場合、falseデータが登録できないため
  # validates_inclusion_ofで入力チェックをおこなう
  validates_inclusion_of(:office_job, :in => [true, false])
  validates(:work_type_code, :presence => true, :length => {:maximum => 10})
  validate :is_valid
  
  # 以下、プライベートメソッド
private
  
  ##
  # バリデーションメソッド
  # 
  def is_valid
    # 作業工程コード
    if work_type_code.present?
      if !(/^[0-9A-Za-z]+$/ =~ work_type_code)
        errors.add(:work_type_code, 'は半角英数字を入力してください。')
      end
      
      if WorkType.exist_work_type_code(id, work_type_code)
        errors.add(:work_type_code, 'が他工程で使用済みです。')
      end
    end
  end
  
  # 以下、パブリックメソッド
public
  ##
  # 作業工程コードが他データで使用済みか
  # 
  # 戻り値::
  #   true:使用済み / false:未使用
  #
  def self.exist_work_type_code(id, code)
    if id.present?
      count = WorkType.count(:work_type_code,
          :conditions => ['id != ? AND work_type_code = ?', id, code])
    else
      count = WorkType.count(:work_type_code,
          :conditions => ['work_type_code = ?', code])
    end
    return (count > 0)? true : false
  end

  ##
  # 作業工程名を取得する
  #
  # id::
  #   作業工程ID
  # 戻り値::
  #   作業工程名を返す
  #
  def self.get_name_by_id(id)
    work_type = self.where('id = ?', id).first
    return '' if work_type.blank?
    return work_type.name
  end
  
  ##
  # 工程リストを取得する
  #
  # 戻り値::
  #   工程リスト
  #
  def self.work_types_list
    return WorkType.select('name, id')
                  .list_order
                  .collect{|work_type| [work_type.name, work_type.id]}
  end
  
  ##
  # プロジェクト情報で選択されている工程かどうか？
  # 
  # work_type_id::
  #   対象工程ID
  # 戻り値::
  #   工程がプロジェクトで選択されている場合、trueを返す
  #
  def self.project_work_type?(work_type_id)
    return PrjWorkType.where(:work_type_id => work_type_id).exists?
  end
end
