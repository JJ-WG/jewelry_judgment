# encoding: utf-8

#
#= Applicationヘルパークラス
#
# Created:: 2012/10/5
#
module ApplicationHelper
  ##
  # 現地日時の取得
  # 
  # time::
  #   日付データ
  # 戻り値::
  #   現地日時に変更した日付。
  #   現地日時に変更できない場合は、そのままの値を返す。
  #
  def localtime(time)
    if time.present? && time.is_a?(Time)
      return l time
    else
      return time
    end
  end
  
  ##
  # メイン機能（システム管理機能以外）用のヘッダーを読み込む
  # 
  def render_main_header
    content_for(:header) do
      render :partial => 'common/main_header'
    end
  end
  
  ##
  # アプリケーションビューの幅を最大限に広げる
  # 
  def render_max_width
    content_for(:header) do
      render :partial => 'common/max_width'
    end
  end
  
  ##
  # テーブルのセルの余白を狭くする
  # 
  def render_narrow_padding
    content_for(:header) do
      render :partial => 'common/narrow_padding'
    end
  end
  
  ##
  # 名前を取得する
  # 
  # model::
  #   モデルデータ
  # 戻り値::
  #   各モデルのnameデータ。
  #   nameデータが取得できない場合、空白タグを返す。
  #
  def get_name(model)
    if model.present? && model.respond_to?(:name) && model.name.present?
      return model.name
    else
      return raw('&nbsp;')
    end
  end
  
  ##
  # 必須項目表示
  # 
  # 戻り値::
  #   必須項目表示タグ
  #
  def essential
    text = '<span class="required">（必須）</span>'
    return raw(text) 
  end
  
  ##
  # 数値リストを取得する
  # 
  # start_number::
  #   先頭値
  # end_number::
  #   末尾値
  # 戻り値::
  #   引数start_number～end_numberの連番の数値リスト
  #
  def numeric_list(start_number, end_number)
    # 数値の大小が逆の場合、入れ替え
    if (start_number > end_number)
      buf = start_number
      start_number = end_number
      end_number = buf
    end
    
    list = []
    for i in start_number..end_number do
      list << [i, i]
    end
    return list
  end
  
  ##
  # 改行を <br /> に変換する
  # 
  # text::
  #   対象文字列
  # 戻り値::
  #   改行置換した文字列
  #
  def nl2br(text)
    return text.gsub(/\r\n|\r|\n/, '<br />')
  end
  
  ##
  # 複数行のテキストを表示する
  # 
  # text::
  #   対象文字列
  # 戻り値::
  #   改行処理した文字列
  #
  def multi_line(text)
    return raw(nl2br(h(text)))
  end
  
  ##
  # 削除フラグ選択用HTMLタグを取得
  # 
  # deleted::
  #   削除フラグ
  # 戻り値::
  #   削除フラグ選択用のSELECTタグ
  #
  def include_deleted_flag_selector(deleted = '0')
    return '<select id="deleted" name="search[deleted]">' +
           '<option value="0"' + ((deleted == '0')? ' selected' : '') +
           '>未削除</option>' +
           '<option value="1"' + ((deleted == '1')? ' selected' : '') +
           '>削除済み</option>' +
           '</select>'
  end
  
  ##
  # 都道府県リストを取得する
  # 
  # 戻り値::
  #   都道府県リスト
  #
  def prefectures_list
    list = []
    PREF_CODE.each_pair {|key, value|
      list << [value, key.to_i]
    }
    return list
  end
  
  ##
  # 条件に応じてstrongタグまたはemタグで囲む
  # 
  # strong_condition:
  #   strongタグで囲む条件
  # em_condition:
  #   emタグで囲む条件
  # content:
  #   タグで囲む文字列
  # options:
  #   HTMLオプション（省略可）
  # 戻り値:
  #   strong_conditionがtrueの場合、contentをstrongタグで囲んだ文字列を返す。
  #   それ以外でem_conditionがtrueの場合、contentをemタグで囲んだ文字列を返す。
  #   それ以外の場合、contentを返す。
  #
  def conditional_tag(strong_condition, em_condition, content, options = nil)
    if strong_condition
      return content_tag(:strong, content, options)
    elsif em_condition
      return content_tag(:em, content, options)
    else
      return content
    end
  end
  
  ##
  # 千円単位の金額を取得
  # 
  # price:
  #   対象金額
  # 戻り値:
  #   千円単位の金額を返す。
  #
  def unit_thousand_yen(price)
    value = (price / 1000).round(2)
    return value
  end
  
  ##
  # すべてのプロジェクトを取得する（社内業務プロジェクト含む）
  # 
  # options:: 
  #   include_internal: 社内業務も含むかどうか(ディフォルト：含む)
  #     (true/false)
  #
  # 戻り値::
  #   プロジェクトリスト
  #
  def all_project_list(options = {include_internal: true})
    list = Project.projects_list({include_finished_project: true})
    if options && options[:include_internal]
      list.insert(0, [Project::INTERNAL_BUSSINESS_PRJ[:name], Project::INTERNAL_BUSSINESS_PRJ[:id]])
    end
    return list
  end
end
