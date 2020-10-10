---
layout: post
title: linux下性能分析---bootchart
date: '2020-09-05 11:33'
categories:
  - 工具
tags:
  - bootchart
  - 性能
abbrlink: 5f89ded7
---

> `BootChart`是一个用于linux启动过程性能分析的开源软件工具，它可以在内核装载后就开始运行，记录各个程序启动占用的时间、CPU以及硬盘读写，直到系统启动完成为止。进入系统后，bootchart可以将启动时记录下的内容生成多种格式（PNG，SVG或者EPS）的图形报表，以便分析。

<!--more-->

# 一般应用运行分析

## 用perf录制系统的sched情况

``` shell
$sudo perf sched record -a
^C[ perf record: Woken up 5 times to write data ]
[ perf record: Captured and wrote 11.284 MB perf.data (87520 samples) ]
```

## 生成timechart

``` shell
$sudo perf timechart
Written 24.6 seconds of trace to output.svg.
```

使用Firefox浏览器查看生成结果：

![bootchart_sample](/images/2020/09/bootchart_sample.png)

# 系统启动时间的分析

## bootchart

**ubuntu20.04中不适用，不过使用`systemd-analyze`可以查看开机时间和耗时部分**

``` shell
sudo apt install bootchart pybootchartgui
```
>~在ubuntu20.04系统安装后(其他系统安装也可)，下次系统启动时生成一个系统启动时的各个组件启动所花的时间的记录的图表，此图表位于:`/var/log/bootchart`文件夹下。默认格式为.png格式~

## initcall_debug内核启动图

这个方法多用于嵌入式系统中，在内核命令行中添加`initcall_debug`参数，可以在`dmesg`日志中打印出每个函数调用的时间点

1. 将`dmesg`的日志保存到`boot.log`中
2. 运行内核源码中自带的`scripts/bootgraph.pl`脚本生成启动图(矢量图)
   ```
   scripts/bootgraph.pl boot.log > boot.svg
   ```
