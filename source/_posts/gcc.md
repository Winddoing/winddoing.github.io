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


## Optimization Levels（优化等级）

启用优化会使编译器尝试以牺牲编译时间和调试程序的能力为代价来提高性能和/或代码大小。如果您使用多个`-O`选项，无论是否有级别编号，最后一个这样的选项是有效的。

默认是优化关闭。 这导致了最快的编译时间，但 GNAT 绝对不尝试优化，并且生成的程序比启用优化时更大更慢。 您可以使用 -O 开关（允许的形式是 -O0、-O1 -O2、-O3 和 -Os）到 gcc 来控制优化级别：

| 等级  | 描述  |
|:----:|:-----|
| `-O0`  | 无优化（默认）； 生成未优化的代码，但编译时间最快。请注意，即使指定了“无优化”，许多其他编译器也会进行大量优化。 对于 gcc，如果执行时间有任何问题，将 -O0 用于生产是非常不寻常的，因为 -O0 意味着（几乎）没有优化。 在进行性能比较时，应该记住 gcc 和其他编译器之间的这种差异。  |
| `-O1`  | 适度优化； 优化得相当好，但不会显着缩短编译时间。  |
| `-O2`  | 全面优化； 生成高度优化的代码并具有最慢的编译时间。 |
| `-O3`  | `-O2`的完全优化； 还使用更积极的自动内联单元内的子程序（子程序内联）并尝试矢量化循环。  |
| `-Os`  | 优化结果程序的空间使用（代码和数据）。  |

> https://gcc.gnu.org/onlinedocs/gcc-11.1.0/gnat_ugn/Optimization-Levels.html#Optimization-Levels

## Compiler Switches

> https://gcc.gnu.org/onlinedocs/gcc-11.1.0/gnat_ugn/Alphabetical-List-of-All-Switches.html#Alphabetical-List-of-All-Switches

## 参考

- [GNAT User’s Guide for Native Platforms](https://gcc.gnu.org/onlinedocs/gcc-9.4.0/gnat_ugn.pdf) --- gcc编译参数
