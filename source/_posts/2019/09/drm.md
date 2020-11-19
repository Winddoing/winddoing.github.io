---
layout: post
title: DRM
date: '2019-09-20 23:40'
tags:
  - drm
categories:
  - 设备驱动
abbrlink: 16573
---

显卡驱动相关：

<!--more-->

## GEM (Graphics Execution Manager)


## TTM (Translation Table Manager)

>  To this end, the TTM layer provides "fence" objects. A fence is a special operation which is placed into the GPU's command FIFO. When the fence is executed, it raises a signal to indicate that all instructions enqueued before the fence have now been executed, and that the GPU will no longer be accessing any associated buffers. How the signaling works is very much dependent on the GPU; it could raise an interrupt or simply write a value to a special memory location. When a fence signals, any associated buffers are marked as no longer being referenced by the GPU, and any interested user-space processes are notified.
> https://lwn.net/Articles/257417/

TTM层提供“fence”对象。fence是一种特殊的操作，被放置在GPU的命令FIFO中。当执行fence时，它会发出一个信号，指示现已执行fence之前排队的所有指令，并且GPU将不再访问任何关联的缓冲区。信号的工作方式在很大程度上取决于GPU。它可能会引发中断，或者只是将值写入特殊的存储位置。当fenc发出信号时，所有关联的缓冲区都将标记为不再被GPU引用，并且会通知任何感兴趣的用户空间进程。


## 参考

- [Linux DRM Developer's Guide](http://www.landley.net/kdocs/htmldocs/drm.html#drmIntroduction)
- [GEM v. TTM](https://lwn.net/Articles/283793/)
