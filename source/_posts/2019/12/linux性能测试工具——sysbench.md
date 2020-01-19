---
layout: post
title: Linux性能测试工具---sysbench
date: '2019-12-17 15:22'
tags:
  - sysbench
categories:
  - 工具
  - 性能测试
abbrlink: 37666
---


Linux环境下的性能测试：

<!--more-->

## sysbench

```
sudo apt install sysbench
```

源码：

```
git clone https://github.com/akopytov/sysbench.git
```

### CPU测试

CPU的性能测试通常有：
1. 质数计算；
2. 圆周率计算.

cpu测试主要是进行`质数加法`运算, 找指定范围内最大质数**时间越短，性能越好**

``` shell
sysbench cpu run
```

``` shell
sysbench cpu --cpu-max-prime=100000 --num-threads=`grep "processor" /proc/cpuinfo | sort -u | wc -l` run
```

```
mpstat -P ALL 1
```
>间隔1s，打印当前所有CPU核的使用情况

``` shell
$sysbench cpu run
sysbench 1.0.11 (using system LuaJIT 2.1.0-beta3)

Running the test with following options:
Number of threads: 1  #指定线程数为1
Initializing random number generator from current time


Prime numbers limit: 10000 #每个线程产生的素数上限均为10000个

Initializing worker threads...

Threads started!

CPU speed:
    events per second:  1181.65 #所有线程每秒完成的event次数

General statistics:
    total time:                          10.0007s #总消耗时间
    total number of events:              11819    #event次数

Latency (ms):
         min:                                  0.78
         avg:                                  0.85
         max:                                  4.57
         95th percentile:                      0.99
         sum:                               9996.65

Threads fairness:
    events (avg/stddev):           11819.0000/0.00
    execution time (avg/stddev):   9.9967/0.00
```

## 圆周率测试

``` shell
time echo "scale=5000;4*a(1)"|bc -l -q
```
