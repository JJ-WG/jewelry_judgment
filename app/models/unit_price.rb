# encoding: utf-8

#
#= UnitPriceモデルクラス
#
# Authors:: 青山 ひろ子
# Created:: 2012/10/5
#
class UnitPrice < ActiveRecord::Base
  # アクセサ定義
  attr_accessible :start_date, :unit_price, :user_id
  
  # アソシエーション
  belongs_to :user
  
  # 以下、パブリックメソッド
public

  ##
  # ユーザ工数単価を取得する
  #
  # user_id::
  #   対象ユーザーID
  # user_idstart_date::
  #   工数単価を取得する際の基準日
  #   省略時は当日の日付を基準日とする
  # 戻り値::
  #   ユーザの工数単価を返す
  #
  def self.unit_price(user_id, start_date = Date.today)
    # 工数単価マスタから対象ユーザの工数単価を取得する
    unit_price = UnitPrice.where('user_id = ? AND start_date <= ?', user_id, start_date)
                          .order(:start_date)
                          .last
    return unit_price.unit_price if unit_price.present?
    return SystemSetting.default_unit_price
  end
end
