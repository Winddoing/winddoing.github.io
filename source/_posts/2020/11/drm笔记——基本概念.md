---
layout: post
title: DRM笔记——基本概念
date: '2020-11-13 11:20'
tags:
  - gpu
  - drm
categories:
  - 设备驱动
abbrlink: 195f15d1
---

`DRM`（Direct Rendering Manager）是linux中主流的图形显示框架，它将GPU的管理驱动和Display驱动，使得软件架构更为统一，方便管理和维护

![DRM](/images/2020/11/drm.png)

DRM主要可以分为3部分：`libdrm`、`KMS`、`GEM`

<!--more-->

## libdrm

对linux系统底层接口进行了封装，向上层通过统一的API接口，主要是将驱动的各种ioctl接口的封装

## KMS

>目的：将不同的像素缓冲区渲染到屏幕上或内存中。

Kernel Mode Setting，所谓Mode setting，其实说白了就两件事：`更新画面`和`设置显示参数`。
- 更新画面：显示buffer的切换，多图层的合成方式，以及每个图层的显示位置。
- 设置显示参数：包括分辨率、刷新率、电源状态（休眠唤醒）等。

## GEM

Graphic Execution Manager，主要负责显示buffer的分配和释放，也是GPU唯一用到DRM的地方。

## 基本元素

DRM框架涉及到的元素很多，大致如下：
KMS：`CRTC`，`ENCODER`，`CONNECTOR`，`PLANE`，`FB`，`VBLANK`，`property`
GEM：`DUMB`、`PRIME`、`fence`

## 参考

- [Linux DRM Developer's Guide](http://www.landley.net/kdocs/htmldocs/drm.html#drmIntroduction)
- [DRM（Direct Rendering Manager）学习简介](https://blog.csdn.net/hexiaolong2009/article/details/83720940)
