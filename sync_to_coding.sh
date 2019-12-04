#!/bin/bash
##########################################################
# File Name		: sync_to_coding.sh
# Author		: winddoing
# Created Time	: 2019年11月13日 星期三 17时21分54秒
# Description	:
##########################################################

set -ev

USER_NAME="winddoing"
CODING_REF="git.coding.net/Winddoing/winddoing.git"
CUR_TIME=`date`

ls -lsh .

cd ./public

ls -lsh .

git init 

git add -A

git commit -m "backup: $CUR_TIME"

git branch

git push --force --quiet "https://${USER_NAME}:${Travis_co_token}@${CODING_REF}" master:master

git push --quiet "https://${USER_NAME}:${Travis_co_token}@${CODING_REF}" master:master --tags
