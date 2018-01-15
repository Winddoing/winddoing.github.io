---
title: double free or corruption (fasttop)
date: 2018-01-15 23:07:24
categories: 程序设计
tags: [app, free]
---

```
*** Error in `./rixitest-static-ok': double free or corruption (fasttop): 0x76e006f0 ***`
```

>在进行多线程编程的时候，可能出现`double free` 问题。主要是在多线程函数中有个对`new`出来的变量进行操作，但是未加锁同步导致的。只要在在对new变量进行读写操作之前，加个锁，就可以避免该问题的产生。

`0x76e006f0` : 多次`free`的变量地址，变量（或对象）通过`new`得到的，地址空间在堆里。
<!--more-->

## exit and _exit

>用于终止一个程序

``` C
void exit(int status);
void _exit(int status);
```
![exit_and__exit](/images/app/exit_and__exit.png)

`_exit`直接进入内核，`exit`则先执行一些清除处理（在进程退出之前要检查文件状态，将文件缓冲区中的内容写回文件）再进入内核


调用`_exit`函数时，其会关闭进程所有的文件描述符，清理内存以及其他一些内核清理函数，但不会刷新流（stdin,stdout,stderr…）.`exit`函数是在`_exit`函数之上增加了一个封装，写回文件缓存区中的内容



