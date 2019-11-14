---
layout: post
title: glxinfo之Video Memory大小
date: '2019-11-13 16:00'
tags:
  - glxinfo
  - 显存
categories:
  - 多媒体
abbrlink: 18632
---

mesa中的显存大小：

``` shell
$glxinfo -B
name of display: :0
display: :0  screen: 0
direct rendering: Yes
Extended renderer info (GLX_MESA_query_renderer):
    Vendor: X.Org (0x1002)
    Device: AMD OLAND (DRM 2.50.0, 5.3.8-050308-generic, LLVM 8.0.0) (0x6611)
    Version: 19.1.6
    Accelerated: yes
    Video memory: 1024MB <----------- 显存
    Unified memory: no
    Preferred profile: core (0x1)
    Max core profile version: 4.5
    Max compat profile version: 4.5
    Max GLES1 profile version: 1.1
    Max GLES[23] profile version: 3.2
```

<!--more-->

## glxinfo

源码文件：
```
git clone https://gitlab.freedesktop.org/mesa/demos.git
```

获取显存大小：`queryInteger(GLX_RENDERER_VIDEO_MEMORY_MESA, v)`
```
queryInteger(GLX_RENDERER_ACCELERATED_MESA, v);                              
printf("    Accelerated: %s\n", *v ? "yes" : "no");                          
queryInteger(GLX_RENDERER_VIDEO_MEMORY_MESA, v);                             
printf("    Video memory: %dMB\n", *v);                                      
queryInteger(GLX_RENDERER_UNIFIED_MEMORY_ARCHITECTURE_MESA, v);              
printf("    Unified memory: %s\n", *v ? "yes" : "no");                        
```
> file: glxinfo.c

## mesa

queryInteger在mesa中的实现：

```
glXQueryCurrentRendererIntegerMESA
  \->__glXQueryRendererInteger --- GLX_RENDERER_VIDEO_MEMORY_MESA
    -> psc->vtable->query_renderer_integer()
```
>

- dri3
``` C
static const struct glx_screen_vtable dri3_screen_vtable = {           
   .create_context         = dri3_create_context,                      
   .create_context_attribs = dri3_create_context_attribs,              
   .query_renderer_integer = dri3_query_renderer_integer,              
   .query_renderer_string  = dri3_query_renderer_string,               
};                                                                     
```

```
dri3_query_renderer_integer
 \-> dri2_convert_glx_query_renderer_attribs
    \/
  dri_attribute = __DRI2_RENDERER_VIDEO_MEMORY <--GLX_RENDERER_VIDEO_MEMORY_MESA
 \->psc->rendererQuery->queryInteger((psc->driScreen, dri_attribute, value)
```

``` C
const __DRI2rendererQueryExtension dri2RendererQueryExtension = {               
    .base = { __DRI2_RENDERER_QUERY, 1 },                                       

    .queryInteger         = dri2_query_renderer_integer,                        
    .queryString          = dri2_query_renderer_string                          
};                                                                              
```
> fire: src/gallium/state_trackers/dri/dri_query_renderer.c

```
dri2_query_renderer_integer
 \-> __DRI2_RENDERER_VIDEO_MEMORY
   > screen->base.screen->get_param(screen->base.screen, PIPE_CAP_VIDEO_MEMORY)
```
- `get_param`接口是`struct pipe_screen`提供给驱动的接口，需要各个驱动自己实现。

### virgl

``` C
struct pipe_screen *                                              
virgl_create_screen(struct virgl_winsys *vws)                     
{                                                                 
   struct virgl_screen *screen = CALLOC_STRUCT(virgl_screen);     

   screen->base.get_name = virgl_get_name;        
   screen->base.get_vendor = virgl_get_vendor;    
   screen->base.get_param = virgl_get_param;      
   ...
}
```

```
virgl_get_param <- PIPE_CAP_VIDEO_MEMORY
\-> {
      ...
      case PIPE_CAP_VIDEO_MEMORY:
      return 0;               
    }
```
> **在virgl中没有实现显存接口，默认为0，无法通过glxinfo获取**

在virgl中的部分其他参数是获取host端的参数，通过`struct virgl_winsys`结构体中的`get_caps`接口。
- drm： `DRM_IOCTL_VIRTGPU_GET_CAPS`
- vtest： `VCMD_GET_CAPS`+`VCMD_GET_CAPS2`

### radeonsi

``` C
void si_init_screen_get_functions(struct si_screen *sscreen)
{
  sscreen->b.get_name = si_get_name;                                
  sscreen->b.get_vendor = si_get_vendor;                            
  sscreen->b.get_device_vendor = si_get_device_vendor;              
  sscreen->b.get_param = si_get_param;                              
  ...
}
```

```
static int si_get_param(struct pipe_screen *pscreen, enum pipe_cap param)
{
  switch (param) {
    case PIPE_CAP_VIDEO_MEMORY:              
      return sscreen->info.vram_size >> 20;   
  }
  ...
}
```

在Radeon驱动中通过`drmCommandWriteRead`接口获取`DRM_RADEON_GEM_INFO`中的配置参数
```
/* Get GEM info. */                                         
retval = drmCommandWriteRead(ws->fd, DRM_RADEON_GEM_INFO,   
        &gem_info, sizeof(gem_info));                       
```
