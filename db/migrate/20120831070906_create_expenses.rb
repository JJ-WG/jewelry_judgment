class CreateExpenses < ActiveRecord::Migration
  def change
    create_table :expenses do |t|
      t.integer  :user_id,         :null => false                # 精算者ID
      t.integer  :project_id,      :null => false                # プロジェクトID
      t.integer  :expense_type_id, :null => false                # 経費種類ID
      t.integer  :tax_division_id, :null => false                # 税区分ID
      t.date     :adjusted_date,   :null => false                # 精算日
      t.string   :item_name,       :null => false, :limit => 40  # 経費内容
      t.decimal  :amount_paid,     :null => false,
                 :precision => 10, :scale => 0                   # 精算金額

      t.timestamps
    end
  end
end
