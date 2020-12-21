---
layout: post
title: OpenGL Frame Buffer
date: '2020-12-21 22:57'
tags:
  - opengl
categories:
  - 多媒体
  - OpenGL
---

OpenGL中`Frame Buffer`包含多种不同类型的buffer,主要有`ColorBuffers`,`Z buffer`, `double-buffer`

<!--more-->

## double-buffer

> `Front buffer` = what is being shown on screen (the last frame)
> `Back buffer` = where you're currently drawing (the current frame)

## Z buffer

Z-buffer也称为Depth Buffer存储fragment的深度，即离视点的距离


## Stencil Buffer

模版缓冲（stencil buffer）或印模缓冲，是在OpenGL三维绘图等计算机图像硬件中常见的除颜色缓冲、像素缓冲、深度缓冲之外另一种数据缓冲。

`stencil buffer`可以将绘图限制到屏幕的规定部分，比如透过窗户的场景。

## Accumulation Buffer

Accumulation Buffer存储的也是颜色值，这个buffer累积一些列的图像，得到一个最终图像，可用于super sampling antialiasing。

## 参考

- [Z-Buffer or Depth-Buffer method](https://www.geeksforgeeks.org/z-buffer-depth-buffer-method/)
- [What is Back and Front Buffer?](https://www.gamedev.net/forums/topic/619051-what-is-back-and-front-buffer/)
