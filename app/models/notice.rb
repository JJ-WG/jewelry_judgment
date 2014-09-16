# encoding: utf-8

#
#= Noticeモデルクラス
#
# Authors:: 青山 ひろ子
# Created:: 2012/10/5
#
class Notice < ActiveRecord::Base
  # アクセサ定義
  attr_accessible :message, :message_cd, :project_id, :user_id
 
  # アソシエーション
  belongs_to :user
  belongs_to :project

  # 以下、パブリックメソッド
public

  ##
  # プロジェクト関連通知メッセージ更新処理
  #
  def self.update
    logger.info('プロジェクト関連通知メッセージ更新処理を開始しました。')
    begin
      # ① プロジェクトリストの取得
      projects = Project.uncompleted.alive
      
      # ② 実績値チェック、通知メッセージ生成
      projects.each do |project|
        # プロジェクトの全ての予算値と実績値を集計
        project.totalize_all
        
        #　1) 工数チェック
        self.excess_check(project, project.result_man_days, project.planned_man_days,
          MESSAGE_CODE[:man_days_over], MESSAGE_CODE[:cancel_man_days_over])
  
        #　2) 期間チェック
        self.excess_check(project, Date.today, project.finish_date,
          MESSAGE_CODE[:behind_schedule], MESSAGE_CODE[:cancel_behind_schedule])
        
        #　3) 経費チェック
        self.excess_check(project, project.direct_expense_result, project.direct_expense_budget,
          MESSAGE_CODE[:cost_over], MESSAGE_CODE[:cancel_cost_over])
       
        #　4) 粗利チェック
        self.excess_check(project, project.gross_profit_result, project.gross_profit_budget,
          MESSAGE_CODE[:profit_shortage], MESSAGE_CODE[:cancel_profit_shortage])
          
        # 5) 赤字チェック
        self.excess_check(project, project.gross_profit_result, 0,
          MESSAGE_CODE[:deficit], MESSAGE_CODE[:surplus])
      end
      
      # ③ メッセージ自動削除
      # 1) 通知メッセージ表示期間の取得
      system_setting = SystemSetting.find(1)
      notice_indication_days = 
        system_setting.present? ? system_setting.notice_indication_days : 30
      
      # 2) 通知メッセージ自動削除
      # 通知メッセージのプロジェクトの状態が[完了]で、
      # プロジェクト終了日から[通知メッセージ表示期間]以上の日数が経過している通知メッセージを削除
      self.includes(:project)
          .where('projects.status_cd = ? and projects.finished_date <= ?',
                 STATUS_CODE[:finished],
                 notice_indication_days.days.ago(Date.today))
          .destroy_all
      # 通知メッセージのプロジェクトが論理削除されていて、
      # プロジェクトの最終更新日から[通知メッセージ表示期間]以上の日数が経過している通知メッセージを削除
      self.includes(:project)
          .where('projects.deleted = ? and projects.updated_at <= ?',
                 false,
                 notice_indication_days.days.ago)
          .destroy_all
    rescue
      logger.error($!)
    ensure
      logger.info('プロジェクト関連通知メッセージ更新処理を終了しました。')
    end
  end
  
  ##
  #　self.updateへのエイリアス
  #
  def self.Update
    self.update
  end

  ##
  #　メッセージ種類コードに対応する通知メッセージを登録する
  #
  # project_id::
  #   対象プロジェクト
  # message_cd::
  #   通知メッセージのメッセージ種類コード
  # member_id::
  #   対象メンバーのユーザID(メンバー追加、削除の場合のみ)
  # 戻り値::
  #   全ての通知メッセージの登録に成功した場合、trueを返す。
  #
  def self.create(project, message_cd, member_id=0)
    succeeded = true
    scope1 = 'notice_message'
    scope2 = 'notice_message_with_name'
    user_ids = [project.manager_id] | [project.leader_id] |
               project.prj_members.collect{|member| member.user_id}
    user_ids.each do |user_id|
      notice = self.new
      notice.user_id = user_id
      notice.project_id = project.id
      notice.message_cd = message_cd
      case message_cd
      when MESSAGE_CODE[:start_project]
        # プロジェクト開始
        notice.message = I18n.t(:start_project, :scope => scope1)
      when MESSAGE_CODE[:finish_project]
        # プロジェクト終了
        notice.message = I18n.t(:finish_project, :scope => scope1)
      when MESSAGE_CODE[:restart_project]
        # プロジェクト再開
        notice.message = I18n.t(:restart_project, :scope => scope1)
      when MESSAGE_CODE[:delete_project]
        # プロジェクト削除
        notice.message = I18n.t(:delete_project, :scope => scope1)
      when MESSAGE_CODE[:restore_project]
        # プロジェクト復活
        notice.message = I18n.t(:restore_project, :scope => scope1)
      when MESSAGE_CODE[:leader_assign]
        # リーダーアサイン
        if user_id == project.leader_id
          notice.message = I18n.t(:leader_assign, :scope => scope1)
        else
          notice.message = I18n.t(:leader_assign, :scope => scope2,
                                  :name => project.leader_name)
        end
      when MESSAGE_CODE[:relieve_leader]
        # リーダーアサイン解除
        if user_id == project.leader_id
          notice.message = I18n.t(:relieve_leader, :scope => scope1)
        else
          notice.message = I18n.t(:relieve_leader, :scope => scope2,
                                  :name => project.leader_name)
        end
      when MESSAGE_CODE[:manager_assign]
        # マネージャーアサイン
        if user_id == project.manager_id
          notice.message = I18n.t(:manager_assign, :scope => scope1)
        else
          notice.message = I18n.t(:manager_assign, :scope => scope2,
                                  :name => project.manager_name)
        end
      when MESSAGE_CODE[:relieve_manager]
        # マネージャーアサイン解除
        if user_id == project.manager_id
          notice.message = I18n.t(:relieve_manager, :scope => scope1)
        else
          notice.message = I18n.t(:relieve_manager, :scope => scope2,
                                  :name => project.manager_name)
        end
      when MESSAGE_CODE[:assign_member]
        # メンバーアサイン
        if user_id == member_id
          notice.message = I18n.t(:assign_member, :scope => scope1)
        else
          notice.message = I18n.t(:assign_member, :scope => scope2,
                                  :name => User.get_name(member_id))
        end
      when MESSAGE_CODE[:relieve_member]
        # メンバーアサイン解除
        if user_id == member_id
          notice.message = I18n.t(:relieve_member, :scope => scope1)
        else
          notice.message = I18n.t(:relieve_member, :scope => scope2,
                                  :name => User.get_name(member_id))
        end
      when MESSAGE_CODE[:man_days_over]
        # 工数超過
        notice.message = I18n.t(:man_days_over, :scope => scope1)
      when MESSAGE_CODE[:cancel_man_days_over]
        # 工数超過解消
        notice.message = I18n.t(:cancel_man_days_over, :scope => scope1)
      when MESSAGE_CODE[:behind_schedule]
        # 期間超過
        notice.message = I18n.t(:behind_schedule, :scope => scope1)
      when MESSAGE_CODE[:cancel_behind_schedule]
        # 期間超過解消
        notice.message = I18n.t(:cancel_behind_schedule, :scope => scope1)
      when MESSAGE_CODE[:cost_over]
        # 経費超過
        notice.message = I18n.t(:cost_over, :scope => scope1)
      when MESSAGE_CODE[:cancel_cost_over]
        # 経費超過解消
        notice.message = I18n.t(:cancel_cost_over, :scope => scope1)
      when MESSAGE_CODE[:profit_shortage]
        # 利益不足
        notice.message = I18n.t(:profit_shortage, :scope => scope1)
      when MESSAGE_CODE[:cancel_profit_shortage]
        # 利益不足解消
        notice.message = I18n.t(:cancel_profit_shortage, :scope => scope1)
      when MESSAGE_CODE[:deficit]
        # 赤字転落
        notice.message = I18n.t(:deficit, :scope => scope1)
      when MESSAGE_CODE[:surplus]
        # 黒字復帰
        notice.message = I18n.t(:surplus, :scope => scope1)
      end
      logger.info("#{notice.message}[#{project.name}]")
      if notice.message.present?
        begin
          notice.save! 
        rescue
          succeeded = false
          logger.error("通知メッセージを登録できませんでした。[#{message_cd}]")
          logger.debug($!)
        end
      else
        succeeded = false
        logger.error("不明なメッセージコードです。[#{message_cd}]")
      end
    end
    return succeeded
  end

  # 以下、プライベートメソッド
private

  ##
  #　与えられた実績値と計画値を比較し、その結果に応じて超過メッセージまたは解消メッセージを登録する。
  #
  # project::
  #   対象プロジェクトのARオブジェクト
  # result_value::
  #   実績値
  # planned_value::
  #   計画値
  # excess_message_cd::
  #   超過メッセージコード
  # cancel_message_cd::
  #   解消メッセージコード
  # 戻り値::
  #   通知メッセージ登録無し、または、全ての通知メッセージの登録に成功した場合、trueを返す。
  #   登録できなかった通知メッセージがある場合、falseを返す。
  #
  def self.excess_check(project, result_value, planned_value, excess_message_cd, cancel_message_cd)
    succeeded = true
    message_cd = self.last_notice(project.id, [excess_message_cd, cancel_message_cd])
    if message_cd.nil? || message_cd == cancel_message_cd
      if result_value > planned_value
        # 超過メッセージ発行
        succeeded = self.create(project, excess_message_cd)
      end
    elsif message_cd == excess_message_cd
      if result_value <= planned_value
        # 解消メッセージ発行
        succeeded = self.create(project, cancel_message_cd)      
      end
    end
    return succeeded
  end 

  ##
  # 通知メッセージテーブルから、対象プロジェクトに対して発行された特定の種類のメッセージを抽出し、
  # その中で最新のものを検索する
  #
  # project_id::
  #   対象プロジェクトのプロジェクトID
  # message_cds::
  #   対象メッセージのメッセージコードの配列
  # 戻り値::
  #   検索された通知メッセージのメッセーコードを返す
  #   該当するメッセージが見つからなかった時はnilを返す
  #
  def self.last_notice(project_id, message_cds)
    notice = self.where(:project_id => project_id,
                        :message_cd => message_cds)
                 .select(:message_cd)
                 .last
    return nil if notice.blank?
    return notice.message_cd
  end
  
end
