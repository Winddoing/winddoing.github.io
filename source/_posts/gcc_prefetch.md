---
title: GCC编译器的优化：预取指令
date: 2018-04-1 23:07:24
categories: 编译工具
tags: [GCC]
---

-fprefetch-loop-arrays 生成数组预读取指令，对于使用巨大数组的程序可以加快代码执行速度，适合数据库相关的大型软件等
