---
layout: post
title: linux系统下修改uboot环境变量
date: '2022-08-16 14:40'
tags:
  - uboot
categories:
  - uboot
---

在linux系统下修改uboot环境变量，uboot自带工具`fw_printenv`

```
$ls tools/env
crc32.c  ctype.c  env_attr.c  env_flags.c  fw_env.c  fw_env.config  fw_env.h  fw_env_main.c  fw_env_private.h  linux_string.c  Makefile  README
```

<!--more-->


- 编译

```
make CROSS_COMPILE=aarch64-none-linux-gnu- envtools
```
