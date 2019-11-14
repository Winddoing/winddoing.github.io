---
title: LTP测试
categories: 计算机系统
tags:
  - LTP
  - kernel
abbrlink: 39613
date: 2017-12-21 23:07:24
---

LTP套件是由 Linux Test Project 所开发的一套系统测试套件。它基于系统资源的利用率统计开发了一个测试的组合,为系统提供足够的压力。

通过压力测试来判断系统的稳定性和可靠性。

压力测试是一种破坏性的测试,即系统在非正常的、超负荷的条件下的运行情况 。用来评估在超越最大负载的情况下系统将如何运行,是系统在正常的情况下对某种负载强度的承受能力的考验

LTP测试套件对Linux操作系统进行超长时间的测试,重点在于Linux用户环境相关的工作负荷。而并不是致力于证明缺陷。
<!--more-->

## LTP测试

测试分为两个阶段：`初始测试`，`压力测试`

### 初始测试

>是开始测试的必要条件。初始测试包括LTP测试套件在硬件和操作系统上成功运转,这些硬件和操作系统将用于可靠性运转

测试脚本：

``` shell
runalltests.sh(或runltp)
```
>runltp默认执行的内容与runalltests相同


``` shell
cd usr; ./runltp
```
>详细使用见：[LTP使用说明](/doc/LTP使用说明.doc)

## 测试单元

``` shell
cd /usr; ./runltp -f crashme
```

### crashme

对系统的极端测试

| 测试项 | 说明 |
| :--:  | :--: |
| f00f	| x86测试	|
| crash01 | 生成随机指令进行执行， 申请一块空间写随机值后，将PC跳转至此进行执行，并判断执行结果, 由于指令随机生成可能导致相同卡死，就看相同是否足够强壮，（同时也可能存成内存的泄露） |
| crash02 |	随机进行系统调用（0～127）， 并且系统调用的所有参数全是随机值， 由于随机的系统调用可以进行内存分配，而不会释放，也可能存在内存泄露|
| mem01 | 根据系统中可以内存的大小，随机或线性申请内存，别填充释放	|
| fork12 | 尽可能的fork子进程，目的是耗尽系统的pid号，主要冲突是pid_max和内存容量|


## mm

### max_map_count

```
# cat /proc/sys/vm/max_map_count
65530
```
>限制一个进程所拥有的最大内存区域(64MB)

### min_free_kbytes

```
# cat /proc/sys/vm/min_free_kbytes
1961
```
>表示系统所保留空闲内存的最低限

### 压力测试

>验证产品在系统高使用率时的健壮性。

## 参考

1. [LTP--linux稳定性测试,性能测试和压力测试](http://blog.csdn.net/trochiluses/article/details/10061513)
2. [测试 Linux 的可靠性](https://www.ibm.com/developerworks/cn/linux/l-rel/)
3. [Building a Robust Linux kernel piggybacking The Linux Test Project
](http://ltp.sourceforge.net/documentation/technical_papers/ltp-ols-2008-paper.pdf)
4. [[kernel]----理解kswapd的低水位min_free_kbytes](https://www.cnblogs.com/muahao/p/6532527.html)
