#!/bin/sh
#
# スケジュール自動反映スクリプト
#


### 便利関数定義 ###
# ログ出力用関数
logger()
{
    now=`date '+%Y/%m/%d %H:%M'`
    echo "${now}: $1"
}

export PATH=/usr/local/bin:/usr/bin:$PATH

cd /opt/jj/

logger "スケジュール自動反映処理が開始します"

bundle exec rails runner -e production "Schedule.auto_reflect"

logger "スケジュール自動反映処理が完了しました"
