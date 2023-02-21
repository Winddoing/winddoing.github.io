---
title: jiffies && HZ
categories:
  - Linux内核
tags:
  - kernel
  - time
abbrlink: 33522
date: 2017-12-25 23:07:24
---

## jiffies

全局变量`jiffies`用来记录自系统启动以来产生的节拍的总数。启动时，内核将该变量初始化为0，此后，每次时钟中断处理程序都会增加该变量的(jiffies是记录着从电脑开机到现在总共的时钟中断次数),一秒内时钟中断的次数等于Hz，所以jiffies一秒内增加的值也就是Hz。系统运行时间以秒为单位，等于i`jiffies/Hz`。

**注意**: jiffies类型为`无符号长整型(unsigned long)`，其他任何类型存放它都不正确。


* 将以秒为单位的时间转化为jiffies： seconds * Hz (jiffies)
* 将jiffies转化为以秒为单位的时间： jiffies / Hz (s)

## HZ

LINUX系统时钟频率是一个常数HZ来决定的， 通常`HZ＝100`，那么他的精度度就是10ms（毫秒）。也就是说每10ms一次中断。

<!--more-->

## 接口

### 时间比较

```
time_after(a,b)
time_before(a,b)
time_after_eq(a,b)
time_before_eq(a,b)
time_in_range(a,b,c)
```

### 时间转换

jiffies和msecs以及usecs的转换：
```
unsigned int jiffies_to_msecs(const unsigned long);
unsigned int jiffies_to_usecs(const unsigned long);
unsigned long msecs_to_jiffies(const unsigned int m);
unsigned long usecs_to_jiffies(const unsigned int u);
```

## 实例

1. watchdog_timeo = 2 * HZ;

将2s转换为jiffies, 设定2s延时。

2. mod_timer(&host->timer, jiffies + 10 * HZ);

设定10s的定时时间。

