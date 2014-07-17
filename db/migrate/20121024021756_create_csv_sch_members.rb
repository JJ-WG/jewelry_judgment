class CreateCsvSchMembers < ActiveRecord::Migration
  def change
    create_table :csv_sch_members do |t|
      t.integer :schedule_id, :null => false  # スケジュールID
      t.integer :user_id,     :null => false  # ユーザーID

      t.timestamps
    end
  end
end
