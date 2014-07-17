# encoding: utf-8

#
#= CsvResultモデルクラス 
#
# Created:: 2012/10/24
#
class CsvResult < ActiveRecord::Base
  # アクセサ定義
  attr_accessible :notes, :project_id, :result_date, :user_id, :start_at, :end_at, :work_type_id, :deleted
  
  # アソシエーション
  belongs_to :user
  belongs_to :project
  belongs_to :work_type
  
  # バリデーション設定
  validates(:work_type_id, :presence => true)
  validates(:result_date, :presence => true)
  validates(:start_at, :presence => true)
  validates(:end_at, :presence => true)
  validates(:user_id, :presence => true)
 
  # デフォルトスコープ
  default_scope where({deleted: 0})

  # スコープ定義
  scope :list, includes(:project).includes(:work_type).includes(:user)
  .order('`csv_results`.result_date DESC, `projects`.project_code ASC, `work_types`.view_order ASC, `csv_results`.start_at ASC, `csv_results`.end_at ASC')

  # 作業工程名
  def work_type_name
    return self.work_type.blank? ? '': self.work_type.name
  end

  ##
  # プロジェクト情報の取得
  # project_idが0の場合、社内業務プロジェクトを戻ります
  #
  def project
    return Project.find(self.project_id) unless self.project_id == Project::INTERNAL_BUSSINESS_PRJ[:id]
    prj = Project.new(Project::INTERNAL_BUSSINESS_PRJ)
    prj.id = Project::INTERNAL_BUSSINESS_PRJ[:id]
    return prj
  end
end
