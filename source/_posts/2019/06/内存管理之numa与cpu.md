---
layout: post
title: 内存管理之NUMA与CPU
date: '2019-06-16 12:37'
tags:
  - 内存
categories:
  - Linux内核
  - MMU
---

NUMA与CPU之间的关系,如系统中有2个CPU（可以超过2个CPU）时， NUMA内存访问模型

![mmu_numa_cpu](/images/2019/06/mmu_numa_cpu.png)

> 平台：arm64
> kernel：linux4.4

<!--more-->

## NUMA(Non Uniform Memory Access)

NUMA和SMP是两种CPU相关的硬件架构。在SMP架构里面，所有的CPU争用一个总线来访问所有内存，优点是资源共享，而缺点是总线争用激烈。随着PC服务器上的CPU数量变多（不仅仅是CPU核数），总线争用的弊端慢慢越来越明显，于是Intel在Nehalem CPU上推出了NUMA架构，而AMD也推出了基于相同架构的Opteron CPU。

NUMA最大的特点是引入了node和distance的概念。对于CPU和内存这两种最宝贵的硬件资源，NUMA用近乎严格的方式划分了所属的资源组（node），而每个资源组内的CPU和内存是几乎相等。资源组的数量取决于物理CPU的个数（现有的PC server大多数有两个物理CPU，每个CPU有4个核）；distance这个概念是用来定义各个node之间调用资源的开销，为资源调度优化算法提供数据支持。

![mmu_numa_intel_access](/images/2019/06/mmu_numa_intel_access.png)

- 查看NUMA相关情况
```
#numactl  --show
```
## ARM64内存在管理相当于单个node

![mmu_one_node](/images/2019/06/mmu_one_node.png)

```
On node 0 totalpages: 524288
  DMA zone: 8192 pages used for memmap
  DMA zone: 0 pages reserved
  DMA zone: 524288 pages, LIFO batch:31
...
```
> 内核启动部分打印

### node的初始化

在内核启动时进行初始化：

```
start_kernel
  \->setup_arch //不同的CPU对node的使用不同
      \->paging_init
          \->bootmem_init
              \->zone_sizes_init(arch/arm64/mm/minit.c)
                  \->free_area_init_node(nid=0, ...)
                    {
                       pg_data_t *pgdat = NODE_DATA(nid);

                       calculate_node_totalpages(pgdat, start_pfn, end_pfn,
                         zones_size, zholes_size);
                       alloc_node_mem_map(pgdat);
                    }
```

## 物理内存与node之间的关系


## 参考

* [NUMA的取舍与优化设置](https://www.cnblogs.com/xueqiuqiu/articles/9282903.html)
