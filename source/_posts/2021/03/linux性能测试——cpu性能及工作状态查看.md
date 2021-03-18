---
layout: post
title: Linux性能测试——CPU性能及工作状态
date: '2021-03-05 16:36'
tags:
  - linux
  - cpu
categories:
  - 工具
  - 性能测试
---

Linux下查看系统状态的一些命令`mpstat`、`vmstat`、`iostat`、`sar`、`top`、`pidstat`、`pstack`

![Linux Performance Tools](/images/2021/03/linux_observability_tools.png)

<!--more-->

## 衡量CPU性能的指标

1. 用户使用CPU
 - CPU运行实时进程
 - CPU运行niced process
 - CPU运行常规用户进程
2. 系统使用CPU
 - 用于I/O管理：中断和驱动
 - 用于内存管理：页面交换
 - 用于进程管理：进程开始和上下文切换
3. WIO：用于进程等待磁盘I/O而使CPU处于空闲状态的比率。
4. CPU的空闲率，除了上面的WIO以外的空闲时间
5. CPU用于上下文交换的比率
6. nice
7. real-time
8. 运行进程队列的长度
9. 平均负载

## Linux常用监控CPU整体性能的工具

- `mpstat`： mpstat不但能查看所有CPU的平均信息，还能查看指定CPU的信息,以及中断利用率
- `vmstat`：只能查看所有CPU的平均信息；查看cpu队列信息；
- `iostat`: 只能查看所有CPU的平均信息。
- `sar`： 与mpstat 一样，不但能查看CPU的平均信息，还能查看指定CPU的信息。
- `top`：显示的信息同ps接近，但是top可以了解到CPU消耗，可以根据用户指定的时间来更新显示。
- `pidstat`:用于监控全部或指定进程的cpu、内存、线程、设备IO等系统资源的占用情况,`-w`可以查看每个进程的上下文切换情况。
- `pstack`：显示每个进程的栈跟踪，可以确定进程挂起的位置。此命令允许使用的唯一选项是要检查的进程的PID。


## 参考

- [linux CPU性能及工作状态查看指令](https://blog.csdn.net/z1134145881/article/details/52089698)
- [Linux Performance](http://www.brendangregg.com/linuxperf.html)
