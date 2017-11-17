---
date: 2015-06-18 01:49
layout: post
title: find命令——文件中字符查找
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
