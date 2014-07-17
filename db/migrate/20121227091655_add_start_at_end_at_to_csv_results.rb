class AddStartAtEndAtToCsvResults < ActiveRecord::Migration
  def up
    add_column(:csv_results, :start_at, :datetime)
    add_column(:csv_results, :end_at, :datetime)
  end

  def down
    remove_column(:csv_results, :start_at)
    remove_column(:csv_results, :end_at)
  end
end
