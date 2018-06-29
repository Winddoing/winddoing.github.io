---
title: 【转】网络库libevent、libev、libuv对比
date: 2018-06-29 8:07:24
categories: 网络
tags: [事件, lib]
---

地址：https://blog.csdn.net/lijinqi1987/article/details/71214974

>三者都是*异步事件库（Asynchronous event library）。

## 异步事件库

1. 异步事件通知
2. 可移植

异步事件库本质上是提供异步事件通知（Asynchronous Event Notification，AEN）的。可移植（Portable）、可扩展（Scalable）这些特性只是为了使库更通用、易用，并非必须。

### 异步事件通知

异步事件通知机制就是根据发生的事件，调用相应的回调函数进行处理。

1. 事件（Event）：事件是异步事件通知机制的核心，比如fd事件、超时事件、信号事件、
定时器事件。有时候也称事件为事件处理器（Event Handler），这个名称更形象，因为Handler本身表示了包含处理所需数据（或数据的地址）和处理的方法（回调函数），更像是面向对象思想中的称谓。
   * 数据（Data）：提供给回调函数的输入数据，可以是实际的数据，也可以指针，为了提供统一的API，一般为 void * 指针。
   * 回调函数（Callback Function）：事件发生时调用的方法。注意回调只是一种机制，跟异步没有太大关系，同步也可以采用回调机制（API）。
2. 事件循环（Event Loop）：等待并分发事件。事件循环用于管理事件。   

对于应用程序来说，这些只是异步事件库提供的API，封装了异步事件库跟操作系统的交互，异步事件库会选择一种操作系统提供的机制来实现某一种事件，比如利用Unix/Linux平台的epoll机制实现网络IO事件，在同时存在多种机制可以利用时，异步事件库会采用最优机制。

<!--more-->
## 事件

### 事件种类

| type | libevent | libev | libuv |
|:---------|:-------|:--------|:-------|
| IO | fd | io | fs_event |
| 计时器（mono clock）| timer | timer | timter |
| 计时器（wall clock）| -- | periodic | -- |
| 信号 | signal | signal | signal |
| 进程控制 | -- | child | process |
| 文件stat | -- | stat | fs_poll |
| 每次循环都会执行的Idle事件 | -- |idle | idle |
| 循环block之前执行 | -- | prepare | prepare |
| 循环blcck之后执行 | -- | check | check |
| 嵌套loop | -- | embed | -- |
| fork | -- | fork | -- |
| loop销毁之前的清理工作 | -- | cleanup | -- |
| 操作另一个线程中的loop | -- | async | async |
| 双向通信 | -- | -- | stream ( tcp, pipe, tty ) |

这个对比对于libev和libuv更有意义，对于libevent，很多都是跟其设计思想有关的。
libev中的embed很少用，libuv没有也没关系；cleanup完全可以用libuv中的async_exit来替代；libuv没有fork事件。

### 优先级

在libevent中，激活的事件是组织在优先级队列中的，各类事件默认的优先级是相同的，可以通过设置事件的优先级使其优先被处理。

libev也通过优先级队列来管理激活的时间，也可以设置事件的优先级。

libuv没有优先级的概念，而是按照固定的顺序访问各类事件。

### 事件循环

#### 略有不同

对于事件循环，libev和libuv是相同的，即管理事件（等待并分发事件）。

但是在libevent里还有一个概念是event\_base，是用于管理事件的，而lievent中的loop只是一个执行过程（仅仅是函数），并非一个实体（数据和函数）。

> Before you can use any interesting Libevent function, you need to allocate one or more event\_base structures. Each event\_base structure holds a set of events and can poll to determine which events are active.

> If an event\_base is set up to use locking, it is safe to access it between multiple threads. Its loop can only be run in a single thread, however. If you want to have multiple threads polling for IO, you need to have an event\_base for each thread.

> Tip

> [A future version of Libevent may have support for event\_bases that run events across multiple threads.]

根据官网的介绍（不考虑其中提到的特殊版本），并对照源码中event\_base\_loop的实现

``` c
int
event_base_loop(struct event_base *base, int flags)
{
	...

	/* Grab the lock.  We will release it inside evsel.dispatch, and again
	* as we invoke user callbacks. */
	EVBASE_ACQUIRE_LOCK(base, th_base_lock);

	if (base->running_loop) {
	event_warnx("%s: reentrant invocation.  Only one event_base_loop"
	    " can run on each event_base at once.", __func__);
	EVBASE_RELEASE_LOCK(base, th_base_lock);
	return -1;
	}

	...

	done:
	clear_time_cache(base);
	base->running_loop = 0;

	EVBASE_RELEASE_LOCK(base, th_base_lock);

	...
}
```

在loop执行过程中，传入的base已被加锁，是不能用于其他执行过程的。

所以基本上libev和libuv里的loop相当于libevent中的loop函数和event\_base的结合。

下文中提到的loop仅指libev和libuv中的loop。

## 线程安全

libevent、libev、libuv里的event\_base和loop都不是线程安全的，也就是说一个event\_base或loop实例只能在用户的一个线程内访问（一般是主线程），注册到event\_base或loop的event都是串行访问的，即每个执行过程中，会按照优先级顺序访问已经激活的事件，执行其回调函数。所以在仅使用一个event\_base或loop的情况下，回调函数的执行不存在并行关系。

如果应用程序除了主loop外，没有自己启动任何线程，那么不用担心回调里的“临界区”。

如果使用了多个event_base或loop（一般每个线程一个event_base或loop），需要考虑共享数据的同步问题。

## 可移植

### 支持的操作系统

三个库都支持Linux, *BSD, Mac OS X, Solaris, Windows

| type | libevent | libev | libuv |
|:---------|:-------|:--------|:-------|
| dev/poll (Solaris) | y | y | y |
| event ports | y | y | y |
| kqueue (*BSD) | y | y | y |
| POSIX select | y | y | y |
| Windows select | y | y | y |
| Windows IOCP | y | N | y |
| poll | y | y | y |
| epoll | y | y | y |

对于Unix/Linux平台，没有什么大不同，优先选择epoll，对于windows，libevent、libev都使用select检测和分发事件（不I/O），libuv在windows下使用IOCP。libevent有一个socket handle, 在windows上使用IOCP进行读写。libev没有类似的。但是libevent的IOCP支持也不是很好（性能不高）。所以如果是在windows平台下，使用原生的IOCP进行I/O，或者使用libuv。


## 异步架构程序设计原则

1. 回调函数不可以执行过长时间，因为一个loop中可能包含其他事件，尤其是会影响一些准确度要求比较高的timer。
2. 尽量采用库中所缓存的时间，有时候需要根据时间差来执行timeout之类的操作。当然能够利用库中的timer最好。
