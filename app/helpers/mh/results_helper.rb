# encoding: utf-8

#
#= Mh::Resultsヘルパークラス
#
# Authors:: 兪　春芳
# Created:: 2012/12/11
#
module Mh::ResultsHelper

  ##
  # 実績時間を取得する
  # 
  # 戻り値::
  #   実績時間
  #
  def format_real_date(start_at, end_at)
    return '' if start_at.blank? || end_at.blank?
    result = start_at.strftime('%H:%M') + ' ～ ' + end_at.strftime('%H:%M')
    tmp = (end_at-start_at)/1.hour
    hour = tmp.to_i
    minute = ((tmp-hour) * 60).to_i
    result +=  "（#{hour.to_s}:#{minute.to_s.rjust(2, '0')} h）"
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
      if param_date.wday == 0
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
  # カレンダーの背景色クラスを取得する
  #
  # param_date::
  #   対象日付
  #
  # 戻り値::
  #   クラス名前
  #
  def get_backcolor_class_by_result_date(param_date=nil)
    result = ''
    unless param_date.blank?
      if param_date.wday == 0
        result = 'cresult_sunday'
      elsif param_date.wday == 6
        result = 'cresult_saturday'
      else
        result = 'cresult_other_day'
      end
    end
    return result
  end

  ##
  # 時間選択用リスト（時）を取得する
  # 
  # 戻り値::
  #   時間リスト（時）
  #
  def hour_select_list
    return (0..23).map{|i| [sprintf("%02d", i), sprintf("%02d", i)]}
  end

  ##
  # 時間選択用リスト（分）を取得する
  # 
  # minute_step:: 
  #   刻み時間（分）
  #
  # 戻り値::
  #   時間リスト（分）
  #
  def minute_select_list(minute_step = 1)
    minute_list = []
    (0..59).each do |minute|
      if minute == 0
        minute_list << minute
      elsif (minute % minute_step) == 0
        minute_list << minute
      end
    end
    return minute_list.map{|i| [sprintf("%02d", i), sprintf("%02d", i)]}
  end
end
