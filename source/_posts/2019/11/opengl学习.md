---
layout: post
title: OpenGL学习
date: '2019-11-08 14:17'
tags:
  - OpenGL
categories:
  - 多媒体
  - OpenGL
abbrlink: 36394
---

OpenGL中的概念与数据渲染流程：

![gl_block_diagram](/images/2019/11/gl_block_diagram.png)

<!--more-->

## 概念

### OpenGL Context

OpenGL上下文代表许多东西。上下文存储与此OpenGL实例关联的所有状态。它表示未绘制到帧缓冲区对象时渲染命令将绘制到的（潜在可见）默认帧缓冲区。将上下文视为拥有所有OpenGL的对象；当上下文被销毁时，OpenGL被销毁。

> In order for any OpenGL commands to work, a context must be current; all OpenGL commands affect the state of whichever context is current. The current context is a thread-local variable, so a single process can have several threads, each of which has its own current context. However, **a single context cannot be current in multiple threads at the same time.**
> [Khronos wiki](https://www.khronos.org/opengl/wiki/OpenGL_Context)


## 参考

- [OpenGL](http://www.songho.ca/opengl)
- [Linux graphic stack](https://studiopixl.com/2017-05-13/linux-graphic-stack-an-overview)
