class CreateDatabases < ActiveRecord::Migration
  def change
    create_table :databases do |t|
      t.string  :name,       :null => false, :limit => 20  # DB名
      t.integer :view_order, :null => false                # 表示順

      t.timestamps
    end
  end
end
