---
layout: post
title: LInux内核——CMA
date: '2022-10-17 17:27'
tags:
  - linux
  - 内存管理
categories:
  - Linux内核
abbrlink: 38033c5c
---

`CMA`，Contiguous Memory Allocator，是内存管理子系统中的一个模块，**负责物理地址连续的内存分配**。一般系统会在启动过程中，从整个memory中配置一段连续内存用于CMA，然后内核其他的模块可以通过CMA的接口API进行连续内存的分配。CMA的核心并不是设计精巧的算法来管理地址连续的内存块，实际上它的底层还是依赖内核伙伴系统这样的内存管理机制，或者说CMA是处于需要连续内存块的其他内核模块（例如DMA mapping framework）和内存管理模块之间的一个中间层模块，主要功能包括：

- 解析DTS或者命令行中的参数，确定CMA内存的区域，这样的区域我们定义为CMA area。
- 提供cma_alloc和cma_release两个接口函数用于分配和释放CMA pages
- 记录和跟踪CMA area中各个pages的状态
- 调用伙伴系统接口，进行真正的内存分配。

<!--more-->

## CMA最初的目的

> https://lwn.net/Articles/396657/

连续内存分配器(CMA)是一个框架，它允许为物理连续内存管理设置特定于计算机的配置。然后根据该配置为设备分配内存。
该框架的主要作用**不是分配内存，而是解析和管理内存配置，以及充当设备驱动程序和可插入分配器之间的中介**。因此，它不依赖于任何内存分配方法或策略。


## CMA使用

cma区域可以通过`设备树`、`cmdline`和`menuconfig`指定，并且可以通过设备树的phandle机制和单独的设备绑定，具体的实现和原理说明如下:

https://zhuanlan.zhihu.com/p/139790210

### 设备树指定

### cmdline指定

### menuconfig指定


## 原理



## 应用

内核版本： `5.4.217`

```
# dmesg | grep cma
[    0.000000] cma: Reserved 1280 MiB at 0x0000000020000000
[    0.000000] Memory: 553676K/1966080K available (9982K kernel code, 1174K rwdata, 3328K rodata, 896K init, 497K bss, 101684K reserved, 1310720K cma-reserved)
```
> - 当前系统内存2G，而cma预留了1280MB，这1280MB内存预留有谁决定？？
> - 除去CMA预留的1280MB，内存剩余768MB，如果系统占用内存超过768MB事，如何处理？？？
> - 2G系统内存，预留1280MB，为啥free看到的可用内存依然是1866MB，是不是CMA预留内存也可以被系统应用所使用？？？
> - 如果CMA预留内存也可以被系统使用，那么后期内存碎片化严重时，在CMA中无法分配大内存区域时怎么办？？？

```
0.000000] Call trace:
[    0.000000]  dump_backtrace+0x0/0x19c
[    0.000000]  show_stack+0x28/0x34
[    0.000000]  dump_stack+0xa4/0xe4
[    0.000000]  cma_declare_contiguous+0x2f4/0x330
[    0.000000]  dma_contiguous_reserve_area+0x5c/0x8c
[    0.000000]  dma_contiguous_reserve+0xe4/0x110
[    0.000000]  arm64_memblock_init+0x200/0x270
[    0.000000]  setup_arch+0x240/0x5c0
[    0.000000]  start_kernel+0x90/0x468
[    0.000000] cma: Reserved 1280 MiB at 0x0000000020000000
```

函数调用栈：
```
start_kernel
  \-> setup_arch
    \-> arm64_memblock_init
      \-> dma_contiguous_reserve
        \-> dma_contiguous_reserve_area
          \-> cma_declare_contiguous
```

物理内存范围：
```
                               总大小1920 MB
    +-----------------------------------------------------------------------------+
    |                                                                             |
    |                                                                             |
    +-----------------------------------------------------------------------------+
0x7800 0000                                                                       0
```

### CMA预留大小

首先，确定`Reserved 1280 MiB`日志输出的位置，再找到其调用关系及cma预留大小的定义。

``` C
int __init cma_declare_contiguous(phys_addr_t base,             
            phys_addr_t size, phys_addr_t limit,                
            phys_addr_t alignment, unsigned int order_per_bit,  
            bool fixed, const char *name, struct cma **res_cma)
{                                                               
  ...
  pr_info("Reserved %ld MiB at %pa\n", (unsigned long)size / SZ_1M,
    &base);                                                      
  return 0
}
```
> mm/cma.c

在`dma_contiguous_reserve`接口中指定需要预留的内存大小

``` C
void __init dma_contiguous_reserve(phys_addr_t limit)                                                   
{                                                                               
    ...
    } else {                                                                    
#ifdef CONFIG_CMA_SIZE_SEL_MBYTES                                               
        selected_size = size_bytes;                                             
#elif defined(CONFIG_CMA_SIZE_SEL_PERCENTAGE)                                   
        selected_size = cma_early_percent_memory();                             
#elif defined(CONFIG_CMA_SIZE_SEL_MIN)                                          
        selected_size = min(size_bytes, cma_early_percent_memory());            
#elif defined(CONFIG_CMA_SIZE_SEL_MAX)                                          
        selected_size = max(size_bytes, cma_early_percent_memory());            
#endif                                                                          
    }                                                                           

    if (selected_size && !dma_contiguous_default_area) {                        
        pr_debug("%s: reserving %ld MiB for global area\n", __func__,           
             (unsigned long)selected_size / SZ_1M);                             

        dma_contiguous_reserve_area(selected_size, selected_base,               
                        selected_limit,                                         
                        &dma_contiguous_default_area,                           
                        fixed);                                                 
    }                                                                           
}                                                                               
```

menuconfig中指定了`CONFIG_CMA_SIZE_SEL_MBYTES`，因此CMA预留内存大小为`size_bytes`
```
#ifdef CONFIG_CMA_SIZE_MBYTES                   
#define CMA_SIZE_MBYTES CONFIG_CMA_SIZE_MBYTES  
#else                                           
#define CMA_SIZE_MBYTES 0                       
#endif                                          

/*                                                                            
 * Default global CMA area size can be defined in kernel's .config.           
 * This is useful mainly for distro maintainers to create a kernel            
 * that works correctly for most supported systems.                           
 * The size can be set in bytes or as a percentage of the total memory        
 * in the system.                                                             
 *                                                                            
 * Users, who want to set the size of global CMA area for their system        
 * should use cma= kernel parameter.                                          
 */                                                                           
static const phys_addr_t size_bytes = (phys_addr_t)CMA_SIZE_MBYTES * SZ_1M;
```

实际预留大小在menuconfig中进行配置：
```
#                                                   
# Default contiguous memory area size:              
#                                                   
CONFIG_CMA_SIZE_MBYTES=1280                         
CONFIG_CMA_SIZE_SEL_MBYTES=y                        
# CONFIG_CMA_SIZE_SEL_PERCENTAGE is not set         
# CONFIG_CMA_SIZE_SEL_MIN is not set                
# CONFIG_CMA_SIZE_SEL_MAX is not set                
CONFIG_CMA_ALIGNMENT=8                              
```

```
         + <--------------------------+ 物理内存总大小1920MB +-------------------------> +
         |        + <----------+ CMA区域大小1280MB +---------> +                        |
         |        |                                           |                        |
         +-----------------------------------------------------------------------------+
         |        |                CMA area                   |                        |
         +--------+-------------------------------------------+------------------------+
0x7800 0000    0x7000 0000                                0x2000 0000                  0
                                                           cma base
```

### CMA预留内存与系统内存关系


### 系统free是否统计CMA内存

CMA区域内存既是reserved又是memory的，但更像是一段普通的memory。

> 结论：free会统计CMA区域内存。

在`cma_declare_contiguous`函数中，通过memblock_phys_alloc_range获取内存

```

```



## 问题——PFNs busy


## 参考

- [The Contiguous Memory Allocator](https://lwn.net/Articles/396657/)
