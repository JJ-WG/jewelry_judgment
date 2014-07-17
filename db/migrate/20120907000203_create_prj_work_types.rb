class CreatePrjWorkTypes < ActiveRecord::Migration
  def change
    create_table :prj_work_types do |t|
      t.integer :project_id,         :null => false                    # プロジェクトID
      t.integer :work_type_id,       :null => false                    # 作業工程ID
      t.decimal :planned_man_days,   :null => false, :default => 0.0,
                :precision => 6,     :scale => 2                       # 社内予定工数(人日)
      t.decimal :presented_man_days, :null => false, :default => 0.0,
                :precision => 6,     :scale => 2                       # 客先提示工数(人日)
      t.decimal :progress_rate,      :null => false, :default => 0.0,
                :precision => 5,     :scale => 2                       # 進捗率（％）

      t.timestamps
    end

    change_table :prj_work_types do |t|
      t.index [:project_id, :work_type_id], :unique => true
    end
  end
end
