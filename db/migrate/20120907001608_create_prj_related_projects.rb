class CreatePrjRelatedProjects < ActiveRecord::Migration
  def change
    create_table :prj_related_projects do |t|
      t.integer :project_id,         :null => false  # プロジェクトID
      t.integer :related_project_id, :null => false  # 関連プロジェクトID

      t.timestamps
    end

    change_table :prj_related_projects do |t|
      t.index [:project_id, :related_project_id], :unique => true
    end
  end
end
