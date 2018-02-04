---
title: shell常用代码
date: 2018-02-04 23:07:24
categories: 程序设计
tags: [shell]
---

{% note info %} shell常用代码： {% endnote %}

<!--more-->

## 多线程

``` shell
#!/bin/sh

cpu_tmp=0
cpu=""
pmon=""
cycles=0
data_dir="test_rpt.$$"

while read LINE
do
	if echo $LINE|grep 'cpu_tmp'
	then
		cpu_tmp=${LINE#*:}
	fi


	if echo $LINE|grep 'cycles'
	then
		cycles=${LINE#*:}
	fi

done < run.cfg

#多线程：
# init fifo file 
THREAD1DIR=3 && FIFONR=4 && FIFONAME="$$.ff" && mkfifo $FIFONAME && str="exec $FIFONR<> $FIFONAME" && eval $str && rm $FIFONAME -f
i=0
while [ $i -lt $THREAD1DIR ]; do
	i=$((i+1))
	echo 
done >& $FIFONR
#for (( i=0; i<$THREAD1DIR; i++ )); do

# start test 1st level dir
all=`find . -maxdepth 1 -name "?????\.*"`
for i in $all
do
	if [ -d $i ]
	then
		read 
		( echo $i" 1runing" && cd $i/ && ./$i'.run'.sh $cycles && cd - && echo >& $FIFONR ) &
	fi
done <& $FIFONR

# rm fifo file
wait && str="exec $FIFONR>&-" && eval $str

#get log
[ -d $data_dir ] && rm -rf $data_dir || mkdir $data_dir && cp run.cfg $data_dir -f

for i in $all
do
	if [ -d $i ]
	then
		des_dir=$data_dir'/'$i'/'
		mkdir $des_dir
		src_dir='./'$i'/'
		file_path=`find $src_dir/ -name *_*.log`
		echo $file_path
		mv $file_path $des_dir	
	fi
done
chmod 777 './'$data_dir -R
rm *.ff -f
```
