---
layout: post
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

## for循环拼接字符串

```
# 在当前目录下创建文本文件temp，如果文件存在则清空文件
$(> temp)
# for 循环将参数追加到当前目录的temp文件，逗号分隔，echo -n 不换行
for i in $*;do
	((n++))
	# 从第四个开始拼接
	if [[ n -gt 3 ]];then
		echo -n ${i}, >> temp
	fi
done
# h2取tempfile文本里的字符串
h2=$(cat temp)
# 将字符串最后的一个逗号去掉
h2=${h2%*,}
echo $h2
```

## 参数组合执行

``` shell
set -- $(getopt -q dbc "$@")
while [ -n "$1" ]
do
        case "$1" in
            -d) echo "Deploy ..."

                shift ;;
            -b) echo "Build  ..."

                shift ;;
            -c) echo "Clean  ..."

                shift ;;
            --) shift
                break ;;
            -*) echo "Nothing to do";;
        esac
done
```
以上参数可以单独传递执行，也可以组合一起执行。
例如：

``` shell
$./m.sh -d
Deploy ...

$./m.sh -c
Clean  ...

$./m.sh -db
Deploy ...
Build  ...

$./m.sh -d -b
Deploy ...
Build  ...

$./m.sh -dbc
Deploy ...
Build  ...
Clean  ...
```


## 调试技巧

``` shell
#!/bin/bash
set -euo pipefail
IFS=$'\n\t'
```
- `-e`: 如果任何命令返回为非零，则bash 立即退出。如果没有这条命令，那么当前命令失败后，后面的指令还是会执行，这会带来意想不到的bug。
- `-u`: 设置后对未定义的任何变量的使用（除了 $* 和 $@）都会报错，程序立即退出。
- `-o`: 如果管道中的任何命令失败，该返回代码将用作整个管道的返回代码
- `IFS`: bash的默认分隔符是`空格`、`换行`、`Tab`，遍历含有空格的字符串时，会以空格为分隔符，单着常常不是我们想要的。IFS=$'\n\t'的作用就是只设置`换行`和`Tab`作为分隔符。


## 获取随机MAC地址

``` shell
echo -n 00-60-2F; dd bs=1 count=3 if=/dev/urandom 2>/dev/null |hexdump -v -e '/1 "-%02X"'

#or

echo -n 00-60-2F; head -c 3 /dev/urandom | hexdump -v -e '/1 "-%02X"'
```


## shell单例模式

``` shell
# 此函数用于获取不到锁时主动退出
activate_exit(){
    echo "`date +'%Y-%m-%d %H:%M:%S'`--error. get lock fail. there is other instance running. will be exit."
    exit 1
}

# 此函数用于申请锁
get_lock(){
    lock_file_name="/tmp/`basename $0`.pid"
    # exec 6<>${lock_file_name}，即以6作为lock_file_name的文件描述符（file descriptor number）
    # 6是随便取的一个数值，但不要是0/1/2，也不要太大（不要太太包含不能使用$$，$$值可能会比较大）
    # 不用担心如test.sh和test1.sh都使用
    exec 6<>${lock_file_name}
    # 如果获取不到锁，flock语句就为假，就会执行||后的activate_exit
    # 引入一个activate_exit函数的原因是||后不知道怎么写多个命令
    flock -n 6 || activate_exit
    # 如果没有执行activate_exit，那么程序就可以继续执行
    echo "`date +'%Y-%m-%d %H:%M:%S'`--ok. get lock success. there is not any other instance running."
    # 将当前获取锁的进程id写入文件
    echo "$$">&6

    # 设置监听信号
    # 当进程因这些信号致使进程中断时，最后仍要释放锁。类似java等中的final
    # 这个其实不需要，因为进程结束时fd会自动关闭
    # trap 'release_lock && activate_exit "1002" "break by some signal."' 1 2 3 9 15
}

# 程序主要逻辑
exec_main_logic(){
  echo "you can code your main logic in this function."
  # 这个sleep只是为了用于演示，替换成自己的代码即可
  sleep 30
}

# 程序主体逻辑
main(){
  # 获取锁
  get_lock $@
  # 程序主要逻辑
  exec_main_logic
}

main $@
```


## wait

`wait`是用来阻塞当前进程的执行，直至指定的子进程执行结束后，才继续执行。

``` shell
#!/bin/bash
tst()
{
  while [ 1 ]
	do
		sleep 1
		echo "Test wait ..."
	done
}

tst &

wait
```


## sh下获取一个随机数

``` shell
#!/bin/sh

rand()
{
	min=$1
	max=$(($2-$min+1))
	num=$(cat /dev/urandom | head -n 10 | cksum | awk -F ' ' '{print $1}')
	echo $(($num % $max + $min))
}

rnd=$(rand 100 500)
echo $rnd
```

获取随机字符串:

``` shell
head -c 4 /dev/urandom | od -A n -t x | tr -d ' '
```


## bash调试命令

Shell本身提供一些调试方法选项：

- `-n`: 读一遍脚本中的命令但不执行，用于检查脚本中的语法错误。
- `-v`: 一边执行脚本，一边将执行过的脚本命令打印到标准输出。
- `-x`: 提供跟踪执行信息，将执行的每一条命令和结果依次打印出来。

基本写法： `sh [-nxv] 脚本名字`

``` shell

$bash -x  aa.sh

#or

#!/bin/bash -x

```


## 获取centos发行版本

``` shell
rpm --query centos-release
#或
rpm -q centos-release --qf 'centos %{v}-%{r}\n'
```
> https://unix.stackexchange.com/questions/417656/bash-command-to-get-distribution-and-version-only

``` shell
OS_VERSION_ID=$(grep "VERSION_ID=" /etc/*-release | awk -F "=" '{print $2}')
OS_VERSION_ID=$(echo $OS_VERSION_ID | sed 's/\"//g')

echo "Current OS CentOS $OS_VERSION_ID"
```

## 检测IP地址格式是否有效

``` shell
function check_ip()
{
    local ip=$1
    info "Check ip: $ip"
    local valid_check=$(echo $ip | awk -F. '$1<=255&&$2<=255&&$3<=255&&$4<=255{print "yes"}')
    if echo $ip | grep -E "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$">/dev/null; then
        if [ ${valid_check:-no} == "yes" ]; then
            echo "IP $ip available."
        else
            error "IP $ip not available!"
            return 311
        fi
    else
        error "IP format error!"
        return 312
    fi
}
```

## if条件中使用正则表达式

> The =~ Regular Expression match operator no longer requires quoting of the pattern within [[ … ]].

示例：
``` shell
newip="192.168.1.1"
if [[ "$newip" =~ ^([0-9]{1,3}.){3}[0-9]{1,3}$ ]];then
    echo "找到了ip地址"
fi

#or

if [[ "$tag_version" =~ ^v[0-9].[0-9].[0-9] ]]; then
    echo "$tag_version format is valid."
else
    echo "$tag_version format error. example: v0.0.1 or v0.0.1a"
    exit 1
fi
```
**注**： 正则表达式正在[[...]]中不能使用双引号

## sed修改配置文件

`"/^BOOTPROTO/c BOOTPROTO=static"`： 查找出首字符是`BOOTPROTO`的行，并将其替换为`BOOTPROTO=static`

``` shell
sed -i "/^BOOTPROTO/c BOOTPROTO=static" /etc/sysconfig/network-scripts/ifcfg-eno1
sed -i "/^ONBOOT/c ONBOOT=yes" /etc/sysconfig/network-scripts/ifcfg-eno1
sed -i "/^IPADDR/c IPADDR=192.168.1.11" /etc/sysconfig/network-scripts/ifcfg-eno1
sed -i '$a NETMASK=255.255.255.0' /etc/sysconfig/network-scripts/ifcfg-eno1
```
> 配置IP地址

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

``` shell
 [ ${UID} -ne 0 ] && echo "Please run with sudo" && exit -1
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
