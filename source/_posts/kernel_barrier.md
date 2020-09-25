---
title: 内存屏障
categories: Linux内核
tags:
  - mem
  - barrier
abbrlink: 15089
date: 2017-12-27 23:07:24
---

>Memory barrier能够让`CPU`或`编译器`在内存访问上有序。一个Memory barrier之前的**内存访问操作必定先于其之后的完成**。

程序在运行时内存实际的访问顺序和程序代码编写的访问顺序不一定一致，这就是内存乱序访问。内存乱序访问行为出现的理由是为了提升程序运行时的性能.

Linux kernel doc: [memory-barriers](https://www.kernel.org/doc/Documentation/memory-barriers.txt)

内存乱序访问主要发生在两个阶段：

* 编译时，编译器优化导致内存乱序访问（指令重排）
* 运行时，多CPU间交互引起内存乱序访问


``` C
#define wmb()       fast_wmb()
#define rmb()       fast_rmb()
#define mb()        fast_mb()
#define iob()       fast_iob()

#  define smp_mb()  __asm__ __volatile__("sync" : : :"memory")
#  define smp_rmb() __asm__ __volatile__("sync" : : :"memory")
#  define smp_wmb() __asm__ __volatile__("sync" : : :"memory")
```
> [MIPS] file: arch/mips/include/asm/barrier.h

<!--more-->

## smp_mb

作用对象：CPU与CPU

## mb

作用对象：CPU与IO


## 参考

1. [理解 Memory barrier（内存屏障）](http://blog.csdn.net/world_hello_100/article/details/50131497)

