---
layout: "post"
title: "armv8缓存——cache"
date: "2021-12-17 11:01"
tags:
  - arm64
  - cache
categories:
  - arm
---

缓存是位于核心和主内存之间的小而快速的内存块。 它在主内存中保存项目的副本。 对高速缓冲存储器的访问比对主存储器的访问快得多。 每当内核读取或写入特定地址时，它首先会在缓存中查找。 如果它在高速缓存中找到地址，它就使用高速缓存中的数据，而不是执行对主存储器的访问。 通过减少缓慢的外部存储器访问时间的影响，这显着提高了系统的潜在性能。 通过避免驱动外部信号的需要，它还降低了系统的功耗。

![armv8 cache](/images/2021/12/armv8_cache.png)

实现ARMv8-A架构的处理器通常使用`两级`或更多级缓存来实现。 这通常意味着处理器的每个内核都有小的L1`指令`和`数据`缓存。 Cortex-A53和Cortex-A57处理器通常采用两级或更多级缓存来实现，即小的L1指令和数据缓存和更大的、统一的L2缓存，在集群中的多个内核之间共享。 此外，可以有一个外部L3缓存作为外部硬件块，在集群之间共享。


<!--more-->

![cache transfer](/images/2021/12/cache_transfer.png)

- Data is transferred in the form of words between the cache memory and the CPU.
- Data is transferred in the form of blocks or pages between the cache memory and the main memory.

## Cache terminology

![armv8 cache terminology](/images/2021/12/armv8_cache_terminology.png)

- `tag`:
  tag是存储在缓存中的内存地址的一部分，用于标识与数据行相关联的主内存地址。
  64位地址的最高位告诉缓存信息来自主内存中的哪里，称为tag。 尽管用于保存标签值的RAM不包括在计算中，但总缓存大小是对其可以保存的数据量的度量。 但是，该标签会占用缓存中的物理空间。

- `line`:
  为每个标签地址保存一个数据字是低效的，因此通常将多个位置组合在同一标签下。 这个逻辑块通常被称为cacheline，是指缓存的最小可加载单元，来自主内存的连续字块。 缓存行在包含缓存数据或指令时被称为有效，如果不包含则称为无效。
  与每一行数据相关联的是一个或多个状态位。 通常，您有一个有效位将行标记为包含可以使用的数据。 这意味着地址标签代表了一些实际值。 在数据缓存中，您可能还有一个或多个脏位，用于标记缓存行（或其一部分）是否保存与主内存内容不同（更新）的数据。

- `index`:
  index是内存地址的一部分，它确定可以在缓存的哪些行中找到该地址。
  地址或索引的中间位标识该行。 索引用作高速缓存RAM的地址，不需要作为标记的一部分进行存储。 本章稍后将对此进行更详细的介绍。

- `way`:
  way是高速缓存的细分，每路具有相同的大小并以相同的方式编入索引。 一组由共享特定索引的所有方式的缓存行组成。

- `set`:


### linux下cache相关数据

- 一级cache大小
  ```
  cat /sys/devices/system/cpu/cpu0/cache/index0/size
  32K
  ```
- 一级cache中set个数
  ```
  cat /sys/devices/system/cpu/cpu0/cache/index0/number_of_sets
  64
  ```
- 一级cache中set的cacheline个数
  ```
  cat /sys/devices/system/cpu/cpu0/cache/index0/ways_of_associativity
  8
  ```
- 一级cache中cacheline大小
  ```
  cat /sys/devices/system/cpu/cpu0/cache/index0/coherency_line_size
  64
  ```
> cache的大小是：64×8×64/1024=32KB


## 参考

- DEN0024A_v8_architecture_PG.pdf
- [计算机缓存Cache以及Cache Line详解](https://zhuanlan.zhihu.com/p/37749443)
