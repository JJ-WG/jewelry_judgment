# encoding: utf-8

#
#= Resultモデルクラス
#
# Authors:: 青山 ひろ子
# Created:: 2012/10/24
#
require 'csv'

class Result < ActiveRecord::Base
  # アクセサ定義
  attr_accessible :notes, :project_id, :result_date, :schedule_id, :user_id,
      :start_at, :end_at, :work_type_id, :deleted,
      :start_at_hour, :start_at_minute, :end_at_hour, :end_at_minute
  attr_accessor :start_at_hour, :start_at_minute, :end_at_hour, :end_at_minute

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
  validates(:user_id, :presence => true)
  validate :date_select_validate
  validate :date_eql_validate
  validate :date_compare_validate
  validate :date_overlap_validate
  
  # デフォルトスコープ
  default_scope where({deleted: 0})
  
  # スコープ定義
  scope :list, includes(:project).includes(:work_type).includes(:user)
               .order('`results`.result_date ASC, `projects`.project_code ASC, `work_types`.view_order ASC, `results`.start_at ASC, `results`.end_at ASC' )
  
  # 時間選択チェック
  def date_select_validate
    if Mh::ResultsController.controller_name == "results"
      # 工数実績登録の場合
      if self.start_at_hour.blank?
        self.errors[:start_at_hour] <<
            I18n.t('errors.messages.blank', start_at_hour: I18n.t('activerecord.attributes.result.start_at_hour'))
      end
      if self.start_at_minute.blank?
        self.errors[:start_at_minute] <<
            I18n.t('errors.messages.blank', start_at_minute: I18n.t('activerecord.attributes.result.start_at_minute'))
      end
      if self.end_at_hour.blank?
        self.errors[:end_at_hour] <<
            I18n.t('errors.messages.blank', end_at_hour: I18n.t('activerecord.attributes.result.end_at_hour'))
      end
      if self.end_at_minute.blank?
        self.errors[:end_at_minute] <<
            I18n.t('errors.messages.blank', end_at_minute: I18n.t('activerecord.attributes.result.end_at_minute'))
      end
    elsif Mh::ResultsController.controller_name == "csv_results"
      # 工数実績CSV登録の場合
      if self.start_at.blank?
        self.errors[:start_at] <<
            I18n.t('errors.messages.blank', start_at: I18n.t('activerecord.attributes.result.start_at'))
      end
      if self.end_at.blank?
        self.errors[:end_at] <<
            I18n.t('errors.messages.blank', end_at: I18n.t('activerecord.attributes.result.end_at'))
      end
    end
  end

  # 終了時間と開始時間の比較チェック
  def date_compare_validate
    if self.errors[:start_at_hour].blank? && self.errors[:start_at_minute].blank? &&
        self.errors[:end_at_hour].blank? && self.errors[:end_at_minute].blank? &&
        self.errors[:start_at].blank? && self.errors[:end_at].blank? &&
        self.start_at > self.end_at
      self.errors[:end_at] << I18n.t('errors.messages.datetime_compare_error', start_at: I18n.t('activerecord.attributes.schedule.start_at'))
    end
  end

  # 終了時間と開始時間の同値チェック
  def date_eql_validate
    if self.errors[:start_at_hour].blank? && self.errors[:start_at_minute].blank? &&
        self.errors[:end_at_hour].blank? && self.errors[:end_at_minute].blank? &&
        self.errors[:start_at].blank? && self.errors[:end_at].blank? &&
        self.start_at == self.end_at
      self.errors[:end_at] << I18n.t('errors.messages.datetime_eql_error', start_at: I18n.t('activerecord.attributes.schedule.start_at'))
    end
  end

  # 同時刻の重複チェック
  def date_overlap_validate
    results = Result.where(:user_id => self.user_id ,:result_date => self.result_date)
    results.each do |i|
      next if i.id == self.id  # 自分自身とはチェックしない
      if self.errors[:start_at_hour].blank? && self.errors[:start_at_minute].blank? &&
          self.errors[:start_at].blank? &&
          self.start_at >= i.start_at && self.start_at < i.end_at
        self.errors[:start_at] << I18n.t('errors.messages.datetime_overlap_error')
      end
      if self.errors[:end_at_hour].blank? && self.errors[:end_at_minute].blank? &&
          self.errors[:end_at].blank? &&
          self.end_at > i.start_at && self.end_at <= i.end_at
        self.errors[:end_at] << I18n.t('errors.messages.datetime_overlap_error')
      end
      if self.errors[:start_at_hour].blank? && self.errors[:start_at_minute].blank? &&
          self.errors[:end_at_hour].blank? && self.errors[:end_at_minute].blank? &&
          self.errors[:start_at].blank? && self.errors[:end_at].blank? && 
          self.start_at <= i.start_at && self.end_at >= i.start_at &&
          self.start_at <= i.end_at && self.end_at >= i.end_at
        self.errors[:start_at] << I18n.t('errors.messages.datetime_overlap_error')
        self.errors[:end_at] << I18n.t('errors.messages.datetime_overlap_error')
      end
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
  
  ##
  # 指定月の工数実績入力日を取得する
  #
  # user_id::
  #   ユーザーID
  # date::
  #   工数実績入力日を取得する月の日付
  #
  # 戻り値::
  #   ユーザーIDが引数user_id、引数dateの月の工数実績入力日のリストを返す
  #
  def self.result_date_list(user_id, date)
    date_list = ""
    results = Result.select(:result_date)
                    .where(:user_id => user_id,
                           :result_date => date.beginning_of_month..date.end_of_month)
    date_list = results.map{|result| result.result_date.strftime("%Y/%m/%d")}.join(",")
    return date_list
  end
end
