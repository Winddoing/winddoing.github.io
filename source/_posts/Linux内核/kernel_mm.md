---
title: setup_per_cpu_areas
categories:
  - Linux内核
tags:
  - mmu
  - linux
abbrlink: 23122
date: 2018-01-25 23:07:24
---

>为了对内核的内存管理`（mm）`进行初始化而调用的函数之一。只在`SMP`系统中调用，`UP`（单核）中不执行任何操作。
>为SMP的每个处理器生成per-cpu数据

```
start_kernel
	\->setup_per_cpu_areas
```
>file: init/main.c

<!--more-->



## 参考

1. [start_kernel——setup_per_cpu_areas](http://blog.csdn.net/yin262/article/details/46787879)
2. [对Linux内核中percpu data进行分析](http://blog.csdn.net/xylovezf/article/details/6828929)
