# encoding: utf-8

#
#= Admin::IndirectCostsヘルパークラス
#
# Created:: 2012/10/5
#
module Admin::IndirectCostsHelper
  ##
  # 間接労務費計算方法の表示文字列を取得する
  # 
  # indirect_cost_method_cd::
  #   間接労務費計算方式コード
  # 戻り値::
  #   間接労務費計算方法の表示文字列
  #
  def indirect_cost_method_indication(indirect_cost_method_cd)
    scope = 'indirect_cost_method'
    case indirect_cost_method_cd
      when INDIRECT_COST_METHOD_CODE[:method1]
        return t(:method1, :scope => scope, :default => 'method1')
      when INDIRECT_COST_METHOD_CODE[:method2]
        return t(:method2, :scope => scope, :default => 'method2')
      when INDIRECT_COST_METHOD_CODE[:method3]
        return t(:method3, :scope => scope, :default => 'method3')
    end
  end
  
  ##
  # 間接労務費計算方法選択用HTMLタグを取得
  # 
  # method_cd::
  #   間接労務費計算方式コード
  # 戻り値::
  #   間接労務費計算方法選択用のSELECTタグ
  #
  def indirect_cost_method_radio_button(method_cd = 0)
    tag = ''
    INDIRECT_COST_METHOD_CODE.each_pair { |key, value|
      tag += '<div class="radio_button">'
      tag += '<input id="indirect_cost_indirect_cost_method_cd_' + value.to_s +
          '" name="indirect_cost[indirect_cost_method_cd]" type="radio"' +
          ' class="indirect_cost_method_cd" value="' + value.to_s + '"' +
          ((method_cd == value)? ' checked':'') + '/>'
      tag += '</div>'
      tag += '<div class="indirect_cost_method">' + indirect_cost_method_indication(value) +'</div>'
      tag += '<div style="clear:both;"></div>'
    }
    return tag;
  end
end
