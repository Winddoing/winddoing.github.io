#!/bin/bash
##########################################################
# File Name		: web-server.sh
# Author		: winddoing
# Created Time	: Sat May 30 13:11:59 2020
# Description	:
##########################################################

set -x

PWD=`pwd`
PATH=$PATH:$PWD/node_modules/hexo/bin

hexo clean

hexo generate

hexo server --debug
