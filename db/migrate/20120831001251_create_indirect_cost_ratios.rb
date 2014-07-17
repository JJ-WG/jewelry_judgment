class CreateIndirectCostRatios < ActiveRecord::Migration
  def change
    create_table :indirect_cost_ratios do |t|
      t.integer :indirect_cost_id,         :null => false                     # 間接労務費ID
      t.integer :indirect_cost_subject_cd, :null => false                     # 対象区分
      t.integer :order_type_cd,            :null => false                     # 受注形態
      t.decimal :ratio,                    :null => false, :default => 0.00,
                :precision => 5,           :scale => 2                        # 間接労務費比率

      t.timestamps
    end
  end
end
