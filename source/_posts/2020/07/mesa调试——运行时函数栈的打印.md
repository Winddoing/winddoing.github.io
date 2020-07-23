---
layout: post
title: mesa调试——运行时函数栈的打印
date: '2020-07-23 17:03'
tags:
  - mesa
  - OpenGL
  - GPU
  - debug
categories:
  - 程序设计
  - 虚拟机
---

阅读mesa代码时，追踪一些函数的调用关系，但是由于mesa的编译选项的不同导致一些函数调用流程存在差异。在编译的配置选项中发现了`-Dlibunwind=true`，mesa应该提供了函数调用栈打印的接口，接口如下：


<!--more-->

``` C
struct debug_stack_frame
{
#ifdef HAVE_LIBUNWIND
   unw_word_t start_ip;
   unsigned int off;
   const char *procname;
#else
   const void *function;
#endif
};


void
debug_backtrace_capture(struct debug_stack_frame *backtrace,
                        unsigned start_frame,
                        unsigned nr_frames);

void
debug_backtrace_dump(const struct debug_stack_frame *backtrace,
                     unsigned nr_frames);

void
debug_backtrace_print(FILE *f,
                      const struct debug_stack_frame *backtrace,
                      unsigned nr_frames);
```
> file: src/gallium/auxiliary/util/u_debug_stack.h

## 添加函数栈打印接口


``` diff
--- a/src/gallium/drivers/virgl/virgl_context.c
+++ b/src/gallium/drivers/virgl/virgl_context.c
@@ -1471,6 +1471,9 @@ struct pipe_context *virgl_context_create(struct pipe_screen *pscreen,
       return NULL;
    }

+   debug_backtrace_capture(vctx->create_backtrace, 1, VIRGL_DEBUG_CREATE_BACKTRACE);
+   debug_backtrace_dump(vctx->create_backtrace, VIRGL_DEBUG_CREATE_BACKTRACE);
+
    vctx->base.destroy = virgl_context_destroy;
    vctx->base.create_surface = virgl_create_surface;
    vctx->base.surface_destroy = virgl_surface_destroy;
diff --git a/src/gallium/drivers/virgl/virgl_context.h b/src/gallium/drivers/virgl/virgl_context.h
index 8ea3e1e2f6e..1dbfd41573e 100644
--- a/src/gallium/drivers/virgl/virgl_context.h
+++ b/src/gallium/drivers/virgl/virgl_context.h
@@ -31,6 +31,8 @@
 #include "virgl_staging_mgr.h"
 #include "virgl_transfer_queue.h"

+#include "util/u_debug_stack.h"
+
 struct pipe_screen;
 struct tgsi_token;
 struct u_upload_mgr;
@@ -66,11 +68,15 @@ struct virgl_shader_binding_state {
    uint32_t image_enabled_mask;
 };

+#define VIRGL_DEBUG_CREATE_BACKTRACE 15
+
 struct virgl_context {
    struct pipe_context base;
    struct virgl_cmd_buf *cbuf;
    unsigned cbuf_initial_cdw;

+   struct debug_stack_frame create_backtrace[VIRGL_DEBUG_CREATE_BACKTRACE];
+
    struct virgl_shader_binding_state shader_bindings[PIPE_SHADER_TYPES];
    struct pipe_shader_buffer atomic_buffers[PIPE_MAX_HW_ATOMIC_BUFFERS];
    uint32_t atomic_buffer_enabled_mask;
```

这是是想获取`virgl_context_create`函数的调用栈，因此将`debug_backtrace_capture`和`debug_backtrace_dump`接口加在了同一个位置，其实`debug_backtrace_dump`接口也可以加到后续调用的函数中

**注**：目前我在window系统中使用这些接口无法打印函数栈信息


- 函数调用栈

```
/home/out/lib/x86_64-linux-gnu/dri/swrast_dri.so(+0xe20b5) (st_api_create_context+0x22a) [0x7f4bb8a000b5]
/home/out/lib/x86_64-linux-gnu/dri/swrast_dri.so(+0xd07c6) (dri_create_context+0x477) [0x7f4bb89ee7c6]
/home/out/lib/x86_64-linux-gnu/dri/swrast_dri.so(+0x85c327) (driCreateContextAttribs+0x499) [0x7f4bb917a327]
/home/out/lib/x86_64-linux-gnu/dri/swrast_dri.so(+0x85c3be) (driCreateNewContextForAPI+0x59) [0x7f4bb917a3be]
/home/out/lib/x86_64-linux-gnu/dri/swrast_dri.so(+0x85c414) (driCreateNewContext+0x3c) [0x7f4bb917a414]
/home/out/lib/x86_64-linux-gnu/libGL.so.1(+0x47828) (drisw_create_context+0x137) [0x7f4bb9f9a828]
/home/out/lib/x86_64-linux-gnu/libGL.so.1(+0x492b9) (CreateContext+0xbd) [0x7f4bb9f9c2b9]
/home/out/lib/x86_64-linux-gnu/libGL.so.1(+0x49788) (glXCreateContext+0x13f) [0x7f4bb9f9c788]
glxgears(+0x416f) (?+0x27f) [0x55b7c388816f]
glxgears(+0x257f) (?+0x16f) [0x55b7c388657f]
/lib/x86_64-linux-gnu/libc.so.6(+0x270b3) (__libc_start_main+0xf3) [0x7f4bb9ad80b3]
glxgears(+0x2f0a) (?+0x2a) [0x55b7c3886f0a]
```

## SwapBuffer接口调用

```
func: virgl_flush_eq, line: 922
   /home/out/lib/x86_64-linux-gnu/dri/swrast_dri.so(+0x951a57) (virgl_flush_from_st+0x3e) [0x7f19f19f6a57]
   /home/out/lib/x86_64-linux-gnu/dri/swrast_dri.so(+0xfbf26) (st_flush+0x4a) [0x7f19f11a0f26]
   /home/out/lib/x86_64-linux-gnu/dri/swrast_dri.so(+0xfc03d) (st_glFlush+0x42) [0x7f19f11a103d]
   /home/out/lib/x86_64-linux-gnu/dri/swrast_dri.so(+0x1aeb37) (_mesa_flush+0x96) [0x7f19f1253b37]
   /home/out/lib/x86_64-linux-gnu/dri/swrast_dri.so(+0x1aec65) (_mesa_Flush+0x56) [0x7f19f1253c65]
   /home/out/lib/x86_64-linux-gnu/libGL.so.1(+0x47f08) (driswSwapBuffers+0x3f) [0x7f19f2721f08]
   /home/out/lib/x86_64-linux-gnu/libGL.so.1(+0x4a1e9) (glXSwapBuffers+0x9d) [0x7f19f27241e9]
   ./glxgears(+0x2dfd) (main+0x61d) [0x564f11c10dfd]
   /lib/x86_64-linux-gnu/libc.so.6(+0x270b3) (__libc_start_main+0xf3) [0x7f19f225f0b3]
   ./glxgears(+0x330e) (_start+0x2e) [0x564f11c1130e]
```
