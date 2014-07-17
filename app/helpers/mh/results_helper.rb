# encoding: utf-8

#
#= Mh::Resultsヘルパークラス
#
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
end
