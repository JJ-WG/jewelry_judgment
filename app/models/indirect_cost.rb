# encoding: utf-8

#
#= IndirectCostモデルクラス
#
# Created:: 2012/10/5
#
class IndirectCost < ActiveRecord::Base
  # アクセサ定義
  attr_accessible :indirect_cost_method_cd, :start_date, :indirect_cost_ratios_attributes

  # アソシエーション
  has_many :indirect_cost_ratios
  accepts_nested_attributes_for :indirect_cost_ratios
  
  # バリデーション設定
  validates(:start_date, :presence => true)
  validates(:indirect_cost_method_cd, :presence => true,
      :inclusion => {:in => INDIRECT_COST_METHOD_CODE.values})
  validate :is_valid
  
  # 以下、プロテクテッドメソッド
protected  

  ##
  # バリデーションメソッド
  # 
  def is_valid  
    # 適用開始日
    indirect_cost_data = IndirectCost.order('start_date DESC').first
    if self.start_date.present? && indirect_cost_data.present?
      if self.id.present?
        indirect_cost_data = IndirectCost.where('id != ?', self.id)
            .order('start_date DESC').first
      end
      
      if self.start_date <= indirect_cost_data.start_date
        errors.add(:start_date, 'を正しく指定してください。')
      end
    end
  end
  
  # 以下、パブリックメソッド
public  
  ##
  # 間接労務費率を取得する
  #
  # order_type_cd::
  #   受注形態コード
  # subject_cd::
  #   対象区分コード
  #   省略時は社員用の間接労務費率を取得する
  # 戻り値::
  #   受注形態コード、対象区分コードに対応する間接労務費率を返す
  #
  def ratio(order_type_cd, subject_cd = INDIRECT_COST_SUBJECT_CODE[:employee])
    ratio = IndirectCostRatio
        .where(:indirect_cost_id => self.id,
               :order_type_cd => order_type_cd,
               :indirect_cost_subject_cd => subject_cd)
        .first
    return 0.0 if ratio.blank?
    return ratio.ratio
  end
  
  ##
  # 指定された間接労務費の適用開始日が最新かどうか？
  # 
  # indirect_cost_id::
  #   対象間接労務費ID
  # 戻り値::
  #   間接労務費の適用開始日が最新の場合、trueを返す
  #
  def self.start_date_latest?(indirect_cost_id)
    cost = IndirectCost.order('start_date DESC').first
    return indirect_cost_id == cost.id
  end
end
