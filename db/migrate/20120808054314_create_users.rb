class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.integer  :section_id,        :null => true                      # 部署ID
      t.integer  :occupation_id,     :null => true                      # 職種ID
      t.string   :login,             :null => false, :limit => 20       # ログイン名
      t.string   :crypted_password                                      # 暗号化パスワード
      t.string   :password_salt                                         # パスワードSALT
      t.string   :persistence_token                                     # 永続トークン
      t.integer  :login_count                                           # ログイン回数
      t.datetime :current_login_at                                      # ログイン回数
      t.datetime :last_login_at                                         # 最終ログイン日時
      t.string   :official_position, :null => true,  :limit => 20       # 役職
      t.string   :name,              :null => false, :limit => 20       # 氏名
      t.string   :name_ruby,         :null => false, :limit => 40       # 氏名ふりがな
      t.integer  :user_rank_cd,      :null => false                     # ユーザー区分
      t.string   :home_phome_no,     :null => true,  :limit => 20       # 自宅電話番号
      t.string   :mobile_phone_no,   :null => true,  :limit => 20       # 携帯番号
      t.string   :mail_address1,     :null => false, :limit => 40       # メールアドレス１
      t.string   :mail_address2,     :null => true,  :limit => 40       # メールアドレス２
      t.string   :mail_address3,     :null => true,  :limit => 40       # メールアドレス３
      t.boolean  :deleted,           :null => false, :default => false  # 削除フラグ
      t.string   :user_code,         :null => false, :limit => 10       # ユーザーコード

      t.timestamps
    end
  end
end
