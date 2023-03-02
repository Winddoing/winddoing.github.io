---
title: Cmake中Build生成可执行文件与Install后可执行文件不是同一个文件
tags:
  - cmake
categories:
  - 编译工具
  - cmake
abbrlink: 331f1334
date: 2023-03-01 00:00:00
---


cmake编译生成的可执行文件与Install后的文件不同：

```
$ md5sum build/lib/libenc.so packages/aarch64/Debug/lib/libenc.so
6bd8b76c426515112ab697db589dc229  build/lib/libenc.so
8125674eaa256ece0e08373e758e3013  packages/aarch64/Debug/lib/libenc.so

$ md5sum build/bin/enc_test packages/aarch64/Debug/bin/enc_test
0753ff4ffe4a41e19058628dd3627de9  build/bin/enc_test
1073ccf878e004045bc733630952e6c3  packages/aarch64/Debug/bin/enc_test
```

<!--more-->

一般情况下这两个文件应该是相同的，Install时只是做了简单的文件拷贝。

这里存在差异主要原因是cmake时，对elf文件进行了修改将其中的`RUNPATH`移除了。

`RUNPATH`: 指定运行时搜索库的路径。

## 不用RUNPATH

在cmake编译时，默认会添加`RUNPATH`，添加以下配置可以在Build阶段移除

```
set(CMAKE_SKIP_BUILD_RPATH TRUE
```
> 将CMAKE_SKIP_BUILD_RPATH使能后，Build和Install后的elf文件将完全相同，都不包含`RUNPATH`配置


在Cmake中相关RPATH的默认配置：
```
set(CMAKE_SKIP_BUILD_RPATH FALSE)                 # 编译时加上RPATH
set(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE)         # 编译时RPATH不使用安装的RPATH
set(CMAKE_INSTALL_RPATH "")                       # 安装RPATH为空
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH FALSE)      # 安装的执行文件不加上RPATH
```

## patchelf

可以使用`patchelf`工具对elf的RPATH进行设置或查看。



## 动态库的加载顺序

`man ld` ELF文件的链接顺序：

> The linker uses the following search paths to locate required shared libraries:
>
>  1.  Any directories specified by -rpath-link options.
>
    2.  Any directories specified by -rpath options.  The difference between -rpath and -rpath-link is that directories specified by -rpath options are included in the executable and used at runtime, whereas the -rpath-link option is only effective at link time. Searching -rpath in this way is only supported by native linkers and cross linkers which have been configured with the --with-sysroot option.
>
> 3.  On an ELF system, for native linkers, if the -rpath and -rpath-link options were not used, search the contents of the environment variable "LD_RUN_PATH".
>
> 4.  On SunOS, if the -rpath option was not used, search any directories specified using -L options.
>
> 5.  For a native linker, search the contents of the environment variable "LD_LIBRARY_PATH".
>
> 6.  For a native ELF linker, the directories in "DT_RUNPATH" or "DT_RPATH" of a shared library are searched for shared libraries needed by it. The "DT_RPATH" entries are ignored if "DT_RUNPATH" entries exist.
>
> 7.  The default directories, normally /lib and /usr/lib.
>
> 8.  For a native linker on an ELF system, if the file /etc/ld.so.conf exists, the list of directories found in that file.
>
>  If the required shared library is not found, the linker will issue a warning and continue with the link.

