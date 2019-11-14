---
title: Android ANR分析
categories: Android
tags:
  - Android
abbrlink: 35493
date: 2018-02-05 23:07:24
---

>ANR是`Application Not Response`的简写就是应用没有响应。Android应用主线程卡住的时候系统会提示用户是否需要结束掉此App，这是Android系统优化用户体验的一种做法，类似的Windows系统也有类似“程序没有响应”的提示。就是**主线程无法及时响应用户输入**

```
E/ActivityManager(  373): ANR in com.android.settings (com.android.settings/.Settings)
E/ActivityManager(  373): PID: 803
E/ActivityManager(  373): Reason: Input dispatching timed out (Waiting because no window has focus but there is a focused application that may eventually add a window when it finishes starting up.)
```

<!--more-->


## 原因

1. 主线程被阻塞
2. 主线程有耗时操作,比如IO
3. 主线程异常操作比如Thread.sleep,Thread.wait
4. (Activity)应用在5秒内没有响应用户输入（例如键盘输入, 触摸屏幕等）
5. BroadcastReceiver10秒钟没有响应
6. 获取不到CPU时间片（CPU太满了）


### CPU占有率100%

```
E/ActivityManager(  373): ANR in com.android.settings (com.android.settings/.Settings)
E/ActivityManager(  373): PID: 803
E/ActivityManager(  373): Reason: Input dispatching timed out (Waiting because no window has focus but there is a focused application that may eventually add a window when it finishes starting up.)
	Load: 1.43 / 2.3 / 1.84
	//表示ANR发生之前的一段时间内的CPU使用率，并不是某一时刻的值
	CPU usage from 810ms to -13732ms ago:
	63% 803/com.android.settings: 17% user + 45% kernel / faults: 3557 minor 225 major
	55% 373/system_server: 22% user + 33% kernel / faults: 3423 minor
	...
	1% 569/android.process.acore: 0% user + 1% kernel / faults: 1 minor
	1% 777/Binder_4: 0% user + 1% kernel
100% TOTAL: 39% user + 60% kernel
```

## traces memory

```
Heap: 15% free, 1338KB/`1585KB`; 51388 objects
```
> 虚拟机堆会动态扩展，`1585KB`代表堆扩展到的大小，1338KB代表堆上使用的大小，15%是使用的百分比, 51388创建的对象数量

```
1. //Total number of allocations 170340
2. //Total bytes allocated 13MB
3. //Free memory 247KB
4. //Free memory until GC 247KB
5. //Free memory until OOME 62MB
6. //Total memory `1585KB`
7. //Max memory 64MB
```
> 1. 进程创建到现在一共创建的对象数
> 2. 进程创建到现在一共申请的内存
> 3. 不扩展堆的情况下可用的内存
> 4. 可回收的大小
> 5. 还能扩展多少内存达到Max memory
> 6. `堆扩展`后的大小
> 7. 进程最多能申请的内存


## 参考

1. [ANR机制以及问题分析](http://blog.csdn.net/tabactivity/article/details/52945343)
