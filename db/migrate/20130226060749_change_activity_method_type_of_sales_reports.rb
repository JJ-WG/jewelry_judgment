class ChangeActivityMethodTypeOfSalesReports < ActiveRecord::Migration
  def up
    change_column(:sales_reports, :activity_method, :integer, {:null => false})
  end

  def down
    change_column(:sales_reports, :activity_method, :string, {:null => true, :limit => 40})
  end
end
