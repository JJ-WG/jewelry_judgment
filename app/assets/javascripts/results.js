//
// プロジェクト管理機能JavaScript
//
jQuery(function(){

    //
    // プロジェクトの選択が変更された時の処理
    // （on_change_project_list.jsを呼び出し、メンバーリストを変更する）
    //
    $('#result_project_id').change(function(){
        var project_id = $("#result_project_id").val();
        $.get(app_name_for_url + "/mh/results/on_change_project_list.js?project_id=" + project_id);
    });

    $('.sample textarea').click(function(){
      $(this).select();
      return false;
    });

});
