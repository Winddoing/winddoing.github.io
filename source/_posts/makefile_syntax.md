---
title: Makefile基础语法
categories:
  - Makefile
tags:
  - makefile
abbrlink: 21058
date: 2018-03-22 23:07:24
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


## 解析版本号

Makefile文件：
```
SRC_PATH := $(dir $(lastword $(MAKEFILE_LIST)))
PWD := $(shell pwd)

# version decode: client.major.minor.release
#	client: the proposed client ID
#       major: increase the major number every year
#       		2020=>K.2.2.0 2021=>K.3.2.0 2022=>K.4.2.0
#       minor: increase the minor number every promotion
#       		K.2.1.0=>K.2.2.0=>K.2.3.0=>...=>K.2.255.0
#       release: change the release number with each release
VERSION_FILE = $(SRC_PATH)/VERSION
GCC_VER_GE9 = $(shell echo `gcc -dumpversion | cut -f1-2 -d.`\>=9 | bc)
GCC_VER_GE6 = $(shell echo `gcc -dumpversion | cut -f1-2 -d.`\>=6 | bc)

getver = $(shell grep $1 $(VERSION_FILE) | awk -F'=' '{print $$2}')
ifneq ("", "$(wildcard $(VERSION_FILE))")
  TST_VERSION = $(call getver,client).$(call getver,major).$(call getver,minor).$(call getver,release)
else
  TST_VERSION = staging
endif

$(info $(GCC_VER_GE9))
$(info $(GCC_VER_GE6))
$(info $(TST_VERSION))

ifeq ($(GCC_VER_GE9),1)
	subdir-ccflags-y += -fcf-protection=none
endif

ifeq ($(GCC_VER_GE6),1)
	subdir-ccflags-y += -Wshift-negative-value
endif


all:
	echo "Test"
```

VERSION文件：
```
$cat VERSION
client=R
major=3
minor=88
release=1
```
