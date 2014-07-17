class ChangeWorkTypeIdNullToTrue < ActiveRecord::Migration
  def up
    change_column_null(:schedules, :work_type_id, true)
    change_column_null(:csv_schedules, :work_type_id, true)
  end

  def down
    change_column_null(:schedules, :work_type_id, false)
    change_column_null(:csv_schedules, :work_type_id, false)
  end
end
