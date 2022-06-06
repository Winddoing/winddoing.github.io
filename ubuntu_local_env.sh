#!/bin/bash
##########################################################
# File Name		: ubuntu18.04_local.sh
# Author		: winddoing
# Created Time	: 2019年11月14日 星期四 11时37分42秒
# Description	:
##########################################################

set -x

#sudo npm i -g express --registry https://registry.npm.taobao.org

node -v | grep v14 > /dev/null
if [ $? -ne 0 ]; then
	curl -sL https://deb.nodesource.com/setup_14.x | sudo bash -
fi

sudo apt install nodejs libssl-dev npm

#npm install --registry=https://registry.npm.taobao.org

npm install
