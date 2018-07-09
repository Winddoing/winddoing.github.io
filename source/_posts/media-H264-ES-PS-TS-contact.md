---
title: H264 ES PS TS流之间的联系
date: 2018-07-09 8:07:24
categories: 多媒体
tags: [H264]
---

> `ES流(Elementary Stream)`: 也叫基本码流,包含视频、音频或数据的连续码流.

> `PES流(Packet Elementary Stream)`: 也叫打包的基本码流, 是将基本的码流ES流根据需要分成长度不等的数据包, 并加上包头就形成了打包的基本码流PES流.

> `TS流(Transport Stream)`: 也叫传输流, 是由固定长度为`188字节`的包组成, 含有独立时基的一个或多个program, 一个program又可以包含多个视频、音频、和文字信息的ES流;

<!--more-->
