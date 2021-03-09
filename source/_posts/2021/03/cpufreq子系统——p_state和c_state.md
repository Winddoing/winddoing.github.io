---
layout: post
title: 电源管理——P-State和C-State
date: '2021-03-09 19:56'
tags:
  - power
  - linux
  - kernel
categories:
  - Linux内核
---

CPU电源状态：`C-state`(CPU Power states）)
CPU性能状态：`P-state`(CPU Performance states)

>  The concepts of C/P-states originally come from  ACPI (Advanced Configuration and Power Interface) specification, Cx talk about processor sleep status, while P about running status. please check wiki for more details:

<!--more-->
## C-state

C-state有C0，C1...Cn多种模式，但只有`C0`是正常工作模式（active），其他方式都是idle状态，只是idle的程度不同，`C后的数越高，CPU睡眠得越深，CPU的功耗被降低得越多`，同时需要更多的时间回到C0模式

### C1状态（挂起）
- 可以通过执行汇编指令“HLT（挂起）”进入这一状态
- 唤醒时间超快！（快到只需10纳秒！）
- 可以节省70%的CPU功耗
- 所有现代处理器都必须支持这一功耗状态

### C2状态（停止允许）
- 处理器时钟频率和I/O缓冲被停止
- 换言之，处理器执行引擎和I/0缓冲已经没有时钟频率
- 在C2状态下也可以节约70%的CPU和平台能耗
- 从C2切换到C0状态需要100纳秒以上

### C3状态（深度睡眠）
- 总线频率和PLL均被锁定
- 在多核心系统下，缓存无效
- 在单核心系统下，内存被关闭，但缓存仍有效
- 可以节省70%的CPU功耗，但平台功耗比C2状态下大一些
- 唤醒时间需要50微妙

### C4状态（更深度睡眠）
- 与C3相似，但有两大区别
- 一是核心电压低于1.0V
- 二是二级缓存内的数据存储将有所减少
- 可以节约98%的CPU最大功耗
- 唤醒时间比较慢，但不超过1秒

### C5状态
- 二级缓存的数据被减为零
- 唤醒时间超过200微妙

### C6状态
- 这是Penryn处理器中新增的功耗管理模式
- 二级缓存减至零后，CPU的核心电压更低
- 不保存CPU context
- 功耗未知，应该接近零
- 唤醒时间未知



## 参考

- [linux电源管理——C-state,P-state,turbo分析](http://blog.chinaunix.net/uid-28541347-id-5822288.html)
- [关于CPU C-States 省电模式，你需要知道的事情](http://blog.chinaunix.net/uid-25871104-id-3072582.html)
