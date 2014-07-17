class RemoveReliabilityCdAndSummaryFromSalesReports < ActiveRecord::Migration
  def up
    remove_column(:sales_reports, :reliability_cd)
    remove_column(:sales_reports, :summary)
  end

  def down
    add_column(:sales_reports, :reliability_cd, :integer, {:null => false, :after => :responses})
    add_column(:sales_reports, :summary, :text, {:null => true, :after => :reliability_cd})
  end
end
