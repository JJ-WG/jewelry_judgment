class CreatePrjReflections < ActiveRecord::Migration
  def change
    create_table :prj_reflections do |t|
      t.integer :project_id,              :null => false                    # プロジェクトID
      t.decimal :order_volume,            :null => false, :default => 0.0,
                :precision => 10,         :scale => 0                       # 受注額（実績値）
      t.decimal :sales_cost,              :null => false, :default => 0.0,
                :precision => 10,         :scale => 0                       # 販売原価（実績値）
      t.decimal :man_day,                 :null => false, :default => 0.0,
                :precision => 6,          :scale => 2                       # 開発工数（実績値）
      t.decimal :direct_labor_cost,       :null => false, :default => 0.0,
                :precision => 10,         :scale => 0                       # 直接労務費（実績値）
      t.decimal :subcontract_cost,        :null => false, :default => 0.0,
                :precision => 10,         :scale => 0                       # 外注費（実績値）
      t.decimal :expense,                 :null => false, :default => 0.0,
                :precision => 10,         :scale => 0                       # 直接経費（実績値）
      t.decimal :indirect_labor_cost,     :null => false, :default => 0.0,
                :precision => 10,         :scale => 0                       # 間接労務費（実績値）
      t.decimal :development_cost,        :null => false, :default => 0.0,
                :precision => 10,         :scale => 0                       # 開発原価（実績値）
      t.decimal :gross_profit,            :null => false, :default => 0.0,
                :precision => 10,         :scale => 0                       # 粗利（実績値）
      t.decimal :profit_ratio,            :null => false, :default => 0.0,
                :precision => 5,          :scale => 2                       # 粗利率（実績値）
      t.integer :overall_rank,            :null => false, :limit => 1       # 総合評価ランク
      t.text    :reasons_for_termination, :null => true                     # プロジェクト終了の理由
      t.text    :self_evaluation,         :null => true                     # 自己評価
      t.date    :finished_date,           :null => false                    # 終了年月日
      t.date    :planned_finish_date,     :null => false                    # 終了予定年月日
      t.integer :delay_days,              :null => false                    # 遅れ日数
      t.integer :schedule_rank,           :null => false, :limit => 1       # スケジュール評価ランク
      t.text    :reasons_for_dalay,       :null => true                     # 遅れの主な要因
      t.decimal :planned_man_days,        :null => false, :default => 0.0,
                :precision => 6,          :scale => 2                       # 予定工数
      t.decimal :exceeded_man_days,       :null => false, :default => 0.0,
                :precision => 6,          :scale => 2                       # 超過工数
      t.integer :man_days_rank,           :null => false, :limit => 1       # 工数評価ランク
      t.text    :reasons_for_overtime,    :null => true                     # 工数超過の主な要因
      t.decimal :expense_budget,          :null => false, :default => 0.0,
                :precision => 10,         :scale => 0                       # 経費予算
      t.decimal :exceeded_expense,        :null => false, :default => 0.0,
                :precision => 10,         :scale => 0                       # 超過金額
      t.integer :expense_rank,            :null => false, :limit => 1       # 経費評価ランク
      t.text    :reasons_for_over_budget, :null => true                     # 経費超過の主な要因
      t.text    :successful_things,       :null => true                     # うまく行ったこと
      t.text    :failed_things,           :null => true                     # うまく行かなかったこと
      t.text    :improvable_things,       :null => true                     # 改善できること
      t.text    :next_actions,            :null => true                     # 今後のアクション
      t.text    :learned_skills,          :null => true                     # 学習したスキル

      t.timestamps
    end
  end
end
