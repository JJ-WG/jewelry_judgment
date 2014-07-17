class CreateSystemSettings < ActiveRecord::Migration
  def change
    create_table :system_settings do |t|
      t.integer :notice_indication_days,     :null => false, :default => 30    # 通知メッセージ表示日数
      t.decimal :default_unit_price,         :null => false, :default => 0.0,
                :precision => 10,            :scale => 0                       # 工数単価初期値
      t.boolean :lock_project_after_editing, :null => false, :default => true  # プロジェクト変更時自動ロックフラグ

      t.timestamps
    end
  end
end
