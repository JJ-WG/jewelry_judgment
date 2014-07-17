class CreateOccupations < ActiveRecord::Migration
  def change
    create_table :occupations do |t|
      t.string  :name,       :null => false, :limit => 20  # 職種名
      t.integer :view_order, :null => false                # 表示順

      t.timestamps
    end
  end
end
