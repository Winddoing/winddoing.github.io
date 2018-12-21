---
layout: post
title: '进程状态-Z:僵尸进程产生的原因'
date: '2018-12-20 17:36'
tags:
  - 进程
categories:
  - 进程
  - 进程状态
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



## 调试&&Debug




## 设计时的预防
