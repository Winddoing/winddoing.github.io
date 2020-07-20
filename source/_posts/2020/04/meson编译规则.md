---
layout: post
title: meson编译规则
date: '2020-04-29 15:29'
tags:
  - meson
  - build
categories:
  - 编译工具
abbrlink: 434f8def
---

在meson编译的项目中添加修改编译规则

<!--more-->


## 添加依赖库

添加OpenGL依赖库示例：
```
libgl_dep = dependency('GL')

test_sources = [
   'test.c',
   'test.h',
]

test = executable(
   'test.out',
   test_sources,
   dependencies : [libsdl_dep, libgl_dep],
   install : true
)
```

## Built-in options

> https://mesonbuild.com/Builtin-options.html

- `b_vscrt`: 为工程在window下通过mesa使用MSVC进行编译,如`-Db_vscrt=mtd`

### Base options


| Option  | Default value  | Possible values                        | Description                              |
| ------- | -------------- | -------------------------------------- | ---------------------------------------- |
| b_vscrt | from_buildtype | none, md, mdd, mt, mtd, from_buildtype | VS runtime library to use (since 0.48.0) |



## Native file properties

> As of Meson 0.54.0, the `--native-file nativefile.ini` can contain:
> - binaries
> - paths
> - properties

- https://mesonbuild.com/Release-notes-for-0-54-0.html#page-description
- https://mesonbuild.com/Contributing.html#page-description

本机文件属性,这里主要是指定meson在配置阶段加载本机的文件路径.用到它是因为本机的llvm存在多个版本,meson配置阶段总是加载最高版本的llvm-config-10,而我想用相对低版本(llvm-config-8),通过meson[手册](https://mesonbuild.com)可以通过`--native-file nativefile.ini`进行指定

版本大于`0.54.0`

```shell
$ls -lsh /usr/bin/llvm-config-10
0 lrwxrwxrwx 1 root root 30 4月  20 13:12 /usr/bin/llvm-config-10 -> ../lib/llvm-10/bin/llvm-config
$ls -lsh /usr/bin/llvm-config-8
0 lrwxrwxrwx 1 root root 29 3月  19 16:50 /usr/bin/llvm-config-8 -> ../lib/llvm-8/bin/llvm-config
$ls -lsh /usr/bin/llvm-config-7
0 lrwxrwxrwx 1 root root 29 3月  23 18:59 /usr/bin/llvm-config-7 -> ../lib/llvm-7/bin/llvm-config
```

~使用软链接修改`llvm-config`的路径测试,配置是依旧加载`llvm-config-10`,软连接方式不行~

### nativefile.ini

```
[binaries]
llvm-config = '/usr/lib/llvm-8/bin/llvm-config'
```

### 编译

```
meson builddir/ --native-file nativefile.ini
```
