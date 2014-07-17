class AddReliabilityCdToDeals < ActiveRecord::Migration
  def up
    add_column :deals, :reliability_cd, :integer, {:null => false, :after => :billing_destination}
    Deal.reset_column_information
    Deal.unscoped.all.each do |deal|
      deal.update_attribute :reliability_cd, RELIABILITY_CODE[:appear_deal]
    end
  end

  def down
    remove_column(:deals, :reliability_cd)
  end
end
