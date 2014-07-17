class CreateSections < ActiveRecord::Migration
  def change
    create_table :sections do |t|
      t.string  :name,       :null => false, :limit => 40       # 部署名
      t.integer :view_order, :null => false                     # 表示順 
      t.boolean :deleted,    :null => false, :default => false  # 削除フラグ

      t.timestamps
    end
  end
end
