# encoding: utf-8

#
#= Scheduleモデルクラス
#
# Created:: 2012/10/5
#
require 'csv'

class Schedule < ActiveRecord::Base
  # アクセサ定義
  attr_accessible :project_id, :work_type_id, :schedule_date, :start_at, :end_at, :auto_reflect, :notes, :deleted
  attr_accessor :schedule_member_user_id, :selected_schedule_member_user_id
  
  # Constants
  # 自動反映
  AUTO_REFLECTS = {
    yes: 1,   # 自動反映
    no: 0     # 自動反映じゃない
  }

  # アソシエーション
  belongs_to :project
  belongs_to :work_type
  has_many :sch_members, :autosave => true
  has_one :result

  # バリデーション設定
  validates(:project_id, :presence => true)
  validates(:schedule_date, :presence => true)
  validates(:start_at, :presence => true)
  validates(:end_at, :presence => true)
  validates(:auto_reflect, :presence => true, :inclusion => { in: AUTO_REFLECTS.values, if: Proc.new{|e| !e.auto_reflect.blank?} })
  validate :date_compare_validate

  # デフォルトスコープ
  default_scope where({deleted: 0})

  # スコープ定義
  scope :list, includes(:project).includes(:work_type)
               .order('`schedules`.schedule_date DESC, `projects`.project_code ASC, `work_types`.view_order ASC, `schedules`.start_at ASC, `schedules`.end_at ASC' )
  # 指定ユーザのスケジュール取得
  scope :by_user_id, lambda{|user_id| {:include => :sch_members, :conditions => ['`sch_members`.user_id = ? and `sch_members`.deleted = 0', user_id]} }

  # 終了時間と開始時間の比較チェック
  def date_compare_validate
    if self.errors[:start_at].blank? && self.errors[:end_at].blank? && self.start_at > self.end_at
      self.errors[:end_at] << I18n.t('errors.messages.datetime_compare_error', start_at: I18n.t('activerecord.attributes.schedule.start_at'))
    end
  end

  # CSVヘッダー項目
  CSV_HEADERS = %W!プロジェクトコード プロジェクト 作業工程コード 作業工程 日付 開始時間 終了時間 自動反映処理フラグ 備考 参加者コード 参加者!
  # CSV出力日付フォーマット
  CSV_DATE_FORMAT = '%Y-%m-%d'
  CSV_TIME_FORMAT = '%H:%M'

  # CSV レコード作成
  def to_csv_arr
    member_codes = []
    member_names = []
    sch_members.each { |member| member_codes << User.find(member.user_id).user_code; member_names << User.find(member.user_id).name}
    [
      project.project_code,
      project.name,
      work_type.blank? ? '' : work_type.work_type_code,
      work_type_name,
      schedule_date.strftime(CSV_DATE_FORMAT),
      start_at.strftime(CSV_TIME_FORMAT),
      end_at.strftime(CSV_TIME_FORMAT),
      auto_reflect.to_s,
      notes,
      member_codes.join(':'),
      member_names.join(':')
    ]
  end

  # 指定ユーザが当該スケジュールの参加者かどうかの判断
  def has_member?(user_id)
    Schedule.where(:id => self.id).by_user_id(user_id).length > 0
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
  # 反映済みかどうかの判断
  #
  # user_id::
  #   指定ユーザの反映済みかどうか
  #
  # 戻り値::
  #   (true/false)
  def reflected?(user_id = nil)
    if user_id.blank?
      # 当該スケジュールに対して、反映されたユーザの取得
      result_user_ids = Result.select(:user_id).where(schedule_id: self.id).collect {|item| item.user_id}
      # 一つユーザでも反映されてない場合、falseを戻る
      return false if result_user_ids.length == 0
      return SchMember.where(schedule_id: self.id).where('user_id NOT IN (?)', result_user_ids).length == 0
    else
      return Result.where({schedule_id: self.id, user_id: user_id}).length > 0
    end
  end

  ##
  # 反映済みかどうかの判断
  #
  # user_id::
  #   指定ユーザの反映済みかどうか
  #
  # 戻り値::
  #   (true/false)
  def get_result_for_user(user_id = nil)
    return nil if user_id.blank?
    return Result.first(:conditions => {schedule_id: self.id, user_id: user_id})
  end

  ##
  # スケジュールを工数実績に反映
  #
  def reflect_to_result
    if work_type.blank?
      raise I18n.t('label.schedule_reflection.errors.work_type_error', :id => self.id)
    end
    self.sch_members.each do |member|
      reflect_to_result_by_user(member.user_id)
    end
  end

  ##
  # 指定ユーザを工数実績に反映
  #
  def reflect_to_result_by_user(user_id)
    unless User.find(user_id).blank?
      return if self.reflected?(user_id)
      attrs = self.attributes.select{|key, value|
        key == 'project_id' || key == 'work_type_id' || key == 'notes' || key == 'start_at' || key == 'end_at'
      }
      attrs[:result_date] = self.schedule_date
      attrs[:schedule_id] = self.id
      attrs[:user_id] = user_id
      Result.new(attrs).save!
    end
  end

  ##
  # 工数実績自動反映バッチ処理
  #
  def self.auto_reflect
    STDOUT.puts "==================================================="
    begin
      # 自動反映対象の取得
      schedules = Schedule.where('auto_reflect = 1 AND work_type_id IS NOT NULL AND end_at < ?', DateTime.now).all
      ActiveRecord::Base.transaction do
        STDOUT.puts "工数実績自動反映を行っています......"
        schedules.each do |sch|
          sch.reflect_to_result
        end
        STDOUT.puts "#{schedules.length}件スケジュールを自動反映しました。"
        STDOUT.puts "完了"
      end
    rescue Exception => e
      # 失敗の場合
      STDOUT.puts e.message
      STDOUT.puts "工数実績自動反映に失敗しました。"
    end
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
