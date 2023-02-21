---
layout: post
title: linux下性能分析---kernelshark
date: '2020-09-05 11:44'
categories:
  - 工具
  - kernelshark
tags:
  - kernelshark
  - 性能
abbrlink: 321101fe
---

Kernelshark作为trace-cmd的前端，借助图形化，灵活的filter，缩放功能，能更有效的帮助分析，高效的得到结果。它包含Ftrace以进行内部Linux内核跟踪，以分析内核中正在发生的事情。

> `trace-cmd`是设置读取`ftrace`的命令行工具，`kernelshark`既可以记录数据，也可以图形化分析结果。

<!--more-->

## 安装工具

``` shell
sudo apt install trace-cmd kernelshark
```

## trace-cmd

``` shell
git clone https://git.kernel.org/pub/scm/linux/kernel/git/rostedt/trace-cmd.git
```


## 测试

### 跟踪系统进程切换

``` shell
$sudo trace-cmd record -e 'sched_wakeup*' -e sched_switch -e 'sched_migrate*'
Hit Ctrl^C to stop recording
^C
CPU0 data recorded at offset=0x6ea000
    2752512 bytes in size
CPU1 data recorded at offset=0x98a000
    2891776 bytes in size
CPU2 data recorded at offset=0xc4c000
    2756608 bytes in size
CPU3 data recorded at offset=0xeed000
    2805760 bytes in size
```
> `CTRL+c`停止记录并保存到trace.dat中

## kernelshark来打开录制的点

``` shell
$kernelshark trace.dat
```
> 方便查看某一个进程在某一个时刻在做什么，在哪个CPU核上运行，其他的CPU核在干什么

![kernel_shark_sample](/images/2020/09/kernel_shark_sample.png)
