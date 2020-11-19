---
layout: post
title: Linux性能测试工具---Lmbench
date: '2019-01-19 14:37'
tags:
  - lmbench
categories:
  - 工具
  - 性能测试
abbrlink: 54953
---

Lmbench是一套简易，可移植的，符合ANSI/C标准为UNIX/POSIX而制定的微型测评工具。一般来说，它衡量两个关键特征：`反应时间`和`带宽`。Lmbench旨在使系统开发者深入了解关键操作的基础成本。

> 测试包括文档读写、内存操作、进程创建销毁开销、网络等性能，测试方法简单
>
> Lmbench: [http://www.bitmover.com/lmbench](http://www.bitmover.com/lmbench/)

|   带宽测评(`bw_*`)   |    <命令>    |                   反应时间测评（`lat_*`）                    | <命令> |
|:------------:|:------------:|:-------------------------------------------------:|:------:|
| 读取缓存文件 |  bw_file_rd  |                    上下文切换                     |   -    |
|   拷贝内存   | bw_mem 1M cp | 网络： 连接的建立，管道，TCP，UDP和RPC hot potato |   -    |
|    读内存    | bw_mem 1M rd |               文件系统的建立和删除                |   -    |
|    写内存    | bw_mem 1M wr |                     进程创建                      |   -    |
|     管道     |   bw_pipe    |                     信号处理                      |   -    |
|     TCP      |    bw_tcp    |                  上层的系统调用                   |   -    |
|      -       |      -       |                 内存读入反应时间                  |   lat_mem_rd   |

> `man`获取详细信息

<!--more-->

移植方便可在buildroot配置

## mhz

计算处理时钟

``` shell
# mhz
1290 MHz, 0.7752 nanosec clock
```

## tlb

获取TLB大小

``` shell
# tlb
tlb: 10 pages
```

## line

Cache line大小

``` shell
# line
64
```

## stream

测试内存带宽

``` shell
# stream
STREAM copy latency: 4.98 nanoseconds
STREAM copy bandwidth: 3213.50 MB/sec
STREAM scale latency: 6.71 nanoseconds
STREAM scale bandwidth: 2385.57 MB/sec
STREAM add latency: 10.64 nanoseconds
STREAM add bandwidth: 2256.06 MB/sec
STREAM triad latency: 12.45 nanoseconds
STREAM triad bandwidth: 1927.25 MB/sec
```

## lmdd

移动io进行性能和调试测试

``` shell
# time lmdd if=/dev/urandom of=/tmp/xxx bs=1M count=10
10.0000 MB in 1.7651 secs, 5.6653 MB/sec  #速度
real    0m 1.77s
user    0m 0.00s
sys     0m 1.77s
```

## 测试示例

### 拷贝内存

``` shell
# bw_mem 500M cp
500.00 858.05   #500M测试数据，拷贝速度858.05MB/s
```

### 内存写入反应时间

``` shell
# lat_mem_rd 1M
"stride=64     #步长，
0.00049 2.343  #写入大小，反应时间纳秒（ns）
0.00098 2.343
0.00195 2.343
0.00293 2.343
^C
```
