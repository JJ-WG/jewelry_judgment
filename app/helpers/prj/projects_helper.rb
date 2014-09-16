# encoding: utf-8

#
#= Prj::Projectsヘルパークラス
#
# Authors:: 青山 ひろ子
# Created:: 2012/10/5
#
module Prj::ProjectsHelper
  ##
  # プロジェクト状態リストを取得する
  # 
  # 戻り値::
  #   プロジェクト状態リスト
  #
  def statuses_list
    list = []
    STATUS_CODE.each_value { |cd|
      list << [status_indication(cd), cd]
    }
    return list
  end
  
  ##
  # プロジェクト状態の表示文字列を取得する
  # 
  # 戻り値::
  #   プロジェクト状態の表示文字列
  #
  def status_indication(status_cd)
    scope = 'status'
    case status_cd
      when STATUS_CODE[:preparation]
        return t('preparation', :scope => scope, :default=>'Preparation')
      when STATUS_CODE[:progress]
        return t('progress', :scope => scope, :default=>'Progress')
      when STATUS_CODE[:finished]
        return t('finished', :scope => scope, :default=>'Finished')
    end
  end
  
  ##
  # プロジェクトメンバー数を取得する
  # 
  # 戻り値::
  #   プロジェクトメンバー数
  #
  def get_prj_member_count(id)
    prj_members = PrjMember.find(:all, :conditions=>['project_id=?', id])
    return prj_members.size
  end
  
  ##
  # 状態リストを取得する
  # 
  # 戻り値::
  #   状態リスト
  #
  def statuses_list
    list = []
    STATUS_CODE.each_value { |cd|
      list << [status_indication(cd), cd]
    }
    return list
  end
  
  ##
  # 状態の表示文字列を取得する
  # 
  # 戻り値::
  #   状態の表示文字列
  #
  def status_indication(status_cd)
    scope = 'status'
    case status_cd
      when STATUS_CODE[:preparation]
        return t('preparation', :scope => scope, :default=>'Preparation')
      when STATUS_CODE[:progress]
        return t('progress', :scope => scope, :default=>'Progress')
      when STATUS_CODE[:finished]
        return t('finished', :scope => scope, :default=>'Finished')
    end
  end
  
  ##
  # 状態表示用HTMLタグを取得
  # 
  # status_cd::
  #   状態コード
  # 戻り値::
  #   状態表示用のSPANタグ
  #
  def include_status_span(status_cd, deleted)
    tag = '<span>'
    if deleted
      tag = '<span class="deleted">削除済み</span>'
    else
      case status_cd
        when STATUS_CODE[:preparation]
          tag = '<span class="preparation">'
        when STATUS_CODE[:progress]
        tag = '<span class="progress">'
        when STATUS_CODE[:finished]
          tag = '<span class="complete">'
      end
      tag += "#{status_indication(status_cd)}" + '</span>'
    end
    return tag
  end
  
  ##
  # 受注形態リストを取得する
  # 
  # 戻り値::
  #   受注形態リスト
  #
  def order_types_list
    list = []
    ORDER_TYPE_CODE.each_value { |cd|
      list << [order_type_indication(cd), cd]
    }
    return list
  end
  
  ##
  # 受注形態の表示文字列を取得する
  # 
  # order_type_cd::
  #   受注形態コード
  # 戻り値::
  #   受注形態の表示文字列
  #
  def order_type_indication(order_type_cd)
    scope = 'order_type'
    case order_type_cd
      when ORDER_TYPE_CODE[:contract]
        return t('contract', :scope => scope, :default=>'Contract')
      when ORDER_TYPE_CODE[:instrument]
        return t('instrument', :scope => scope, :default=>'Instrument')
      when ORDER_TYPE_CODE[:maintenance]
        return t('maintenance', :scope => scope, :default=>'Maintenance')
      when ORDER_TYPE_CODE[:investment]
        return t('investment', :scope => scope, :default=>'Investment')
    end
  end
  
  ##
  # 検索用状態リストを取得する
  # 
  # 戻り値::
  #   検索用状態リスト
  #
  def search_status_items_list
    list = []
    PROJECT_SEARCH_STATUS_CODE.each_value { |cd|
      list << [search_status_item_indication(cd), cd]
    }
    return list
  end
  
  ##
  # 検索用状態名の表示文字列を取得する
  # 
  # 戻り値::
  #   検索用状態名リスト
  #
  def search_status_item_indication(status_item_cd)
    scope = 'project_search_status'
    case status_item_cd
      when PROJECT_SEARCH_STATUS_CODE[:not_include_deleted]
        return t('not_include_deleted', :scope => scope,
                 :default=>'Not include deleted')
      when PROJECT_SEARCH_STATUS_CODE[:preparation_or_progress]
        return t('preparation_or_progress', :scope => scope,
                 :default=>'Preparation or progress')
      when PROJECT_SEARCH_STATUS_CODE[:preparation]
        return t('preparation', :scope => scope, :default=>'Preparation')
      when PROJECT_SEARCH_STATUS_CODE[:progress]
        return t('progress', :scope => scope, :default=>'Progress')
      when PROJECT_SEARCH_STATUS_CODE[:completed]
        return t('completed', :scope => scope, :default=>'Completed')
      when PROJECT_SEARCH_STATUS_CODE[:deleted]
        return t('deleted', :scope => scope, :default=>'Deleted')
    end
  end
  
  ##
  # 検索用オーダー種別リストを取得する
  # 
  # 戻り値::
  #   検索用オーダー種別リスト
  #
  def search_order_items_list
    list = []
    PROJECT_SEARCH_ORDER_CODE.each_value { |cd|
      list << [search_order_item_indication(cd), cd]
    }
    return list
  end
  
  ##
  # 検索用オーダー種別名の表示文字列を取得する
  # 
  # 戻り値::
  #   検索用オーダー種別名リスト
  #
  def search_order_item_indication(order_item_cd)
    scope = 'project_search_order'
    case order_item_cd
      when PROJECT_SEARCH_ORDER_CODE[:preorder]
        return t('preorder', :scope => scope, :default=>'Preorder')
      when PROJECT_SEARCH_ORDER_CODE[:normal]
        return t('normal', :scope => scope, :default=>'Normal')
      when PROJECT_SEARCH_ORDER_CODE[:nothing]
        return t('nothing', :scope => scope, :default=>'Nothing')
    end
  end
  
  ##
  # 検索用期間年リストを取得する
  # 
  # 戻り値::
  #   期間年リスト
  #
  def project_term_year_list
    today_year = Date.today.year
    project_minimum = Project.minimum('start_date')
    project_maximum = Project.maximum('finish_date')
    
    if project_minimum.blank? || project_maximum.blank?
      return numeric_list(today_year, today_year)
    end
    
    return numeric_list(project_minimum.year, project_maximum.year)
  end
  
  ##
  # 検索用納期年リストを取得する
  # 
  # 戻り値::
  #   納期年リスト
  #
  def finish_date_year_list
    today_year = Date.today.year
    project_minimum = Project.minimum('finish_date')
    project_maximum = Project.maximum('finish_date')
    
    if project_minimum.blank? || project_maximum.blank?
      return numeric_list(today_year, today_year)
    end
    
    return numeric_list(project_minimum.year, project_maximum.year)
  end
end
