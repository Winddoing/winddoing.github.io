---
layout: post
title: H265编码—Profile、Level、Tier
date: '2022-09-02 10:28'
tags:
  - h265
categories:
  - 多媒体
  - H265
abbrlink: '46234127'
---

在H265中的Profile和Level参数表示的含义与H264中类似。

为了提供不同应用之间的兼容互通，HEVC/H265定义了不同的编码`Profile`(档次)、`Level`(水平)、`Tier`(等级)

## Profile、Level、Tier三者的关系

- `Profile`规定了码流中使用了哪些编码工具和算法
- `Level`中规定了对给定 Profile、Tier所对应的解码器处理负担和存储容量参数，主要包括采样率、分辨率、码率的最大值、压缩率的最小值、解码图像缓存区的容量(DPB)、编码图像缓存区的容量(CPB)等。
- `Tier`规定了每个水平的码率的高低。

<!--more-->

## Profile

常用的三个Main profile，即常规8bit像素精度的`Main profile`，支持10bit像素精度的`Main 10 profile`和支持静止图像的`Main Still Picture profile`。

HEVC的*第一个版本*定义了三个配置文件：
- `Main Profile`:
- `Main 10 Profile`:
- `Main Still Picture Profile`:

![H265 Profile](/images/2022/09/h265_profile.png)


## Level


![h265 level limits](/images/2022/09/h265_level_limits.png)


### 计算方法

比如分辨率: `1920x1080`, 参考帧率:`60` 的h265码流是哪个level呢?

H.265的亮度(luma)图像的大小计算公式为:
- samples =  width  *  height

计算得：1920*1080=2073600

每秒亮度采样数量为每帧samples乘以帧率.
- samples/s =samples*参考帧率

计算得： 2073600*60=124416000

参考*Rec. ITU-T H.265 v8 (08/2021) 266页*查表(或上图)，得`1920x1080@60fps`的level应为`4.1`


## 参考

- [T-REC-H.265-202108-I!!PDF-E.pdf](https://www.itu.int/rec/dologin_pub.asp?lang=e&id=T-REC-H.265-202108-I!!PDF-E&type=items) —— pdf
