##########################################################
# File Name		: get_resource.sh
# Author		: winddoing
# Created Time	: 2018年11月12日 星期一 16时43分22秒
# Description	:
##########################################################
#!/bin/bash

PWD=`pwd`

DIR="$PWD/resource"
SRC_DIR="software_tools blog_docs Own-Treasure-Box photos"

if [ ! -d $DIR ]; then
	mkdir $DIR
fi

echo "pwd: $PWD, DIR: $DIR"

for dir in $SRC_DIR
do
	if [ ! -d $DIR/$dir ]; then
		echo "git clone https://git.coding.net/Winddoing/$dir.git $DIR/$dir"
		git clone https://git.coding.net/Winddoing/$dir.git $DIR/$dir
	fi

	(cd $DIR/$dir; git pull)

	echo "[$dir] update completed"
done
