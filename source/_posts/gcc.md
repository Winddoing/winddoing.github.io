---
title: GCC
categories:
  - 编译工具
  - gcc
tags:
  - builtin_xxx
  - gcc
abbrlink: 54464
date: 2018-01-05 23:07:24
---

GCC的使用和相关特性。

<!--more-->

## 内置函数

``` C
__builtin_xxx(x)
```

>GCC includes built-in versions of many of the functions in the standard C library. The versions prefixed with `__builtin_` will always be treated as having the same meaning as the C library function even if you specify the `-fno-builtin` option.


[gcc内置函数](http://gcc.gnu.org/onlinedocs/gcc/Other-Builtins.html)


| 函数                                                    | 作用                                                     | 示例                          |
|:--------------------------------------------------------|:---------------------------------------------------------|:------------------------------|
| `void __builtin___clear_cache (void *begin, void *end)` | 刷新指令Cache (iCache), MIPS使用`synci`指令              |                               |
| `int __builtin_clz (unsigned int x)`                    | 从最高有效位开始，返回x中前导0位的数量。 如果x为0，则结果未定义 | a = __builtin_clz(5) = 29 |
| `int __builtin_popcount (unsigned int x)`               | 返回x中1的个数                                           | a = __builtin_popcount(5) = 2 |


## 编译时警告信息

```
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -g")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O3")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wl,--no-as-needed")

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -std=gnu99")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -g")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -O3")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -W")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wextra")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wno-unused")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wno-unused-parameter")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -D_GNU_SOURCE")
```
详细参数信息说明及更多的参数[Options to Request or Suppress Warnings](https://gcc.gnu.org/onlinedocs/gcc/Warning-Options.html#Warning-Options)
