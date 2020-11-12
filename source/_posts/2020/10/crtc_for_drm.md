---
layout: post
title: CRTC for drm
date: '2020-10-28 10:23'
tags:
  - GPU
  - DRM
  - CRTC
categories:
  - 设备驱动
---

`DRM`是linux下的图形渲染架构(Direct Render Manager),具体的说是显卡驱动的一种架构，为了给上层应用提供操作接口。而显卡，最基本的功能就是把用户的绘图渲染后输出到显示屏上，DRM主要是为了在软件层面实现这一目标。这里主要就包括两部分，`硬件设备`、`软件模块`

![drm](/images/2020/10/drm.png)

> `CRTC`主要负责从Framebuffer中读出待显示的图像，并按照相应的格式输出给Encoder

`CRTC`是阴极射线显像管上下文（Cathode Ray Tube Context）,作用是读取当前Framebuffer的像素数据并借助于PLL电路从其生成视频模式定时信号。

<!--more-->

![drm_layer](/images/2020/10/drm_layer.png)

DRM中`CRTC`模块主要的作用：
- 配置适合显示器的分辨率（kernel）并输出相应时序（hardware logic）
- 扫描framebuffer送显到一个或多个显示设备中
- 更新framebuffer

CRTC模块产生vbank信号进行场同步刷新



## 参考

- [DRM Driver Development For Embedded Systems](https://elinux.org/images/7/71/Elce11_dae.pdf)
- [Linux DRM（二）基本概念和特性](https://blog.csdn.net/dearsq/article/details/78394388)
- [linux drm 架构及linux drm 架构 之代码分析](https://blog.csdn.net/boyemachao/article/details/83576684)
- [关于 DRM 中 DUMB 和 PRIME 名字的由来](https://blog.csdn.net/hexiaolong2009/article/details/105961192)
- [DRM 驱动程序开发（开篇）](https://blog.csdn.net/hexiaolong2009/article/details/89810355)
