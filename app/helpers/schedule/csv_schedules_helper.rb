# encoding: utf-8

#
#= CsvSchedule::CsvSchedulesヘルパークラス
#
# Authors:: 代　如剛
# Created:: 2012/12/26
#
module Schedule::CsvSchedulesHelper

  ##
  # 参加者を取得する
  # 
  # 戻り値::
  #   参加者リスト
  #
  def csv_schedule_member_list(csv_schedule)
    results = []
    csv_schedule.csv_sch_members.each { |member| results << User.find(member.user_id).name }
    results.join(', ') 
  end
end
