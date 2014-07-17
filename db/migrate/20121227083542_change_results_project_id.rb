class ChangeResultsProjectId < ActiveRecord::Migration
  def up
    change_column :results, :project_id, :integer, :null => true
    change_column :csv_results, :project_id, :integer, :null => true
  end

  def down
    change_column :results, :project_id, :integer, :null => false
    change_column :csv_results, :project_id, :integer, :null => false
  end
end
