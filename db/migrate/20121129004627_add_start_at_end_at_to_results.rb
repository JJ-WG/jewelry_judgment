class AddStartAtEndAtToResults < ActiveRecord::Migration
  def up
    add_column(:results, :start_at, :datetime)
    add_column(:results, :end_at, :datetime)
  end

  def down
    remove_column(:results, :start_at)
    remove_column(:results, :end_at)
  end
end
