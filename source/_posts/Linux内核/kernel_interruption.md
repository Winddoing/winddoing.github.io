---
title: Linux内核--中断
categories:
  - Linux内核
tags:
  - 中断
abbrlink: 21246
date: 2018-02-26 23:07:24
---

中断有两种：

1. 由CPU外部产生。（被动）
2. 由CPU本身在执行程序的时候产生。（主动）


中断服务程序一般都是在中断请求关闭的条件下执行的，以避免嵌套而使中断控制复杂化。但是，中断是一个随机事件，它随时会到来，如果关中断的时间太长，CPU就不能及时响应其他的中断请求，从而造成中断的丢失。因此为了保证所有的中断都被响应，并且相对公平的执行，引入了中断下半部，主要有`tasklet`，`工作队列`，`软中断`和`线程化irq`

<!--more-->

| 条件 | tasklet |  workqueue | softirq |
| :-:  | :---:   |  :-------: | :-----:|
| 运行上下文 | 软中断 | 进程（内核态）| 软中断|
| 是否sleep|  否  | 否 | 否 |
| 是否关中断|  否  | 否 | 否 |
| 是否可重新调度| 是  | 否 | 否 |
| 是否可带参数| 是 | 否 | 否 |
| 谁被触发，谁执行 | 是 | 默认是（进程调度） | 是  |
| 可同时多CPU执行 | 同一个Tasklet在任意时刻, 只能被一个CPU执行 | 有进程调度决定 | 同一个softirq_action, 可同时被多个CPU执行 |
| 是否可延时执行 | 否 | 是 | 否 |
| 数据结构 | softirq_action(中断服务), irq_cpustat_t(触发状态) | tasklet_struct, tasklet_head | work_struct, workqueue_struct |
| 初始化 | open_softirq | tasklet_init, DECLARE_TASKLET | INIT_DELAYED_WORK |
| 改变运行状态 |   | tasklet_trylock, tasklet_unlock |  |
| 使能/停止 |  | tasklet_enable, tasklet_disable |  |
| 触发 | raise_softirq, raise_softirq_irqoff | tasklet_schedule, tasklet_hi_schedule| schedule_work, queue_work, schedule_delayed_work |
| 执行 | do_softirq | tasklet_action, tasklet_hi_action | resouer_thread被CPU调度执行 |
| 创建线程 |  |  | alloc_workqueue |
| 结束 |  | tasklet_kill | destroy_weoker, destroy_weokequeue |

## 上半部

>1. 实时性要求高
>2. 不能被中断

  上半部的功能是响应中断。当中断发生时，它就把设备驱动程序中中断处理例程的下半部挂到设备的下半部执行队列中去，然后继续等待新的中断到来


## 下半部

下半部所负责的工作一般是查看设备以获得产生中断的事件信息，并根据这些信息（一般通过读设备上的寄存器得来）进行相应的处理。

## 上半部与下半部的区分？

>下半部和上半部最大的区别是可中断，而上半部却不可中断

对于一个中断，如何划分上下两部分呢？哪些处理放在上半部，哪些处理放在下半部？

1. 如果一个任务对时间十分敏感，将其放在上半部
2. 如果一个任务和硬件有关，将其放在上半部
3. 如果一个任务要保证不被其他中断打断，将其放在上半部
4. 其他所有任务，考虑放在下半部

## 下半部的实现方式

### 软中断

linux中，执行软中断有专门的内核线程，每个处理器对应一个线程，名称`ksoftirqd/n` (n对应处理器号)

### Tasklet

### 工作队列

### 线程化irq

### 区别

1. 什么时候选择哪种方式更好？

## 参考

1. [中断处理“下半部”机制](http://blog.csdn.net/myarrow/article/details/9287169)
2. [《Linux内核设计与实现》读书笔记（八）- 中断下半部的处理](https://www.cnblogs.com/wang_yb/archive/2013/04/23/3037268.html)
