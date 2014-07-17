class CreateNotices < ActiveRecord::Migration
  def change
    create_table :notices do |t|
      t.integer :user_id,    :null => false  # ユーザID
      t.integer :project_id, :null => false  # プロジェクトID
      t.integer :message_cd, :null => false  # メッセージコード
      t.text    :message                     # メッセージ

      t.timestamps
    end
  end
end
