# encoding: utf-8

#
#= SalesReportモデルクラス
#
# Authors:: 青山 ひろ子
# Created:: 2012/10/24
#
class SalesReport < ActiveRecord::Base
  # アクセサ定義
  attr_accessible :activity_date, :activity_method, :deal_id, :destination, :fellow_staff, :main_staff, :deleted, :reports, :responses, :activity_objective
  
  # アソシエーション
  belongs_to :deal

  # バリデーション設定
  validates(:activity_date, :presence => true)
  validates(:activity_method, :presence => true, :length => {in: 1..40, if: Proc.new{|e| !e.activity_method.blank? }})
  validates(:main_staff, :presence => true, :length => {in: 1..20, if: Proc.new{|e| !e.main_staff.blank? }})
  validates(:activity_objective, :presence => true, :length => {in: 1..40, if: Proc.new{|e| !e.activity_objective.blank? }})
  validates(:destination, :presence => true, :length => {in: 1..40, if: Proc.new{|e| !e.destination.blank? }})
  validates(:reports, :presence => true)
  validates(:responses, :presence => true)

  # デフォルトスコープ
  default_scope where({deleted: 0}).order('activity_date ASC')

  ##
  # 商談報告情報 論理削除処理
  #
  def self.logic_delete(report)
    if report.present?
      report.deleted = true
      report.save!(:validate => false)
    end
  end

end
