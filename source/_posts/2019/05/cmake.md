---
layout: post
title: cmake
date: '2019-05-21 11:19'
tags:
  - Makefile
categories:
  - 编译工具
---

<!--more-->

## 显示编译详细信息

打印make进行编译过程中详细的gcc/g++参数信息。

```
make VERBOSE=1
```
> 在CMakeLists.txt中配置`set(CMAKE_VERBOSE_MAKEFILE ON)`


## debug调试

- 使用set命令，修改CMake文件

```
SET(CMAKE_CXX_FLAGS_DEBUG "$ENV{CXXFLAGS} -O0 -Wall -g")
```

- 使用环境变量

```
mkdir Debug
cd Debug
cmake -DCMAKE_BUILD_TYPE=Debug ..
```
