---
title: shell常用代码
tags:
  - Shell
categories:
  - shell
abbrlink: 3776
date: 2018-02-04 23:07:24
---

{% note info %} shell常用代码： {% endnote %}

<!--more-->

## 将逗号分隔的字符串转成换行

``` shell
OLD_IFS="$IFS"
IFS=","
arr=(`cat 1.txt`)
IFS="$OLD_IFS"
for s in ${arr[@]}
do
    echo $s | tr -d '"'
done
```

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

## 修改文件名后缀

``` shell
for file in `find . -name "*.f90"`
do
	newfile=${file%.*}.f77
	#echo "$newfile"
	mv $file $newfile
done
```
>[Linux批量更改文件后缀名](https://blog.csdn.net/longxibendi/article/details/6387732)

## 检查网段IP占用情况

``` shell
#!/bin/bash

up=0
down=0

for siteip in $(seq 1 255)
do
	#site="192.168.2.${siteip}"
	site="172.16.189.${siteip}"
	ping -c1 -W1 ${site} &> /dev/null
	if [ "$?" == "0" ]; then
		up=$[$up+1]
		echo "$site is UP, cnt=$up"
	else
		down=$[$down+1]
		echo "$site is DOWN, cnt=$down"
	fi
done
# 除法
alive=`awk 'BEGIN{printf "%.2f\n",('$up'/'$(($up + $down))')}'`

echo "up:$up, down:$down, alive:$alive"
```

## 提取本地IP

``` shell
ip=`ifconfig | grep "inet " | grep -v "127.0.0.1"| awk '{print $2}'`
```
> `-v`: 排除

## 参考

1. [shell中各种括号的作用()、(())、[]、[[]]、{}](http://blog.csdn.net/taiyang1987912/article/details/39551385)
