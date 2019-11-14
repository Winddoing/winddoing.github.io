---
layout: post
title: Linux下去掉^M的方法
date: '2018-10-23 11:49'
tags:
  - Linux
categories:
  - 工具
abbrlink: 18189
---

在linux下去掉文件行尾的`^M`

```
cat -A filename
```
> 查看到windows下的断元字符^M

<!--more-->

## dos2unix

```
dos2unix filename
```

多文件处理
```
ls ./*.c | xargs dos2unix
```

## sed

```
sed -i 's/^M//g' filename
```
或
```
sed -i 's/\r//g' filename
```
>注意：^M的输入方式是 `Ctrl + v` ，然后`Ctrl + M` 
 
## vi

将两个命令合并成一个，并添加的vi的快捷键中。
```
nmap dm :%s/\r\+$//e<cr>:set ff=unix<cr>
```
>用法： 打开文件直接敲`dm`即可，最后保存
