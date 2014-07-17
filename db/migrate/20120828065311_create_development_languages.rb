class CreateDevelopmentLanguages < ActiveRecord::Migration
  def change
    create_table :development_languages do |t|
      t.string  :name,       :null => false, :limit => 20  # 開発言語名
      t.integer :view_order, :null => false                # 表示順

      t.timestamps
    end
  end
end
