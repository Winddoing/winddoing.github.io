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

`CMA`，Contiguous Memory Allocator，是内存管理子系统中的一个模块，**预留内存的配置解析和管理内存配置**。一般系统会在启动过程中，从整个memory中配置一段连续内存用于CMA，然后内核其他的模块可以通过CMA的接口API进行连续内存的分配。CMA的核心并不是设计精巧的算法来管理地址连续的内存块，实际上它的底层还是依赖内核伙伴系统这样的内存管理机制，或者说CMA是处于需要连续内存块的其他内核模块（例如DMA mapping framework）和内存管理模块之间的一个中间层模块，主要功能包括：

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

### 设备树指定

在设备树中添加`reserved-memory`节点，并且compatible属性指定为shared-dma-pool，并在设备节点中通过memory-region引用该节点，
```
reserved-memory {
    #address-cells = <2>;
    #size-cells = <2>;
    ranges;

    /* Chipselect 2,00000000 is physically at 0x18000000 */
    vram: vram@18000000 {
        /* 8 MB of designated video RAM */
        compatible = "shared-dma-pool";
        reg = <0x00000000 0x18000000 0 0x00800000>;
        no-map;
    };
};
```

节点配置属性：
- compatible (optional) ——standard definition
  - `shared-dma-pool`： 表示一个内存区域，用于一组设备的DMA缓冲区共享池。操作系统可以使用它在必要时实例化必要的池管理子系统。
  - vendor specific, 特定于供应商的字符串，形式为，<vendor>,[<device>-]<usage>
- no-map (optional) —— empty property
  - 指示操作系统不能创建该区域的虚拟映射作为其系统内存的标准映射的一部分，也不允许在使用该区域的设备驱动程序控制之外的任何情况下对其进行投机性访问。
- reusable (optional) ——  empty property
  - 操作系统可以使用该区域的内存，但该区域的设备驱动程序需要能够回收它。通常，这意味着操作系统可以使用该区域存储易失性数据或缓存数据，这些数据可以重新生成或迁移到其他地方。

详细参考文档：`Documentation/devicetree/bindings/reserved-memory/reserved-memory.txt`


### cmdline指定

在uboot的`bootargs`可以添加cma属性指定cma区域

```
cma=nn[MG]@[start[MG][-end[MG]]]
        [ARM,X86,KNL]
        Sets the size of kernel global memory area for
        contiguous memory allocations and optionally the
        placement constraint by the physical address range of
        memory allocations. A value of 0 disables CMA
        altogether. For more information, see
        include/linux/dma-contiguous.h
```
> Documentation/admin-guide/kernel-parameters.txt

```
cma=256M
或
cma=64M@0x0-0xb0000000
```

### menuconfig指定

CMA相关的menuconfig分别在`memory management options`和`library routines`里面

```
Memory Management options  --->
  [*] Contiguous Memory Allocator
  [ ]   CMA debug messages (DEVELOPMENT)
  [*]   CMA debugfs interface
  (7)   Maximum count of the CMA areas

Library routines  --->
  [*] DMA Contiguous Memory Allocator
        *** Default contiguous memory area size: ***
  (1280) Size in Mega Bytes
        Selected region size (Use mega bytes value only)  --->
  (8)   Maximum PAGE_SIZE order of alignment for contiguous buffers
```


## 原理

CMA通过在启动阶段预先保留内存。这些内存叫做CMA区域，稍后返回给伙伴系统从而可以被用作正常申请。如果要保留内存，则需要恰好在底层`MEMBLOCK`分配器初始化之后，及大量内存被占用之前调用，并在伙伴系统建立之前调用。

- 页迁移：

当从伙伴系统申请内存的时候，需要提供一个gfp_mask参数。不管其他事情，这个参数指定了要申请内存的迁移类型。迁移类型是MIGRATE_MOVABLE，它背后的意思是在可移动页面上的数据可以被迁移（或者移动，因此而命名），这对于磁盘缓存或者进程页面来说很有效。为了使相同迁移类型的页面在一起，伙伴系统把页面组成 “页面块 (pageblock)”，每组都有一个指定的迁移类型。分配器根据请求的类型在不同的页面块上分配页。如果尝试失败，分配器会在其它页面块上分配并甚至修改页面块的迁移类型。这意味着一个不可移动的页可能分配自一个MIGRATE_MOVABLE页面块，并导致该页面块的迁移类型改变。这不是CMA想要的，所以它引入了一个MIGRATE_CMA类型，该类型又一个重要的属性: **只有可移动页可以从MIGRATE_CMA页面块种分配**。那么，在启动期间，当dma_congiguous_reserve()和dma_declare_contiguous()方法被调用的时候，CMA在memblock中预留一部分RAM，并在随后将其返还给伙伴系统，仅将其页面块的迁移类型置为MIGRATE_CMA. 最终的结果是所有预留的页都在伙伴系统里，所以它们都可以用于可移动页的分配。

- CMA分配与释放
  ```
  int alloc_contig_range(unsigned long start, unsigned long end, unsigned migratetype, gfp_t gfp_mask)
  void free_contig_range(unsigned long pfn, unsigned nr_pages);
  ```
CMA分配，`dma_alloc_from_contiguous()`选择一个页范围，start和end参数指定了目标内存的页框个数（或PFN范围)。参数migratetype指定了潜在的迁移类型; 在CMA的情况下，这个参数就是MIGRATE_CMA。这个函数所做的第一件事是将包含 (start, end) 范围内的页面块标记为 MIGRATE_ISOLATE。伙伴系统不会去触动这种类型的页面块。改变迁移类型不会魔 法般地释放页面，因此接下来需要调用 __alloc_conting_migrate_range()。它扫 描PFN范围并寻找可以迁移的页面。迁移是将页面复制到系统其它内存部分并更新相 关引用的过程。迁移部份很直接，后面的部分需要内存管理子系统来完成。当数据迁 移完成，旧的页面被释放并回归伙伴系统。这就是为什么之前那些需要包含的页面块 一定要标记为 MIGRATE_ISOLATE 的原因。如果指定了其它的迁移类型，伙伴系统会 毫不犹豫地将它们用于其它类型的申请。

现在所有 alloc_contig_range 关心的页都是空闲的了。该方法将从伙伴系统中取 出它们，并将这些页面块的类型改为 MIGRATE_CMA。然后将这些页返回给调用者。

CMA释放：调用free_contig_range函数迭代所有的页面并将其返还给伙伴系统。

> - 当设备驱动不用时，内存管理系统将该区域用于分配和管理可移动类型页面；
> - 当设备驱动使用时，此时已经分配的页面需要进行迁移，又用于连续内存分配；


## 主要数据结构

``` C
struct cma {
    //起始物理地址对应的页帧号，相当于起始地址
    unsigned long   base_pfn;
    //当前CMA区域页的个数，也就内存总容量，页的默认大小4K
    unsigned long   count;
    //使用bitmap机制维护当前CMA区域内存的物理页，每个bit代表一定数量的物理页，至于代表多少物理页与order_per_bit有关
    unsigned long   *bitmap;
    //指明该CMA区域的bitmap中，每个bit代表的页数量为2^order值
    unsigned int order_per_bit; /* Order of pages represented by one bit */
    struct mutex    lock;
#ifdef CONFIG_CMA_DEBUGFS
    struct hlist_head mem_head;
    spinlock_t mem_head_lock;
#endif
    //当前CMA区域的描述名
    const char *name;
};

//存放各个CMA区域的cma信息的数组
extern struct cma cma_areas[MAX_CMA_AREAS];
//统计当前系统初始化的最大可用的cma区域数量
extern unsigned cma_area_count;
```

## 系统CMA调试信息

- CMA区域内存统计
  ```
  # cat /proc/meminfo | grep cma -i
  CmaTotal:        1310720 kB
  CmaFree:         1309472 kB
  ```
- 各个CMA区域详细信息
  ```
  # ls /sys/kernel/debug/cma/cma-reserved/
  alloc          bitmap         free           order_per_bit
  base_pfn       count          maxchunk       used
  ```

  ```
  # cat /sys/kernel/debug/cma/cma-reserved/count
  327680

  # cat /sys/kernel/debug/cma/cma-reserved/bitmap
  4294967295 4294967295 4294967295 4294967295 16777215 0 0 0 4294967295 4294967295 65535 0 4294967295 4294967295 65535 0 0 0 0 0 0 0

  # cat /sys/kernel/debug/cma/cma-reserved/order_per_bit
  0
  ```
- `order_per_bit`,为0,表示bitmap中的每一位bit代表一个1（2^0）个物理页。
- `bitmap`： 其中的每一项占32bit，而每一bit代表的一个物理页的状态，`0`表示free，`1`表示已经分配。（bitmap的总数为count/32, 327680/32=10240）

> 查看bitmap中的特殊数字
> - 4294967295 -> 0xFFFFFFFF: 32位全1
> - 16777215 -> 0xFFFFFF: 24位全1
> - 65535 -> 0xFFFF: 16为全1

## 应用——memuconfig指定

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

```
[  136.103382] alloc_contig_range: [22200, 22ef4) PFNs busy
[  136.110892] alloc_contig_range: [22400, 22ff4) PFNs busy
[  136.118504] alloc_contig_range: [22400, 230f4) PFNs busy
[  136.126102] alloc_contig_range: [22400, 231f4) PFNs busy
[  136.133735] alloc_contig_range: [22400, 232f4) PFNs busy
[  136.141229] alloc_contig_range: [22800, 233f4) PFNs busy
[  136.148870] alloc_contig_range: [22800, 234f4) PFNs busy
[  136.156469] alloc_contig_range: [22800, 235f4) PFNs busy
[  136.164026] alloc_contig_range: [22800, 236f4) PFNs busy
```

函数调用栈：
```
dma_alloc_coherent
  \-> dma_alloc_attrs
    \-> dma_direct_alloc
      \-> arch_dma_alloc
        \-> __dma_direct_alloc_pages
          \-> dma_alloc_contiguous
            \-> cma_alloc
              \-> alloc_contig_range
                \-> pr_info_ratelimited("...PFNs busy\n")
```

`alloc_contig_range`从伙伴系统中分配一定大小的物理页，该接口参数会指定页的起始和结束号。
PFN范围不必是pageblock或MAX_ORDER_NR_PAGES对齐的。PFN范围必须属于一个单独的区域。
这个例程做的第一件事是尝试MIGRATE_ISOLATE范围内的所有页面块。一旦隔离(isolated)，页面块不应该被其他人修改。

``` C
int alloc_contig_range(unsigned long start, unsigned long end,
               unsigned migratetype, gfp_t gfp_mask)
{
	...
	/*
	 * What we do here is we mark all pageblocks in range as
	 * MIGRATE_ISOLATE.  Because pageblock and max order pages may
	 * have different sizes, and due to the way page allocator
	 * work, we align the range to biggest of the two pages so
	 * that page allocator won't try to merge buddies from
	 * different pageblocks and change MIGRATE_ISOLATE to some
	 * other migration type.
	 *
	 * Once the pageblocks are marked as MIGRATE_ISOLATE, we
	 * migrate the pages from an unaligned range (ie. pages that
	 * we are interested in).  This will put all the pages in
	 * range back to page allocator as MIGRATE_ISOLATE.
	 *
	 * When this is done, we take the pages in range from page
	 * allocator removing them from the buddy system.  This way
	 * page allocator will never consider using them.
	 *
	 * This lets us mark the pageblocks back as
	 * MIGRATE_CMA/MIGRATE_MOVABLE so that free pages in the
	 * aligned range but not in the unaligned, original range are
	 * put back to page allocator so that buddy can use them.
	 */

	ret = start_isolate_page_range(pfn_max_align_down(start),           -----<1>
	                   pfn_max_align_up(end), migratetype, 0);
	if (ret < 0)
	    return ret;

	/*
	 * In case of -EBUSY, we'd like to know which page causes problem.
	 * So, just fall through. test_pages_isolated() has a tracepoint
	 * which will report the busy page.
	 *
	 * It is possible that busy pages could become available before
	 * the call to test_pages_isolated, and the range will actually be
	 * allocated.  So, if we fall through be sure to clear ret so that
	 * -EBUSY is not accidentally used or returned to caller.
	 */
	ret = __alloc_contig_migrate_range(&cc, start, end);                 -----<2>
	if (ret && ret != -EBUSY)
	    goto done;
	ret =0;

	/*
	 * Pages from [start, end) are within a MAX_ORDER_NR_PAGES
	 * aligned blocks that are marked as MIGRATE_ISOLATE.  What's
	 * more, all pages in [start, end) are free in page allocator.
	 * What we are going to do is to allocate all pages from
	 * [start, end) (that is remove them from page allocator).
	 *
	 * The only problem is that pages at the beginning and at the
	 * end of interesting range may be not aligned with pages that
	 * page allocator holds, ie. they can be part of higher order
	 * pages.  Because of this, we reserve the bigger range and
	 * once this is done free the pages we are not interested in.
	 *
	 * We don't have to hold zone->lock here because the pages are
	 * isolated thus they won't get removed from buddy.
	 */

	lru_add_drain_all();                                                -----<3>

	order = 0;
	outer_start = start;
	while (!PageBuddy(pfn_to_page(outer_start))) {                      -----<4>
	    if (++order >= MAX_ORDER) {
	        outer_start = start;
	        break;
	    }
	    outer_start &= ~0UL << order;
	}

	if (outer_start != start) {
	    order = page_order(pfn_to_page(outer_start));

	    /*
	     * outer_start page could be small order buddy page and
	     * it doesn't include start page. Adjust outer_start
	     * in this case to report failed page properly
	     * on tracepoint in test_pages_isolated()
	     */
	    if (outer_start + (1UL << order) <= start)
	        outer_start = start;
	}

	/* Make sure the range is really isolated. */
	if (test_pages_isolated(outer_start, end, false)) {                 -----<5>
	    pr_info_ratelimited("%s: [%lx, %lx) PFNs busy\n",
	        __func__, outer_start, end);
	    ret = -EBUSY;
	    goto done;
	}

	/* Grab isolated pages from freelists. */
	outer_end = isolate_freepages_range(&cc, outer_start, end);         -----<6>
	if (!outer_end) {
	    ret = -EBUSY;
	    goto done;
	}

	/* Free head and tail (if any) */
	if (start != outer_start)
	    free_contig_range(outer_start, start - outer_start);
	if (end != outer_end)
	    free_contig_range(end, outer_end - end);

done:
    undo_isolate_page_range(pfn_max_align_down(start),                -----<7>
                pfn_max_align_up(end), migratetype);
    return ret;
}
```

- <1>: start_isolate_page_range将pfn范围内的页设置为隔离（MIGRATE_ISOLATE）
  - 将页面分配类型设置为`MIGRATE_ISOLATE`意味着将永远不会分配范围内的空闲页面。任何空闲页面和将来释放的页面将不会再次分配。如果指定的范围包括MOVABLE或CMA以外的迁移类型，则会使用-EBUSY失败。为了最终隔离范围内的所有页面，调用者必须释放范围内的全部页面。test_page_isolated()可以用于测试它。
  - 请注意，**也没有与页面分配器的强同步。当页面块标记为“已隔离”时，页面可能会被释放**。在某些情况下，页面可能仍然会出现在pcp列表中，这将允许它们的分配，即使它们实际上已经被隔离。根据调用方需要的保证程度，可能需要drain_all_pages（例如__offline_pages需要在检查隔离范围后调用它，以便下次重试）。
  - 一旦页面块被标记为MIGRATE_ISOLATE，我们就从未对齐的范围（即我们感兴趣的页面）迁移页面。这将把范围内的所有页面作为MIGRATE_ISOLATE放回页面分配器。
  - 完成此操作后，我们从页面分配器中获取范围内的页面，并将其从伙伴系统中删除。这样，页面分配器将永远不会考虑使用它们。
  - 这使我们可以将页面块标记回MIGRATE_CMA/MIGRATE_MOVABLE，以便将对齐范围内的空闲页面（而不是未对齐的原始范围内的）放回页面分配器，以便好友可以使用它们。

- <2>: __alloc_contig_migrate_range申请pfn范围内的页，扫描PFN范围页并寻找可迁移的进行迁移，可能返回BUSY，因为存在页无法迁移。
- <3>: lru_add_drain_all对所有CPU实现缓存的刷新,将每CPU中缓存的页面进行释放
- <4>: PageBuddy判断一个页是是否在buddy系统中，如果是1，说明还没有分配出去
- <5>: test_pages_isolated用于检查确保该pfn范围内的页面已经被隔离
- <6>: isolate_freepages_range则是将指定范围的空闲页面隔离出来
- <7>: undo_isolate_page_range则是将所有的标记为隔离的页面重新标记为MIGRATE_CMA，至此所需的连续内存页面已经分配到了，无需在乎其迁移属性了，便更改回去。


> 出现`PFNs busy`是由于在<5>test_pages_isolated中检查到申请pfn范围内的页有没有被隔离出来，才会输出警告信息
> 而没有被隔离的原因是，这些页可能被系统中的其他应用所占用着，而无法被迁移。

## 参考

- [The Contiguous Memory Allocator](https://lwn.net/Articles/396657/)
- [CMA](https://biscuitos.github.io/blog/CMA/#A000)
