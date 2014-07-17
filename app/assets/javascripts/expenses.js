//
// 経費管理機能JavaScript
//
jQuery(function(){
  //
  // 経費種類の選択が変更された時の処理
  // （on_change_expense_type.jsを呼び出し、税区分リストの選択を変更する）
  //
  $('#expense_expense_type_id').change(function(){
    var expense_type_id = $("#expense_expense_type_id").val();
    $.get("on_change_expense_type.js?expense_type_id=" + expense_type_id);
  });
});
