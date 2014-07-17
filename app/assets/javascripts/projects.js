//
// プロジェクト管理機能JavaScript
//
jQuery(function(){
  //
  // プロジェクト登録・編集機能
  // 商談管理案件の選択が変更された時の処理
  // （on_change_deal_list.jsを呼び出し、顧客リストや受注形態の選択状態、受注額を変更する）
  //
  $('#project_deal_id').change(function(){
    var project_id = $("#project_id").val();
    var deal_id = $("#project_deal_id").val();
    $.get(app_name_for_url + "/prj/projects/on_change_deal_list.js?" +
        "project_id=" + project_id +
        "&deal_id=" + deal_id);
  });
  
  //
  // プロジェクト登録・編集機能
  // 部署の選択が変更された時の処理
  // （on_change_section_list.jsを呼び出し、メンバーリストを変更する）
  //
  $('#project_section_id').change(function(){
    var project_id = $("#project_id").val();
    var section_id = $("#project_section_id").val();
    $.get(app_name_for_url + "/prj/projects/on_change_section_list.js?" +
        "project_id=" + project_id +
        "&section_id=" + section_id);
  });
  
  //
  // プロジェクト登録・編集機能
  // プロジェクトメンバー編集 「<追加」ボタンクリック時の処理
  // （on_click_prj_member_add.jsを呼び出し、プロジェクトメンバーリストを変更する）
  //
  $('#member_add_button').click(function(){
    var project_id = $("#project_id").val();
    var section_id = $("#project_section_id").val();
    var user_id = $("#project_prj_member_user_id").val();
    $.get(app_name_for_url + "/prj/projects/on_click_prj_member_add.js?" +
        "project_id=" + project_id +
        "&section_id=" + section_id +
        "&user_id=" + user_id);
  });
  
  //
  // プロジェクト登録・編集機能
  // 工数編集 社内工数、客先工数の入力変更時の処理
  // （on_click_work_type_total.jsを呼び出し、工数の合計を変更する）
  //
  $('.prj_work_types_man_days').click(function(){
    var project_id = $("#project_id").val();
    
    // 工程数を取得
    var size = document.getElementById('project_prj_work_type_size').value;
    
    var planned_man_days_total = 0;
    var presented_man_days_total = 0;
    var progress_rate_total = 0;
    if (size != 0) {
      // 社内工数、客先工数
      for (i = 0; i < size; i++) {
        planned_man_days = Number(document.getElementById(
            'project_prj_work_types_attributes_' + i + '_planned_man_days').value);
        presented_man_day = Number(document.getElementById(
            'project_prj_work_types_attributes_' + i + '_presented_man_days').value);
        if (!isNaN(planned_man_days)){
          planned_man_days_total += planned_man_days;
        }
        if (!isNaN(presented_man_day)){
          presented_man_days_total += presented_man_day;
        }
      }
      // 進捗率（編集画面のみ）
      if (document.getElementById('project_prj_work_types_attributes_0_progress_rate')){
        for (i = 0; i < size; i++) {
          planned_man_days = Number(document.getElementById(
              'project_prj_work_types_attributes_' + i + '_planned_man_days').value);
          progress_rate = Number(document.getElementById(
              'project_prj_work_types_attributes_' + i + '_progress_rate').value);
          if (!isNaN(planned_man_days) && !isNaN(progress_rate)){ 
            progress = planned_man_days * progress_rate;
            if (progress != 0){
              rate = Math.round(progress / planned_man_days_total * 100) / 100
              progress_rate_total += rate;
            }
          }
        }
      }
    }
    $.get(app_name_for_url + "/prj/projects/on_click_work_type_total.js?" +
        "project_id=" + project_id +
        "&planned_man_days_total=" + planned_man_days_total +
        "&presented_man_days_total=" + presented_man_days_total +
        "&progress_rate_total=" + progress_rate_total);
  });
  
  //
  // プロジェクト登録・編集機能
  // 工数編集 進捗率の入力変更時の処理
  // （on_click_work_type_total.jsを呼び出し、工数の合計を変更する）
  //
  $('.prj_work_types_progress_rate').click(function(){
    $('.prj_work_types_man_days').click();
  });
  
  //
  // プロジェクト登録・編集機能
  // 工数編集 「合計」ボタンクリック時の処理
  // （on_click_work_type_total.jsを呼び出し、工数の合計を変更する）
  //
  $('#work_type_total_button').click(function(){
    $('.prj_work_types_man_days').click();
  });
  
  //
  // プロジェクト登録・編集機能
  // 経費予算編集 経費予算入力変更時の処理
  // （on_click_expense_budget_total.jsを呼び出し、経費予算の合計を変更する）
  //
  $('.prj_expense_budgets_expense_budget').click(function(){
    var project_id = $("#project_id").val();
    var expense_budget_total = 0
    for (i = 0; i <= 2; i++) {
      val = Number($("#project_prj_expense_budgets_attributes_" + i + "_expense_budget").val());
      if (!isNaN(val)){
        expense_budget_total = expense_budget_total + val
      }
    }
    $.get(app_name_for_url + "/prj/projects/on_click_expense_budget_total.js?" +
        "project_id=" + project_id +
        "&expense_budget_total=" + expense_budget_total);
  });
    
  //
  // プロジェクト登録・編集機能
  // 経費予算編集 「合計」ボタンクリック時の処理
  // （on_click_expense_budget_total.jsを呼び出し、経費予算の合計を変更する）
  //
  $('#expense_budget_total_button').click(function(){
    $('.prj_expense_budgets_expense_budget').click();
  });
  
  //
  // プロジェクト登録・編集機能
  // 販売原価編集 「<追加」ボタンクリック時の処理
  // （on_click_sales_cost_add.jsを呼び出し、プロジェクトメンバーリストを変更する）
  //
  $('#sales_cost_add_button').click(function(){
    var project_id = $("#project_id").val();
    var sales_cost_item_name = $("#project_sales_cost_item_name").val();
    var sales_cost_price = $("#project_sales_cost_price").val();
    var sales_cost_tax_division_cd = $("#project_sales_cost_tax_division_cd").val();
    $.get(app_name_for_url + "/prj/projects/on_click_sales_cost_add.js?" +
        "project_id=" + project_id +
        "&sales_cost_item_name=" + encodeURI(sales_cost_item_name) +
        "&amp;sales_cost_price=" + sales_cost_price +
        "&amp;sales_cost_tax_division_cd=" + sales_cost_tax_division_cd);
  });
  
  //
  // プロジェクト登録・編集機能
  // 関連プロジェクト編集 状態の選択が変更された時の処理
  // （on_change_status_list.jsを呼び出し、プロジェクトリストを変更する）
  //
  $('#project_related_project_status_cd').change(function(){
    var project_id = $("#project_id").val();
    var related_project_status_cd = $("#project_related_project_status_cd").val();
    $.get(app_name_for_url + "/prj/projects/on_change_status_list.js?" +
        "project_id=" + project_id +
        "&related_project_status_cd=" + related_project_status_cd);
  });
  
  //
  // プロジェクト登録・編集機能
  // 関連プロジェク編集 「<追加」ボタンクリック時の処理
  // （on_click_related_project_add.jsを呼び出し、プロジェクトメンバーリストを変更する）
  //
  $('#related_project_add_button').click(function(){
    var project_id = $("#project_id").val();
    var related_project_status_cd = $("#project_related_project_status_cd").val();
    var related_project_id = $("#project_related_project_id").val();
    $.get(app_name_for_url + "/prj/projects/on_click_related_project_add.js?" +
        "project_id=" + project_id +
        "&related_project_status_cd=" + related_project_status_cd +
        "&amp;related_project_id=" + related_project_id);
  });
});

//
// プロジェクト登録・編集機能
// プロジェクトメンバー編集 予定工数入力変更時の処理
// （on_change_prj_member_planned_man_days.jsを呼び出し、
//  予定工数をセッションに保存して予定工数合計値や直接労務費予算を変更する）
function on_change_prj_member_planned_man_days(text_box) {
  var project_id = $("#project_id").val();
  var name = text_box.id;
  var index = name.replace('project_prj_members_attributes_', '').replace('_planned_man_days', '');
  var value = text_box.value;
  if (isNaN(index)){
    index = 0;
  }
  if (isNaN(value)){
    value = 0;
  }
  $.get(app_name_for_url + "/prj/projects/on_change_prj_member_planned_man_days.js?" +
      "project_id=" + project_id +
      "&index=" + index +
      "&value=" + value);
}

//
// プロジェクト登録・編集機能
// プロジェクトメンバー編集 予定工数の「合計」ボタンクリック時の処理
// （on_click_prj_member_total.jsを呼び出し、予定工数合計値や直接労務費予算を変更する）
//
function on_click_prj_member_total() {
  var project_id = $("#project_id").val();
  
  // プロジェクトメンバー数を取得
  var size=document.getElementById('project_prj_member_size').value;
  
  var planned_man_days_total = 0;
  var presented_man_days_total = 0;
  for (i = 0; i < size; i++) {
    planned_man_days = Number(document.getElementById(
        'project_prj_work_types_attributes_' + i + '_planned_man_days').value);
    presented_man_day = Number(document.getElementById(
        'project_prj_work_types_attributes_' + i + '_presented_man_days').value);
    if(!isNaN(planned_man_days)){
      planned_man_days_total += planned_man_days;
    }
    if(!isNaN(presented_man_day)){
      presented_man_days_total += presented_man_day;
    }
  }
  $.get(app_name_for_url + "/prj/projects/on_click_work_type_total.js?" +
      "project_id=" + project_id +
      "&planned_man_days_total=" + planned_man_days_total +
      "&presented_man_days_total=" + presented_man_days_total);
}
