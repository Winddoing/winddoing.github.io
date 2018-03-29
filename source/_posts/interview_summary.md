---
title: 面试总结
date: 2018-03-28 23:07:24
categories: 随笔
tags: [面试]
password: xiaomi
---


小米
<!--more-->
## MMC

整体框架

emmc协议的初始化流程（sd，sdio），之间的不同区别差异

## I2C

协议，时序图（示波器的抓取）

驱动框架以及使用，device tree的使用

## alsa

整体结构图，工作流程

数据传输，环形buffer，实现，xrun，overrun和underrun

## OOM

OOM产生的原因：内存没了

OOM的处理流程，杀死进程，是内核态还是用户态？被杀死的进程依据是什么？

## 内存管理

* 伙伴系统
大块内存的申请，算法原理 Buddy system

* slab
小块内存（小于1page）申请
[Linux slab 分配器剖析](https://www.ibm.com/developerworks/cn/linux/l-linux-slab-allocator/)

* 页表
linux内核支持几级页表，mips cpu使用几级页表，其中寻址的原理

* cache

## 中断

* request_irq()
* request_thread_irq()

中断为什么要线程化？

提高实时性。

不能睡眠，为啥？如果睡眠会发生什么？

## 同步

* 信号量
实现，与信号的区别

* spinlock
实现，arm64，x86，mips的关键结构体，实现的原理
spinlock中不能睡眠，如果存在sleep会怎么样？中断上下文，进程上下文之前的切换区别？

* mutex
实现，作用的范围？
与spinlock的区别？

* 读写锁

用处，实现，应用场景？

## Android的启动

android启动进入桌面

## 系统的整体启动

bootram->spl->uboot->kernel->fs
