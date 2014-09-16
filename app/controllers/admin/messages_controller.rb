# encoding: utf-8

#
#= Admin::Messagesコントローラクラス
#
# Authors:: 青山 ひろ子
# Created:: 2012/10/4
#
class Admin::MessagesController < Admin::AdminController
  ##
  # お知らせ管理機能 一覧画面
  # GET /messages
  #
  def index
    @messages = Message
        .order("created_at DESC")
        .paginate(:page => params[:page], :per_page => ITEMS_PER_PAGE)
  end
  
  ##
  # お知らせ管理機能 閲覧画面
  # GET /messages/1
  #
  def show
    begin
      @message = Message.find(params[:id])
    rescue
      add_error_message(t('errors.messages.no_data'))
      redirect_to admin_messages_url
      return
    end
  end
  
  ##
  # お知らせ情報 新規作成処理
  # GET /messages/new
  #
  def new
    @message = Message.new
  end
  
  ##
  # お知らせ管理機能 編集画面
  # GET /messages/1/edit
  #
  def edit
    begin
      @message = Message.find(params[:id])
    rescue
      add_error_message(t('errors.messages.no_data'))
      redirect_to admin_messages_url
      return
    end
  end
  
  ##
  # お知らせ情報 新規作成処理
  # POST /messages
  #
  def create
    begin
      @message = Message.new(params[:message])
      @message.save!
      redirect_to admin_message_path(@message),
          notice: t('common_label.model_was_created', :model => Message.model_name.human)
    rescue => ex
      set_error(ex, :message, :save)
      render action: 'new'
      return
    end
  end
  
  ##
  # お知らせ情報 更新処理
  # PUT /messages/1
  #
  def update
    begin
      @message = Message.find(params[:id])
      @message.update_attributes!(params[:message])
      redirect_to admin_message_path(@message),
          notice: t('common_label.model_was_updated', :model => Message.model_name.human)
    rescue => ex
      set_error(ex, :message, :save)
      render action: 'edit'
      return
    end
  end
  
  ##
  # お知らせ情報 削除処理
  # DELETE /messages/1
  #
  def destroy
    begin
      @message = Message.find(params[:id])
      @message.destroy
    rescue => ex
      set_error(ex, :message, :delete)
    end
    redirect_to admin_messages_url
  end
end
