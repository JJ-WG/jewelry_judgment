# encoding: utf-8

#
#= Admin::SystemSettingsコントローラクラス
#
# Created:: 2012/10/4
#
class Admin::SystemSettingsController < Admin::AdminController
  ##
  # システム設定機能 設定画面
  # GET /admin/system_setting/edit
  #
  def edit
    @system_setting = SystemSetting.find(1)
  end
  
  ##
  # システム設定情報 更新処理
  # PUT /admin/system_setting/1
  #
  def update
    begin
      @system_setting = SystemSetting.find(1)
      @system_setting.update_attributes!(params[:system_setting])
      redirect_to edit_admin_system_setting_url,
          notice: t('common_label.model_was_updated', :model => SystemSetting.model_name.human)
    rescue => ex
      set_error(ex, :system_setting, :save)
      render action: 'edit'
      return
    end
  end
end
