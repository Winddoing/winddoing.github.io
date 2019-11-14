#!/bin/bash
##########################################################
# File Name		: sync_to_coding.sh
# Author		: winddoing
# Created Time	: 2019年11月13日 星期三 17时21分54秒
# Description	:
##########################################################

set -ev

GITWEB_REF="https://github.com/Winddoing/Winddoing.github.io.git"
CODING_REF="git.coding.net/Winddoing/winddoing.git"

ls .

cd ./public

ls ./*

git init 

git add -A

git commit -m "bak"

git branch

git push --force --quiet "https://winddoing:${Travis_co_token}@${CODING_REF}" master:master
