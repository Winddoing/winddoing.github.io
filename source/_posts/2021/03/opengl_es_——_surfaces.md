---
layout: post
title: OpenGL ES —— surfaces
date: '2021-03-06 14:18'
tags:
  - opengl
  - surfaces
categories:
  - 多媒体
---

EGL™ is an interface between Khronos rendering APIs such as OpenGL ES or OpenVG and the underlying native platform window system. It handles graphics context management, surface/buffer binding, and rendering synchronization and enables high-performance, accelerated, mixed-mode 2D and 3D rendering using other Khronos APIs. EGL also provides interop capability between Khronos to enable efficient transfer of data between APIs – for example between a video subsystem running OpenMAX AL and a GPU running OpenGL ES.

EGL provides mechanisms for creating rendering surfaces onto which client APIs like OpenGL ES and OpenVG can draw, creates graphics contexts for client APIs, and synchronizes drawing by client APIs as well as native platform rendering APIs. This enables seamless rendering using both OpenGL ES and OpenVG for high-performance, accelerated, mixed-mode 2D and 3D rendering.

<!--more-->

> EGLSurface可以是一个EGL分配的离屏缓冲区(称为 "pbuffer") 或由操作系统分配的窗口

## Window surfaces

``` C
/* create an EGL window surface */
surface = eglCreateWindowSurface(display, config, target, NULL);

if (surface == EGL_NO_SURFACE) {
    fprintf(stderr, "Create surface failed: 0x%x\n", eglGetError());
    exit(EXIT_FAILURE);
}
```

## Pixmap surfaces



``` C
pmsurface = eglCreatePixmapSurface(display, chosen, gfsurface, NULL);

if (pmsurface == EGL_NO_SURFACE) {
    fprintf(stderr, "Create Pixmap failed: 0x%x\n", eglGetError());
    exit(EXIT_FAILURE);
}
```

## pbuffer surfaces

To create a pbuffer surface, the application must specify the width and height of the surfaces via the EGL_WIDTH and EGL_HEIGHT attributes. In the case of a pbuffer surface, the actual surface memory is always allocated internally by OpenGL ES.

``` C
/* create an EGL pbuffer surface */
pbsurface = eglCreatePbufferSurface(display, chosen, pb_attrs);

if (pbsurface == EGL_NO_SURFACE) {
    fprintf(stderr, "Create PBuffer failed: 0x%x\n", eglGetError());
    exit(EXIT_FAILURE);
}

/* connect the context to the PBuffer surface */
if (eglMakeCurrent(display, pbsurface, pbsurface, context) == EGL_FALSE) {
    fprintf(stderr, "Make current failed: 0x%x\n", eglGetError());
    exit(EXIT_FAILURE);
}
```
