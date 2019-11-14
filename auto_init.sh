##########################################################
# File Name		: a.sh
# Created Time	: 2018年10月13日 星期六 15时12分11秒
# Description	:
##########################################################
#!/bin/bash
PWD=`pwd`

echo "Current path: $PWD"
echo "Current dirs:"

ls -lha

node_modules_sz=`du -sh ./node_modules | awk '{print int($1)}'`
git_sz=`du -sh .git | awk '{print int($1)}'`
all_sz=`du -sh  $SRC_DIR | awk '{print int($1)}'`
sz=$(($all_sz-$node_modules_sz-$git_sz))

echo "all size: $all_sz, node_modules size: $node_modules_sz, .git size: $git_sz"
echo "Data size: $sz"
sed -i "s/xxx/$sz/g" `grep -l xxx source/about/index.md`



xdate=`date +%Y.%m.%d-%H:%M:%S`
echo "Current time: $xdate"
sed -i "s/xdate/$xdate/g" `grep -l xdate source/about/index.md`

echo "exit. path: $PWD"

cat package.json
