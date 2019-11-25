---
layout: post
title: Virtio-GPU相关
date: '2019-08-18 20:27'
tags:
  - virtio
  - GPU
categories:
  - 设备驱动
abbrlink: 56420
---

> For containers in virtualized environments, they are working on accelerated OpenGL ES 2.0 support with that being the lowest common denominator for many mobile platforms. This virtual GPU access they are pursuing is making use of Red Hat's work on Virgil3D as the Gallium3D-based solution for graphics pass-through to the host. Then for the kernel bits are VirtIO-GPU and on the host is the Virgl Renderer with QEMU.

![virtio-gpu-qemu-layer](/images/2019/08/virtio_gpu_qemu_layer.png)

<!--more-->

## OpenGL

OpenGL, OpenGL ES, and OpenGL ES-SC API and Extension Registry

- [OpenGL-Registry](https://github.com/KhronosGroup/OpenGL-Registry/)

## EGL

`EGL`是图形渲染API（如OpenGL ES）与本地平台窗口系统的一层接口，保证了OpenGL ES的平台独立性。EGL提供了若干功能：创建rendering surface、创建graphics context、同步应用程序和本地平台渲染API、提供对显示设备的访问、提供对渲染配置的管理等。

egl是一个管理者的功能。包括管理所有的display ， context， surface，config。可能有很多的display ，每个display有很多的configs，这个display上可以创建很多的context和surface

- [EGL Reference Pages](https://www.khronos.org/registry/EGL/sdk/docs/man/)
- [1EGL 1.4 API Quick Reference Card](https://www.khronos.org/files/egl-1-4-quick-reference-card.pdf)


## GLX

`GLX`是OpenGL Extension to the X Window System的缩写。它作为x的扩展，是x协议和X server的一部分，已经包含在X server的代码中了。GLX提供了X window system使用的OpenGL接口，允许通过x调用OpenGL库。OpenGL 在使用时，需要与一个实际的窗口系统关联起来。

##  GLX、EGL与OpenGL ES之间的关系？？

> 一般EGL和OpenGL ES使用时都会先利用egl函数(egl开头)创建opengl本地环境，然后再利用opengl函数(gl开头)去画图。

**EGL代替的是原先WGL/GLX那套context管理，跟图形API用的什么没关系**

``` C
EGLBoolean eglBindAPI( 	EGLenum api);
```
>Parameters api:
>    Specifies the client API to bind, one of `EGL_OPENGL_API`, `EGL_OPENGL_ES_API`, or `EGL_OPENVG_API`.


## mesa

### Gallium

- [Gallium’s documentation](https://gallium.readthedocs.io/en/latest/)
- [Gallium3D Documentation doxygen](https://dri.freedesktop.org/doxygen/gallium/index.html)


## DRI

- [DRI megadrivers](https://www.x.org/wiki/Events/XDC2013/XDC2013EricAnholtDRIMegadrivers/xdc-2013-megadrivers.pdf)

## Virgil
> Virgil is an effort to provide 3D acceleration using `Gallium3D` for QEMU+KVM virtual machine guests.

- [Virgil Linux News](https://www.phoronix.com/scan.php?page=search&q=Virgil)
- [What’s new in the virtual world?(pdf)](https://xdc2018.x.org/slides/Virgl_Presentation.pdf)
- [GSoC 2018 - Vulkan-ize Virglrenderer](https://studiopixl.com/2018-07-12/vulkan-ize-virgl.html)
- [GSoC 2017 - 3D acceleration using VirtIOGPU](https://studiopixl.com/2017-08-27/3d-acceleration-using-virtio.html)

### virgl_protocol

It is composed of several components:
- a MESA driver, on the guest, which generates `Virgl commands`
- a lib, on the host, which takes virgl commands and generated OpenGL calls from it.


## GPU Driver

### DRM

> he DRM core includes two memory managers, namely Translation Table Maps (TTM) and Graphics Execution Manager (GEM).

- [Linux GPU Driver Developer’s Guide](https://blog.csdn.net/u012839187/article/details/89875800)
- [DRM memory management - 最好的GEM/TTM/PRIME解释](http://ju.outofmemory.cn/entry/158909)


## piglit


## GLSL

> OpenGL着色语言（OpenGL Shading Language）是用来在OpenGL中着色编程的语言，也即开发人员写的短小的自定义程序，他们是在图形卡的GPU （Graphic Processor Unit图形处理单元）上执行的，代替了固定的渲染管线的一部分，使渲染管线中不同层次具有可编程性。


## X.org


2018年X.Org开发者大会相关文档和视频（网络原因视频看不了）

- https://www.x.org/wiki/Events/XDC2018/



## 参考

- [virtio-gpu-wddm-dod](https://gitlab.com/spice/win32/virtio-gpu-wddm-dod)
- [OpenGL ICD for Virtio-GPU Windows driver(Github)](https://github.com/Keenuts/virtio-gpu-win-icd)
- [Virtual I/O Device (VIRTIO) Version 1.1](https://docs.oasis-open.org/virtio/virtio/v1.1/cs01/virtio-v1.1-cs01.html)
- [GSoC 2017 - 3D acceleration using VirtIOGPU](https://studiopixl.com/2017-08-27/3d-acceleration-using-virtio.html)
- [GSoC 2018 - Vulkan-ize Virglrenderer](https://studiopixl.com/2018-07-12/vulkan-ize-virgl.html)
