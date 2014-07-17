class CreatePrjOperatingSystems < ActiveRecord::Migration
  def change
    create_table :prj_operating_systems do |t|
      t.integer :project_id,          :null => false  # 開発言語ID
      t.integer :operating_system_id, :null => false  # オペレーティングシステムID

      t.timestamps
    end

    change_table :prj_operating_systems do |t|
      t.index [:project_id, :operating_system_id], :unique => true,
          :name => 'idx_prj_operating_systems_on_project_id_and_operating_system_id'
    end
  end
end
