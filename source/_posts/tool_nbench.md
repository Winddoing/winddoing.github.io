---
title: nbench
categories:
  - 工具
tags:
  - nbench
abbrlink: 18855
date: 2018-04-16 22:07:24
---

 nbench是一个简单的用于测试处理器，存储器性能的基准测试程序。即著名的BYTE Magazine杂志的BYTEmark benchmark program。nbench在系统中运行并将结果和一台运行Linux的AMD K6-233电脑比较，得到的比值作为性能指数。由于是完全开源的，爱好者可以在各种平台和操作系统上运行nbench，并进行优化和测试，是一个简单有效的性能测试工具。nbench的结果主要分为MEM、INT和FP，其中MEM指数主要体现处理器总线、CACHE和存储器性能，INT当然是整数处理性能，FP则体现双精度浮点性能

<!--more-->

## 下载&编译

```
$git clone https://github.com/Winddoing/nbench.git
$git checkout arch-mips-test
$make
```

## 测试

运行`./nbench`

### mips
