class AddDeletedToCsvResults < ActiveRecord::Migration
  def up
    add_column(:csv_results, :deleted, :boolean, {:null => false, :default => false, :after => :notes})
  end
  
  def down
    remove_column(:csv_results, :deleted)
  end
end
