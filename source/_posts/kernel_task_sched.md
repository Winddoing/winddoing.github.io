---
title: 任务调度
date: 2018-01-29 23:07:24
categories: 计算机系统
tags: [task, schedule]
---

{% note info %} 调度器 {% endnote %}

多任务操作系统分为非抢占式多任务和抢占式多任务。与大多数现代操作系统一样，Linux采用的是抢占式多任务模式。这表示对CPU的占用时间由操作系统决定的，具体为操作系统中的调度器。调度器决定了什么时候停止一个进程以便让其他进程有机会运行，同时挑选出一个其他的进程开始运行

1. schedule
2. 抢占

<!--more-->

## 调度时机

>调度什么时候发生？schedule()函数什么时候被调用

调度方式：

* 主动式调度（自愿调度）
在内核中进程直接调用`schelule()`, 当进程需要等待资源而暂时停止运行时，会把进程状态置为挂起（睡眠），并主动请求调度，让出CPU。

* 被动式调度（抢占调度）
内核抢占和用户抢占

1. 用户抢占
当内核即将返回用户空间时, 内核会检查`need_resched`是否设置, 如果设置, 则调用schedule(), 此时,发生用户抢占.

2. 内核抢占
内核抢占就是指一个在内核态运行的进程, 可能在执行内核函数期间被另一个进程取代.



## 参考

1. [Linux用户抢占和内核抢占详解(概念, 实现和触发时机)--Linux进程的管理与调度(二十）)](http://blog.csdn.net/gatieme/article/details/51872618)