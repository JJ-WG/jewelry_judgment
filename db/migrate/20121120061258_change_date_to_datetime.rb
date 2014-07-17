class ChangeDateToDatetime < ActiveRecord::Migration
  def up
    change_column(:schedules, :start_at, :datetime)
    change_column(:schedules, :end_at, :datetime)
    change_column(:csv_schedules, :start_at, :datetime)
    change_column(:csv_schedules, :end_at, :datetime)
  end

  def down
    change_column(:schedules, :start_at, :date)
    change_column(:schedules, :end_at, :date)
    change_column(:csv_schedules, :start_at, :date)
    change_column(:csv_schedules, :end_at, :date)
  end
end
