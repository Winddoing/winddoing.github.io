---
layout: post
title: '`GLIBCXX_3.4.21'' not found'
date: '2021-05-21 16:05'
tags:
  - gcc
categories:
  - 编译工具
---

``` shell
/lib64/libstdc++.so.6: version `GLIBCXX_3.4.21' not found (required by /usr/local/bin/a.out)
```
> 程序运行是加载的`libstdc++`库版本低， 解决方法直接升级gcc版本

<!--more-->

## 检查引用库GLIBCXX版本

``` shell
# strings /usr/lib64/libstdc++.so.6|grep GLIBCXX
GLIBCXX_3.4
GLIBCXX_3.4.1
GLIBCXX_3.4.2
GLIBCXX_3.4.3
GLIBCXX_3.4.4
GLIBCXX_3.4.5
GLIBCXX_3.4.6
GLIBCXX_3.4.7
GLIBCXX_3.4.8
GLIBCXX_3.4.9
GLIBCXX_3.4.10
GLIBCXX_3.4.11
GLIBCXX_3.4.12
GLIBCXX_3.4.13
GLIBCXX_3.4.14
GLIBCXX_3.4.15
GLIBCXX_3.4.16
GLIBCXX_3.4.17
GLIBCXX_3.4.18
GLIBCXX_3.4.19
GLIBCXX_DEBUG_MESSAGE_LENGTH
```

## CentOS升级gcc

### 安装gcc9

``` shell
yum -y install centos-release-scl
yum -y install devtoolset-9-gcc devtoolset-9-gcc-c++
```
> 可以安装多个版本，使用时自由切换

### 切换gcc版本

``` shell
scl enable devtoolset-9 bash
#或
source /opt/rh/devtoolset-3/enable
```

### libstdc++

安装后的文件：`/opt/rh/devtoolset-9/root/usr/lib/gcc/x86_64-redhat-linux/9/libstdc++.so`


## 程序运行时加载库的流程

升级完成gcc后，切换到高版本进行编译后，可以正常运行，但是此时系统中存在多个`libstdc++`库，它是如何找到那个高版本库加载的？


``` shell
# ldd /usr/local/bin/a.out | grep c++
	libstdc++.so.6 => /lib64/libstdc++.so.6 (0x00007fab09a88000)
```
ldd查看其依赖库依然是`/lib64/libstdc++.so.6`，这个gcc低版本库，正常应该是不能运行的，但是此时程序运行是正常的（使用系统默认gcc编译后无法正常运行）。


``` shell
strings /opt/rh/devtoolset-9/root/usr/lib/gcc/x86_64-redhat-linux/9/libstdc++.so
/* GNU ld script
   Use the shared library, but some functions are only in
   the static library, so try that secondarily.  */
OUTPUT_FORMAT(elf64-x86-64)
INPUT ( /usr/lib64/libstdc++.so.6 -lstdc++_nonshared )
```
通过`strings`查看该库时，发现以上信息。个人理解应该是再切换了编译器后，在编译时将部分代码结构，以静态的方式直接编译到了可执行程序中，这样在运行时即使加载旧的`libstdc++`库，也可以正常运行。
