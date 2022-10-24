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

CMA通过在启动阶段预先保留内存。这些内存叫做CMA区域，稍后返回给伙伴系统从而可以被用作正常申请。如果要保留内存，则需要恰好在底层`MEMBLOCK`分配器初始化之后，及大量内存被占用之前调用，并在伙伴系统建立之前调用。

> 页迁移：
> 当从伙伴系统申请内存的时候，需要提供一个gfp_mask参数。不管其他事情，这个参数指定了要申请内存的迁移类型。迁移类型是MIGRATE_MOVABLE，它背后的意思是在可移动页面上的数据可以被迁移（或者移动，因此而命名），这对于磁盘缓存或者进程页面来说很有效。为了使相同迁移类型的页面在一起，伙伴系统把页面组成 “页面块 (pageblock)”，每组都有一个指定的迁移类型。分配器根据请求的类型在不同的页面块上分配页。如果尝试失败，分配器会在其它页面块上分配并甚至修改页面块的迁移类型。这意味着一个不可移动的页可能分配自一个MIGRATE_MOVABLE页面块，并导致该页面块的迁移类型改变。这不是CMA想要的，所以它引入了一个MIGRATE_CMA类型，该类型又一个重要的属性: **只有可移动页可以从MIGRATE_CMA页面块种分配**。那么，在启动期间，当dma_congiguous_reserve()和dma_declare_contiguous()方法被调用的时候，CMA在memblock中预留一部分RAM，并在随后将其返还给伙伴系统，仅将其页面块的迁移类型置为MIGRATE_CMA. 最终的结果是所有预留的页都在伙伴系统里，所以它们都可以用于可移动页的分配。



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
``` C
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

在`cma_declare_contiguous`函数中的memblock_phys_alloc_range接口申请了CMA内存区域。

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

CMA base地址如何确定：随机还是指定？
- cmdline方式中可以指定CMA区域的base地址和大小
- menuconfig方式中指定指定CMA区域的大小，base地址随机指定符合要求的区域。

在`cma_declare_contiguous`函数中，通过`memblock_phys_alloc_range`接口申请完了CMA区域的内存后，紧接着使用`cma_init_reserved_mem`接口将其进行初始化。

初始化的目的指定CMA相应区域的参数，比如基址、大小等

CMA区域的个数可以进行配置，内核默认最多`8`个，因为`CONFIG_CMA_AREAS`默认值为7
``` C
struct cma cma_areas[MAX_CMA_AREAS];
unsigned cma_area_count;             

//MAX_CMA_AREAS定义：

/*                                                             
 * There is always at least global CMA area and a few optional
 * areas configured in kernel .config.                         
 */                                                            
#ifdef CONFIG_CMA_AREAS                                        
#define MAX_CMA_AREAS   (1 + CONFIG_CMA_AREAS)                 
```

每个CMA区域将一定大小的内存申请后将通过`cma_init_reserved_mem`进行初始化，并将参数信息保存到`cma_areas`数组中。

使用memconfig进行CMA预留区域的指定，只会使用一个`cma_areas`数组项，而设计多个的目的是在设备树中可以指定多个不同的CMA预留区域。

``` C
/**
 * cma_init_reserved_mem() - create custom contiguous area from reserved memory
 * @base: Base address of the reserved area
 * @size: Size of the reserved area (in bytes),
 * @order_per_bit: Order of pages represented by one bit on bitmap.
 * @name: The name of the area. If this parameter is NULL, the name of
 *        the area will be set to "cmaN", where N is a running counter of
 *        used areas.
 * @res_cma: Pointer to store the created cma region.
 *
 * This function creates custom contiguous area from already reserved memory.
 */
int __init cma_init_reserved_mem(phys_addr_t base, phys_addr_t size,
                 unsigned int order_per_bit,
                 const char *name,
                 struct cma **res_cma)
{
  ...
  cma = &cma_areas[cma_area_count];
  if (name) {
      cma->name = name;
  } else {
      cma->name = kasprintf(GFP_KERNEL, "cma%d\n", cma_area_count);
      if (!cma->name)
          return -ENOMEM;
  }
  cma->base_pfn = PFN_DOWN(base);
  cma->count = size >> PAGE_SHIFT;
  cma->order_per_bit = order_per_bit;
  *res_cma = cma;
  cma_area_count++;
  totalcma_pages += (size / PAGE_SIZE);

  return 0;
}
```

各个CMA预留区域的内存页初始化：

系统启动初期根据各种参数，预留CMA区域的物理内存，将其基地址和大小进行确认，并检查其合法性；系统启动过程中，调用`cma_init_reserved_areas`接口对个CMA区域内存进行初始化后， CMA就可用供其他模块、设备和子系统使用。

```
core_initcall(cma_init_reserved_areas)
  cma_init_reserved_areas
    \-> 遍历cma_areas数组进行初始化
    |-> cma_activate_area
      \-> cma->bitmap = bitmap_zalloc(cma_bitmap_maxno(cma), GFP_KERNEL)
      |-> init_cma_reserved_pageblock
        \-> set_pageblock_migratetype(page, MIGRATE_CMA);
        |-> __free_pages
        |-> adjust_managed_page_count
```
`init_cma_reserved_pageblock`接口将释放整个页面块并将其迁移类型设置为`MIGRATE_CMA`。

内核初始化过程中，通过core_initcall()函数将该 section 内的初始化 函数遍历执行，其中包括 CMA 的激活入口 cma_init_reserved_areas() 函数， 该函数遍历 CMA 分配的所有 CMA 分区并激活每一个 CMA 分区。在该函数中， 函数首先调用kzalloc()函数为CMA分区的bitmap所需的内存，然后调用`init_cma_reserved_pageblock()`函数，在该函数中，内核将CMA区块内的**所有物理页都清除RESERVED标志，引用计数设置为0**，接着按pageblock的方式设置区域内的页组迁移类型都是`MIGRATE_CMA`。函数继续调用set_page_refcounted()函数将引用计数设置为1以及调用`__free_pages()`函数将所有的页从CMA分配器中释放并归还给buddy管理器。最后调用`adjust_managed_page_count()`更新系统可用物理页总数。至此系统的其他部分可以开始使用CMA分配器分配的连续物理内存。


### 系统free是否统计CMA内存

> 结论：free会统计CMA区域内存。

因为CMA区域中的page被设置为`MIGRATE_CMA`,然后放入`伙伴系统`中，等待用户使用（NOTE：MIGRATE_CMA是伙伴系统中页属性的概念,所以CMA区也只是伙伴系统中的一个概念，不是一个ZONE）,这样进行初始化后，free统计时也会将CMA区域的内存统计进去。


### CMA预留内存与系统内存关系

> 结论：CMA区域的内存即是预留内存（reserved），也是系统内存（memory）；也就是说CMA区域这部分内存除了设备驱动申请DMA内存使用外，在系统内存不足时可以使用，

系统中何时使用CMA区域内存：
- 设备驱动中主动申请DMA内存时使用，这个每个驱动实现不同由驱动工程师自主控制。
- 系统应用程序的使用，也就是申请内存时如何使用MIGRATE_CMA page？







## 问题——PFNs busy


## 参考

- [The Contiguous Memory Allocator](https://lwn.net/Articles/396657/)
- [CMA](https://biscuitos.github.io/blog/CMA/#A000)
