#!/bin/bash
##########################################################
# File Name		: ubuntu18.04_local.sh
# Author		: winddoing
# Created Time	: 2019年11月14日 星期四 11时37分42秒
# Description	:
##########################################################

set -x

#sudo npm i -g express --registry https://registry.npm.taobao.org

sudo apt install nodejs libssl-dev npm

#npm install --registry=https://registry.npm.taobao.org

npm install
