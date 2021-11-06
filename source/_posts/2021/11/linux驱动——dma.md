---
layout: "post"
title: "linux驱动——DMA"
date: "2021-11-06 16:42"
---

`DMA`（Direct Memory Access），直接内存访问，这里的直接是和需要CPU参与的内存访问相对的概念。

主要使用场景：

- 将数据从一片内存搬到另一片内存
- 从IO设备读取数据到内存
- 将内存数据写入IO设备

<!--more-->
