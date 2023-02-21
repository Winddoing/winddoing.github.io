---
layout: post
title: 内存屏障——arm64
date: '2021-12-09 11:17'
tags:
  - arm
  - arm64
  - smb
  - 内存
categories:
  - Linux内核
abbrlink: 9a485b42
---

`内存屏障`，也称内存栅栏，内存栅障，屏障指令等， 是一类同步屏障指令，是`CPU或编译器在对内存随机访问的操作中的一个同步点`，使得此点之前的所有读写操作都执行后才可以开始执行此点之后的操作

<!--more-->

内存屏障的主要目的是为了防止指令重排引起的错误。


## 参考

- [Arm64内存屏障](https://blog.csdn.net/Roland_Sun/article/details/107468055)
- [带你了解缓存一致性协议 MESI](https://mp.weixin.qq.com/s?__biz=MzU5MTg2OTc3Ng==&mid=2247483717&idx=1&sn=41f10e428eb6ee683f3b4dd9dd025742&chksm=fe29237ac95eaa6c9492ded3258a90de4f02343a2ee56839d4cdaa58f4427f84a622ba75770b&token=1601845131&lang=zh_CN#rd)
- [内存屏障（Memory Barrier）究竟是个什么鬼？](https://zhuanlan.zhihu.com/p/125737864)
