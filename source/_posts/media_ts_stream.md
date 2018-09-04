---
title: TS流
date: 2018-07-16 8:07:24
categories: 多媒体
tags: [TS]
---

TS流

<!--more-->

![TS](/images/media/TS.svg)

## 数据结构

``` C
// Transport packet header
typedef struct TS_packet_header
{
    unsigned sync_byte                        : 8;
    unsigned transport_error_indicator        : 1;
    unsigned payload_unit_start_indicator    : 1;
    unsigned transport_priority                : 1;
    unsigned PID                            : 13;
    unsigned transport_scrambling_control    : 2;
    unsigned adaption_field_control            : 2;
    unsigned continuity_counter                : 4;
} TS_packet_header;
```

>TS包的标识(即sync_byte)为`0x47`，并且为了确保这个TS包里的数据有效，所以我们一开始查找`47 40 00`这三组16进制数
