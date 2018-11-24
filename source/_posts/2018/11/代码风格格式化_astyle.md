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

   --style=stroustrup  OR  -A4
   Stroustrup style formatting/indenting.
   Linux braces.

   --style=whitesmith  OR  -A5
   Whitesmith style formatting/indenting.
   Broken, indented braces.
   Indented class blocks and switch blocks.

   --style=vtk  OR  -A15
   VTK style formatting/indenting.
   Broken, indented braces except for the opening braces.

   --style=ratliff  OR  --style=banner  OR  -A6
   Ratliff style formatting/indenting.
   Attached, indented braces.

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

   --style=mozilla  OR  -A16
   Mozilla style formatting/indenting.
   Linux braces, with broken braces for structs and enums,
   and attached braces for namespaces.

   --style=pico  OR  -A11
   Pico style formatting/indenting.
   Run-in opening braces and attached closing braces.
   Uses keep one line blocks and keep one line statements.

   --style=lisp  OR  -A12
   Lisp style formatting/indenting.
   Attached opening braces and attached closing braces.
   Uses keep one line statements.
```

## 使用

```
astyle --style=linux -n ./*.c
```
- `--style=linux` : linux风格缩进
- `-n` : 不保存备份
