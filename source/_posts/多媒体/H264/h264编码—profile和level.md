---
layout: post
title: H264编码—profile和level
date: '2022-09-01 10:15'
tags:
  - h264
categories:
  - 多媒体
  - H264
abbrlink: e114a1a8
---


H.264有四种画质级别,分别是`baseline`, `extended`, `main`, `high`：
- baseline profile：基本画质。支持I/P 帧，只支持无交错（Progressive）和CAVLC
- extended profile：进阶画质。支持I/P/B/SP/SI 帧，只支持无交错（Progressive）和CAVLC；(用的少)
- main profile：主流画质。提供I/P/B 帧，支持无交错（Progressive）和交错（Interlaced），也支持CAVLC和CABAC的支持
- high profile：高级画质。在main profile的基础上增加了8x8内部预测、自定义量化、无损视频编码和更多的YUV格式

H.264 baseline profile、extended profile和main profile都是针对`8位`样本数据、4:2:0格式(YUV)的视频序列。在相同配置情况下，high profile（HP）可以比main profile（MP降低10%的码率

<!--more-->

- `profile`: 规定了一个算法特征和限制的子集，任何遵守某个profile的解码器都应该支持与其相应的子集,是对*视频压缩特性的描述*（CABAC、颜色采样数等）
- `level`: 规定了一组对标准中语法成员（syntax element）所采用的各种参数值的限制，对*视频本身特性的描述*(fps(帧率)、码率、分辨率)
> 总的来说就是，profile越高，说明采用了越高级的压缩特性；level越高，说明视频的帧率、码率、分辨率越高

## profile

![h264 profile](/images/2022/09/h264_profile.png)
- Baseline Profile (BP)：主要用于计算资源有限的低成本应用程序，此配置文件广泛用于视频会议和移动应用程序。
- Main Profile (MP)：最初打算作为广播和存储应用程序的主流消费者配置文件，当为这些应用程序开发 High profile 时，此配置文件的重要性逐渐消失。
- Extended Profile (XP)：旨在作为流视频配置文件，此配置文件具有相对较高的压缩能力和一些额外的技巧，以提高数据丢失和服务器流切换的鲁棒性。
- High Profile (HiP)：广播和光盘存储应用程序的主要配置文件，尤其是高清电视应用程序（例如，HD DVD 和蓝光光盘采用的配置文件）。
- High 10 Profile (Hi10P)： 超越当今的主流消费产品功能，此配置文件建立在 High Profile 之上——增加了对解码图像精度的每个样本高达10位的支持。
- High 4:2:2 Profile (Hi422P)：主要针对使用隔行视频的专业应用程序，此配置文件建立在High 10 Profile之上——增加了对4:2:2色度子采样格式的支持，同时使用多达10位每个解码图像精度的样本。
- High 4:4:4 Predictive Profile (Hi444PP)：此配置文件建立在高 4:2:2 配置文件之上——支持高达 4:4:4 色度采样，每个样本高达 14 位，此外还支持高效无损区域编码和将每张图片编码为三个独立的颜色平面。


## level

![h264 level](/images/2022/09/h264_level.png)

level的计算方法：
比如分辨率:`1920x1080`, 参考帧率:`60` 的h264码流是哪个level呢

H.264的宏块大小为`16×16` in H.264,每帧宏块的个数为分辨率除以16

- max-fs = ceil( width / 16.0 ) * ceil( height / 16.0 )

计算得:8100

每秒宏块数量为每帧宏块数乘以帧率.

- max-mbps =max-fs*参考帧率(60)

计算得:486000

![h264 level limits](/images/2022/09/h264_level_limits.png)
> T-REC-H.264-202108-I!!PDF-E.pdf

因此对比表上的数据`1920x1080@60fps`，level应该选择`4.2`

## 编解码

在编解码的过程中，level的值直接关系到编解码器内部buffer的申请大小，因此不同的level关系到内存空间的申请大小和消耗时间。

在相同的profile下，不同的level配置，level越大码流越大，也就跟耗资源。


## 参考

- [H.264 profiles and levels](http://blog.mediacoderhq.com/h264-profiles-and-levels/)
- [T-REC-H.264-202108-I!!PDF-E.pdf](https://www.itu.int/rec/dologin_pub.asp?lang=e&id=T-REC-H.264-202108-I!!PDF-E&type=items) — pdf
