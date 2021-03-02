---
title: shell常用代码
tags:
  - shell
categories:
  - shell
abbrlink: 3776
date: 2018-02-04 23:07:24
---

{% note info %} shell常用代码： {% endnote %}

<!--more-->

## 递归便利整个目录及子目录

``` shell
function getdir(){
    echo $1
    for file in $1/*
    do
        if test -f $file
        then
            echo $file
            arr=(${arr[*]} $file)
        else
            getdir $file
        fi
    done
}
getdir ./src
#echo ${arr[@]}
```

## 打开多个窗口并登录ssh执行命令

``` shell
#!/bin/bash

run_cmd_shell=$(tempfile)
cat > $run_cmd_shell << EOF
#!/bin/bash

ssh root@192.168.101.55 'pwd; ls; sleep 10'
EOF
echo "Run cmd shell: $run_cmd_shell"

for win in {1..5}
do
    gnome-terminal -t "win-$win" --window -e \
        "bash ${run_cmd_shell}"
done
```

## 判断是否使用sudo

``` shell
# root or not
if [[ $EUID -ne 0 ]]; then
  SUDO='sudo -H'
else
  SUDO=''
fi

$SUD0 apt update -y
```
> `EUID`: 在shell启动时被初始化的当前用户的有效ID,如果是root用户`EUID=0`
> > shell命令`id -u`作用相同

``` shell
(( EUID != 0 )) && exec sudo -E -- "$0" "$@"
```

## ${:-}变量的默认值

``` shell
NUM_THREADS=${NUM_THREADS:-4}
```
> 如果NUM_THREADS变量没有被定义，NUM_THREADS值将是`：-`后得默认值；如果NUM_THREADS变量被定义，NUM_THREADS值将定义值

``` shell
=====>$bash -v aa.sh
#!/bin/bash
NUM_THREADS=${NUM_THREADS:-4}
echo "num-thread=$NUM_THREADS"
num-thread=4

=====>$bash -v aa.sh
#!/bin/bash
NUM_THREADS=8
NUM_THREADS=${NUM_THREADS:-4}
echo "num-thread=$NUM_THREADS"
num-thread=8
```

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
2. [shell变量详解](https://www.cnblogs.com/barrychiao/archive/2012/10/22/2733210.html)
