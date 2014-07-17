# encoding: utf-8

#
#= Admin::Commonヘルパークラス
#
# Created:: 2012/10/5
#
module Admin::CommonHelper
  ##
  # システム管理機能用のヘッダーを読み込む
  # 
  def render_header
    content_for(:header) do
      render :partial => 'admin/common/header'
    end
  end
  
  ##
  # 管理メニューを表示する
  # 
  def render_menu
    content_for(:sidebar) do
      render :partial => 'admin/common/menu'
    end
  end
end
