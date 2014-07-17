# encoding: utf-8

#
#= Dealモデルクラス
#
# Created:: 2012/10/5
#
class Deal < ActiveRecord::Base

  include ::CodeIndicationModule

  #PERIOD_DATE_FORMAT = '%Y-%m'
  PERIOD_DATE_FORMAT = '%Y年%m月頃'

  # CSVヘッダー項目
  CSV_HEADERS = %W!案件名 顧客名 担当営業名 ステータス 最終営業日 営業回数 受注確度 オーダー 添付!

  # アクセサ定義
  attr_accessible :adoption_period, :anticipated_price, :billing_destination, :budge_amount, :contact_person_name, :customer_id, :customer_section, :deal_status_cd, :delivery_period, :name, :notes, :order_type_cd, :order_volume, :prj_managed, :selection_method, :solution_name, :staff_user_id, :reliability_cd, :deleted
  
  # アソシエーション
  has_one :project
  has_many :sales_reports
  belongs_to :customer
  belongs_to :staff_user, :foreign_key => :staff_user_id, :class_name => 'User'
  
  # バリデーション設定
  validates(:name, :presence => true, :length => {in: 1..40, if: Proc.new{|e| !e.name.blank? }}, :on => :create)
  validates(:customer_id, :presence => true, :on => :create)
  validates(:contact_person_name, :presence => true, :length => {in: 1..20, if: Proc.new{|e| !e.contact_person_name.blank? }})
  validates(:staff_user_id, :presence => true)

  validates(:budge_amount, :numericality =>
      {:only_integer => true, :greater_than_or_equal_to => 0,
      :less_than_or_equal_to => 9999999999, :if => Proc.new{|e| !e.budge_amount.blank? } })
  validates(:anticipated_price, :numericality =>
      {:only_integer => true, :greater_than_or_equal_to => 0,
      :less_than_or_equal_to => 9999999999, :if => Proc.new{|e| !e.anticipated_price.blank? }})
  validates(:selection_method, :length => 0..20)
  # 請求先
  validates(:billing_destination, :length => 0..40)
  validates(:reliability_cd, :presence => true)
  validates(:order_volume, :on => :update, :numericality =>
      {:only_integer => true, :greater_than_or_equal_to => 0,
      :less_than_or_equal_to => 9999999999, :if => Proc.new{|e| !e.order_volume.blank? }})

  # デフォルトスコープ
  default_scope where({deleted: 0})

  # スコープ定義
  scope :list, order('id ASC' )
  
  before_save :set_default_values

  ##
  # 商談情報IDに対応する商談情報の名前を取得する
  #
  # id::
  #   対象商談情報の商談情報ID
  # 戻り値::
  #   商談情報の名前を返す
  #
  def self.get_name(id)
    begin
      deal = Deal.find(id)
      return deal.name
    rescue
      return ''
    end
  end
  
  ##
  # 商談情報リストを取得する
  # 
  # option::
  #    ハッシュにより下記のオプションを指定可能
  #    - :only_before_order_decision_deal
  #       受注決定以前の案件リストにするか(true/false)
  #    - :only_prj_managed_deal
  #       PJ管理対象フラグがTrueの商談のみをリストにするか(true/false)
  #       省略した場合、PJ管理対象フラグは条件に含めない
  # 戻り値::
  #   商談情報リスト
  #
  def self.deals_list(option = {})
    return Deal.select('name, id')
        .where(option[:only_before_order_decision_deal] ? 
            {:deal_status_cd => [DEAL_STATUS_CODE[:under_negotiation],
                                 DEAL_STATUS_CODE[:demo_request],
                                 DEAL_STATUS_CODE[:making_estimate],
                                 DEAL_STATUS_CODE[:being_proposed],
                                 DEAL_STATUS_CODE[:order_decision]]} : nil)
        .where(
            (option[:only_prj_managed_deal].nil? || !option[:only_prj_managed_deal]) ?
            nil : {:prj_managed => true})
        .order('created_at DESC')
        .collect{|deal| [deal.name, deal.id]}
  end
  
  ##
  # 商談ステータスを取得する
  #
  # 戻り値::
  #   商談ステータスを返す
  #
  def deal_status
    return ApplicationController.helpers.deal_status_indication(deal_status_cd)
  end

  ##
  # 関連資料を取得する
  #
  def related_file_list
    list = []
    if File.exist?(self.related_file_path)
      Dir.foreach(self.related_file_path) do |file|
        list << file if File.file?(related_file_path(file))
      end
    end
    return list.sort
  end

  ##
  # 添付あるかどうかを取得する
  #
  def has_related_file?
    self.related_file_list.length > 0
  end

  ##
  # 指定関連資料を削除する
  #
  def delete_related_file(filename)
    FileUtils.rm(related_file_path(filename)) if filename.present? && exist_file?(filename)
  end

  ##
  # 指定関連資料が存在かどうかチェック
  #
  def exist_file?(filename)
    File.exist?(related_file_path(filename)) if filename.present?
  end

  ##
  # 指定関連資料の絶対パースの取得
  # ファイル名がNULLの場合、ディレクトリのパースを戻る
  #
  def related_file_path(filename=nil)
    File.join(DEAL_FILES_PATH, self.id.to_s, (filename.nil? ? '' : filename))
  end

  ##
  # 最終営業日
  #
  def last_activity_date
    SalesReport.unscoped.select('max(activity_date) as last_activity_date')
                .where({deleted: false, deal_id: self.id}).first[:last_activity_date]
  end

  ##
  # 指定された商談情報が商談情報に無い場合、
  # 商談情報リストの最後に商談情報を追加する
  # 
  # list::
  #   商談情報リスト
  # user_id::
  #   リストに追加する商談情報の商談情報ID 
  # 戻り値::
  #   商談情報リスト
  #
  def self.add_to_list(list, deal_id)
    if list.nil?
      list = []
    else
      list.each do |item|
        if item.last == deal_id
          return list
        end
      end
    end
    return list << [get_name(deal_id), deal_id]
  end

  ##
  # CSV レコード作成
  #
  def to_csv_arr
    [
      name,
      customer.name,
      staff_user.name,
      deal_status_indication(deal_status_cd),
      last_activity_date ? I18n.l(last_activity_date) : '',
      sales_reports.length,
      reliability_indication(reliability_cd),
      project.present? ? project.project_code : '',
      has_related_file? ? I18n.t('label.common.has_one') : ''
    ]
  end

  ##
  # CSVファイルの作成
  #
  def self.csv_content_for(objs)
    CSV.generate("", {:row_sep => "\r\n"}) do |csv|
      csv << CSV_HEADERS
      objs.each do |record|
        csv << record.to_csv_arr
      end
    end
  end

private
  def set_default_values
    self.budge_amount = 0 if self.budge_amount.blank?
    self.anticipated_price = 0 if self.anticipated_price.blank?
    self.order_volume = 0 if self.order_volume.blank?
  end

end
