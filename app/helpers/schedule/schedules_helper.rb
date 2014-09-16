# encoding: utf-8

#
#= Schedule::Schedulesヘルパークラス
#
# Authors:: 代　如剛
# Created:: 2012/12/11
#
module Schedule::SchedulesHelper

  ##
  # 予定時間を取得する
  # 
  # 戻り値::
  #   予定時間
  #
  def format_plan_date(start_at, end_at)
    return '' if start_at.blank? || end_at.blank?
    result = start_at.strftime('%H:%M') + ' ～ ' + end_at.strftime('%H:%M')
    tmp = (end_at-start_at)/1.hour
    hour = tmp.to_i
    minute = ((tmp-hour) * 60).to_i
    result +=  "（#{hour.to_s}:#{minute.to_s.rjust(2, '0')} h）"
  end

  ##
  # 自動反映をフォーマットする
  # 
  # 戻り値::
  #   trueの場合、◯
  #   falseの場合、☓
  #
  def format_auto_reflect(auto_reflect)
    auto_reflect == Schedule::AUTO_REFLECTS[:yes] ? t('label.circle') : t('label.cross')
  end

  ##
  # 自動反映をフォーマットする（詳細表示画面）
  # 
  # 戻り値::
  #   trueの場合、有
  #   falseの場合、無
  #
  def format_auto_reflect_show(auto_reflect)
    auto_reflect == Schedule::AUTO_REFLECTS[:yes] ? t('label.with') : t('label.without')
  end

  ##
  # スケジュール参加者を取得する
  # 
  # 戻り値::
  #   参加者リスト
  #
  def schedule_member_list(schedule)
    results = []
    schedule.sch_members.each { |member| results << User.find(member.user_id).name }
    results.join(', ') 
  end

  ##
  # カレンダーメニューの日付計算結果を取得する
  # 
  # 戻り値::
  #   カレンダーメニューの日付計算結果
  #
  def get_cs_nav_dates(current_date=nil)
    results = {
      pre_month: nil,   # 前月
      pre_week: nil,    # 前週
      pre_day: nil,     # 前日
      today: nil,       # 今日
      next_day: nil,    # 翌日
      next_week: nil,   # 翌週
      next_month: nil   # 翌月
    }
    unless current_date.blank?
      results[:pre_month] = current_date.prev_month
      results[:pre_week] = (current_date - 7).beginning_of_week(:sunday) + current_date.wday
      results[:pre_day] = current_date.yesterday
      results[:today] = Date.today
      results[:next_day] = current_date.tomorrow
      results[:next_week] = (current_date + 7).beginning_of_week(:sunday) + current_date.wday
      results[:next_month] = current_date.next_month
    end
    return results
  end

  ##
  # カレンダーの背景色クラスを取得する
  #
  # param_date::
  #   対象日付
  #
  # 戻り値::
  #   クラス名前
  #
  def get_backcolor_class_by_date(param_date=nil)
    result = ''
    unless param_date.blank?
      if param_date.today?
        result = 'cs_today'
      elsif param_date.wday == 0
        result = 'cs_sunday'
      elsif param_date.wday == 6
        result = 'cs_saturday'
      else
        result = 'cs_other_day'
      end
    end
    return result
  end

  ##
  # スケジュールレコード行の背景色クラスを取得する
  #
  # sch::
  #   対象スケジュール
  #
  # 戻り値::
  #   クラス名前
  #
  def get_schedule_backcolor_class(sch)
    return sch && sch.reflected? ? 'reflected' : ''
  end

  ##
  # カレンダーの開始日・終了日を取得する
  # 
  # 戻り値::
  #   カレンダーメニューの開始日・終了日
  #
  def get_cs_nav_range(current_date=Date.today)
    start_date = current_date
    end_date = ((start_date + 7).beginning_of_week(:sunday) + start_date.wday).yesterday
    return "#{start_date.strftime(t('time.formats.date_only'))} ～ #{end_date.strftime(t('time.formats.date_only'))}"
  end
end
