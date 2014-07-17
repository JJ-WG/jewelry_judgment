class RemoveWorkHoursFromCsvResults < ActiveRecord::Migration
  def up
    remove_column(:csv_results, :work_hours)
  end

  def down
    add_column(:csv_results, :work_hours, :date)
  end
end
