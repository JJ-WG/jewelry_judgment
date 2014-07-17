class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.integer  :customer_id,     :null => true                      # プロジェクトID
      t.integer  :manager_id,      :null => false	               # プロジェクトマネージャーID
      t.integer  :leader_id,       :null => false                     # 顧客ID
      t.integer  :deal_id,         :null => true                      # リーダーID
      t.integer  :order_type_cd,   :null => false                     # 商談情報ID
      t.integer  :status_cd,       :null => false                     # 受注形態コード
      t.string   :name,            :null => false, :limit => 40       # プロジェクト名
      t.date     :start_date,      :null => false                     # 開始予定年月日
      t.date     :started_date,    :null => true                      # 開始年月日
      t.date     :finish_date,     :null => false                     # 終了予定年月日
      t.date     :finished_date,   :null => true                      # 終了年月日
      t.text     :remarks,         :null => true                      # 備考
      t.boolean  :attention,       :null => false, :default => false  # 注目プロジェクト
      t.boolean  :deleted,         :null => false, :default => false  # 削除プラグ
      t.decimal  :order_volume,    :null => true,  :default => 0.0,
                 :precision => 10, :scale => 0                        # 受注額
      t.boolean  :locked,          :null => false, :default => false  # ロックプラグ
      t.string   :project_code,    :null => false, :limit => 10       # プロジェクトコード

      t.timestamps
    end

    change_table :projects do |t|
      t.index :project_code, :unique => true
    end
  end
end
