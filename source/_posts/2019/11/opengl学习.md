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
![opengl_pipeline](/images/2019/11/opengl_pipeline.png)

<!--more-->

## 概念

### OpenGL Context

OpenGL上下文代表许多东西。上下文存储与此OpenGL实例关联的所有状态。它表示未绘制到帧缓冲区对象时渲染命令将绘制到的（潜在可见）默认帧缓冲区。将上下文视为拥有所有OpenGL的对象；当上下文被销毁时，OpenGL被销毁。

> In order for any OpenGL commands to work, a context must be current; all OpenGL commands affect the state of whichever context is current. The current context is a thread-local variable, so a single process can have several threads, each of which has its own current context. However, **a single context cannot be current in multiple threads at the same time.**
> [Khronos wiki](https://www.khronos.org/opengl/wiki/OpenGL_Context)

## OpenGL渲染管线

![gl_block_diagram](/images/2019/11/gl_block_diagram.png)

![opengl_ops](/images/2019/11/opengl_ops.png)

![OpenGL_render_pipeline](/images/2019/11/opengl_render_pipeline.png)

- 顶点着色
- 细分着色
- 几何着色
- 图元装配
  - 将顶点与相关的几何图元之间组织起来，准备下一步的剪切和光栅化
- 剪切
  - 顶点可能会落到视口（viewport）之外，此时与顶点相关的图元会进行改动，保证像素不会在视口之外绘制，这个过叫剪切，全部由OpenGL自动完成
- 光栅化
  - 更新后的图元传递到光栅化单元，生成片元。光栅化的工作是判断某一部分几何体（点，线或者三角形）所覆盖的屏幕空间
- 片元着色
  - 通过着色器计算片元的最终颜色
- 逐片元操作
  - 使用深度测试（depth test 或者称为z缓存）和模板测试（stencil test）的方式来决定一个片元是否是可见的

**顶点着色（包括细分和几何着色）决定了一个图元应该位于屏幕的什么位置；片元着色使用这些信息决定某个片元的颜色应该是什么**

## OpenGL可编程管线

OpenGL 4.5版本的图形管线有4个阶段，还有1个通用计算阶段。
1. 顶点着色阶段（vertex shader stage）
2. 细分着色阶段（tessellation shader stage）
  - 细分控制着色器（tessellation control shader）
  - 细分赋值着色器（tessellation evaluation shader）
3. 几何着色阶段（geometry shader stage）
4. 片元着色阶段（fragment shader stage）
5. 计算着色阶段（compute shader stage）

## 着色器

### 细分控制着色器（Tessellation Control Shader）


### 细分赋值着色器（Tessellation Evaluation Shader）


## 参考

- [OpenGL](http://www.songho.ca/opengl)
- [Linux graphic stack](https://studiopixl.com/2017-05-13/linux-graphic-stack-an-overview)
- [A Simple OpenGL Shader Example](https://www.cnblogs.com/opencascade/p/4604734.html)
- [opengl tutorial 教程](http://www.opengl-tutorial.org/cn/beginners-tutorials/tutorial-2-the-first-triangle/)
- [Learn OpenGL【中】](https://learnopengl-cn.github.io/)
- [Learn OpenGL【英】](https://learnopengl.com/)
- [CHAPTER8 Texture Mapping: The Basics](https://www.scss.tcd.ie/Michael.Manzke/CS7055/Lab2/SuperBible.4th.Ed.Ch8-9.pdf)
- [OpenGLR©Graphics with the X Window System (Version 1.4)](https://www.khronos.org/registry/OpenGL/specs/gl/glx1.4.pdf)
