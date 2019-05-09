---
title: GCC
date: 2018-01-05T23:07:24.000Z
categories:
  - 编译工具
  - gcc
tags:
  - builtin_xxx
  - gcc
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
