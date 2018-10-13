##########################################################
# File Name		: a.sh
# Created Time	: 2018年10月13日 星期六 15时12分11秒
# Description	:
##########################################################
#!/bin/bash


sz=`du -sh`

echo "size: $sz"

sed -i "s/xxx/$sz/g" `grep -l xxx source/about/index.md`
