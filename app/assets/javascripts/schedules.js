//
// プロジェクト管理機能JavaScript
//
jQuery(function(){
  // 全選択のクリック処理
  $('#selectAll').click(function(){
    var selectboxes = document.getElementsByName('select_ids[]');
    for(i=0; i<selectboxes.length; i++) {
      selectboxes[i].checked = true;
    } 
  });

  // 全解除のクリック処理
  $('#unselectAll').click(function(){
    var selectboxes = document.getElementsByName('select_ids[]');
    for(i=0; i<selectboxes.length; i++) {
      selectboxes[i].checked = false;
    } 
  });

  //
  // プロジェクトの選択が変更された時の処理
  // （on_change_project_list.jsを呼び出し、メンバーリストを変更する）
  //
  $('#schedule_project_id').change(function(){
    var project_id = $("#schedule_project_id").val();
    $.get(app_name_for_url + "/schedule/schedules/on_change_project_list.js?project_id=" + project_id);
  });

  //
  // 参加者選択の「追加 >」ボタンクリック時の処理
  // （on_click_schedule_member_add.jsを呼び出し、選択した参加者のリストを変更する）
  //
  $('#schedule_member_add_button').click(function(){
    var project_id = $("#schedule_project_id").val();
    var user_ids = $("#schedule_schedule_member_user_id").val() || [];
    if(user_ids.length > 0) {
      $.get(app_name_for_url + "/schedule/schedules/on_click_schedule_member_add.js?project_id=" + project_id + "&user_ids=" + user_ids.join(':'));
    }
  });

  //
  // 参加者選択の「< 削除」ボタンクリック時の処理
  // （on_click_schedule_member_remove.jsを呼び出し、選択した参加者のリストを変更する）
  //
  $('#schedule_member_remove_button').click(function(){
    var project_id = $("#schedule_project_id").val();
    var user_ids = $("#schedule_sch_members").val() || [];
    if(user_ids.length > 0) {
      $.get(app_name_for_url + "/schedule/schedules/on_click_schedule_member_remove.js?project_id=" + project_id + "&user_ids=" + user_ids.join(':'));
    }
  });
})
