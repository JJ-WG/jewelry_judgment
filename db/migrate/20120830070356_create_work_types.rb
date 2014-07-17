class CreateWorkTypes < ActiveRecord::Migration
  def change
    create_table :work_types do |t|
      t.string  :name,           :null => false, :limit => 20       # 工程名
      t.integer :view_order,     :null => false                     # 表示順
      t.boolean :office_job,     :null => false, :default => false  # 社内業務フラグ
      t.string  :work_type_code, :null => false, :limit => 10       # 作業工程コード

      t.timestamps
    end

    change_table :work_types do |t|
      t.index :work_type_code, :unique => true
    end
  end
end
