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

	echo "del_end_of_line_space:"

	is_suffix ${file} "md"
	ret=$?

	if [ $ret -eq 0 ]; then 
		sed -i 's/[\t ]\+$//' ${file}
	fi
}

# 文件类型转为unix
file_dos_convert_unix()
{
	local file=$1

	echo "file_dos_convert_unix:"

	dos2unix $file
}

# 将文章分类改为目录结构形式
adjust_categories()
{
	echo "----------------adjust_categories--------------------"
	local file=$1

	echo "===>file: $file"

	local cgs=$(head -n 12 $file | grep "categories:" -A 3 | grep -v "categories" | grep -v "tags" | grep -v "abbrlink" | grep -v "\-\-\-" | awk '{print $2}')
	local dir=$(echo $cgs | sed 's# #/#g')

	echo "cgs:[$cgs]  ->  dir:[$dir]"
	[ ! $dir ] && dir="tmp"
	local post_path="./source/_posts/$dir"

	echo "post_path=$post_path"

	set -x
	mkdir -p $post_path
	mv $file $post_path
	set +x

	echo "-----------------------------------------------------"
}

# 删除文件名前面的日期
# 如：2015-05-21-development-board-start-up.md
del_filename_prefix_date()
{
	local file=$1

	echo "del_filename_prefix_date:"

	local ret=$(echo $file | grep "[0-9][0-9][0-9][0-9]-[0-9][0-9]")
	if [ x$ret != x"" ]; then
		local new_filename=$(echo $file | sed "s:[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]-::g")
		echo "$file --> $new_filename"
		mv $file $new_filename
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
            echo "----> $1/$file"   #在此处处理文件即可
			del_end_of_line_space $1"/"$file
			file_dos_convert_unix $1"/"$file
			#adjust_categories $1"/"$file
			del_filename_prefix_date $1"/"$file
        fi
    done
}


# main
lookup_dir "./source/_posts"

