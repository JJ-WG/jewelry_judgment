class AddActivityObjectiveToSalesReports < ActiveRecord::Migration
  def change
    add_column(:sales_reports, :activity_objective, :string, {:null => false, :limit => 40, :after => :fellow_staff})
  end
end
