---
layout: post
title: 视频流基础知识1-PSI/SI
date: '2018-11-15 10:50'
tags:
  - 视频 PSI
categories:
  - 多媒体
  - 视频
---

在ts流转成es流的学习过程中,了解到PSI相关的基础知识在这里做一记录总结,方便以后查找和理解.

<!--more-->

## PSI/SI关键词

| 序号 | 关键字 |              全拼               |      翻译      | 备注                                                                     |
|:----:|:------:|:-------------------------------:|:--------------:|:-------------------------------------------------------------------------|
|  1   |  PSI   |  Program Specific Information   |  节目引导信息  | 对单一码流的描述                                                         |
|  2   |   SI   |       Service Information       |    业务信息    | 对系统中所有码流的描述，包含了PSI（PSI+9张表）                           |
|  3   |  TS包  |        Transport Packet         |     传输包     | 数字视音频、图文数据打包成TS包                                           |
|  4   |   TS   |        Transport Stream         | 传输流（TS流） | 一个频道（多个节目及业务）的TS包复用后称TS流                             |
|  5   |  PAT   |    Program Association Table    |   节目关联表   | 将节目号码和节目映射表PID相关联，获取数据的开始                          |
|  6   |  PMT   |        Program Map Table        |   节目映射表   | 指定一个或多个节目的PID                                                  |
|  7   |  CAT   |    Conditional Access Table     |   条件接收表   | 将一个或多个专用EMM流分别与唯一的PID相关联                               |
|  8   |  NIT   |    Network Information Table    |   网络信息表   | 描述整个网络，如多少TS流、频点和调制方式等信息                           |
|  9   |  SDT   |    Service Description Table    |   **业务**描述表   | 包含业务数据（如业务名称、起始时间、持续时间等）                         |
|  10  |  BAT   |    Bouquet Association Table    |  业务群关联表  | 给出业务群的名称及其业务列表等信息                                       |
|  11  |  EIT   |     Event Information Table     |   **事件**信息表   | 包含事件或节目相关数据，是生成EPG的主要表                                |
|  12  |  RST   |      Running Status Table       |   运行状态表   | 给出事件的状态（运行/非运行）                                            |
|  13  |  TDT   |         Time&Date Table         |  时间和日期表  | 给出当前事件和日期相关信息，更新频繁                                     |
|  14  |  TOT   |        Time Offset Table        |   时间偏移表   | 给出了当前时间日期与本地时间偏移的信息                                   |
|  15  |   ST   |         Stuffing Table          |     填充表     | 用于使现有的段无效，如在一个传输系统的边界                               |
|  16  |  SIT   |   Stuffing Information Table    |   选择信息表   | 仅用于码流片段中，如记录的一段码流，包含描述该码流片段业务信息段的地方   |
|  17  |  DIT   | Discontinuity Information Table |   间断信息表   | 仅用于码流片段，如记录的一段码流中，它将插入到码流片段业务信息间断的地方 |

> * `PAT`,`PMT`,`CAT`,`NIT`为**PSI信息**,由**MPEG2标准**定义,NIT是由**SI标准**规定
> * `SDT`,`BAT`,`EIT`,`RST`,`TDT`,`TOT`,`ST`,`SIT`,`DIT`为**SI信息**


## 业务(Service)与事件(Event)

`业务`就是指“频道”，`事件`就是“节目”.
>举个例子：CCTV1是一个频道，也就是我们所说的“业务（Service）”；《新闻联播》是一个节目，也就是我们所说的“事件(Event)”。


## SI信息的构成

>SI信息内容是按照network(网络)→transport strem（传输流）→service（业务）→event（事件）的分层顺序描述

![video_ts_SI](/images/2018/11/video_ts_si.png)

为了能有效地从众多的数据包中组织起SI信息，而使用了很多的标识。有Network_id(网络标识)、 Original_network_id(原始网络标识)、Transport_stream_id(传输流标识)、Service id(业务标识)、eventid_id(事件标识)、Bouquet_id(业务群组标识)。

* 一个网络信息由network_id来定位。
* 一个TS由network_id、Original_network_id、Transport_stream_id来定位，标明这个流在那个网络播发，它原属那个网络，并给它加上标识。
* 一个业务由network_id、Original_network_id、Transport_stream_id、service_id来定位，标明这个业务在那个网络播发，它原属那个网络和那个流，并给它加上标识。这体现在SDT表中。
* 一个事件由network_id、Original_network_id、Transport_stream_id、service_id、event_id来定位，标明这个事件在那个网络播发，它原属那个网络和那个流及那个业务，并给它加上标识。这体现在EIT表中。

### SI和SI信息的各种表的PID

|   Table    |  PID   |
|:----------:|:------:|
|    PAT     | 0x0000 |
|    CAT     | 0x0001 |
|    TSDT    | 0x0002 |
|   NIT,ST   | 0x0010 |
| SDT,BAT,ST | 0x0011 |
|   EIT,ST   | 0x0012 |
|   RST,ST   | 0x0013 |
| TDT,TOT,ST | 0x0014 |
|    DIT     | 0x001E |
|    SIT     | 0x001F |

### 表

>表是组成SI信息的一种数据结构。

由MPEG-2定义的TS里面，数据包携带了两类信息：
* 一是音、视频等素材的数据，
* 二是PSI表。

具有给定PID的数据包的有序排列就形成了TS 流。PSI表里的承载的内容主要是TS（本节目流）的描述参数。

由MPEG-2定义的PSI主要包含有三个表：`PAT`、`PMT`、`CAT`。每个表都可作为一个或多个TS包的净荷插入TS中传送。

一个TS数据包的净荷为188个字节，当一个PSI/SI表的字节长度大于184字节时，就要对这个表进行分割，形成段（section）来传送。分段机制主要是将一个数据表分割成多个数据段。在PSI/SI表到TS包的转换过程中，段起到了中介的作用。由于一个数据包只有188字节，而段的长度是可变的，EIT表的段限长4096字节，其余PSI/SI表的段限长为1024字节。因此，一个段要分成几部分插入到TS包的净荷中。
![video_ts_table](/images/2018/11/video_ts_table.png)



## 参考

* [【PSI/SI学习系列】2.PSI/SI深入学习1——预备知识](https://blog.csdn.net/kkdestiny/article/details/12993971)
* [PSI/SI解析（各种id说明）](http://blog.sina.com.cn/s/blog_a57c156801014p57.html)
