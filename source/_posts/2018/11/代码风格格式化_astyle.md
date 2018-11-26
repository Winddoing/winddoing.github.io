---
layout: post
title: 代码风格格式化--Astyle
date: '2018-11-22 14:01'
tags:
  - 编码
categories:
  - 程序设计
  - 代码风格
---

`Astyle`是一个用来对C/C++代码进行格式化
>文档: [Artistic Style 3.1](http://astyle.sourceforge.net/astyle.html)

<!--more-->


## 安装

```
$sudo apt install astyle
```

## 预定风格


```
   default brace style
   If no brace style is requested, the opening braces will not be
   changed and closing braces will be broken from the preceding line.

   --style=allman  OR  --style=bsd  OR  --style=break  OR  -A1
   Allman style formatting/indenting.
   Broken braces.

   --style=java  OR  --style=attach  OR  -A2
   Java style formatting/indenting.
   Attached braces.

   --style=kr  OR  --style=k&r  OR  --style=k/r  OR  -A3
   Kernighan & Ritchie style formatting/indenting.
   Linux braces.

   ...

   --style=gnu  OR  -A7
   GNU style formatting/indenting.
   Broken braces, indented blocks.

   --style=linux  OR  --style=knf  OR  -A8
   Linux style formatting/indenting.
   Linux braces, minimum conditional indent is one-half indent.

   --style=horstmann  OR  --style=run-in  OR  -A9
   Horstmann style formatting/indenting.
   Run-in braces, indented switches.

   --style=1tbs  OR  --style=otbs  OR  -A10
   One True Brace Style formatting/indenting.
   Linux braces, add braces to all conditionals.

   --style=google  OR  -A14
   Google style formatting/indenting.
   Attached braces, indented class modifiers.
```

## 使用

```
astyle --style=linux -n ./*.c
```
- `--style=linux` : linux风格缩进
- `-n` : 不保存备份


>```
>astyle --style=linux --indent=force-tab=4 --convert-tabs --pad-oper --unpad-paren --break-blocks=all --delete-empty-lines *.c *.h
>```

### 递归格式化

```
astyle --style=linux --recursive *.c,*.h
```
> 必须中间加`,`

## 自定义规则

>在`--style=linux`的基础上修改,只做必要改动

### 缩进Tab

默认tab是4个空格.

```
--indent=force-tab=#  OR  -T#
```
> 优先采用空格缩进, 这样配置后同vim中的tab缩进配置4个空格相同,格式化后的代码相当于vim中的`gg=G`

### switch缩进

默认

### 操作符两边加空格
```
--pad-oper  OR  -p
```
### 删除括号()两边多余空格
```
--unpad-paren  OR  -U
```
### 空行分隔没有关系的块,类,标签(不包括函数块)
```
 --break-blocks  OR  -f
```
### 空行分隔无关系的块,包括else catch等
```
--break-blocks=all  OR  -F
```
### 删除多余空行
```
--delete-empty-lines  OR  -x
```
### Tab转换为空格
```
--convert-tabs  OR  -c
```

## 参考

* [Astyle编程语言格式化工具的中文说明](http://www.cnblogs.com/tfanalysis/articles/4874793.html)
