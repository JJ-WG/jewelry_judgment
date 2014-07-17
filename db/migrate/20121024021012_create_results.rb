class CreateResults < ActiveRecord::Migration
  def change
    create_table :results do |t|
      t.integer :schedule_id,  :null => true   # スケジュールID
      t.integer :user_id,      :null => false  # ユーザーID
      t.integer :project_id,   :null => false  # プロジェクトID
      t.integer :work_type_id, :null => false  # 作業工程ID
      t.date    :result_date,  :null => false  # 日付
      t.time    :work_hours,   :null => false  # 作業時間
      t.text    :notes,        :null => true   # 備考

      t.timestamps
    end
  end
end
