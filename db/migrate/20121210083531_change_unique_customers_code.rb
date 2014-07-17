class ChangeUniqueCustomersCode < ActiveRecord::Migration
  def up
    remove_index :customers, :code
    add_index :customers, :code, :unique => false
  end

  def down
    remove_index :customers, :code
    add_index :customers, :code, :unique => true
  end
end
