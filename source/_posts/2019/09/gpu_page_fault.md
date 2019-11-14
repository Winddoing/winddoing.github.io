---
layout: post
title: GPU page fault
date: '2019-09-21 22:53'
tags:
  - GPU
categories:
  - 设备驱动
abbrlink: 793
---

尽管许多GPU都支持页面错误，但并非所有都支持。 一些GPU使用下列方式响应内存错误：
- 位存储桶写入(bit-bucket writes)
- 读取模拟数据（如零）(reading simulated data (for example, zeros))
- 或仅挂起(by simply hanging)

<!--more-->

```
[  712.873530] amdgpu 0001:01:00.0: GPU fault detected: 146 0x0218082c
[  712.878462] pcieport 0001:00:00.0: AER: Multiple Corrected error received: id=0000
[  712.878469] pcieport 0001:00:00.0: PCIe Bus Error: severity=Corrected, type=Physical Layer, id=0000(Receiver ID)
[  712.878471] pcieport 0001:00:00.0:   device [1def:e006] error status/mask=00000001/00002000
[  712.878472] pcieport 0001:00:00.0:    [ 0] Receiver Error         (First)
[  712.912617] amdgpu 0001:01:00.0:   VM_CONTEXT1_PROTECTION_FAULT_ADDR   0x00101043
[  712.920085] amdgpu 0001:01:00.0:   VM_CONTEXT1_PROTECTION_FAULT_STATUS 0x0400802C
[  712.927554] amdgpu 0001:01:00.0: VM fault (0x2c, vmid 2) at page 1052739, read from 'TC2' (0x54433200) (8)
[  712.937273] amdgpu 0001:01:00.0: GPU fault detected: 146 0x03403d0c
[  712.943527] amdgpu 0001:01:00.0:   VM_CONTEXT1_PROTECTION_FAULT_ADDR   0x00101468
[  712.950995] amdgpu 0001:01:00.0:   VM_CONTEXT1_PROTECTION_FAULT_STATUS 0x0403D00C
[  712.958463] amdgpu 0001:01:00.0: VM fault (0x0c, vmid 2) at page 1053800, read from 'SDM1' (0x53444d31) (61)
[  712.968329] amdgpu 0001:01:00.0: GPU fault detected: 146 0x03a0770c
[  712.974582] amdgpu 0001:01:00.0:   VM_CONTEXT1_PROTECTION_FAULT_ADDR   0x00101474
[  712.982050] amdgpu 0001:01:00.0:   VM_CONTEXT1_PROTECTION_FAULT_STATUS 0x0A07700C
[  712.989519] amdgpu 0001:01:00.0: VM fault (0x0c, vmid 5) at page 1053812, read from 'SDM0' (0x53444d30) (119)
```

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
