//
// ユーザ管理機能JavaScript
//
jQuery(function(){
  //
  // ユーザ登録・編集機能
  // 1日あたりの工数単価編集 「<追加」ボタンクリック時の処理
  // （on_click_unit_price_add.jsを呼び出し、工数単価リストを変更する）
  //
  $('#unit_price_add_button').click(function(){
    var user_id = $("#user_id").val();
    var unit_price_start_date = $("#user_unit_price_start_date").val();
    var unit_price_unit_price = $("#user_unit_price_unit_price").val();
    
    if (Date.parse(unit_price_start_date) <= (new Date()).getTime()){
      if (window.confirm('プロジェクトの損益が変更されてしまう恐れがあります。本当に追加しますか？')){
        addUnitPrice();
      }
    } else {
      addUnitPrice();
    }
    
    function addUnitPrice(){
      $.get(app_name_for_url + "/admin/users/on_click_unit_price_add.js?" +
          "user_id=" + user_id +
          "&unit_price_start_date=" + unit_price_start_date +
          "&unit_price_unit_price=" + unit_price_unit_price);
    }
  });
  
  //
  // ユーザ登録・編集機能
  // 1日あたりの工数単価編集 「削除」ボタンクリック時の処理
  // （on_click_unit_price_delete.jsを呼び出し、工数単価リストを変更する）
  //
  $('#unit_price_delete_button').click(function(){
    var user_id = $("#user_id").val();
    var unit_price_start_date = $("#user_unit_prices_attributes_0_start_date").val();
    
    if (window.confirm('適用開始日が最新の工数単価を削除します。よろしいですか？')){
      if (Date.parse(unit_price_start_date.replace("-", "/")) <= (new Date()).getTime()){
        if (window.confirm('プロジェクトの損益が変更されてしまう恐れがあります。本当に削除しますか？')){
          deleteUnitPrice();
        }
      } else {
        deleteUnitPrice();
      }
    }
        
    function deleteUnitPrice(){
      $.get(app_name_for_url + "/admin/users/on_click_unit_price_delete.js?user_id=" + user_id);
    }
  });
});
