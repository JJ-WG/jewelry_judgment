# encoding: utf-8

#
#= SystemSettingモデルクラス
#
# Created:: 2012/10/5
#
class SystemSetting < ActiveRecord::Base
  # アクセサ定義
  attr_accessible :notice_indication_days, :default_unit_price, :lock_project_after_editing
  
  # バリデーション設定
  validates(:notice_indication_days, :presence => true, :numericality =>
      {:only_integer => true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 999999999})
  validates(:default_unit_price, :presence => true, :numericality =>
      {:greater_than_or_equal_to => 0, :less_than_or_equal_to => 999999999})
  # lock_project_after_editingは、「:presence => true」の場合、falseデータが登録できないため
  # validates_inclusion_ofで入力チェックをおこなう
  validates_inclusion_of(:lock_project_after_editing, :in => [true, false])
  
  # 以下、パブリックメソッド
public
  
  ##
  # 通知メッセージ表示日数を取得する
  # 
  # 戻り値::
  #   通知メッセージ表示日数を返す
  #
  def self.notice_indication_days
    system_setting = SystemSetting.find(1)
    return system_setting.notice_indication_days if system_setting.present?
    rerutn 30
  end
  
  ##
  # 工数単価初期値を取得する
  # 
  # 戻り値::
  #   工数単価初期値を返す
  #
  def self.default_unit_price
    system_setting = SystemSetting.find(1)
    return system_setting.default_unit_price if system_setting.present?
    return 0.0
  end
  
  ##
  # プロジェクト変更時自動ロックフラグを取得する
  # 
  # 戻り値::
  #   プロジェクト変更時自動ロックフラグを返す
  #
  def self.lock_project_after_editing
    system_setting = SystemSetting.find(1)
    return system_setting.lock_project_after_editing if system_setting.present?
    return false
  end
end
