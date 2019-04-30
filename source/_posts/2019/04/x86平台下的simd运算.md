---
layout: post
title: X86平台下的SIMD运算
date: '2019-04-30 17:52'
tags:
  - SIMD
categories:
  - 程序设计
  - 性能
---

```
#include <xmmintrin.h>
#include <immintrin.h>     
#include <emmintrin.h>     
```

<!--more-->

SSE2、XMM关系？？

## 参考

* [SSE2 Intrinsics各函数介绍](https://blog.csdn.net/fengbingchun/article/details/18460199)
* [GCC中SIMD指令的应用方法](https://www.ibm.com/developerworks/cn/linux/l-gccsimd)
* [mmintrin.h与MMX指令集 Intrinsics函数](https://blog.csdn.net/u014713819/article/details/38433879)
* [SIMD指令初学](https://blog.csdn.net/tercel_zhang/article/details/80694573)
* [An evaluation of the automatic generation of parallel X86 SIMD](https://www.cri.ensmp.fr/classement/doc/E-272.pdf)
