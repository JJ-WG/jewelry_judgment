class CreatePrjSalesCosts < ActiveRecord::Migration
  def change
    create_table :prj_sales_costs do |t|
      t.integer :project_id,      :null => false                    # プロジェクトID
      t.integer :tax_division_id, :null => false                    # 税区分ID
      t.string  :item_name,       :null => false, :limit => 40      # 品目名
      t.decimal :price,           :null => false, :default => 0.0,
                :precision => 10, :scale => 0                       # 価格

      t.timestamps
    end
  end
end
