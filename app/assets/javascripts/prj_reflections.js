//
// 振り返り情報管理機能JavaScript
//
jQuery(function(){
  //
  // 振り返り情報編集機能
  // プロジェクト終了日が変更された時の処理
  // （on_change_finished_date.jsを呼び出し、遅れ日数、評価を再計算し、表示更新する）
  //
  $('#prj_reflection_finished_date').change(function(){
    var finished_date = $("#prj_reflection_finished_date").val();
    var id = $("#prj_reflection_id").val();
    $.get(app_name_for_url + "/prj/prj_reflections/" + id + "/on_change_finished_date.js?" +
          "finished_date=" + finished_date);
  });
});