---
layout: post
title: autotools自动编译---手动添加依赖库
date: '2019-09-30 11:28'
tags:
  - autotools
  - configure
  - autogen
categories:
  - 编译工具
abbrlink: 31094
---

`autotools`根据配置文件(configure.ac)自动生成`makefile`

<!--more-->

```
./autogen.sh  #根据configure.ac生成configure与相关头文件
./configure --prefix=$ALT_LOCAL --enable-debug
make -j4
make install
```

## 在现有应用中添加SDL的依赖

将gcc的编译参数`-lSDL2`,添加到`configure`生成的Makefile，并可以在配置阶段检测系统是否以安装SDL2相关库

### 修改configure.ac

添加对SDL2库的检测
```
PKG_CHECK_MODULES([SDL2], [sdl2])
```

执行`autogen.sh`生成configure和config.log等，在`config.log`中将生成：
```
SDL2_CFLAGS='-D_REENTRANT -I/usr/include/SDL2'
SDL2_LIBS='-lSDL2'
```
### 编辑Makefile.am

修改需要链接SDL2的源码目录中的`Makefile.am`
```
AM_LDFLAGS = $(SDL2_LIBS)
AM_CFLAGS = $(SDL2_CFLAGS)
```

## make参数

```
make -j4 --trace
```
> `--trace`: 打印gcc编译的详细数据

## 参考

- [autotools自动编译系列之三---autogen.sh实例](https://blog.csdn.net/kongshuai19900505/article/details/79104442)
