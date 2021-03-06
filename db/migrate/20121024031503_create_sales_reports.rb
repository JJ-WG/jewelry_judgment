class CreateSalesReports < ActiveRecord::Migration
  def change
    create_table :sales_reports do |t|
      t.integer :deal_id,         :null => false                # ¤kîñID
      t.date    :activity_date,   :null => false                # cÆú
      t.string  :activity_method, :null => true,  :limit => 40  # cÆû@
      t.string  :main_staff,      :null => false, :limit => 20  # ÎÒ
      t.text    :fellow_staff,    :null => true                 # ¯sÒ
      t.string  :destination,     :null => false, :limit => 40  # Kâæ
      t.text    :reports,         :null => false                # ñàe
      t.text    :responses,       :null => true                 # Úq½
      t.integer :reliability_cd,  :null => false                # ómxR[h
      t.text    :summary,         :null => true                 # ñÉÎ·é

      t.timestamps
    end
  end
end
