---
layout: post
title: '进程状态-Z:僵尸进程产生的原因'
date: '2018-12-20 17:36'
tags:
  - 进程
categories:
  - 进程
  - 进程状态
abbrlink: 5718
---

`Z (zombie)`:僵死状态是一个比较特殊的状态。进程在退出的过程中，处于`TASK_DEAD`状态。
> 在这个退出过程中，进程占有的所有资源将被回收，除了task_struct结构（以及少数资源）以外。于是进程就只剩下task_struct这么个空壳，故称为僵尸。

``` shell
# ps
  PID USER       VSZ STAT COMMAND
    1 root      3100 S    init
    2 root         0 SW   [kthreadd]
    3 root         0 SW   [ksoftirqd/0]
    4 root         0 SW   [kworker/0:0]
    5 root         0 SW<  [kworker/0:0H]
    6 root         0 SW   [kworker/u8:0]
    ...
    1380 root      0 Z    [view]     #僵尸进程
    ...
    1392 root   3104 S    -/bin/sh
    1404 root      0 SW<  [kworker/2:1H]
    1429 root      0 SW<  [kworker/0:1H]
    1444 root      0 SW<  [kworker/1:1H]
```
- 僵尸进程产生的原因???
- 如何确定根本原因???
- 如何避免???

<!--more-->

## 僵尸进程产生的原因

>**僵尸进程**: 是当子进程比父进程先结束，而父进程又没有回收子进程，释放子进程占用的资源，此时子进程将成为一个僵尸进程。如果父进程先退出 ，子进程被init接管，子进程退出后init会回收其占用的相关资源

原因:
1. 子进程被直接杀死
2. 子进程无法正常关闭

场景:主进程创建的线程在进行数据搬运时,搬运数据的大小超过了放置数据buffer的大小,导致部分数据被污染,最终导致子线程在运行过程中出现段错误,将其直接杀死,没有等到父进程回收,而产生了僵尸进程.

## 调试&&Debug

- 查找子进程被杀死的原因,如,段错误可以重新定义段错误信号的处理打印部分信息.
- 排查显示fork和隐式fork,对子进程的操作.
- 子进程退出信号`signal(SIGCHLD,sig_child)`的自定义处理

## 设计时的预防

* 父进程通过wait和waitpid等函数等待子进程结束，这会导致父进程挂起。
    - 执行wait（）或waitpid（）系统调用，则子进程在终止后会立即把它在进程表中的数据返回给父进程，此时系统会立即删除该进入点。在这种情形下就不会产生defunct进程。

* 如果父进程很忙，那么可以用signal函数为SIGCHLD安装handler。在子进程结束后，父进程会收到该信号，可以在handler中调用wait回收。

* 如果父进程不关心子进程什么时候结束，那么可以用signal（SIGCLD, SIG_IGN）或signal（SIGCHLD, SIG_IGN）通知内核，自己对子进程的结束不感兴趣，那么子进程结束后，内核会回收，并不再给父进程发送信号

* fork两次，父进程fork一个子进程，然后继续工作，子进程fork一个孙进程后退出，那么孙进程被init接管，孙进程结束后，init会回收。不过子进程的回收还要自己做
