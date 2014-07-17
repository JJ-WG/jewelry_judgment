# encoding: utf-8

#
#= Admin::WorkTypesヘルパークラス
#
# Created:: 2012/10/5
#
module Admin::WorkTypesHelper
  ##
  # 社内業務リストを取得する
  # 
  # 戻り値::
  #   社内業務リスト
  #
  def office_job_items_list
    list = []
    OFFICE_JOB_CODE.each_value { |cd|
      list << [office_job_item_indication(cd), cd]
    }
    return list
  end
  
  ##
  # 社内業務の表示文字列を取得する
  # 
  # 戻り値::
  #   社内業務リスト
  #
  def office_job_item_indication(office_job_cd)
    scope = 'office_job'
    case office_job_cd
      when OFFICE_JOB_CODE[:development]
        return t('development', :scope => scope, :default=>'Development')
      when OFFICE_JOB_CODE[:office_job]
        return t('office_job', :scope => scope, :default=>'Office job')
    end
  end
end
