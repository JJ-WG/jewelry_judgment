# encoding: utf-8

#
#= Notice::Noticesコントローラクラス
#
# Authors:: 青山 ひろ子
# Created:: 2012/10/4
#
class Notice::NoticesController < Notice::NoticeController
  ##
  # お知らせ機能 一覧画面
  # GET /notices
  #
  def index
    # お知らせ表示期限を取得
    notice_indication_term = SystemSetting.notice_indication_days.days.ago
    
    # ログインユーザーへの通知を取得
    @notices = 
      Notice.where(:user_id => current_user.id)
            .where('updated_at >= ?', notice_indication_term)
            .order('id DESC')
            .paginate(:page => params[:page],
                      :per_page => MESSAGE_ITEMS_PER_PAGE)
    
    # お知らせを取得
    @messages = Message.where('updated_at >= ?', notice_indication_term)
                       .order('id DESC')
    
    # ログインユーザーの当日のスケジュールを取得
    @schedules =
      Schedule.where(:schedule_date => db_date(Date.today.to_s))
              .where(
                'EXISTS(SELECT * FROM sch_members' +
                ' WHERE sch_members.schedule_id = schedules.id' +
                ' AND sch_members.user_id = ?)', current_user.id)
              .order(:start_at)
  end
  
  ##
  # お知らせ機能 お知らせ詳細画面
  # GET /notices/show_message/1
  #
  def show_message
    begin
      @message = Message.find(params[:id])
    rescue
      add_error_message(t('errors.messages.no_data'))
      redirect_to notice_notices_url
    end
  end
end
