class ChangeSizeOfUnitPrice < ActiveRecord::Migration
  def up
    change_column(:prj_members, :unit_price, :decimal, {:precision => 10, :scale => 0 })
  end

  def down
    change_column(:prj_members, :unit_price, :decimal, {:precision => 6, :scale => 2 })
  end
end
