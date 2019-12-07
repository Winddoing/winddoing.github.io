---
title: OpenGL编程指南——红宝石
date: 2019-12-07 8:07:24
comments: false
---

## 缓存数据

glNamedBufferData(),glCopyNamedBufferSubData(),glGetNamedBufferData()都存在一个共同的问题：`都会导致OpenGL进行一次数据拷贝`

### glMapBuffer

```
void* glMapBuffer(GLenum target, GLenum access);
```

> 将当前绑定target的缓存对象的整个数据区域映射到客户端的地址空间中。
