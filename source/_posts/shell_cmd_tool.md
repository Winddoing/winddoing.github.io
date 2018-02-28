---
date: 2015-06-18 01:49
layout: post
title: 常用的shell命令
thread: 166
categories: 常用工具
tags: [Shell, xargs]
---

常用的shell命令： `find`, `cat`

<!-- more -->

## Find

``` shell
[root@linfeng etc]# find . -type f -name "*" | xargs grep "root/init.sh"
```

* `-type f` : 表示只找文件
* `-name "xxx"` :  表示查找特定文件；也可以不写，表示找所有文件

## Cat

>cat和重定向进行写文件操作

``` shell
=====>$cat > test.sh << EOF
> this is test
> > EOF
```

* `>` : 以覆盖文件内容的方式，若此文件不存在，则创建
* `>>` : 以追加的方式写入文件

## tee

``` shell
make USE_NINJA=false USE_CLANG_PLATFORM_BUILD=false 2>&1 | tee build.log
```

## ssh

``` shell
xbin="u-boot-with-spl-mbr-gpt.bin"                                              
xdst="user@192.168.10.44:/home/user/x2000_ddr_test"

scp $xbin fpga@192.168.4.13:/tmp/$xbin           
ssh fpga@192.168.4.13 "scp /tmp/$xbin $xdst"     
```

## tftp

> 开发板（busybox）


``` shell
tftp -g -r user/xxxx/system.tar 192.168.4.13
```

tftp的服务器(PC):

``` shell
# /etc/default/tftpd-hpa

TFTP_USERNAME="tftp"
TFTP_DIRECTORY="/home/"
TFTP_ADDRESS="0.0.0.0:69"
TFTP_OPTIONS="--secure"
```
> file: /etc/default/tftpd-hpa


## 解压ramdisk

``` shell
gunzip rootfs.cpio.gz
mkdir tmp
cd tmp
cpio -i -F ../rootfs.cpio
```
>code: [unzip_ramdisk.sh](https://raw.githubusercontent.com/Winddoing/MyCode/master/android/debug/unzip_ramdisk.sh)


## minicom

记录串口的输出日志：

``` shell
#!/bin/sh

mkdir dd
echo "while [ 1 ];do killall minicom; sleep 36000;done" > ./b.sh
chmod +x ./b.sh
./b.sh &

while [ 1 ]
do
	ff=`date +%Y%m%d%H%M`;
	echo $ff;
	minicom -w -C ./dd/$ff -o;
done
```

* 串口输出增加时间戳：
```
Ctrl + a ; n
```

* 串口打印内存信息：
```
Ctrl + a; f; m
```
>`Ctrl + a; f`(send break)进行发送命令，`m`查看当前内存状态的命令

| break signal | |
| :----------: | :----: |
| m | 查看当前内存状态的命令 |


## 参考

1. [minicom中文手册](https://www.cnblogs.com/my-blog/archive/2008/12/10/1351753.html)
