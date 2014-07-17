class CreateCustomers < ActiveRecord::Migration
  def change
    create_table :customers do |t|
      t.string  :code,       :null => true,  :limit => 10  # 顧客コード
      t.string  :name,       :null => false, :limit => 20  # 顧客名
      t.string  :name_ruby,  :null => false, :limit => 40  # 顧客名ふりがな
      t.integer :pref_cd,    :null => false                # 都道府県コード
      t.text    :location,   :null => true                 # 所在地

      t.timestamps
    end

    change_table :customers do |t|
      t.index :code, :unique => true
    end
  end
end
