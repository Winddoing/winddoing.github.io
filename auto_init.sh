##########################################################
# File Name		: a.sh
# Created Time	: 2018年10月13日 星期六 15时12分11秒
# Description	:
##########################################################
#!/bin/bash
PWD=`pwd`

echo "Current path: $PWD"

sz=`du -sh`
echo "Data size: $sz"

sed -i "s/xxx/$sz/g" `grep -l xxx source/about/index.md`
