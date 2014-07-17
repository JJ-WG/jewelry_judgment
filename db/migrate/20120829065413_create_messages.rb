class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :title,   :null => false, :limit => 50  # タイトル
      t.text   :message, :null => false                # メッセージ

      t.timestamps
    end
  end
end
