class AddDeletedToSalesReports < ActiveRecord::Migration
  def change
    add_column(:sales_reports, :deleted, :boolean, {:null => false, :default => false, :after => :responses})
  end
end
