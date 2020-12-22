---
layout: post
title: Android模拟器
date: '2020-03-09 18:08'
categories:
  - android
tags:
  - android
abbrlink: 40058
---

Android模拟器开发和调试应用肯定比使用真机方便

<!--more-->

## 模拟器源码下载

Android 模拟器源码的下载与 Android AOSP 源码库的下载过程类似。

模拟器的分支：在 https://android.googlesource.com/platform/manifest/+refs 可以看到所有可以指定的分支，包括 Android 分支和模拟器分支，其中模拟器分支主要有如下这些：

```
emu-1.4-release
emu-1.5-release
emu-2.0-release
emu-2.2-release
emu-2.3-release
emu-2.4-arc
emu-2.4-release
emu-2.5-release
emu-2.6-release
emu-2.7-release
emu-2.8-release
emu-29.0-release
emu-3.0-release
emu-3.1-release
emu-gn-dev
emu-master-dev
emu-master-qemu
emu-master-qemu-release
```

下载最新模拟器代码：
``` shell
$ repo init -u https://android.googlesource.com/platform/manifest -b emu-master-dev
```

> 在国内可以使用清华源更快下载:
> ``` shell
> repo init -u https://aosp.tuna.tsinghua.edu.cn/platform/manifest -b emu-master-dev
> ```


## 编译


``` shell
cd external/qemu/android/
./rebuild.sh --no-tests
```
> - `--no-tests`: 告诉编译系统，编译完成之后不要执行测试程序，以节省时间，提高效率


## Android Hardware OpenGLES emulation design overview

> path: `external/qemu/android/android-emugl/DESIGN`

```
_________            __________          __________
|         |          |          |        |          |
|EMULATION|          |EMULATION |        |EMULATION |     GUEST
|   EGL   |          | GLES 1.1 |        | GLES 2.0 |     SYSTEM
|_________|          |__________|        |__________|     LIBRARIES
    ^                    ^                    ^
    |                    |                    |
- - | - - - - - - - - -  | - - - - - - - - -  | - - - - -
    |                    |                    |
____v____________________v____________________v____      GUEST
|                                                   |     KERNEL
|                       QEMU PIPE                   |
|___________________________________________________|
                        ^
                        |
 - - - - - - - - - - - -|- - - - - - - - - - - - - - - -
                        |
                        |    PROTOCOL BYTE STREAM
                   _____v_____
                  |           |
                  |  EMULATOR |
                  |___________|
                        ^
                        |   UNMODIFIED PROTOCOL BYTE STREAM
                   _____v_____
                  |           |
                  |  RENDERER |
                  |___________|
                      ^ ^  ^
                      | |  |
    +-----------------+ |  +-----------------+
    |                   |                    |
____v____            ___v______          ____v_____
|         |          |          |        |          |
|TRANSLATOR          |TRANSLATOR|        |TRANSLATOR|     HOST
|   EGL   |          | GLES 1.1 |        | GLES 2.0 |     TRANSLATOR
|_________|          |__________|        |__________|     LIBRARIES
    ^                    ^                    ^
    |                    |                    |
- - | - - - - - - - - -  | - - - - - - - - -  | - - - - -
    |                    |                    |
____v____            ____v_____          _____v____      HOST
|         |          |          |        |          |     SYSTEM
|   GLX   |          |  GL 2.0  |        |  GL 2.0  |     LIBRARIES
|_________|          |__________|        |__________|

(NOTE: 'GLX' is for Linux only, replace 'AGL' on OS X, and 'WGL' on Windows).
```
