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
  - ARM
---

`内存屏障`，也称内存栅栏，内存栅障，屏障指令等， 是一类同步屏障指令，是`CPU或编译器在对内存随机访问的操作中的一个同步点`，使得此点之前的所有读写操作都执行后才可以开始执行此点之后的操作

<!--more-->


## 参考

- [Arm64内存屏障](https://blog.csdn.net/Roland_Sun/article/details/107468055)
