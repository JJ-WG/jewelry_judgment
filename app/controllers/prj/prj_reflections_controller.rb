# encoding: utf-8

require 'prawn'
require 'prawn/measurement_extensions'

#
#= Prj::PrjReflectionsコントローラクラス
#
# Created:: 2012/10/4
#
class Prj::PrjReflectionsController < Prj::PrjController
  # コントローラのメソッドをviewでも使えるように設定
  helper_method :viewable?, :editable?

  ##
  # プロジェクト振り返り情報管理機能 閲覧画面
  # GET /prj/prj_reflections/1
  #
  def show
    begin
      @prj_reflection = PrjReflection.find(params[:id])
      @project = @prj_reflection.project
      railse if @project.nil?
    rescue
      add_error_message(t('errors.messages.no_data'))
      redirect_back_or_default(prj_projects_url)
      return
    end
    # 権限チェック
    unless viewable?(@project)
      add_error_message(t('errors.messages.not_permitted'))
      redirect_to :top
      return
    end
    # プロジェクトの集計値を取得する
    unless @project.restore_totalized_values(session[:totalized_values])
      @project.totalize_all
      session[:totalized_values] = @project.totalized_values
    end
  end
  
  ##
  # プロジェクト振り返り情報管理機能 編集画面
  # GET /prj/prj_reflections/1/edit
  #
  def edit
    begin
      @prj_reflection = PrjReflection.find(params[:id])
      @project = @prj_reflection.project
      railse if @project.nil?
    rescue
      add_error_message(t('errors.messages.no_data'))
      redirect_back_or_default(prj_projects_url)
      return
    end  
    # 権限、状態チェック
    unless editable?(@project)
      add_error_message(t('errors.messages.not_permitted'))
      redirect_to :top
      return
    end
    # プロジェクトの集計値を取得する
    unless @project.restore_totalized_values(session[:totalized_values])
      @project.totalize_all
      session[:totalized_values] = @project.totalized_values
    end
  end
  
  ##
  # プロジェクト振り返り情報 更新処理
  # PUT /prj/prj_reflections/1
  #
  def update
    begin
      @prj_reflection = PrjReflection.find(params[:id])
       @project = @prj_reflection.project
      railse if @project.nil?
    rescue
      add_error_message(t('errors.messages.no_data'))
      redirect_back_or_default(prj_projects_url)
      return
    end  
    # 権限、状態チェック
    unless editable?(@project)
      add_error_message(t('errors.messages.not_permitted'))
      redirect_to :top
      return
    end
    # データ登録・更新処理
    begin
      ActiveRecord::Base.transaction do
        logger.debug params[:prj_reflection].to_s
        @prj_reflection.update_attributes!(params[:prj_reflection])
        @prj_reflection.update_schedule_rank
        @prj_reflection.save!(:validate => false)
        unless @project.update_attribute(
          :finished_date, params[:prj_reflection][:finished_date])
          raise 'プロジェクトの終了日を更新できませんでした'
        end
      end
      redirect_to prj_prj_reflection_path(@prj_reflection),
        notice: t('common_label.model_was_updated',
                  :model => PrjReflection.model_name.human)
    rescue => ex
      set_error(ex, :prj_reflection, :save, @project.name)
      # プロジェクトの集計値を取得する
      unless @project.restore_totalized_values(session[:totalized_values])
        @project.totalize_all
        session[:totalized_values] = @project.totalized_values
      end
      # 編集画面を表示する
      render action: 'edit'
      return
    end
  end
  
  ##
  # 完了報告書印刷画面
  # GET /prj/prj_reflections/1/project_report.pdf
  #
  def report
    begin
      @prj_reflection = PrjReflection.find(params[:id])
      @project = @prj_reflection.project
      railse if @project.nil?
    rescue
      render :text=>t('errors.messages.no_data')
      return
    end
    # ユーザ権限チェック
    unless viewable?(@project)
      render :text=>t('errors.messages.not_permitted')
      return
    end
    # プロジェクトの集計値を取得する
    unless @project.restore_totalized_values(session[:totalized_values])
      @project.totalize_all
      session[:totalized_values] = @project.totalized_values
    end
    # 完了報告書印刷画面を表示する
    respond_to do |format|
      format.pdf {
        prawnto(:prawn => {
                :page_size => 'A4',
                :page_layout => :portrait,
                :margin => 20.mm,
                :info => {
                  :Title => t('label.project_reflection.report.title'),
                  :Subject => @project.name + '/' + @project.customer_name,
                  :Creator => t('common_label.app_title'),
                  :CreationDate => Time.now,
                } ,
                :inline => true
        })
        return
      }
    end
  end

  ##
  # プロジェクト終了日変更時の処理
  # GET /prj/prj_reflections/1/on_change_finished_date
  #
  def on_change_finished_date
    @prj_reflection = nil
    id = params[:id]
    finished_date = params[:finished_date]
    if id.present? && finished_date.present?
      begin
        @prj_reflection = PrjReflection.find(id)
        @prj_reflection.finished_date = Date.parse(finished_date)
        @prj_reflection.update_schedule_rank
      rescue
        logger.error($!)
      end
    end
    render 
  end

  # 以下、プライベートメソッド
private

  ##
  # ログインユーザが閲覧可能か
  #
  # project:
  #   対象プロジェクトのARインスタンス
  # 戻り値::
  #   ログインユーザがシステム管理者かマネージャー、または、
  #   対象プロジェクトのメンバー、プロジェクトリーダー、または
  #   プロジェクトマネージャーの場合、trueを返す。
  # 
  def viewable?(project)
    return true if (administrator? || manager?)
    return false if project.nil?
    return (project.project_member?(current_user) ||
            project.project_leader?(current_user) ||
            project.project_manager?(current_user))
  end 
  
  ##
  # ログインユーザが編集可能か
  #
  # project:
  #   対象プロジェクトのARインスタンス
  # 戻り値::
  #   対象プロジェクトの状態が完了、かつ、論理削除されてなく、
  #   ログインユーザがシステム管理者か、
  #   対象プロジェクトのプロジェクトリーダー、または
  #   プロジェクトマネージャーの場合、trueを返す。
  # 
  def editable?(project)
    return false if project.nil?
    return false if project.deleted? || project.uncompleted? 
    return (administrator? ||
            project.project_leader?(current_user) ||
            project.project_manager?(current_user))
  end 
  
end
