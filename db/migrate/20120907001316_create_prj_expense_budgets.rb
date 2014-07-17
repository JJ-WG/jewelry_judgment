class CreatePrjExpenseBudgets < ActiveRecord::Migration
  def change
    create_table :prj_expense_budgets do |t|
      t.integer :project_id,      :null => false                    # プロジェクトID
      t.integer :expense_item_cd, :null => false                    # 経費科目コード
      t.decimal :expense_budget,  :null => false, :default => 0.0,
                :precision => 10, :scale => 0                       # 経費予算金額（税抜）

      t.timestamps
    end

    change_table :prj_expense_budgets do |t|
      t.index [:project_id, :expense_item_cd], :unique => true
    end
  end
end
