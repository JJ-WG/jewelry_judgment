class CreateIndirectCosts < ActiveRecord::Migration
  def change
    create_table :indirect_costs do |t|
      t.date    :start_date,              :null => false                 # 適用開始日
      t.integer :indirect_cost_method_cd, :null => false, :default => 0  # 間接労務費計算方式コード

      t.timestamps
    end
  end
end
