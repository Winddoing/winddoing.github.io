---
layout: post
title: GBM for EGL (Linux)
date: '2019-12-26 14:59'
tags:
  - gbm
  - egl
categories:
  - 多媒体
  - EGL
---

> Mesa GBM (`Generic Buffer Manager`) basically provides a EGL native window type (just like Wayland and X11), so one could obtain a real EGL surface and create render target buffers. With that then, GL can be used to render into these buffers, which will be shown to the display by queuing a page flip via KMS/DRM API.

用户应用程序直接对内存进行管理，通过EGL可以获取真实的EGL表面并创建渲染目标缓冲区

<!--more-->

## MESA_platform_gbm

>This extension defines how to create EGL resources from native GBM resources using the functions defined by EGL_EXT_platform_base. (GBM is a `Generic Buffer Manager` for Linux).


## 离屏渲染--简单示例

> https://github.com/elima/gpu-playground/tree/master/render-nodes-minimal

``` C
#include <EGL/egl.h>
#include <EGL/eglext.h>
#include <GLES3/gl31.h>
#include <assert.h>
#include <fcntl.h>
#include <gbm.h>
#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

/* a dummy compute shader that does nothing */
#define COMPUTE_SHADER_SRC "          \
#version 310 es\n                                                       \
                                                                        \
layout (local_size_x = 1, local_size_y = 1, local_size_z = 1) in;       \
                                                                        \
void main(void) {                                                       \
   /* awesome compute code here */                                      \
}                                                                       \
"

int32_t
main (int32_t argc, char* argv[])
{
   bool res;

   int32_t fd = open ("/dev/dri/renderD128", O_RDWR);
   assert (fd > 0);

   struct gbm_device *gbm = gbm_create_device (fd);
   assert (gbm != NULL);

   /* setup EGL from the GBM device */
   EGLDisplay egl_dpy = eglGetPlatformDisplay (EGL_PLATFORM_GBM_MESA, gbm, NULL);
   assert (egl_dpy != NULL);

   res = eglInitialize (egl_dpy, NULL, NULL);
   assert (res);

   const char *egl_extension_st = eglQueryString (egl_dpy, EGL_EXTENSIONS);
   assert (strstr (egl_extension_st, "EGL_KHR_create_context") != NULL);
   assert (strstr (egl_extension_st, "EGL_KHR_surfaceless_context") != NULL);

   static const EGLint config_attribs[] = {
      EGL_RENDERABLE_TYPE, EGL_OPENGL_ES3_BIT_KHR,
      EGL_NONE
   };
   EGLConfig cfg;
   EGLint count;

   res = eglChooseConfig (egl_dpy, config_attribs, &cfg, 1, &count);
   assert (res);

   res = eglBindAPI (EGL_OPENGL_ES_API);
   assert (res);

   static const EGLint attribs[] = {
      EGL_CONTEXT_CLIENT_VERSION, 3,
      EGL_NONE
   };
   EGLContext core_ctx = eglCreateContext (egl_dpy,
                                           cfg,
                                           EGL_NO_CONTEXT,
                                           attribs);
   assert (core_ctx != EGL_NO_CONTEXT);

   res = eglMakeCurrent (egl_dpy, EGL_NO_SURFACE, EGL_NO_SURFACE, core_ctx);
   assert (res);

   /* print some compute limits (not strictly necessary) */
   GLint work_group_count[3] = {0};
   for (unsigned i = 0; i < 3; i++)
      glGetIntegeri_v (GL_MAX_COMPUTE_WORK_GROUP_COUNT,
                       i,
                       &work_group_count[i]);
   printf ("GL_MAX_COMPUTE_WORK_GROUP_COUNT: %d, %d, %d\n",
           work_group_count[0],
           work_group_count[1],
           work_group_count[2]);

   GLint work_group_size[3] = {0};
   for (unsigned i = 0; i < 3; i++)
      glGetIntegeri_v (GL_MAX_COMPUTE_WORK_GROUP_SIZE, i, &work_group_size[i]);
   printf ("GL_MAX_COMPUTE_WORK_GROUP_SIZE: %d, %d, %d\n",
           work_group_size[0],
           work_group_size[1],
           work_group_size[2]);

   GLint max_invocations;
   glGetIntegerv (GL_MAX_COMPUTE_WORK_GROUP_INVOCATIONS, &max_invocations);
   printf ("GL_MAX_COMPUTE_WORK_GROUP_INVOCATIONS: %d\n", max_invocations);

   GLint mem_size;
   glGetIntegerv (GL_MAX_COMPUTE_SHARED_MEMORY_SIZE, &mem_size);
   printf ("GL_MAX_COMPUTE_SHARED_MEMORY_SIZE: %d\n", mem_size);

   /* setup a compute shader */
   GLuint compute_shader = glCreateShader (GL_COMPUTE_SHADER);

   assert (glGetError () == GL_NO_ERROR);
   const char *shader_source = COMPUTE_SHADER_SRC;

   glShaderSource (compute_shader, 1, &shader_source, NULL);
   assert (glGetError () == GL_NO_ERROR);

   glCompileShader (compute_shader);
   assert (glGetError () == GL_NO_ERROR);

   GLuint shader_program = glCreateProgram ();

   glAttachShader (shader_program, compute_shader);
   assert (glGetError () == GL_NO_ERROR);

   glLinkProgram (shader_program);
   assert (glGetError () == GL_NO_ERROR);

   glDeleteShader (compute_shader);

   glUseProgram (shader_program);
   assert (glGetError () == GL_NO_ERROR);

   /* dispatch computation */
   glDispatchCompute (1, 1, 1);
   assert (glGetError () == GL_NO_ERROR);

   printf ("Compute shader dispatched and finished successfully\n");

   /* free stuff */
   glDeleteProgram (shader_program);
   eglDestroyContext (egl_dpy, core_ctx);
   eglTerminate (egl_dpy);
   gbm_device_destroy (gbm);
   close (fd);

   return 0;
}
```

```
gcc main.c `pkg-config --libs --cflags egl gbm gl`
```

主要分4部分：
- 从渲染节点创建GBM设备
- 设置（无表面的）EGL / OpenGL-ES上下文
- 创建一个计算着色器程序
- 调度计算着色器

## 参考

- [MESA_platform_gbm](https://www.khronos.org/registry/EGL/extensions/MESA/EGL_MESA_platform_gbm.txt)
- [drm gbm demo](https://github.com/eyelash/tutorials/blob/master/drm-gbm.c)
- [EGLDisplay on GBM](https://stackoverflow.com/questions/20816844/egldisplay-on-gbm)
- [Example: Run a headless OpenGL (ES) compute shader via DRM render-nodes](https://blogs.igalia.com/elima/2016/10/06/example-run-an-opengl-es-compute-shader-on-a-drm-render-node/)
