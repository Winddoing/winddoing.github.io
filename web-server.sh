#!/bin/bash
##########################################################
# File Name		: web-server.sh
# Author		: winddoing
# Created Time	: Sat May 30 13:11:59 2020
# Description	:
##########################################################

PWD=`pwd`
export PATH=$PATH:$PWD/node_modules/.bin

set -x

hexo clean

# 图片压缩
#gulp images

hexo generate

#hexo server --debug
hexo server
