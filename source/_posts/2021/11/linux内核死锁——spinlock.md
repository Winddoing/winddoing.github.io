---
layout: post
title: linux内核spinlock死锁——两核互锁
date: '2021-11-15 09:18'
tags:
  - linux
  - spinlock
  - 死锁
categories:
  - Linux内核
abbrlink: 3099dbdc
---

``` shell
[24881.771099] BUG: spinlock wrong CPU on CPU#0, aplay/691
[24881.777642]  lock: 0xffffff8011d96348, .magic: dead4ead, .owner: aplay/691, .owner_cpu: 1
```
>软硬件环境：Linux5.4.110, arm64
>> CPU0进行上锁时，发现该锁被CPU1所持有，所以造成两核互锁

<!--more-->

以上log是在一次测试中出现的，系统打印出上述日志后直接卡死，该日志提示当前进程中的一个spinlock锁是在`CPU1核上上锁`，但是在`CPU0核上解锁`，才导致出现以上日志警告。

## 为什么会出现以上现象？


## 死锁的解决方法
