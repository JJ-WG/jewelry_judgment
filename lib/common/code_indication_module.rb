# encoding: utf-8
#
#= 共通メソッド
#
# Created:: 2013/02/27
#
module CodeIndicationModule
  ##
  # 商談ステータスの表示文字列を取得する
  # 
  # deal_status_cd::
  #   商談ステータスコード
  # 戻り値::
  #   商談ステータスの表示文字列
  #
  def deal_status_indication(deal_status_cd)
    scope = 'deal_status'
    case deal_status_cd
      when DEAL_STATUS_CODE[:under_negotiation]
        return I18n.t('under_negotiation', :scope => scope, :default=>'Under Negotiation')
      when DEAL_STATUS_CODE[:demo_request]
        return I18n.t('demo_request', :scope => scope, :default=>'Demo Request')
      when DEAL_STATUS_CODE[:making_estimate]
        return I18n.t('making_estimate', :scope => scope, :default=>'Making Estimate')
      when DEAL_STATUS_CODE[:being_proposed]
        return I18n.t('being_proposed', :scope => scope, :default=>'Being Proposed')
      when DEAL_STATUS_CODE[:order_decision]
        return I18n.t('order_decision', :scope => scope, :default=>'Order Decision')
      when DEAL_STATUS_CODE[:pj_progress]
        return I18n.t('pj_progress', :scope => scope, :default=>'PJ Progress')
      when DEAL_STATUS_CODE[:accepted]
        return I18n.t('accepted', :scope => scope, :default=>'Accepted')
      when DEAL_STATUS_CODE[:declinature]
        return I18n.t('declinature', :scope => scope, :default=>'Declinature')
      when DEAL_STATUS_CODE[:failure_order]
        return I18n.t('failure_order', :scope => scope, :default=>'Failure Order')
    end
  end

  ##
  # 受注確度の表示文字列を取得する
  # 
  # reliability_cd::
  #   受注確度コード
  # 戻り値::
  #   受注確度の表示文字列
  #
  def reliability_indication(reliability_cd)
    scope = 'reliability'
    case reliability_cd
      when RELIABILITY_CODE[:appear_deal]
        return I18n.t('appear_deal', :scope => scope, :default=>'Appear Deal')
      when RELIABILITY_CODE[:start_deal]
        return I18n.t('start_deal', :scope => scope, :default=>'Start Deal')
      when RELIABILITY_CODE[:strong]
        return I18n.t('strong', :scope => scope, :default=>'Strong')
      when RELIABILITY_CODE[:notification]
        return I18n.t('notification', :scope => scope, :default=>'Notification')
      when RELIABILITY_CODE[:decision]
        return I18n.t('decision', :scope => scope, :default=>'Decision')
    end
  end
end
