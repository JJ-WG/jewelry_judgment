class CreateUnitPrices < ActiveRecord::Migration
  def change
    create_table :unit_prices do |t|
      t.integer :user_id,         :null => false                    # ユーザーID
      t.date    :start_date,      :null => false                    # 適用開始日
      t.decimal :unit_price,      :null => false, :default => 0.0,
                :precision => 10, :scale => 0                       # 工数単価

      t.timestamps
    end
  end
end
