class CreateTaxDivisions < ActiveRecord::Migration
  def change
    create_table :tax_divisions do |t|
      t.string  :name,           :null => false, :limit => 20       # 区分名
      t.integer :view_order,     :null => false                     # 表示順
      t.integer :tax_type_cd,    :null => false                     # 税種別コード
      t.decimal :tax_rate,       :null => false, :default => 0.00,
                :precision => 5, :scale => 2                        # 税率

      t.timestamps
    end
  end
end
