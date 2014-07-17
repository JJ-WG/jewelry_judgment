class AddDeletedToDeals < ActiveRecord::Migration
  def up
    add_column(:deals, :deleted, :boolean, {:null => false, :default => false, :after => :notes})
  end

  def down
    remove_column(:deals, :deleted)
  end
end
