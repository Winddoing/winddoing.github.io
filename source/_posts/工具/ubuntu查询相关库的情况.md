---
layout: post
title: ubuntu查询相关库的情况
date: '2019-01-02 15:39'
tags:
  - 库
categories:
  - 工具
abbrlink: 31784
---

查询一个库的`位置`

<!--more-->

> **环境**: Ubuntu 18.04.1 LTS
> - 测试库名: libmpfr



## 库的相关描述

```
$dpkg -l "*库信息*"
```
示例:
```
$dpkg -l "*libmpfr*"
Desired=Unknown/Install/Remove/Purge/Hold
| Status=Not/Inst/Conf-files/Unpacked/halF-conf/Half-inst/trig-aWait/Trig-pend
|/ Err?=(none)/Reinst-required (Status,Err: uppercase=bad)
||/ Name                                     Version                   Architecture              Description
+++-========================================-=========================-=========================-======================================================================================
ii  libmpfr6:amd64                           4.0.1-1                   amd64                     multiple precision floating-point computation
```

## 库的位置

查询`libmpfr`的路径

### 直接查找
```
$ldconfig -p | grep "库信息"
```
示例:
```
$ldconfig -p | grep "libmpfr"
	libmpfr.so.6 (libc6,x86-64) => /usr/lib/x86_64-linux-gnu/libmpfr.so.6
```
### 间接查找

```
dpkg -L "库名称"
```
示例:
```
$dpkg -L "libmpfr6:amd64"
/.
/usr
/usr/lib
/usr/lib/x86_64-linux-gnu
/usr/lib/x86_64-linux-gnu/libmpfr.so.6.0.1
/usr/share
/usr/share/doc
/usr/share/doc/libmpfr6
/usr/share/doc/libmpfr6/AUTHORS
/usr/share/doc/libmpfr6/BUGS
/usr/share/doc/libmpfr6/NEWS.gz
/usr/share/doc/libmpfr6/README
/usr/share/doc/libmpfr6/TODO.gz
/usr/share/doc/libmpfr6/changelog.Debian.gz
/usr/share/doc/libmpfr6/copyright
/usr/lib/x86_64-linux-gnu/libmpfr.so.6
```
