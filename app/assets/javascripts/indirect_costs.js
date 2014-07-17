//
// 間接労務費管理機能JavaScript
//
jQuery(function(){
  //
  // 間接労務費の計算方法の選択が変更された時の処理
  // （on_click_indirect_cost_method.jsを呼び出し、表示を変更する）
  //
  $('.indirect_cost_method_cd').click(function(){
    var indirect_cost_id = $("#indirect_cost_id").val();
    var indirect_cost_method_cd = $( this ).val();
    $.get(app_name_for_url + "/admin/indirect_costs/on_click_indirect_cost_method.js?" +
        "indirect_cost_id=" + indirect_cost_id +
        "&indirect_cost_method_cd=" + indirect_cost_method_cd);
  });
});
