#!/bin/bash
##########################################################
# File Name		: web-server.sh
# Author		: winddoing
# Created Time	: Sat May 30 13:11:59 2020
# Description	:
##########################################################

set -x

PWD=`pwd`
PATH=$PATH:$PWD/node_modules/.bin

hexo clean

hexo generate

#gulp

#hexo server --debug
hexo server
