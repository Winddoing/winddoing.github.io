---
layout: post
title: GPU page fault
date: '2019-09-21 22:53'
tags:
  - GPU
categories:
  - 设备驱动
---

尽管许多GPU都支持页面错误，但并非所有都支持。 一些GPU使用下列方式响应内存错误：
- 位存储桶写入(bit-bucket writes)
- 读取模拟数据（如零）(reading simulated data (for example, zeros))
- 或仅挂起(by simply hanging)

<!--more-->

## 造成的现象

系统整体卡住，有时鼠标键盘无响应，但是可以通过ssh登录系统，并且测试无法kill掉xorg

## GPU页错误

>A GPU page fault commonly occurs under one of these conditions. An application mistakenly executes work on the GPU that references a deleted object. This is one of the top reasons for an unexpected device removal. An application mistakenly executes work on the GPU that accesses an evicted resource, or a non-resident tile.

 GPU 页面错误通常在下列情况之一下发生：
 - 应用程序在 GPU 上错误地执行了应用已删除的对象的作业。 这是意外删除设备的主要原因之一。
 - 应用程序错误地在 GPU 上执行了访问已逐出的资源或非驻留磁贴的作业。
 - 着色器引用未初始化的或过时的描述符。
 - 着色器索引超出根绑定末尾。



## 参考

- [Use DRED to diagnose GPU faults](https://docs.microsoft.com/en-us/windows/win32/direct3d12/use-dred)
- [使用 DRED 诊断 GPU 错误](https://docs.microsoft.com/zh-cn/windows/win32/direct3d12/use-dred)
- [[Vega10] GPU lockup on boot: VMC page fault](https://bugs.freedesktop.org/show_bug.cgi?id=105251)
- [GPU Multisplit](http://on-demand.gputechconf.com/gtc/2016/presentation/s6517-saman-ashkiani-gtc-multisplit.pdf)
- [Bug 105733 - Amdgpu randomly hangs and only ssh works. Mouse cursor moves sometimes but does nothing. Keyboard stops working. ](https://bugs.freedesktop.org/show_bug.cgi?id=105733)
- [Debugging mesa and the linux 3D graphics stack ](http://ballmerpeak.web.elte.hu/devblog/debugging-mesa-and-the-linux-3d-graphics-stack.html)
- [Debugging HyperZ and fixing a radeon drm linux kernel module ](http://ballmerpeak.web.elte.hu/devblog/debugging-hyperz-and-fixing-a-radeon-drm-linux-kernel-module.html)
