---
layout: post
title: linux下shell基础--获取脚本路径
date: '2018-11-24 14:21'
tags:
  - Shell
categories:
  - shell
---

在执行脚本时我们或多或少的都要知道当前所在的路径,或者脚本存放的路径,记录几个常用的获取`路径`的方法

<!--more-->

## 脚本路径

### $(cd `dirname $0`;pwd)

> 获取当前`脚本`所在的`绝对路径`

```
basepath=$(cd `dirname $0`; pwd)
```
- `dirname $0` :取得当前执行脚本文件的父目录

### pwd

> 获取当前`执行脚本`的所在的`绝对路径`

### $(readlink -f $(dirname $0))

> 获取当前`脚本`所在的`相对路径``

### 测试

> xxx:主机名

* 测试脚本

```
#!/bin/bash

basepath1=`pwd`
basepath2=$(cd `dirname $0`; pwd)
basepath3=$(readlink -f $(dirname $0))
basepath4=$(dirname $0)
basepath5=$(dirname $(readlink -f $0))

echo "basepath1= $basepath1"
echo "basepath2= $basepath2"
echo "basepath3= $basepath3"
echo "basepath4= $basepath4"
echo "basepath5= $basepath5"
```
* 测试环境

```
14:47 [xxx@xxx-pc]~/test
=====>$ls -l a.sh
lrwxrwxrwx 1 xxx xxx 13 11月 24 14:42 a.sh -> aa/bb/cc/a.sh
```
* 执行脚本

```
14:48 [xxx@xxx-pc]~
=====>$./test/a.sh
basepath1= /home/xxx
basepath2= /home/xxx/test
basepath3= /home/xxx/test
basepath4= ./test
basepath5= /home/xxx/test/aa/bb/cc
```

## readlink

> 用来找出符号链接所指向的位置

```
$readlink .vimrc
/home/xxx/.work_env/vim/vimrc
```
- `-f`: 递归跟随给出文件名的所有符号链接以标准化，除最后一个外所有组件必须存在。
