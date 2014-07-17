class CreatePrjMembers < ActiveRecord::Migration
  def change
    create_table :prj_members do |t|
      t.integer :project_id,       :null => false                    # プロジェクトID
      t.integer :user_id,          :null => false                    # ユーザID
      t.decimal :unit_price,       :null => false, :default => 0.0, 
                :precision => 6,   :scale => 2                       # 工数単価
      t.decimal :planned_man_days, :null => false, :default => 0.0, 
                :precision => 6,   :scale => 2                       # 予定工数(人日)
      
      t.timestamps
    end
    
    change_table :prj_members do |t|
      t.index [:project_id, :user_id], :unique => true
    end
  end
end
