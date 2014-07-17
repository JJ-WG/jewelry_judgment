class CreateCsvSchedules < ActiveRecord::Migration
  def change
    create_table :csv_schedules do |t|
      t.integer :project_id,    :null => false  # プロジェクトID
      t.integer :work_type_id,  :null => false  # 作業工程ID
      t.date    :schedule_date, :null => false  # 日付
      t.date    :start_at,      :null => false  # 開始時間
      t.date    :end_at,        :null => false  # 終了時間
      t.integer :auto_reflect,  :null => false  # 自動反映処理フラグ
      t.text    :notes,         :null => true   # 備考

      t.timestamps
    end
  end
end







