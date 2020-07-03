---
layout: "post"
title: "meson编译规则"
date: "2020-04-29 15:29"
tags:
  - meson
  - build
categories:
  - 编译工具
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
