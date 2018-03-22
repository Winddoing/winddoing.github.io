---
title: Makefile基础语法
date: 2018-03-22 23:07:24
categories: Makefile 
tags: [Makefile]
---

Makefile语法

<!--more-->

##  = := ?= +=

1. `=` 是最基本的赋值
2. `:=` 是覆盖之前的值
3. `?=` 是如果没有被赋值过就赋予等号后面的值
4. `+=` 是添加等号后面的值

### `=`

make会将整个makefile展开后，再决定变量的值。也就是说，变量的值将会是整个makefile中最后被指定的值。

```
x = foo
y = $(x) bar
x = xyz

all:
    echo "==: $y" 
```
>结果==: xyz bar

### `:=`

表示变量的值决定于它在makefile中的位置，而不是整个makefile展开后的最终值。

```
x := foo
y := $(x) bar
x := xyz

all:
    echo "==: $y"
```
>结果==: foo bar


