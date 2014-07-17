# encoding: utf-8

#
#= Resultモデルクラス
#
# Created:: 2012/10/24
#
require 'csv'

class Result < ActiveRecord::Base
  # アクセサ定義
  attr_accessible :notes, :project_id, :result_date, :schedule_id, :user_id, :start_at, :end_at, :work_type_id, :deleted

  # アソシエーション
  belongs_to :schedule
  belongs_to :project
  belongs_to :user
  belongs_to :section
  belongs_to :work_type
  
  # バリデーション設定
  validates(:project_id, :presence => true)
  validates(:work_type_id, :presence => true)
  validates(:result_date, :presence => true)
  validates(:start_at, :presence => true)
  validates(:end_at, :presence => true)
  validates(:user_id, :presence => true)
  validate :date_compare_validate
  
  # デフォルトスコープ
  default_scope where({deleted: 0})
  
  # スコープ定義
  scope :list, includes(:project).includes(:work_type).includes(:user)
               .order('`results`.result_date ASC, `projects`.project_code ASC, `work_types`.view_order ASC, `results`.start_at ASC, `results`.end_at ASC' )
  
  # 終了時間と開始時間の比較チェック
  def date_compare_validate
    if self.errors[:start_at].blank? && self.errors[:end_at].blank? && self.start_at > self.end_at
      self.errors[:end_at] << I18n.t('errors.messages.datetime_compare_error', start_at: I18n.t('activerecord.attributes.schedule.start_at'))
    end
  end

  # CSVヘッダー項目
  CSV_HEADERS = %W!プロジェクトコード プロジェクト 作業工程コード 作業工程 日付 開始時間 終了時間 ユーザーコード ユーザー 備考!
  # CSV出力日付フォーマット
  CSV_DATE_FORMAT = '%Y-%m-%d'
  CSV_TIME_FORMAT = '%H:%M'

  # CSV レコード作成
  def to_csv_arr
    [
      project.project_code,
      project.name,
      work_type.blank? ? '' : work_type.work_type_code,
      work_type_name,
      result_date.strftime(CSV_DATE_FORMAT),
      start_at.strftime(CSV_TIME_FORMAT),
      end_at.strftime(CSV_TIME_FORMAT),
      user.user_code,
      user.name,
      notes
    ]
  end

  # 指定ユーザが当該工数実績のユーザーかどうかの判断
  def has_member?(user_id)
    Result.where(:id => self.id, :user_id => user_id).length > 0
  end

  # CSVファイルの作成
  def self.csv_content_for(objs)
    CSV.generate("", {:row_sep => "\r\n"}) do |csv|
      csv << CSV_HEADERS
      objs.each do |record|
        csv << record.to_csv_arr
      end
    end
  end

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
  
  def day_work_hours
    attributes['day_work_hours']
  end
  
  # 以下、パブリックメソッド
public
  
  ##
  # 作業実績の実績工数を取得する
  #
  # 戻り値::
  #   作業実績の実績工数（人日）を返す
  #
  def work_hours
    work_hours = (end_at - start_at) / 3600.0 / WORK_HOURS_PER_DAY
    return work_hours
  end
  
end
