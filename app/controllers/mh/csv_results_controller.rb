# encoding: utf-8

#
#= Mh::CSV_Resultsコントローラクラス
#
# Authors:: 兪　春芳
# Created:: 2012/12/25
#
class Mh::CsvResultsController < Mh::MhController
  # コントローラのメソッドをviewでも使えるように設定
  helper_method :can_show_result_sum?
  ##
  # 工数実績情報 CSV登録
  # GET /mh/csv_results/index
  #
  def index
    @csv_results = []
    @csv_results = CsvResult.list if params[:show_flag] && params[:show_flag] == '1'
 
  end
  ##
  # ユーザーが指定工数実績集計が表示できるかどうか
  # 
  # result::
  #    指定工数実績集計（NULLを許さない）
  #
  # 戻り値::
  #   (true/false)
  #
  def can_show_result_sum?
    return true if administrator? || manager? || project_manager?
    return false
  end
  ##
  # 工数実績情報 実データ登録
  # PUT /mh/csv_results/actual_date_create
  #
  def actual_data_create
    show_list_flag = '1'
    if request.put?
      begin
        ActiveRecord::Base.transaction do
          CsvResult.all.each do |csv_rst|
            attrs = csv_rst.attributes.delete_if {|key, value| ['id', 'updated_at', 'created_at'].include?(key)}
            result = Result.new(attrs)
            result.save!
          end
          show_list_flag = '0'
          flash[:notice] = I18n.t('common_label.actual_data_was_created', :model => Result.model_name.human)
        end
      rescue => e
        flash[:warning] = I18n.t('errors.messages.actual_data_create_error', :model => Result.model_name.human)
        logger.error(e.message)
      end
    end
    redirect_to mh_csv_results_path(show_flag: show_list_flag)
  end

  ##
  # 工数実績情報 仮データ登録
  # POST /mh/csv_results/csv_date_create
  #
  def csv_data_create
    show_list_flag = '0'
    @csv_results = []
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
        n, all_rows_include_errors, csv_results = 0, [], []
        has_error_row_flag = false
        CSV.parse(infile) do |row|
          n += 1
          if n == 1
            # ヘッダのチェック
            if row.join.blank? || row.length != Result::CSV_HEADERS.length ||
                row.join(':').force_encoding('UTF-8') != Result::CSV_HEADERS.join(':').force_encoding('UTF-8')
              flash.now[:warning] = I18n.t('errors.messages.csv_header_error')
              render 'index'
              return
            end
          end
          # ヘッダー行または空白行の場合
          next if n == 1 || row.join.blank?
          # CSVデータ有効性チェック
          errs, rst = validate_csv_data(row)
          has_error_row_flag = true unless errs.blank?
          all_rows_include_errors << (row + errs)
          csv_results << rst
        end
        if has_error_row_flag
          file_name = params[:file].original_filename.split('.')[0] + "_error_#{Time.now.strftime('%Y%m%d%H%M%S')}.csv"
          # エラーのCSVファイルにヘッダ追加
          all_rows_include_errors.insert(0, Result::CSV_HEADERS)

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
            CsvResult.all.each do |rst|
              rst.update_attributes!(deleted: 1)
            end
            csv_results.each { |csv_result| csv_result.save! }
          end
          show_list_flag = '1'
          redirect_to mh_csv_results_path(show_flag: show_list_flag), notice: I18n.t('common_label.csv_model_was_created', :model => Result.model_name.human)
        end
      else
        flash.now[:warning] = I18n.t('errors.messages.csv_file_blank_error') if request.post?
        render 'index'
      end
    rescue => e
      # エラー発生、例えば、ファイルの内容が不正, DB登録エラー等
      flash[:warning] = I18n.t('errors.messages.csv_model_create_error', :model => Result.model_name.human)
      logger.error(e.message)
      render 'index'
    end
  end

  private
  ##
  # 工数実績情報 CSVデータのチェック
  #
  # 戻り値：
  #   errs: チェックエラー配列
  #   工数実績オブジェクト: チェックエラーがない場合、対応するオブジェクト
  #                             エラーがある場合、nil
  # 
  def validate_csv_data(row)
    errs, rst = [], nil
    # lengthのチェック
    return errs << I18n.t('label.csv_result_reflection.check_error.size_error'), rst unless !row.blank? && row.length == Result::CSV_HEADERS.length

    # 入力必須チェック
    row.each_index do |index|
      if [0, 2, 4, 5, 6, 7].include?(index) && row[index].blank?
        return errs << Result::CSV_HEADERS[index] + I18n.t('errors.messages.blank'), rst
      end
    end
    
    # プロジェクト存在チェック
    if row[0] != Project::INTERNAL_BUSSINESS_PRJ[:project_code]
      project_ids = []
      get_current_user_can_acccess_projects.each { |project| project_ids << project[1] }
      project = Project.where('project_code = (?) and id in (?)', row[0], project_ids).first
      return errs << I18n.t('label.csv_result_reflection.check_error.project_not_exist'), rst if project_ids.blank? || project.blank?
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
        return errs << I18n.t('label.csv_result_reflection.check_error.work_type_not_exist'), rst if work_type.blank?
      else
        prj_work_type_ids = project.prj_work_types.collect {|item| item.work_type_id}
        if prj_work_type_ids.length == 0 || WorkType.where(work_type_code: row[2]).where('id in (?)', prj_work_type_ids).length == 0
          return errs << I18n.t('label.csv_result_reflection.check_error.work_type_not_exist'), rst
        end
        work_type = WorkType.find_by_work_type_code(row[2])
      end
    end

    # 日付のチェック
    begin
      result_date = Date.parse(row[4])
    rescue
      return errs << I18n.t('label.csv_result_reflection.check_error.date_format_error', item: Result::CSV_HEADERS[4]), rst
    end

    # 開始時間のチェック
    begin
      start_at = DateTime.parse(row[5])
      start_at = Time.zone.local(result_date.year, result_date.month, result_date.day, start_at.hour, start_at.minute, 0)
    rescue
      return errs << I18n.t('label.csv_result_reflection.check_error.time_format_error', item: Result::CSV_HEADERS[5]), rst
    end

    # 終了時間のチェック
    begin
      end_at = DateTime.parse(row[6])
      end_at = Time.zone.local(result_date.year, result_date.month, result_date.day, end_at.hour, end_at.minute, 0)
    rescue
      return errs << I18n.t('label.csv_result_reflection.check_error.time_format_error', item: Result::CSV_HEADERS[6]), rst
    end
    # 終了時間が開始時間より後であるチェック
    return errs << I18n.t('label.csv_result_reflection.check_error.time_greater_than_error', item_end: Result::CSV_HEADERS[6], item_start: Result::CSV_HEADERS[5]), rst if start_at > end_at
    # 開始時間と終了時間の同値チェック
    return errs << I18n.t('label.csv_result_reflection.check_error.datetime_eql_error', item_end: Result::CSV_HEADERS[6], item_start: Result::CSV_HEADERS[5]), rst if start_at == end_at
    #ユーザーの存在チェック
    prj_member_ids = []
    if row[0] != Project::INTERNAL_BUSSINESS_PRJ[:project_code]
      project.prj_members.each { |member| prj_member_ids << member.user_id }
    else
      # 社内業務プロジェクトの場合
      User.alive.each { |user| prj_member_ids << user.id }
    end
    # ユーザーのコードが実在しているかチェックuser
    user = User.find_by_user_code(row[7]) 
    return errs << I18n.t('label.csv_result_reflection.check_error.user_code_not_exist', code: row[7]), rst if user.blank?
    # ユーザーコードから、ユーザーの既存の実績と、日付、開始・終了時間を検索し、実績が重複していないかどうかチェック
    return errs << I18n.t('label.csv_result_reflection.check_error.user_code_result_exist', code: row[7]), rst unless Result.where({user_id: user.id, result_date: result_date, start_at: start_at, end_at: end_at}).blank?
    # ユーザーコードは、その行のプロジェクトのユーザーに含まれているかどうかチェック
    return errs << I18n.t('label.csv_result_reflection.check_error.user_code_not_member_of_project', code: row[7]), rst unless prj_member_ids.include?(user.id)
    rst = CsvResult.new({   user_id: user.id,
        project_id: project.id,
        work_type_id: work_type.id,
        result_date: result_date,
        start_at: start_at,
        end_at: end_at,
        notes: row[9]})
    return errs, rst
  end
  
end
