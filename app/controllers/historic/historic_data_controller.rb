# encoding: utf-8

#
#= Historic::HistoricDataコントローラクラス
#
# Created:: 2013/01/07
#
class Historic::HistoricDataController < Historic::HistoricController

  # フィルター設定
  before_filter :require_system_admin_or_manager

  ##
  # 年間実績機能 一覧画面
  # GET /historic/historic_data
  #
  def index
    create_search_detail
  end

  ##
  # 年間実績機能 詳細表示画面
  # GET /historic/historic_data/detail
  #
  def detail
    create_search_detail_for_user
  end

private
  ##
  # 検索処理
  # 
  # 検索結果レコード構成::
  #   {
  #     user: user1,
  #     project_num: 5,
  #     project_total_amount: 1234567,
  #     project_surplus_persent: 50
  #   }
  #
  def create_search_detail
    tmp_year = (Date.today > Date.new(Date.today.year, 6, 30)) ? 0 : 1
    # 初期の日付の設定
    params[:search] ||= { start_at: {year: Date.today.year-1-tmp_year, month: 7 }, 
                          end_at: {year: Date.today.year-tmp_year, month: 6 } }
    @historic_data = []
    start_at = end_at = nil
    unless params[:search][:start_at].blank?
      start_at = Date.civil(params[:search][:start_at][:year].to_i, params[:search][:start_at][:month].to_i).beginning_of_month
    end
    unless params[:search][:end_at].blank?
      end_at = Date.civil(params[:search][:end_at][:year].to_i, params[:search][:end_at][:month].to_i).end_of_month
    end
    users = User.alive.order('user_code ASC')
    users.each do |user|
      projects = user.my_finished_project_list({start_at: start_at, end_at: end_at})
      total_amount = 0.0
      # 黒字プロジェクト数量
      black_project_number = 0
      # 黒字プロジェクト率
      surplus_persent = 0
      projects.each do |project|
        total_amount += project.order_volume
        black_project_number += 1 if project.prj_reflection.profit_ratio > 0
      end
      surplus_persent = black_project_number*100/projects.length if projects.length != 0
      @historic_data << { user: user,
         project_num: projects.length,
         project_total_amount: total_amount,
         project_surplus_persent: surplus_persent
       }
    end
    @historic_data = @historic_data.sort{|x, y| y[:project_total_amount] <=> x[:project_total_amount]}
    @historic_data = @historic_data.paginate(:page => params[:page], :per_page => HISTORIC_DATA_LIST_PER_PAGE)
  end

  ##
  # 詳細表示検索処理
  # 
  # 検索結果レコード構成::
  #   {
  #     user: user1,
  #     projects: [ project1, project2, ...]
  #   }
  #
  def create_search_detail_for_user
    return if params[:user_id].blank? || User.where(id: params[:user_id]).blank?
    @detail_info = { user: User.find(params[:user_id]),
                     projects: [] }
    start_at = end_at = nil
    unless params[:search][:start_at].blank?
      start_at = Date.civil(params[:search][:start_at][:year].to_i, params[:search][:start_at][:month].to_i).beginning_of_month
    end
    unless params[:search][:end_at].blank?
      end_at = Date.civil(params[:search][:end_at][:year].to_i, params[:search][:end_at][:month].to_i).end_of_month
    end
    @detail_info[:projects] = @detail_info[:user].my_finished_project_list({start_at: start_at, end_at: end_at})
    @detail_info[:projects] = @detail_info[:projects].paginate(:page => params[:page], :per_page => HISTORIC_DATA_DETAIL_PER_PAGE)
  end
  
end
