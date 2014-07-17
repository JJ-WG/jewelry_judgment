class CreateExpenseTypes < ActiveRecord::Migration
  def change
    create_table :expense_types do |t|
      t.integer :tax_division_id, :null => false                # デフォルト税区分
      t.integer :expense_item_cd, :null => false                # 経費科目
      t.string  :name,            :null => false, :limit => 20  # 経費種類名
      t.integer :view_order,      :null => false                # 表示順

      t.timestamps
    end
  end
end
