---
layout: post
title: linux kernel之NMI
date: '2021-02-23 16:28'
tags:
  - kernel
  - nmi
categories:
  - Linux内核
abbrlink: 98e04b95
---

`NMI`(non-maskable interrupt)，即非可屏蔽中断。即使在内核代码中设置了屏蔽所有中断的时候，NMI也是不可以被屏蔽的。根据Intel的Software Developer手册Volume 3，NMI可由以下两种方式触发：

- 外部assert了CPU的NMI引脚
- CPU从系统总线收到了一个中断请求并且delivery mode是NMI

<!--more-->

1. 无法恢复的硬件错误通常包括：芯片错误、内存ECC校验错、总线数据损坏等等。
2. 当系统挂起，失去响应的时候，可以人工触发NMI，使系统重置，如果早已配置好了kdump，那么会保存crash dump以供分析。有的服务器提供了NMI按钮，而刀片服务器通常不提供按钮，但可以用iLO命令触发。
3. Linux还提供一种称为”NMI watchdog“的机制，用于检测系统是否失去响应（也称为lockup），可以配置为在发生lockup时自动触发panic。原理是周期性地生成NMI，由NMI handler检查hrtimer中断的发生次数，如果一定时间内这个数字停顿了，表示系统失去了响应，于是调用panic例程。NMI watchdog的开关是通过内核参数`kernel.nmi_watchdog`或者在boot parameter中加入`”nmi_watchdog=1″`参数实现，比如：

在centos上编辑`/boot/grub2/grub.cfg`:
```
...
kernel /vmlinuz-2.6.18-128.el5 ro root=/dev/sda nmi_watchdog=1
...
```

命令行设置：
``` shell
sysctl kernel.nmi_watchdog=1
```

## NMI中断的生成

- perf性能优化工具使用时，生成大量的NMI中断

> Run the 'perf' tool in a mode (top or record) that generates many frequent performance monitoring non-maskable interrupts (see "NMI" in /proc/interrupts).  This exercises the NMI entry/exit code which is known to trigger bugs in code paths that did not expect to be interrupted, including nested NMIs.  Using "-c" boosts the rate of NMIs, and using two -c with separate counters encourages nested NMIs and less deterministic behavior.
``` shell
while true; do perf record -c 10000 -e instructions,cycles -a sleep 10; done
```

## 参考

- [Non Maskable Interrupt](https://wiki.osdev.org/Non_Maskable_Interrupt)
- [The x86 NMI iret problem](https://lwn.net/Articles/484932/)
- [linux 内核笔记之watchdog](https://blog.csdn.net/yhb1047818384/article/details/70833825)
- [NMI是什么](http://linuxperf.com/?p=72)
- [Linux内核对x86平台NMI中断的处理](http://blog.bytemem.com/post/linux-kernel-nmi-handler-x86)
- [NMI Trace Events](https://www.kernel.org/doc/html/latest/trace/events-nmi.html)
