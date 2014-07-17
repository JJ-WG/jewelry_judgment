class ChangeColumnNameToCsvSchMembers < ActiveRecord::Migration
  def up
    # スケジュールID
    remove_column(:csv_sch_members, :schedule_id)
    add_column(:csv_sch_members, :csv_schedule_id, :integer, {:null => false, :after => :id})
  end

  def down
    remove_column(:csv_sch_members, :csv_schedule_id)
    add_column(:csv_sch_members, :schedule_id, :integer, {:null => false, :after => :id})
  end
end
