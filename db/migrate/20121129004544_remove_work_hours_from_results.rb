class RemoveWorkHoursFromResults < ActiveRecord::Migration
  def up
    remove_column(:results, :work_hours)
  end

  def down
    add_column(:results, :work_hours, :date)
  end
end
