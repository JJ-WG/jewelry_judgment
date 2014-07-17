class CreatePrjDatabases < ActiveRecord::Migration
  def change
    create_table :prj_databases do |t|
      t.integer :project_id,  :null => false  # プロジェクトID
      t.integer :database_id, :null => false  # データベースID

      t.timestamps
    end

    change_table :prj_databases do |t|
      t.index [:project_id, :database_id], :unique => true
    end
  end
end
