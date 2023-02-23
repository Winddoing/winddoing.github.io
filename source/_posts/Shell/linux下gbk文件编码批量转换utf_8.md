---
layout: post
title: Linux下GBK文件编码批量转换UTF-8
date: '2019-02-18 19:46'
tags:
  - shell
categories:
  - Shell
abbrlink: 38869
---

Windows默认是`GBK`编码格式，Linux默认是`UTF-8`的格式，不同格式之间的乱码处理。

``` shell
enca -L zh_CN -x UTF-8 *.c
```

<!--more-->

## enca -- 文件编码

``` shell
$enca -h
Usage:  enca [-L LANGUAGE] [OPTION]... [FILE]...
        enconv [-L LANGUAGE] [OPTION]... [FILE]...
```

用法：
``` shell
$ enca -L zh_CN file      检查文件的编码
$ enca -L zh_CN -x UTF-8 file 将文件编码转换为"UTF-8"编码
$ enca -L zh_CN -x UTF-8 file1 file2 如果不想覆盖原文件可以这样
```

## convmv -- 文件名编码

``` shell
$ convmv -f 源编码 -t 新编码 [选项] 文件名
```
> - -r 递归处理子文件夹
> - –notest 真正进行操作，请注意在默认情况下是不对文件进行真实操作的，而只是试验。
> - –list 显示所有支持的编码
> - –unescap 可以做一下转义，比如把%20变成空格

示例：
``` shell
$ convmv -f GBK -t UTF-8 --notest utf8 filename
```

``` shell
$ find default -type f -exec convmv -f GBK -t UTF-8 --notest utf8 {} -o utf/{} \;
```
> 批量处理
