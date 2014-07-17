class CreateDeals < ActiveRecord::Migration
  def change
    create_table :deals do |t|
      t.integer :customer_id,         :null => false                    # 顧客ID
      t.integer :staff_user_id,       :null => false                    # 営業担当者ユーザID
      t.string  :solution_name,       :null => true,  :limit => 20      # ソリューション名
      t.string  :name,                :null => false, :limit => 40      # 案件名
      t.string  :customer_section,    :null => true,  :limit => 20      # 顧客所属名
      t.string  :contact_person_name, :null => true,  :limit => 20      # 顧客担当者名
      t.decimal :budge_amount,        :null => false, :default => 0.0,
                :precision => 10,     :scale => 0                       # 予算額（税抜）
      t.decimal :anticipated_price,   :null => false, :default => 0.0,
                :precision => 10,     :scale => 0                       # 予定価格（税抜）
      t.decimal :order_volume,        :null => false, :default => 0.0,
                :precision => 10,     :scale => 0                       # 受注額（税抜）
      t.string  :adoption_period,     :null => true,  :limit => 20      # 選定時期
      t.string  :delivery_period,     :null => true,  :limit => 20      # 導入時期
      t.string  :selection_method,    :null => true,  :limit => 20      # 選定方法
      t.integer :order_type_cd,       :null => true                     # 受注形態コード
      t.string  :billing_destination, :null => true,  :limit => 40      # 請求先
      t.integer :deal_status_cd,      :null => true                     # 商談ステータスコード
      t.boolean :prj_managed                                            # PJ管理対象フラグ
      t.text    :notes,               :null => true                     # 備考

      t.timestamps
    end
  end
end
