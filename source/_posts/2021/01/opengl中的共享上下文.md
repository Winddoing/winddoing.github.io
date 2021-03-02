---
layout: post
title: OpenGL中的共享上下文
date: '2021-01-10 10:30'
tags:
  - opengl
  - egl
  - glx
categories:
  - 多媒体
  - OpenGL
abbrlink: 44245d70
---

OpenGL渲染中有一个`线程相关`的上下文(Context), OpenGL所创建的资源, 其实对程序员可见的仅仅是`上下文ID`而已, 其内容依赖于这个上下文, 有时候为了方便起见, 在某个线程中创建了上下文之后, 所有的OpenGL操作都转到此线程来调用. 这样在简单的2d/3d 渲染中尚可, 但是如果涉及复杂的OpenGL渲染时, 这样就未必足够， 事实上OpenGL已经考虑到这一点， `上下文是可以在多个线程间共享的`，在使用`glXCreateContext`或`eglCreateContext`时， 可以传入一个已创建成功的上下文， 这样就可以得到一个共享的上下文(Shared Context).

<!--more-->

OpenGL的绘制命令都是作用在当前的Context上，这个Current Context是一个`线程私有（thread-local）的变量`，也就是说如果我们在线程中绘制，那么需要为该线程制定一个Current Context的，当多个线程参与绘制任务时，需要原线程解绑再重新绑定新的线程。多个线程不能同时指定同一个Context为Current Context，否则会导致崩溃。

## 共享上下文

一个是进程可以创建多个Context，它们可以分别描绘出不同的图形界面，就像一个应用程序可以打开多个窗口一样。每个OpenGL Context是相互独立的，它们都有自己的OpenGL对象集。但有时会有场景需要多个上下文使用同一份纹理资源的情况，创建Context，意味着系统资源的占用，同一份纹理重复申请会造成资源浪费，因此OpenGL上下文允许共享一部分资源。大部分OpenGL Objects是可以共享的，包括`Sync Object`和`GLSL Objects`。`Container Objects`和`Query Objects`是不能共享的。例如纹理、shader、Buffer等资源是可以共享的，但Frame Buffer Object(FBO)、Vertex Array Object（VAO）等容器对象不可共享，但可将共享的纹理和VBO绑定到各自上下文的容器对象上。

- 共享资源: `纹理`、`shader`、`Buffer`
- 不共享资源: `FBO`, `VAO`

## EGL Context

``` C
EGLContext eglCreateContext(EGLDisplay display,
  	                        EGLConfig config,
  	                        EGLContext share_context,
  	                        EGLint const * attrib_list);
```






## GLX Context

``` C
GLXContext glXCreateContext(Display * dpy,
 	                        XVisualInfo * vis,
 	                        GLXContext shareList,
 	                        Bool direct);
```

GLX创建共享上下文：
``` C
GLXContext currctx = glXGetCurrentContext();
GLXFBConfig* fb_config;
int fb_config_id;
int nelements;
int res;

XInitThreads();

Display* dpy = XOpenDisplay(NULL);
assert(dpy != NULL)

res = glXQueryContext(dpy, currctx, GLX_FBCONFIG_ID, &fb_config_id);
assert(res);

int visual_attribs[] = {
    GLX_FBCONFIG_ID, fb_config_id,
    None
};
fb_config = glXChooseFBConfig(dpy, DefaultScreen(dpy), visual_attribs, &nelements);
assert(fb_config);

int context_attribs[] = {
    GLX_CONTEXT_MAJOR_VERSION_ARB, 4,
    GLX_CONTEXT_MINOR_VERSION_ARB, 0,
    GLX_CONTEXT_PROFILE_MASK_ARB, GLX_CONTEXT_CORE_PROFILE_BIT_ARB,
    None
};
GLXContext glx_share_context = glXCreateContextAttribsARB(dpy, fb_config[0], currctx,
        True, context_attribs);
assert(glx_share_context);
```


## 上下文切换

在执行OpenGL函数之前,必须将切换到其当前的上下文进行处理

### EGL

``` C
EGLBoolean eglMakeCurrent(EGLDisplay display,
  	                      EGLSurface draw,
  	                      EGLSurface read,
  	                      EGLContext context);
```

``` C
eglMakeCurrent(display, EGL_NO_SURFACE, EGL_NO_SURFACE, context);
```

### GLX

``` C
Bool glXMakeCurrent(Display * dpy,
 	                GLXDrawable drawable,
 	                GLXContext ctx);
```








## 参考

- https://www.khronos.org/registry/EGL/sdk/docs/man/html/eglCreateContext.xhtml
- https://khronos.org/registry/OpenGL-Refpages/gl2.1/xhtml/glXCreateContext.xml
- https://www.khronos.org/registry/EGL/sdk/docs/man/html/eglMakeCurrent.xhtml
- https://www.khronos.org/registry/OpenGL-Refpages/gl2.1/xhtml/glXMakeCurrent.xml
- [OpenGL中的上下文 理解整理](https://blog.csdn.net/shenyi0_0/article/details/109382509)
- [GLX Reference Pages](https://www.khronos.org/registry/OpenGL-Refpages/gl2.1/)
- [EGL Reference Pages](https://www.khronos.org/registry/EGL/sdk/docs/man/)
