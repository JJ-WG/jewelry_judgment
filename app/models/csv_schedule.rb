# encoding: utf-8

#
#= CsvScheduleモデルクラス
#
# Authors:: 青山 ひろ子
# Created:: 2012/10/24
#
class CsvSchedule < ActiveRecord::Base
  # アクセサ定義
  attr_accessible :auto_reflect, :end_at, :notes, :project_id, :schedule_date, :start_at, :work_type_id, :deleted
  
  # アソシエーション
  belongs_to :project
  belongs_to :work_type
  has_many :csv_sch_members, :autosave => true

  # バリデーション設定
  validates(:project_id, :presence => true)
  validates(:schedule_date, :presence => true)
  validates(:start_at, :presence => true)
  validates(:end_at, :presence => true)
  validates(:auto_reflect, :presence => true, :inclusion => { in: Schedule::AUTO_REFLECTS.values, if: Proc.new{|e| !e.auto_reflect.blank?} })

  validates_each :csv_sch_members do |record, attr, value|
    record.errors.add attr, I18n.t('errors.messages.blank') unless value.length > 0
  end

  # デフォルトスコープ
  default_scope where({deleted: 0})

  # スコープ定義
  scope :list, includes(:project).includes(:work_type)
               .order('`csv_schedules`.schedule_date DESC, `projects`.project_code ASC, `work_types`.view_order ASC, `csv_schedules`.start_at ASC, `csv_schedules`.end_at ASC')

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
