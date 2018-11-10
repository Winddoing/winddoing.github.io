---
layout: post
title: linux下批量文件处理-字符串替换
date: '2018-11-10 14:09'
tags:
  - Linux shell
categories:
  - shell
  - 字符串处理
---

`sed`进行处理多文件中的字符串替换,可以快速的修改函数名或者变量名.

<!--more-->

## sed

```
sed [-nefri] [动作]
```
* `-n` ：使用安静(silent)模式。在一般 sed 的用法中，所有来自 STDIN 的数据一般都会被列出到终端上。但如果加上 -n 参数后，则只有经过sed 特殊处理的那一行(或者动作)才会被列出来。
* `-e` ：直接在命令列模式上进行 sed 的动作编辑；
* `-f` ：直接将 sed 的动作写在一个文件内， -f filename 则可以运行 filename 内的 sed 动作；
* `-r` ：sed 的动作支持的是延伸型正规表示法的语法。(默认是基础正规表示法语法)
* `-i` ：直接修改读取的文件内容，而不是输出到终端。


## 单文件替换

```
sed -i 's/sockhandle/sock/g' aa.c
```

## 多文件替换

```
grep "sockhandle" . -rl | xargs sed -i 's/sockhandle/sock/g'
```
> `-rl`: 列出文件内容符合指定的范本样式的文件名称
> 
> `-rn`: 在显示符合范本样式的那一列之前，标示出该列的列数编号
