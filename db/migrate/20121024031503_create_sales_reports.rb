class CreateSalesReports < ActiveRecord::Migration
  def change
    create_table :sales_reports do |t|
      t.integer :deal_id,         :null => false                # 商談情報ID
      t.date    :activity_date,   :null => false                # 営業日
      t.string  :activity_method, :null => true,  :limit => 40  # 営業方法
      t.string  :main_staff,      :null => false, :limit => 20  # 対応者
      t.text    :fellow_staff,    :null => true                 # 同行者
      t.string  :destination,     :null => false, :limit => 40  # 訪問先
      t.text    :reports,         :null => false                # 報告内容
      t.text    :responses,       :null => true                 # 顧客反応
      t.integer :reliability_cd,  :null => false                # 受注確度コード
      t.text    :summary,         :null => true                 # 報告に対する総括

      t.timestamps
    end
  end
end
