---
layout: post
title: linux性能测试——load average
date: '2021-03-16 09:52'
tags:
  - linux
  - cpu
categories:
  - 工具
  - 性能测试
abbrlink: 4d1d787a
---

`uptime`和`top`等命令都可以看到`load average`指标，从左至右三个数字分别表示`1分钟`、`5分钟`、`15分钟`的load average：
``` shell
# uptime
 09:52:13 up 20:03, 14 users,  load average: 48.59, 46.08, 46.00
```
> 判断一个系统负载是否偏高需要计算单核CPU的平均负载，等于这里uptime命令显示的系统平均负载/CPU核数，一般以0.7为比较合适的值, 偏高说明有比较多的进程在等待使用CPU资源。
> 除了等待运行的进程还有不可中断的线程

<!--more-->
## 系统负载

- 系统负载度量旨在将系统“资源需求”表示为一个数字。 在经典Unix上，它仅计算对CPU的需求（处于Runnable状态的线程）
- 系统负载度量的单位是“进程/线程数”（或在Linux上称为调度单位的任务）。 平均负载是一个时间段（最后1,5,15分钟）内平均线程数，该时间段在经典unix上“竞争CPU”或在Linux上“竞争CPU或以不间断的睡眠状态等待”
- 可运行状态表示“不受任何阻止”，可以在CPU上运行。 该线程当前正在CPU上运行，或者在CPU运行队列中等待OS调度程序将其放到CPU上
- 在Linux上，系统负载包括处于`Runnable（R）`和处于`Uninterruptible sleep（D）`状态的线程（通常是磁盘I/O，但并非总是如此）


 当前系统负载只是Linux上处于R或D状态的线程（称为任务）的数量。 我们可以运行ps列出这些状态下的当前线程数：
 ``` shell
 # ps -eo s,user | grep ^[RD] | sort | uniq -c | sort -nbr | head -20
      3 R root
      1 D root
 ```


## 参考

- [High System Load with Low CPU Utilization on Linux?](https://tanelpoder.com/posts/high-system-load-low-cpu-utilization-on-linux/)
