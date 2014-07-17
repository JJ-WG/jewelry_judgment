class AddDeleted < ActiveRecord::Migration
  def up
    add_column(:schedules, :deleted, :boolean, {:null => false, :default => false, :after => :notes})
    add_column(:sch_members, :deleted, :boolean, {:null => false, :default => false, :after => :user_id})
    add_column(:results, :deleted, :boolean, {:null => false, :default => false, :after => :notes})
    add_column(:csv_schedules, :deleted, :boolean, {:null => false, :default => false, :after => :notes})
    add_column(:csv_sch_members, :deleted, :boolean, {:null => false, :default => false, :after => :user_id})
  end

  def down
    remove_column(:schedules, :deleted)
    remove_column(:sch_members, :deleted)
    remove_column(:results, :deleted)
    remove_column(:csv_schedules, :deleted)
    remove_column(:csv_sch_members, :deleted)
  end
end
