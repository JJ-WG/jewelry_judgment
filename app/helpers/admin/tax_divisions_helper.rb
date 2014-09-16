# encoding: utf-8

#
#= Admin::TaxDivisionsヘルパークラス
#
# Authors:: 青山 ひろ子
# Created:: 2012/10/5
#
module Admin::TaxDivisionsHelper
  ##
  # 税種別リストを取得する
  # 
  # 戻り値::
  #   税種別リスト
  #
  def tax_types_list
    list = []
    TAX_TYPE_CODE.each_value { |cd|
      list << [tax_type_indication(cd), cd]
    }
    return list
  end
  
  ##
  # 税種別の表示文字列を取得する
  # 
  # tax_type_cd::
  #   税種別コード
  # 戻り値::
  #   税種別の表示文字列
  #
  def tax_type_indication(tax_type_cd)
    scope = 'tax_type'
    case tax_type_cd
      when TAX_TYPE_CODE[:tax_exempt]
        return t('tax_exempt', :scope => scope, :default=>'Tax exempt')
      when TAX_TYPE_CODE[:tax_exclusive]
        return t('tax_exclusive', :scope => scope, :default=>'Tax exclusive')
      when TAX_TYPE_CODE[:tax_inclusive]
        return t('tax_inclusive', :scope => scope, :default=>'Tax inclusive')
    end
  end
end
