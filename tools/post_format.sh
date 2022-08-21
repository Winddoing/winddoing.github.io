#!/bin/bash
##########################################################
# Copyright (C) 2022 wqshao All rights reserved.
#  File Name    : tools/post_format.sh
#  Author       : wqshao
#  Created Time : 2022-08-21 17:11:05
#  Description  :
##########################################################

set -eu

# 获取文件后缀名
file_suffix() 
{
    local filename="$1"

    if [ -n "$filename" ]; then
        echo "${filename##*.}"
    fi
}

# 判断文件后缀是否是指定后缀
is_suffix() 
{
    local filename="$1"
    local suffix="$2"
    if [ "$(file_suffix ${filename})" = "$suffix" ]; then
        return 0
    else
        return 1
    fi
}

# 删除文件中行尾多余空格
del_end_of_line_space()
{
	local file=$1

	is_suffix ${file} "md"
	ret=$?

	if [ $ret -eq 0 ]; then 
		sed -i 's/[\t ]\+$//' ${file}
	fi
}

#遍历当前目录(包括子目录)下所有文件
lookup_dir()
{
    for file in `ls $1`       #注意此处这是两个反引号，表示运行系统命令
    do
        if [ -d $1"/"$file ]  #注意此处之间一定要加上空格，否则会报错
        then
            lookup_dir $1"/"$file
        else
            echo $1"/"$file   #在此处处理文件即可
			del_end_of_line_space $1"/"$file
        fi
    done
}


# main
lookup_dir "./source/_posts"

