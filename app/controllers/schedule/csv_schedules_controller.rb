# encoding: utf-8

#
#= Schedule::CSV_Schedulesコントローラクラス
#
# Created:: 2012/12/25
#
class Schedule::CsvSchedulesController < Schedule::ScheduleController

  ##
  # スケジュール情報 CSV登録
  # GET /schedule/csv_schedules/index
  #
  def index
    @csv_schedules = []
    @csv_schedules = CsvSchedule.list if params[:show_flag] && params[:show_flag] == '1'
 
  end

  ##
  # スケジュール情報 実データ登録
  # PUT /schedule/csv_schedules/actual_date_create
  #
  def actual_data_create
    show_list_flag = '1'
    if request.put?
      begin
        ActiveRecord::Base.transaction do
          CsvSchedule.all.each do |csv_sch|
            attrs = csv_sch.attributes.delete_if {|key, value| ['id', 'updated_at', 'created_at'].include?(key)}
            schedule = Schedule.new(attrs)
            sch_members = []
            csv_sch.csv_sch_members.each { |csv_member| sch_members << SchMember.new({user_id: csv_member.user_id}) }
            schedule.sch_members = sch_members
            schedule.save!
          end
          show_list_flag = '0'
          flash[:notice] = I18n.t('common_label.actual_data_was_created', :model => Schedule.model_name.human)
        end
      rescue => e
        flash[:warning] = I18n.t('errors.messages.actual_data_create_error', :model => Schedule.model_name.human)
        logger.error(e.message)
      end
    end
    redirect_to schedule_csv_schedules_path(show_flag: show_list_flag)
  end

  ##
  # スケジュール情報 仮データ登録
  # POST /schedule/csv_schedules/csv_date_create
  #
  def csv_data_create
    show_list_flag = '0'
    @csv_schedules = []
    begin
      if request.post? && params[:file].present?
        # 拡張子チェック
        unless params[:file].original_filename =~ /\.[c|C][s|S][v|V]$/
          flash.now[:warning] = I18n.t('errors.messages.csv_suffix_error')
          render 'index'
          return
        end

        infile = params[:file].read
        # 文字コードの転換
        infile = infile.force_encoding(Encoding::SJIS).encode('UTF-8')

        n, all_rows_include_errors, csv_schedules = 0, [], []
        has_error_row_flag = false
        CSV.parse(infile) do |row|
          n += 1
          if n == 1
            # ヘッダのチェック
            if row.join.blank? || row.length != Schedule::CSV_HEADERS.length ||
                row.join(':').force_encoding('UTF-8') != Schedule::CSV_HEADERS.join(':').force_encoding('UTF-8')
              flash.now[:warning] = I18n.t('errors.messages.csv_header_error')
              render 'index'
              return
            end
          end
          # ヘッダー行または空白行の場合
          next if n == 1 || row.join.blank?
          # CSVデータ有効性チェック
          errs, sch = validate_csv_data(row)
          has_error_row_flag = true unless errs.blank?
          all_rows_include_errors << (row + errs)
          csv_schedules << sch
        end
        if has_error_row_flag
          file_name = params[:file].original_filename.split('.')[0] + "_error_#{Time.now.strftime('%Y%m%d%H%M%S')}.csv"
          # エラーのCSVファイルにヘッダ追加
          all_rows_include_errors.insert(0, Schedule::CSV_HEADERS)

          # エラーCSVファイルの作成
          errCsv = CSV.generate("", {:row_sep => "\r\n", :encoding => 'utf-8'}) do |csv|
            all_rows_include_errors.each do |row|
              # 文字コードの転換
              row.each { |item| item = item.blank? ? '' : item.force_encoding('utf-8') }
              csv << row 
            end
          end
          send_data( errCsv.encode(Encoding::SJIS),
            disposition: 'attachment',
            type: "text/csv;charset=shift_jis;header=present",
            filename: ERB::Util.url_encode(file_name)
          )
        else
          ActiveRecord::Base.transaction do
            # 既存データの削除
            CsvSchedule.all.each do |sch|
              sch.csv_sch_members.each do |member|
                member.update_attributes!({deleted: 1})
              end
              sch.update_attributes!({deleted: 1})
            end
            csv_schedules.each { |sch| sch.save! }
          end
          show_list_flag = '1'
          redirect_to schedule_csv_schedules_path(show_flag: show_list_flag), notice: I18n.t('common_label.csv_model_was_created', :model => Schedule.model_name.human)
        end
      else
        flash.now[:warning] = I18n.t('errors.messages.csv_file_blank_error') if request.post?
        render 'index'
      end
    rescue => e
      # エラー発生、例えば、ファイルの内容が不正, DB登録エラー等
      flash[:warning] = I18n.t('errors.messages.csv_model_create_error', :model => Schedule.model_name.human)
      logger.error(e.message)
      render 'index'
    end
  end

private
  ##
  # スケジュール情報 CSVデータのチェック
  #
  # 戻り値：
  #   errs: チェックエラー配列
  #   スケジュールオブジェクト: チェックエラーがない場合、対応するオブジェクト
  #                             エラーがある場合、nil
  # 
  def validate_csv_data(row)
    errs, sch = [], nil
    # lengthのチェック
    return errs << I18n.t('label.csv_schedule_reflection.check_error.size_error'), sch unless !row.blank? && row.length == Schedule::CSV_HEADERS.length
    # 入力必須チェック
    row.each_index do |index|
      if [0, 4, 5, 6, 7, 9].include?(index) && row[index].blank?
        return errs << Schedule::CSV_HEADERS[index] + I18n.t('errors.messages.blank'), sch
      end
    end
    # プロジェクト存在チェック
    if row[0] != Project::INTERNAL_BUSSINESS_PRJ[:project_code]
      project_ids = []
      get_current_user_can_acccess_projects.each { |project| project_ids << project[1] }
      project = Project.where('project_code = (?) and id in (?)', row[0], project_ids).first
      return errs << I18n.t('label.csv_schedule_reflection.check_error.project_not_exist'), sch if project_ids.blank? || project.blank?
    else
      project = Project.new(Project::INTERNAL_BUSSINESS_PRJ)
      project.id = Project::INTERNAL_BUSSINESS_PRJ[:id]
    end
    # 工程存在チェック
    work_type = nil
    if !row[2].blank?
      if project.id == Project::INTERNAL_BUSSINESS_PRJ[:id]
        # 社内業務の場合
        work_type = WorkType.office_jobs.find_by_work_type_code(row[2])
        return errs << I18n.t('label.csv_schedule_reflection.check_error.work_type_not_exist'), sch if work_type.blank?
      else
        prj_work_type_ids = project.prj_work_types.collect {|item| item.work_type_id}
        if prj_work_type_ids.length == 0 || WorkType.where(work_type_code: row[2]).where('id in (?)', prj_work_type_ids).length == 0
          return errs << I18n.t('label.csv_schedule_reflection.check_error.work_type_not_exist'), sch
        end
        work_type = WorkType.find_by_work_type_code(row[2])
      end
    end
    # 日付のチェック
    begin
      schedule_date = Date.parse(row[4])
    rescue
      return errs << I18n.t('label.csv_schedule_reflection.check_error.date_format_error', item: Schedule::CSV_HEADERS[4]), sch
    end
    # 開始時間のチェック
    begin
      start_at = DateTime.parse(row[5])
      start_at = Time.zone.local(schedule_date.year, schedule_date.month, schedule_date.day, start_at.hour, start_at.minute, 0)
    rescue
      return errs << I18n.t('label.csv_schedule_reflection.check_error.time_format_error', item: Schedule::CSV_HEADERS[5]), sch
    end
    # 終了時間のチェック
    begin
      end_at = DateTime.parse(row[6])
      end_at = Time.zone.local(schedule_date.year, schedule_date.month, schedule_date.day, end_at.hour, end_at.minute, 0)
    rescue
      return errs << I18n.t('label.csv_schedule_reflection.check_error.time_format_error', item: Schedule::CSV_HEADERS[6]), sch
    end
    # 終了時間が開始時間より後であるチェック
    return errs << I18n.t('label.csv_schedule_reflection.check_error.time_greater_than_error', item_end: Schedule::CSV_HEADERS[6], item_start: Schedule::CSV_HEADERS[5]), sch if start_at > end_at
    # 自動反映処理フラグのチェック
    return errs << I18n.t('label.csv_schedule_reflection.check_error.auto_reflect_error'), sch unless Schedule::AUTO_REFLECTS.values.map {|item| item.to_s}.include?(row[7])
    user_codes = row[9].split(':')
    prj_member_ids = []
    csv_sch_members = []
    if row[0] != Project::INTERNAL_BUSSINESS_PRJ[:project_code]
      project.prj_members.each { |member| prj_member_ids << member.user_id }
    else
      # 社内業務プロジェクトの場合
      User.alive.each { |user| prj_member_ids << user.id }
    end
    user_codes.each do |code|
      # 各々の参加者のコードが実在しているかチェック
      user = User.find_by_user_code(code)
      return errs << I18n.t('label.csv_schedule_reflection.check_error.user_code_not_exist', code: code), sch if user.blank?
      # 各々の参加者コードから、参加者の既存の予定と、日付、開始・終了時間を検索し、予定が重複していないかどうかチェック
      return errs << I18n.t('label.csv_schedule_reflection.check_error.user_code_schedule_exist', code: code), sch unless Schedule.by_user_id(user.id).where({start_at: start_at, end_at: end_at}).blank?
      # 各々の参加者コードは、その行のプロジェクトの参加者に含まれているかどうかチェック
      return errs << I18n.t('label.csv_schedule_reflection.check_error.user_code_not_member_of_project', code: code), sch unless prj_member_ids.include?(user.id)
      csv_sch_members << CsvSchMember.new({user_id: user.id})
    end
    sch = CsvSchedule.new({ project_id: project.id,
                            work_type_id: work_type.blank? ? nil : work_type.id,
                            schedule_date: schedule_date,
                            start_at: start_at,
                            end_at: end_at,
                            auto_reflect: row[7],
                            notes: row[8]})
    sch.csv_sch_members = csv_sch_members
    return errs, sch
  end
end
