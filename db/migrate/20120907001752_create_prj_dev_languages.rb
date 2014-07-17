class CreatePrjDevLanguages < ActiveRecord::Migration
  def change
    create_table :prj_dev_languages do |t|
      t.integer :project_id,              :null => false  # プロジェクトID
      t.integer :development_language_id, :null => false  # 開発言語ID

      t.timestamps
    end

    change_table :prj_dev_languages do |t|
      t.index [:project_id, :development_language_id], :unique => true,
          :name => 'idx_prj_dev_languages_on_project_id_and_development_language_id'
    end
  end
end
