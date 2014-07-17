class CreateOperatingSystems < ActiveRecord::Migration
  def change
    create_table :operating_systems do |t|
      t.string  :name,       :null => false, :limit => 20  # OS名
      t.integer :view_order, :null => false                # 表示ｊ順

      t.timestamps
    end
  end
end
