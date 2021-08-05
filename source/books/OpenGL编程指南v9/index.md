---
title: OpenGL编程指南——红宝石
date: 2019-12-07 8:07:24
comments: false
---

# 基础概念

## 缓存数据

glNamedBufferData(),glCopyNamedBufferSubData(),glGetNamedBufferData()都存在一个共同的问题：`都会导致OpenGL进行一次数据拷贝`

### glMapBuffer

```
void* glMapBuffer(GLenum target, GLenum access);
```

> 将当前绑定target的缓存对象的整个数据区域映射到客户端的地址空间中。


## 纹理

> `纹理`是由纹素（texel）组成，其中通常包含颜色数据信息。


# 着色器

OpenGL的着色器语言是GLSL，着色器类似一个函数调用的方式——数据传输进来，经过处理，然后再传输出去。

GLSL的main()函数没有任何参数，在某个着色阶段中输入和输出的所有数据都是通过着色器中的特殊全局变量来传递的。
