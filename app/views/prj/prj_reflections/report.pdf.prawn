mesh = 'CCCCCC'
max_width = 170.mm
blank_line = 5.mm
right_padding = [5,15,5,5]
day_padding = [5,60,5,5]
scope1 = 'label.project_reflection.report'
scope2 = 'activerecord.attributes'
scope3 = scope2 + '.prj_reflection'
scope4 = scope2 + '.project'

# 共通プロパティ
pdf.font PDF_FONT_PATH
pdf.font_size 10
pdf.default_leading 4

# タイトル
pdf.text t('title', :scope => scope1),
         :size => 16, :align => :center, :leading => blank_line

# プロジェクト情報
title_width = 35.mm
pdf.table([
  # プロジェクト名
  [t(:name, :scope => scope4), @project.name],
  # 顧客名
  [t('customer.name', :scope => scope2), @project.customer_name],
], :width => max_width, :column_widths => {0 => title_width}) do
  columns(0).background_color = mesh
end
pdf.table([
  # 作成日
  [t(:creation_date, :scope => scope1),
    l(@prj_reflection.updated_at, :format => :local_date),
  # リーダー名
    t(:leader_name, :scope => scope4),
    @project.leader_name],
], :width => max_width, :column_widths => {0 => title_width}) do
  columns(0).background_color = mesh
  columns(2).background_color = mesh
end

# ■プロジェクトの結果
pdf.move_down blank_line
pdf.text t(:list_mark, :scope => scope1) +
           t(:project_result, :scope => scope1)
title_width = 45.mm
pdf.table([
  # 受注額
  [t('deal.order_volume', :scope => scope2) +
      t('common_label.without_tax'),
    number_to_currency(@prj_reflection.order_volume),
  # 評価
    t(:rank_label, :scope => scope4),
    EVALUATION_RANK_CODE[@prj_reflection.overall_rank]],
], :width => max_width, :column_widths => {0 => title_width}) do
  columns(0).background_color = mesh
  columns(1).align = :right
  columns(1).padding = right_padding
  columns(2).background_color = mesh
  columns(3).align = :center
end
pdf.table([
  # 開発原価
  [t(:development_cost, :scope => scope3) +
      t('common_label.without_tax'),
    t(:budget, :scope => scope4),
    number_to_currency(@project.development_cost_budget),
    t(:results_cost, :scope => scope4),
    number_to_currency(@prj_reflection.development_cost)],
  # 粗利
  [t(:gross_profit, :scope => scope3) +
      t('common_label.without_tax'),
    t(:budget, :scope => scope4),
    number_to_currency(@project.gross_profit_budget),
    t(:results_cost, :scope => scope4),
    number_to_currency(@prj_reflection.gross_profit)],
  # 粗利率
  [t(:profit_ratio, :scope => scope3),
    t(:budget, :scope => scope4),
    number_to_percentage(@project.profit_ratio_budget),
    t(:results_cost, :scope => scope4),
    number_to_percentage(@prj_reflection.profit_ratio)],
], :width => max_width, :column_widths => {0 => title_width}) do
  columns(0).background_color = mesh
  [1,3].each do |col|
    columns(col).borders = [:top,:bottom,:left]
  end
  [2,4].each do |col|
    columns(col).borders = [:top,:bottom,:right]
    columns(col).align = :right
    columns(col).padding = right_padding
  end
end
pdf.table([
  # プロジェクト終了の理由
  [t(:reasons_for_termination, :scope => scope3),
    @prj_reflection.reasons_for_termination],
  # 自己評価
  [t(:self_evaluation, :scope => scope3),
    @prj_reflection.self_evaluation],
], :width => max_width, :column_widths => {0 => title_width}) do
  columns(0).background_color = mesh
end

# ■スケジュールに対する評価
pdf.move_down blank_line
pdf.text t(:list_mark, :scope => scope1) +
           t(:schedule_evaluation, :scope => scope1)
title_width = 35.mm
pdf.table([
  # 終了予定日
  [t(:planned_finish_date_label, :scope => scope3),
    l(@prj_reflection.planned_finish_date, :format => :local_date),
  # 実績終了日
    t(:finished_date, :scope => scope1),
    l(@prj_reflection.finished_date, :format => :local_date)],
  # 遅れ
  [t(:delay_days, :scope => scope3),
    @prj_reflection.delay_days.to_s + t('datetime.prompts.day'),
  # 評価
    t(:rank_label, :scope => scope4),
    EVALUATION_RANK_CODE[@prj_reflection.schedule_rank]],
], :width => max_width, :column_widths => {
    0 => title_width, 1 => (max_width/2 - title_width),
    2 => title_width}) do
  columns(0).background_color = mesh
  columns(2).background_color = mesh
  row(1).column(1).align = :right
  row(1).column(1).padding = day_padding
  row(1).column(3).align = :center
end
pdf.table([
  # 遅れの主な要因
  [t(:reasons_for_dalay, :scope => scope3),
    @prj_reflection.reasons_for_dalay],
], :width => max_width, :column_widths => {0 => title_width}) do
  columns(0).background_color = mesh
end

# ■工数に対する評価
pdf.move_down blank_line
pdf.text t(:list_mark, :scope => scope1) +
           t(:man_days_evaluation, :scope => scope1)
title_width = 35.mm
pdf.table([
  # 予定工数
  [t(:planned_man_days, :scope => scope3),
    number_with_precision(@project.planned_man_days) +
      t('datetime.prompts.day'),
  # 実績工数
   t(:result_man_days, :scope => scope1),
    number_with_precision(@prj_reflection.man_day) +
      t('datetime.prompts.day')],
  # 超過工数
  [t(:exceeded_man_days, :scope => scope3),
    number_with_precision(@prj_reflection.exceeded_man_days) +
      t('datetime.prompts.day'),
  # 評価
    t(:rank_label, :scope => scope4),
    EVALUATION_RANK_CODE[@prj_reflection.man_days_rank]],
], :width => max_width, :column_widths => {
    0 => title_width, 1 => (max_width/2 - title_width),
    2 => title_width}) do
  columns(0).background_color = mesh
  columns(1).align = :right
  columns(1).padding = day_padding
  columns(2).background_color = mesh
  row(0).column(3).align = :right
  row(0).column(3).padding = day_padding
  row(1).column(3).align = :center
end
pdf.table([
  # 超過の主な要因
  [t(:reasons_for_overtime_label, :scope => scope3),
    @prj_reflection.reasons_for_overtime],
], :width => max_width, :column_widths => {0 => title_width}) do
  columns(0).background_color = mesh
end

# ■経費に対する評価
pdf.move_down blank_line
pdf.text  t(:list_mark, :scope => scope1) +
            t(:expense_evaluation, :scope => scope1)
title_width = 35.mm
pdf.table([
  # 経費予算
  [t(:expense_budget, :scope => scope3) +
      t('common_label.without_tax'),
    number_to_currency(@project.direct_expense_budget),
  # 経費実績
    t(:result_expense, :scope => scope1) +
      t('common_label.without_tax'),
    number_to_currency(@prj_reflection.expense)],
  # 超過金額
  [t(:exceeded_expense, :scope => scope3) +
      t('common_label.without_tax'),
    number_to_currency(@prj_reflection.exceeded_expense),
  # 評価
    t(:rank_label, :scope => scope4),
    EVALUATION_RANK_CODE[@prj_reflection.expense_rank]],
], :width => max_width, :column_widths => {
    0 => title_width, 1 => (max_width/2 - title_width),
    2 => title_width}) do
  columns(0).background_color = mesh
  columns(1).align = :right
  columns(1).padding = right_padding
  columns(2).background_color = mesh
  row(0).column(3).align = :right
  row(0).column(3).padding = right_padding
  row(1).column(3).align = :center
end
pdf.table([
  # 超過の主な要因
  [t(:reasons_for_over_budget_label, :scope => scope3),
    @prj_reflection.reasons_for_over_budget],
], :width => max_width, :column_widths => {0 => title_width}) do
  columns(0).background_color = mesh
end

# ■学んだこと
pdf.move_down blank_line
pdf.text  t(:list_mark, :scope => scope1) +
            t(:lessons_learned, :scope => scope1)
title_width = 45.mm
pdf.table([
  # うまく行ったことは何か
  [t(:successful_things, :scope => scope3),
    @prj_reflection.successful_things],
  # うまく行かなかったことは何か
  [t(:failed_things, :scope => scope3),
    @prj_reflection.failed_things],
  # 改善できることは何か
  [t(:improvable_things, :scope => scope3),
    @prj_reflection.improvable_things],
  # 今後のために必要なアクション
  [t(:next_actions_label, :scope => scope3),
    @prj_reflection.next_actions],
  # プロジェクトを通して学習したスキル
  [t(:learned_skills_label, :scope => scope3),
    @prj_reflection.learned_skills],
], :width => max_width, :column_widths => {0 => title_width}) do
  columns(0).background_color = mesh
end

# ページ番号
pdf.number_pages '- <page> -', {:at => [0,-5.mm], :align => :center}
