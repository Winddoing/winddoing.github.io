---
title: GCC
date: 2018-01-5 23:07:24
categories: 常用工具 
tags: [Linux, gcc]
---

GCC的使用和相关特性。

<!--more-->

## 内置函数

``` C
__builtin_xxx(x)  
```

>GCC includes built-in versions of many of the functions in the standard C library. The versions prefixed with `__builtin_` will always be treated as having the same meaning as the C library function even if you specify the `-fno-builtin` option. 


[gcc内置函数](http://gcc.gnu.org/onlinedocs/gcc/Other-Builtins.html)


|			函数			|			 作用             |
| :-----------------------:	| :------------------------:  |
| __builtin___clear_cache	|  刷新指令Cache (iCache), MIPS使用`synci`指令  |




