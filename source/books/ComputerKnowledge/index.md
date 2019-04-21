---
title: 计算机相关知识
date: 2018-12-06 8:07:24
comments: true
---

{% centerquote %} 基础相关,常见的一些名词或某种说法 {% endcenterquote %}


## UPS

>`UPS`（Uninterruptible Power System/Uninterruptible Power Supply），即不间断电源，是将蓄电池（多为铅酸免维护蓄电池）与主机相连接，通过主机逆变器等模块电路将直流电转换成市电的系统设备。主要用于给单台计算机、计算机网络系统或其它电力电子设备如电磁阀、压力变送器等提供稳定、不间断的电力供应。


## PMS

> `PMS`（production management system）工程生产管理系统

> `PMS`（Plant Management System - Requirements）设备管理体系-要求


## FAE

> 英文Field Application Engineer的缩写，也叫现场技术支持工程师、售前售后服务工程师。

## 鲁棒

>鲁棒是Robust的音译，也就是健壮、强壮、坚定、粗野的意思。鲁棒性（robustness）就是系统的健壮性。它是在异常和危险情况下系统生存的关键。

## EMI/RFI/EMP

> - `EMI`:(Electromagnetic Interference ), 电磁干扰
> - `RFI`:(Radio Frequency Interference ), 射频干扰
> - `EMP`:(Electromagnetic Pulse),电磁脉冲

## ESD

> `ESD`（Electro-Static discharge）的意思是“静电释放”。国际上习惯将用于静电防护的器材统称为ESD，中文名称为静电阻抗器。

## TSC

> TSC: time stamp counter 时间戳计数器

```
static uint64_t rdtsc(void)
{
    uint64_t var;
    uint32_t hi, lo;

    __asm volatile
        ("rdtsc" : "=a" (lo), "=d" (hi));

    var = ((uint64_t)hi << 32) | lo;
    return (var);
}
```
> rdtsc指令返回的是自开机始CPU的周期数
