##########################################################
# File Name		: get_resource.sh
# Author		: winddoing
# Created Time	: 2018年11月12日 星期一 16时43分22秒
# Description	:
##########################################################
#!/bin/bash

PWD=`pwd`

DIR="$PWD/resource"
SRC_DIR="tools docs"
URL="https://e.coding.net/Winddoing/blog/"

if [ ! -d $DIR ]; then
	mkdir $DIR
fi

echo "pwd: $PWD, DIR: $DIR"

for dir in $SRC_DIR
do
	if [ ! -d $DIR/$dir ]; then
		echo "git clone $URL/$dir.git $DIR/$dir"
		git clone $URL/$dir.git $DIR/$dir
	fi

	(cd $DIR/$dir; git pull origin master)

	echo -e "[\033[31m$dir\033[0m] update completed"
done
