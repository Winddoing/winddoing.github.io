---
layout: post
title: Shell获取git信息和编译时间
date: '2018-09-18 15:25'
tags:
  - shell
categories:
  - Shell
abbrlink: 56769
---

记录软件版本每一个编译的时间和log信息：

<!--more-->

``` shell
#!/bin/sh
GIT_SHA1=`(git show-ref --head --hash=8 2> /dev/null || echo 00000000) | head -n1`
GIT_DIRTY=`git diff --no-ext-diff 2> /dev/null | wc -l`
BUILD_ID=`uname -n`"-"`date +%Y%m%d%H%M%S`
test -f release.h || touch release.h
(cat release.h | grep SHA1 | grep $GIT_SHA1) && \
(cat release.h | grep DIRTY | grep $GIT_DIRTY) && exit 0 # Already up-to-date
echo "#define REDIS_GIT_SHA1 \"$GIT_SHA1\"" > release.h
echo "#define REDIS_GIT_DIRTY \"$GIT_DIRTY\"" >> release.h
echo "#define REDIS_BUILD_ID \"$BUILD_ID\"" >> release.h
#touch release.c # Force recompile of release.c
```
- 结果：
```
#define REDIS_GIT_SHA1 "ed5b0648"
#define REDIS_GIT_DIRTY "13"
#define REDIS_BUILD_ID "xxxx-pc-20180918152335"
```
> release.h
