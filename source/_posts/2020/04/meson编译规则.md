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
