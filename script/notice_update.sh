#!/bin/sh
#
# プロジェクト関連通知メッセージ更新処理スクリプト
#


### 便利関数定義 ###
# ログ出力用関数
logger()
{
    now=`date '+%Y/%m/%d %H:%M'`
    echo "${now}: $1"
}

export PATH=/usr/local/bin:/usr/bin:$PATH

cd /opt/jj/current/
logger "プロジェクト関連通知メッセージ更新処理を開始します"

bundle exec rails runner -e production "Notice.update"

logger "プロジェクト関連通知メッセージ更新処理が完了しました"
