---
layout: "post"
title: "「译」Linux DRM开发人员指南"
date: "2020-11-13 17:05"
tags:
  - GPU
  - DRM
categories:
  - 设备驱动
---

最近在看DRM驱动相关的代码，但是总有一种盲人摸象的感觉，今天看到[Linux DRM Developer's Guide](http://www.landley.net/kdocs/htmldocs/drm.html)文档，在这里简单翻译一下,可以对DRM驱动有一个整体的认识。

<!--more-->


# 第1章 简介

Linux DRM层包含旨在满足复杂图形设备需求的代码，通常包含非常适合3D图形加速的可编程管线。 内核中的图形驱动程序可以利用DRM功能来简化诸如内存管理，中断处理和DMA之类的任务，并为应用程序提供统一的接口。

版本说明：本指南涵盖了DRM树中的功能，包括TTM内存管理器，输出配置和模式设置以及新的vblank内部，以及当前内核中的所有常规功能。


# 第2章 DRM内部

本章介绍了与驱动程序作者和开发人员有关的DRM内部，这些工作人员和开发人员致力于为现有驱动程序添加对最新功能的支持。

首先，我们讨论一些典型的驱动程序初始化要求，例如设置命令缓冲区，创建初始输出配置以及初始化核心服务。 后续部分将更详细地介绍核心内部结构，并提供实施说明和示例。

DRM层为图形驱动程序提供了多种服务，其中许多服务是由它通过libdrm提供的应用程序接口驱动的，libdrm是包装大多数DRM ioctl的库。 其中包括vblank事件处理，内存管理，输出管理，帧缓冲区管理，命令提交和防护，挂起/恢复支持以及DMA服务。

## 驱动程序初始化

每个DRM驱动程序的核心是`drm_driver`结构。 驱动程序通常会静态初始化`drm_driver`结构，然后将其传递给`drm_*_init()`函数之一，以将其注册到DRM子系统。

`drm_driver`结构包含描述驱动程序及其支持的功能的静态信息，以及指向DRM核心将调用以实现DRM API的方法的指针。 我们将首先浏览drm_driver静态信息字段，然后在以后的部分中详细描述各个操作。

### 驱动信息

#### 驱动功能

驱动程序通过在`driver_features`字段中设置适当的标志来告知DRM核心其要求和支持的功能。 由于自注册以来，这些标志会影响DRM核心行为，因此必须将大多数标志设置为注册`drm_driver`实例。

``` C
u32 driver_features;
```
驱动程序功能标志：

- `DRIVER_USE_AGP`： 驱动程序使用AGP接口，DRM核心将管理AGP资源。
- `DRIVER_REQUIRE_AGP`： 驱动程序需要AGP接口才能运行。 AGP初始化失败将成为致命错误。
- `DRIVER_PCI_DMA`：驱动程序具有PCI DMA的功能，将启用PCI DMA缓冲区到用户空间的映射。 不推荐使用。
- `DRIVER_SG`： 驱动程序可以执行scatter/gather DMA，将启用catter/gather缓冲区的分配和映射。 不推荐使用。
- `DRIVER_HAVE_DMA`： 驱动程序支持DMA，将支持用户空间DMA API。 不推荐使用。
- `DRIVER_HAVE_IRQ`： DRIVER_HAVE_IRQ指示驱动程序是否具有由DRM Core管理的IRQ处理程序。 设置该标志后，内核将支持简单的IRQ处理程序安装。 安装过程在“[IRQ注册](http://www.landley.net/kdocs/htmldocs/drm.html#drm-irq-registration)”一节中介绍。
- `DRIVER_IRQ_SHARED`：DRIVER_IRQ_SHARED指示设备和处理程序是否支持共享的IRQ（请注意，这是PCI驱动程序所必需的）。
- `DRIVER_GEM`: 驱动程序使用GEM内存管理器。
- `DRIVER_MODESET`: 驱动程序支持模式设置界面（KMS）。
- `DRIVER_PRIME`: 驱动程序实现DRM PRIME缓冲区共享。
- `DRIVER_RENDER`: 驱动程序支持专用渲染节点。

#### Major, Minor and Patchlevel

``` C
char *name;
char *desc;
char *date;
```
驱动程序名称在初始化时被打印到内核日志中，用于IRQ注册，并通过DRM_IOCTL_VERSION传递给用户空间。
驱动程序描述是通过DRM_IOCTL_VERSION ioctl传递给用户空间的纯信息字符串，否则由内核未使用。
格式为YYYYMMDD的驱动程序日期旨在标识对驱动程序的最新修改日期。 但是，由于大多数驱动程序无法更新它，因此它的值几乎没有用。 DRM内核在初始化时将其打印到内核日志，并通过DRM_IOCTL_VERSION ioctl将其传递到用户空间。

### 驱动加载

加载方法是驱动程序和设备初始化的入口点。 该方法负责分配和初始化驱动程序私有数据，指定支持的性能计数器，执行资源分配和映射（例如，获取时钟，映射寄存器或分配命令缓冲区），初始化内存管理器（称为“内存管理”的部分），安装 IRQ处理程序（称为“ IRQ注册”的部分），设置垂直消隐处理（称为“垂直消隐”的部分），模式设置（称为“模式设置”的部分）和初始输出配置（称为“ KMS初始化”的部分） 和清理”）。

> **注**:
>
> 如果需要考虑兼容性（例如将驱动程序从用户模式设置转换为内核模式设置），则必须小心以防止设备初始化和与当前活动的用户空间驱动程序不兼容的控制。 例如，如果正在使用用户级别模式设置驱动程序，则在加载时执行输出发现和配置会很成问题。 同样，如果使用了不了解内存管理的用户级驱动程序，则可能需要省略内存管理和命令缓冲区设置。 这些要求是特定于驱动程序的，因此必须注意使新旧应用程序和库均能正常工作。

``` C
int (*load) (struct drm_device *, unsigned long flags);
```
该方法有两个参数，一个指向新创建的`drm_device`的指针和标志。 这些标志用于传递与传递给`drm_*_init()`的设备相对应的设备ID的`driver_data`字段。 当前只有PCI设备使用此功能，USB和平台DRM驱动程序的加载方法称为标志0。

## 内存管理

现代Linux系统需要大量的图形内存来存储帧缓冲区，纹理，顶点和其他与图形相关的数据。考虑到许多数据的动态特性，因此有效管理图形内存对于图形堆栈至关重要，并且在DRM基础架构中发挥着核心作用。
DRM核心包括两个`内存管理器`，即`转换表映射（TTM）`和`图形执行管理器（GEM）`。 TTM是第一个开发的DRM内存管理器，并试图成为一种“千篇一律”的解决方案。它提供了一个单一的用户空间API，可满足所有硬件的需求，同时支持统一内存体系结构（UMA）设备和具有专用视频RAM的设备（即大多数离散视频卡）。这导致了一个庞大，复杂的代码片段，结果证明这些代码难以用于驱动程序开发。
GEM最初是由英特尔赞助的项目，以应对TTM的复杂性。它的设计理念是完全不同的：GEM没有为每个与图形内存相关的问题提供解决方案，而是确定了驱动程序之间的通用代码，并创建了一个共享它的支持库。与TTM相比，GEM的初始化和执行要求更简单，但它没有视频RAM管理功能，因此仅限于UMA设备。

### 转换表管理器（TTM）

>**警告**
>
>本节已过时。

### 图形执行管理器（GEM）

GEM设计方法导致内存管理器无法在其用户空间或内核API中提供所有（甚至所有常见）用例的完整覆盖。 GEM向用户空间公开了一组与内存相关的标准操作，并向驱动程序提供了一组帮助程序功能，并允许驱动程序使用自己的私有API来实现特定于硬件的操作。
GEM-LWN上的[Graphics Execution Manager](https://lwn.net/Articles/283798/)文章中介绍了GEM用户空间API。尽管有些过时，但该文档很好地概述了GEM API原则。目前，使用特定于驱动程序的ioctl来实现缓冲区分配以及读写操作（作为通用GEM API的一部分进行描述）。
GEM与数据无关。它管理抽象缓冲区对象，而无需知道各个缓冲区包含哪些内容。因此，需要了解缓冲区内容或用途（例如缓冲区分配或同步原语）的API不在GEM的范围内，必须使用特定于驱动程序的ioctl来实现。

从根本上讲，GEM涉及以下几种操作：
- 内存分配和释放
- 命令执行
- 执行命令时的光圈管理

缓冲区对象分配相对简单，并且主要由Linux的shmem层提供，后者提供了用于备份每个对象的内存。

特定于设备的操作，例如命令执行，固定，缓冲区读写，映射和域所有权转移，留给特定于驱动程序的ioctl。

#### GEM初始化

使用GEM的驱动程序必须在`struct drm_driver` `driver_features`字段中设置`DRIVER_GEM`位。 然后，DRM内核将在调用装入操作之前自动初始化GEM内核。 在后台，这将创建DRM内存管理器对象，该对象提供用于对象分配的地址空间池。
在KMS配置中，如果硬件需要，驱动程序需要在核心GEM初始化之后分配和初始化`命令环缓冲区`。 UMA设备通常具有所谓的“被盗”存储区，该存储区为初始帧缓冲区和设备所需的大而连续的存储区提供了空间。 该空间通常不由GEM管理，必须单独初始化为它自己的DRM MM对象。

#### GEM对象创建

GEM将GEM对象的创建和支持它们的内存分配分为两个不同的操作。

GEM对象由`struct drm_gem_object`的实例表示。 驱动程序通常需要使用私有信息来扩展GEM对象，从而创建特定于驱动程序的GEM对象结构类型，以嵌入`struct drm_gem_object`的实例。
要创建GEM对象，驱动程序会为其特定GEM对象类型的实例分配内存，并通过调用`drm_gem_object_init`初始化嵌入式结构`drm_gem_object`。 该函数获取指向DRM设备的指针，指向GEM对象的指针和缓冲区对象的大小（以字节为单位）。

GEM使用`shmem`分配匿名可分页内存。 `drm_gem_object_init`将创建所需大小的shmfs文件，并将其存储在`struct drm_gem_object filp`字段中。 当图形硬件直接使用系统内存时，该内存既可以用作对象的主要存储，也可以用作后备存储。
驱动程序负责通过为每个页面调用`shmem_read_mapping_page_gfp`来分配实际的物理页面。 请注意，它们可以在初始化GEM对象时决定分配页面，或延迟分配直到需要内存（例如，由于用户空间内存访问而导致页面错误，或者驱动程序需要启动涉及到DMA的传输时）。

例如，当硬件需要物理上连续的系统内存时（例如嵌入式设备中的常见情况），并不总是需要匿名的可分页内存分配。 驱动程序可以通过调用`drm_gem_private_object_init`而不是`drm_gem_object_init`来初始化没有shmfs支持的GEM对象（称为专用GEM对象）。 专用GEM对象的存储必须由驱动程序管理。

不需要使用私有信息扩展GEM对象的驱动程序可以调用`drm_gem_object_alloc`函数来分配和初始化结构`drm_gem_object`实例。 在使用`drm_gem_object_init`初始化GEM对象之后，GEM内核将调用可选的驱动程序`gem_init_object`操作。

``` C
int (*gem_init_object) (struct drm_gem_object *obj);
```

私有GEM对象不存在alloc-and-init函数。

#### GEM对象生命周期

所有GEM对象均由GEM内核`引用计数`。 可以通过分别调用`drm_gem_object_reference`和`drm_gem_object_unreference`来获取和释放引用。 调用者必须持有`drm_device struct_mutex`锁。 为了方便起见，GEM提供了可以在不持有锁的情况下调用的`drm_gem_object_reference_unlocked`和`drm_gem_object_unreference_unlocked`函数。

当释放对GEM对象的最后一个引用时，GEM内核将调用`drm_driver gem_free_object`操作。 该操作对于启用了GEM的驱动程序是必需的，并且必须释放GEM对象和所有关联的资源。

``` C
void (*gem_free_object) (struct drm_gem_object *obj);
```

驱动程序负责释放所有GEM对象资源，包括GEM核心创建的资源。 如果已经为对象创建了`mmap`偏移量（在这种情况下，drm_gem_object::map_list::map不为NULL），则必须通过调用`drm_gem_free_mmap_offset`来释放它。 必须通过调用`drm_gem_object_release`释放shmfs后备存储（如果未创建任何shmfs后备存储，则可以安全地调用该函数）。

#### GEM对象命名

用户空间和内核之间的通信使用本地句柄，全局名称或最近使用的文件描述符来引用GEM对象。 所有这些都是32位整数值。 通常的Linux内核限制适用于文件描述符。
GEM句柄是DRM文件本地的。 应用程序通过特定于驱动程序的ioctl获取GEM对象的句柄，并且可以使用该句柄引用其他标准或特定于驱动程序的ioctl中的GEM对象。 关闭DRM文件句柄将释放其所有GEM句柄并取消引用关联的GEM对象。


##### DRM PRIME辅助功能参考


#### GEM对象映射

因为映射操作相当繁重，所以与通过将缓冲区映射到用户空间相比，GEM支持通过特定于驱动程序的ioctl实现对缓冲区的类似于读/写的访问。 但是，当需要随机访问缓冲区（例如执行软件渲染）时，直接访问对象可能会更有效率。
mmap系统调用不能直接用于映射GEM对象，因为它们没有自己的文件句柄。 当前共存在两种方法来将GEM对象映射到用户空间。 第一种方法使用特定于驱动程序的ioctl来执行映射操作，并在后台调用do_mmap。 这通常被认为是可疑的，似乎不建议使用支持GEM的新驱动程序，因此在此不再赘述。

#### Dumb GEM对象

GEM API并未将GEM对象创建标准化，而是将其留给特定于驱动程序的ioctl。 对于包含特定于设备的用户空间组件（例如，在libdrm中）的完整图形堆栈来说，这不是一个问题，但此限制使基于DRM的早期启动图形不必要地复杂。
`Dumb GEM`对象通过提供标准API来创建适合于扫描的哑缓冲区，从而部分缓解了该问题，然后可以将其用于创建KMS帧缓冲区。

#### 内存一致性 —— Memory Coherency

#### 命令执行 —— Command Execution


## 模式设置（Mode Setting）

驱动程序必须通过在DRM设备上调用`drm_mode_config_init`来初始化模式设置核心。 该函数初始化`drm_device mode_config`字段，并且永不失败。 完成后，必须通过初始化以下字段来设置模式配置。

``` C
int min_width, min_height;
int max_width, max_height;
```
> 帧缓冲区的最小和最大宽度和高度，以像素为单位。

``` C
struct drm_mode_config_funcs *funcs;
```
> 模式设定函数

### 帧缓冲区创建

### 输出轮询——Output Polling


### 锁定——Locking

除了某些具有自己的锁定的查找结构（隐藏在接口功能后面）之外，大多数模式集状态还受`dev->mode_config.lock`互斥锁以及逐个`crtc锁`的保护，以允许进行`光标更新`，`页面翻转`和后台任务（例如输出检测）同时发生的类似操作。 跨域的操作（例如完整模式集）始终会抓住所有锁。 那里的驱动程序需要通过额外的锁定来保护crtcs之间共享的资源。 如果modset功能碰到crtc状态，例如，如果他们碰到crtc状态，他们还需要小心以始终抓住相关的crtc锁。 用于负载检测（仅抓取`mode_config.lock`以允许实时crtcs上的并发屏幕更新）。

## KMS初始化和清理

KMS设备被抽象并作为一组平面，`CRTC`，`encoders`和`connectors`。 因此，KMS驱动程序必须在初始化模式设置后的加载时创建并初始化所有这些对象。

### CRTCs (struct drm_crtc)

`CRTC`是代表芯片一部分的抽象，其中包含指向扫描缓冲区的指针。 因此，可用的CRTC数量决定了在任何给定时间可以激活多少个独立的扫描缓冲区。 CRTC结构包含几个字段来支持此操作：指向某些视频内存的指针（抽象为帧缓冲区对象），显示模式以及视频内存中的（x，y）偏移量以支持平移或配置，其中一个 视频存储器跨越多个CRTC。

#### CRTC初始化

KMS设备必须创建并注册至少一个`struct drm_crtc`实例。 该实例可能由驱动程序分配并归零（可能是较大结构的一部分），并使用指向CRTC函数的指针通过调用`drm_crtc_init`进行注册。

#### CRTC运作

##### Set Configuration

``` C
int (*set_config)(struct drm_mode_set *set);
```
将新的CRTC配置应用于设备。 该配置指定了CRTC，要从中扫描出的帧缓冲区，帧缓冲区中的（x，y）位置，显示模式以及连接器阵列（如果可能）以CRTC驱动。
如果配置中指定的帧缓冲区为NULL，则驱动程序必须分离所有连接到CRTC的编码器和所有连接到这些编码器的连接器，并禁用它们。
在保持模式配置锁定的情况下调用此操作。

> **注**:
>
>FIXME：set_config应该如何与DPMS交互？ 如果CRTC被暂停，是否应该恢复？

##### Page Flipping

``` C
int (*page_flip)(struct drm_crtc *crtc, struct drm_framebuffer *fb,
                   struct drm_pending_vblank_event *event);
```

将`页面翻转`到CRTC的给定`帧缓冲区`。在保持模式配置互斥锁的情况下调用此操作。
`页面翻转`是一种`同步机制`，可以在`垂直消隐期`(vblank)间将CRTC扫描出的帧缓冲区替换为新的帧缓冲区，从而避免撕裂。当应用程序请求页面翻转时，DRM内核将验证新的帧缓冲区是否足够大，以供CRTC在当前配置的模式下进行扫描，然后使用指向新帧缓冲区的指针调用CRTC page_flip操作。
`page_flip`操作安排页面翻转。一旦完成了针对新帧缓冲区的任何暂挂渲染，CRTC将重新编程为在下一次垂直刷新后显示该帧缓冲区。该操作必须立即返回，而不必等待渲染或页面翻转完成，并且必须阻止任何新的渲染到帧缓冲区，直到页面翻转完成。
如果可以成功调度页面翻转，则驱动程序必须将`drm_crtc->fb`字段设置为fb指向的新帧缓冲区。这一点很重要，这样可以使基于帧缓冲区的引用计数保持平衡。
如果页面翻转已经挂起，则page_flip操作必须返回-EBUSY。

为了将页面翻转同步到`垂直消隐`，驱动程序可能需要启用`垂直消隐`中断。 为此，它应该调用`drm_vblank_get`，并在页面翻转完成后调用`drm_vblank_put`。
如果在翻页完成时请求通知应用程序，则将使用指向`drm_pending_vblank_event`实例的非NULL事件参数来调用`page_flip`操作。 翻页完成后，驱动程序必须调用`drm_send_vblank_event`填写事件并发送以唤醒所有等待的进程。

``` C
spin_lock_irqsave(&dev->event_lock, flags);
...
drm_send_vblank_event(dev, pipe, event);
spin_unlock_irqrestore(&dev->event_lock, flags);
```
> **注**:
>
>FIXME：不需要等待渲染完成的驱动程序是否可以将事件添加到dev-> vblank_event_list并让DRM内核处理所有事情，例如“常规”垂直消隐事件？

在等待页面翻转完成时，驱动程序可以自由使用`event->base.link`列表头，以将未决事件存储在特定于驱动程序的列表中。
如果在发出事件信号之前关闭了文件句柄，则驱动程序必须注意在其预关闭操作中销毁该事件（如果需要，请调用`drm_vblank_put`）。

##### Miscellaneous（其他）

``` C
void (*set_property)(struct drm_crtc *crtc,
                     struct drm_property *property, uint64_t value);
```
> 将给定的CRTC属性的值设置为value。 有关属性的更多信息，请参见“ KMS属性”一节。

``` C
void (*gamma_set)(struct drm_crtc *crtc, u16 *r, u16 *g, u16 *b,
                        uint32_t start, uint32_t size);
> 将灰度系数应用于设备。 该操作是可选的。

``` C
void (*destroy)(struct drm_crtc *crtc);
```
> 不再需要时销毁CRTC。 请参阅“ KMS初始化和清理”部分。

### Planes (struct drm_plane)

平面(plane)表示可以在扫描过程中与CRTC`混合`或`叠加`在CRTC顶部的图像源。 平面与帧缓冲区关联，以裁剪图像存储器（源）的一部分，并可以选择将其缩放到目标大小。 然后将结果与CRTC混合或叠加在CRTC之上。

#### Plane Initialization

平面是可选的。 要创建平面，KMS驱动程序会分配`struct drm_plane`实例（可能是较大结构的一部分）的实例并将其清零，并通过调用`drm_plane_init`对其进行注册。 该函数采用可与平面关联的CRTC的位掩码，指向平面函数的指针以及格式支持的格式的列表。

#### Plane Operations

``` C
int (*update_plane)(struct drm_plane *plane, struct drm_crtc *crtc,
                        struct drm_framebuffer *fb, int crtc_x, int crtc_y,
                        unsigned int crtc_w, unsigned int crtc_h,
                        uint32_t src_x, uint32_t src_y,
                        uint32_t src_w, uint32_t src_h);
```
> 启用并配置平面以使用给定的CRTC和帧缓冲区。

帧缓冲存储器坐标中的源矩形由`src_x`，`src_y`，`src_w`和`src_h`参数（作为16.16定点值）给出。 不支持亚像素平面坐标的设备可以忽略小数部分。
CRTC坐标中的目标矩形由`crtc_x`，`crtc_y`，`crtc_w`和`crtc_h`参数（作为整数值）给出。 设备将源矩形缩放为目标矩形。 如果不支持缩放，并且源矩形大小与目标矩形大小不匹配，则驱动程序必须返回-EINVAL错误。

``` C
int (*disable_plane)(struct drm_plane *plane);
```
禁用平面。 DRM内核会调用此方法，以响应将帧缓冲区ID设置为0，`DRM_IOCTL_MODE_SETPLANE` ioctl调用。CRTC不能处理禁用的平面。

``` C
void (*destroy)(struct drm_plane *plane);
```
不再需要时销毁平面。 请参阅“ KMS初始化和清理”部分。

### Encoders (struct drm_encoder)

`编码器`从CRTC提取像素数据，并将其转换为适合任何连接的`连接器`的格式。 在某些设备上，CRTC可能会向多个编码器发送数据。 在那种情况下，两个编码器都将从同一个扫描缓冲区接收数据，从而导致跨连接到每个编码器的连接器的“克隆”显示配置。

#### Encoder Initialization

对于CRTC，KMS驱动程序必须创建，初始化和注册至少一个`struct drm_encoder`实例。 该实例由驱动程序分配并归零，可能是较大结构的一部分。
驱动程序必须在注册编码器之前初始化`struct drm_encoder`可能的`_crtcs`和可能的克隆字段。 这两个字段分别是编码器可以连接到的CRTC的位掩码，并且是用于克隆的同级编码器。
初始化之后，必须使用对`drm_encoder_init`的调用来注册编码器。 该函数获取指向编码器功能和编码器类型的指针。 支持的类型是
- DRM_MODE_ENCODER_DAC用于VGA和DVI-I / DVI-A上的模拟
- DRM_MODE_ENCODER_TMDS用于DVI，HDMI和（嵌入式）DisplayPort
- DRM_MODE_ENCODER_LVDS用于显示面板
- 用于电视输出的DRM_MODE_ENCODER_TVDAC（复合，S视频，分量，SCART）
- DRM_MODE_ENCODER_VIRTUAL用于虚拟机显示

`编码器`必须连接到`CRTC`才能使用。 DRM驱动程序在初始化时不附加编码器。 应用程序（或实现时的fbdev兼容性层）负责将要使用的编码器附加到CRTC。

#### Encoder Operations

``` C
void (*destroy)(struct drm_encoder *encoder);
```
在不再需要时调用以销毁编码器。 请参阅“ KMS初始化和清理”部分。

``` C
void (*set_property)(struct drm_plane *plane,
                     struct drm_property *property, uint64_t value);
```
将给定平面属性的值设置为value。 有关属性的更多信息，请参见“ KMS属性”一节。

### Connectors (struct drm_connector)

`连接器`是设备上像素数据的最终目标，并且通常直接连接到外部显示设备，例如监视器或笔记本电脑面板。 一次只能将一个连接器连接到一个编码器。 连接器也是保留有关附加显示器信息的结构，因此它包含显示数据，EDID数据，DPMS和连接状态以及有关附加显示器支持的模式的信息的字段。

#### Connector Initialization

最后，KMS驱动程序必须创建，初始化，注册并附加至少一个`struct drm_connector`实例。 该实例将与其他KMS对象一起创建，并通过设置以下字段进行初始化。

- `interlace_allowed`： 连接器是否可以处理隔行模式。
- `doublescan_allowed`：连接器是否可以处理双重扫描。
- `display_info`：当检测到显示时，显示信息由`EDID`信息填充。 对于嵌入式系统中的非热插拔显示器（如平板显示器），驱动程序应使用显示器的物理尺寸初始化`display_info.width_mm`和`display_info.height_mm`字段。
- `polled`： 连接器轮询模式，组合
  - `DRM_CONNECTOR_POLL_HPD`：连接器会生成热插拔事件，不需要定期进行轮询。 不能将`CONNECT和DISCONNECT`标志与`HPD`标志一起设置。
  - `DRM_CONNECTOR_POLL_CONNECT`：定期轮询连接器以进行连接。
  - `DRM_CONNECTOR_POLL_DISCONNECT`：定期轮询连接器是否断开连接。

对于不支持连接状态发现的连接器，设置为0。

然后，使用指向连接器功能和连接器类型的指针，调用`drm_connector_init`来注册连接器，并通过调用`drm_sysfs_connector_add`通过sysfs公开连接器。

支持的连接器类型为：
- DRM_MODE_CONNECTOR_VGA
- DRM_MODE_CONNECTOR_DVII
- DRM_MODE_CONNECTOR_DVID
- DRM_MODE_CONNECTOR_DVIA
- DRM_MODE_CONNECTOR_Composite
- DRM_MODE_CONNECTOR_SVIDEO
- DRM_MODE_CONNECTOR_LVDS
- DRM_MODE_CONNECTOR_Component
- DRM_MODE_CONNECTOR_9PinDIN
- DRM_MODE_CONNECTOR_DisplayPort
- DRM_MODE_CONNECTOR_HDMIA
- DRM_MODE_CONNECTOR_HDMIB
- DRM_MODE_CONNECTOR_TV
- DRM_MODE_CONNECTOR_eDP
- DRM_MODE_CONNECTOR_VIRTUAL

必须将`connector`连接到`encoder`上才能使用。 对于将连接器映射到编码器1：1的设备，应在初始化时通过调用`drm_mode_connector_attach_encoder`来连接连接器。 驱动程序还必须将`drm_connector`编码器字段设置为指向附加的编码器。

最后，驱动程序必须通过调用`drm_kms_helper_poll_init`来初始化连接器状态更改检测。 如果至少一个连接器是可轮询的，但不能生成热插拔中断（由`DRM_CONNECTOR_POLL_CONNECT`和`DRM_CONNECTOR_POLL_DISCONNECT`连接器标志指示），则延迟的工作将自动排队，以定期轮询更改。 可以生成热插拔中断的连接器必须改用`DRM_CONNECTOR_POLL_HPD`标志进行标记，并且它们的中断处理程序必须调用`drm_helper_hpd_irq_event`。 该功能将使延迟的工作排队等待检查所有连接器的状态，但是不会进行定期轮询。

#### Connector Operations

> **注**:
>
>除非另有说明，否则所有操作都是强制性的。

##### DPMS(Display Power Management Signaling)

``` C
void (*dpms)(struct drm_connector *connector, int mode);
```
DPMS操作设置连接器的电源状态。 模式参数是以下之一
- DRM_MODE_DPMS_ON
- DRM_MODE_DPMS_STANDBY
- DRM_MODE_DPMS_SUSPEND
- DRM_MODE_DPMS_OFF

在除DPMS_ON模式以外的所有模式下，连接器所连接的编码器均应通过适当地驱动其信号，将显示器置于低功耗模式。 如果编码器上连接了多个连接器，则应注意不要改变其他显示器的电源状态。 当所有相关的连接器都置于低功耗模式时，应将低功耗模式传播到编码器和CRTC。

##### Modes

``` C
int (*fill_modes)(struct drm_connector *connector, uint32_t max_width,
                      uint32_t max_height);
```
用连接器所有受支持的模式填充模式列表。 如果`max_width`和`max_height`参数不为零，则实现必须忽略所有大于`max_width`或大于`max_height`的模式。

连接器还必须使用连接的显示器物理尺寸（以毫米为单位）填写此操作的`display_info width_mm`和`height_mm`字段。 如果该值未知或不适用（例如，对于投影仪设备），则应将字段设置为0。

##### Connection Status

如果支持，则通过轮询或热插拔事件更新连接状态（请参阅[polled]()）。 状态值通过ioctls报告给用户空间，并且不能在驱动程序内部使用，因为状态值只能通过从用户空间调用drm_mode_getconnector进行初始化。

``` C
enum drm_connector_status (*detect)(struct drm_connector *connector,
                                        bool force);
```
检查是否有任何东西连接到连接器。 由于用户请求，在轮询时将`force`参数设置为false，或者在检查连接器时将`force`参数设置为true。 驾驶员可以使用这种力来避免自动探测过程中昂贵的破坏性操作。
如果连接器已连接某些东西，则返回`connector_status_connected`；如果未连接任何东西，则返回`connector_status_disconnected`；如果连接状态未知，则返回`connector_status_unknown`。
如果确实已将连接状态探测为已连接，则驱动程序仅应返回connector_status_connected。 无法检测到连接状态的连接器或失败的连接状态探测，应返回connector_status_unknown。

##### Miscellaneous

``` C
void (*set_property)(struct drm_connector *connector,
                     struct drm_property *property, uint64_t value);
```
> 将给定的连接器属性的值设置为value。 有关属性的更多信息，请参见“ KMS属性”一节。

``` C
void (*destroy)(struct drm_connector *connector);
```
> 不再需要时销毁连接器。 请参阅“ KMS初始化和清理”部分。

### Cleanup

DRM核心管理其对象的生存期。 当不再需要某个对象时，内核调用其destroy函数，该函数必须清除并释放为该对象分配的所有资源。 每个`drm_*_init`调用必须与相应的`drm_*_cleanup`调用匹配，以清理CRTC（drm_crtc_cleanup），平面（drm_plane_cleanup），编码器（drm_encoder_cleanup）和连接器（drm_connector_cleanup）。 此外，在调用`drm_connector_cleanup`之前，必须通过调用`drm_sysfs_connector_remove`来删除已添加到sysfs的连接器。

必须通过调用`drm_kms_helper_poll_fini`清除连接器状态更改检测。

### Output discovery and initialization example

``` C
void intel_crt_init(struct drm_device *dev)
{
	struct drm_connector *connector;
	struct intel_output *intel_output;

	intel_output = kzalloc(sizeof(struct intel_output), GFP_KERNEL);
	if (!intel_output)
		return;

	connector = &intel_output->base;
	drm_connector_init(dev, &intel_output->base,
			   &intel_crt_connector_funcs, DRM_MODE_CONNECTOR_VGA);

	drm_encoder_init(dev, &intel_output->enc, &intel_crt_enc_funcs,
			 DRM_MODE_ENCODER_DAC);

	drm_mode_connector_attach_encoder(&intel_output->base,
					  &intel_output->enc);

	/* Set up the DDC bus. */
	intel_output->ddc_bus = intel_i2c_create(dev, GPIOA, "CRTDDC_A");
	if (!intel_output->ddc_bus) {
		dev_printk(KERN_ERR, &dev->pdev->dev, "DDC bus registration "
			   "failed.\n");
		return;
	}

	intel_output->type = INTEL_OUTPUT_ANALOG;
	connector->interlace_allowed = 0;
	connector->doublescan_allowed = 0;

	drm_encoder_helper_add(&intel_output->enc, &intel_crt_helper_funcs);
	drm_connector_helper_add(connector, &intel_crt_connector_helper_funcs);

	drm_sysfs_connector_add(connector);
}
```
在上面的示例（取自i915驱动程序）中，创建了CRTC，连接器和编码器组合。 还创建了特定于设备的i2c总线，以获取EDID数据并执行监视器检测。 该过程完成后，将向sysfs注册新的连接器，以使其属性可用于应用程序。

### [KMS API Functions](http://www.landley.net/kdocs/htmldocs/drm.html#idp5132320)


## Mode Setting Helper Functions

驱动程序提供的`CRTC`，`编码器`和`连接器`功能实现DRM API。它们由DRM核心和ioctl处理程序调用以处理设备状态更改和配置请求。由于实现这些功能通常需要特定于驱动程序的逻辑，因此可以使用中间层帮助程序功能来避免重复样板代码。

DRM核心包含一个`中间层(mid-layer)`实现。中间层提供了几种`CRTC`，`编码器`和`连接器`功能的实现（从中间层的顶部调用），这些功能可预处理请求并调用驱动程序提供的较低级功能（在中间层的底部） 。例如，`drm_crtc_helper_set_config`函数可用于填充结构`drm_crtc_funcs set_config`字段。调用时，它将`set_config`操作拆分为更小，更简单的操作，并调用驱动程序进行处理。

要使用中间层，驱动程序调用`drm_crtc_helper_add`，`drm_encoder_helper_add`和`drm_connector_helper_add`函数以安装其中间层底层操作处理程序，并使用指向中间层顶层API的指针填充drm_crtc_funcs，drm_encoder_funcs和drm_connector_funcs结构。最好在注册相应的KMS对象之后立即完成中间层底部操作处理程序的安装。

`mid-layer`未在`CRTC`，`encoder`和`connector`操作之间划分。要使用它，驱动程序必须为所有三个KMS实体提供底层功能。

### Helper Functions

``` C
int drm_crtc_helper_set_config(struct drm_mode_set *set);
```
`drm_crtc_helper_set_config`帮助器函数是CRTC `set_config`实现。它首先尝试通过调用连接器`best_encoder`帮助程序操作来找到每个连接器的最佳编码器。

找到合适的编码器后，帮助器函数将调用`mode_fixup`编码器和CRTC帮助器操作来调整请求的模式，或者完全拒绝该模式，在这种情况下，错误将返回给应用程序。如果模式调整后的新配置与当前配置相同，则辅助功能将返回而无需执行任何其他操作。

如果调整后的模式与当前模式相同，但是需要对帧缓冲区进行更改，则`drm_crtc_helper_set_config`函数将调用CRTC `mode_set_base`帮助程序操作。如果调整后的模式不同于当前模式，或者如果未提供`mode_set_base`辅助操作，则辅助功能通过按此顺序调用prepare，mode_set以及commit CRTC和编码器辅助操作来执行完整模式设置序列。

``` C
void drm_helper_connector_dpms(struct drm_connector *connector, int mode);
```
`drm_helper_connector_dpms`帮助器函数是一个连接器dpms实现，可跟踪连接器的电源状态。 要使用该功能，驱动程序必须为CRTC和编码器提供dpms帮助程序操作，以将DPMS状态应用于设备。

``` C
int drm_helper_probe_single_connector_modes(struct drm_connector *connector,
                                            uint32_t maxX, uint32_t maxY);
```
`drm_helper_probe_single_connector_modes`帮助器函数是连接器`fill_modes`实现，该实现更新连接器的连接状态，然后通过调用连接器`get_modes`帮助器操作来检索模式列表。

如果指定，该函数将滤除大于max_width和max_height的模式。 然后，它为所探测列表中的每个模式调用连接器mode_valid helper操作，以检查该模式是否对连接器有效。

### CRTC Helper Operations

``` C
bool (*mode_fixup)(struct drm_crtc *crtc,
                       const struct drm_display_mode *mode,
                       struct drm_display_mode *adjusted_mode);
```
让CRTC调整请求的模式或完全拒绝它。 如果模式被接受（可能在调整之后），则此操作返回true；如果模式被拒绝，则返回false。

如果无法合理使用`mode_fixup`操作，则应拒绝该模式。 在这种情况下，“合理”的定义目前是模糊的。 一种可能的行为是，当将固定模式面板与能够缩放的硬件一起使用时，将调整后的模式设置为面板定时。 另一行为是接受任何输入模式并将其调整为硬件支持的最接近模式（FIXME：这需要澄清）。


``` C
int (*mode_set_base)(struct drm_crtc *crtc, int x, int y,
                     struct drm_framebuffer *old_fb)
```
将当前帧缓冲区（存储在crtc-> fb中）上的CRTC移到位置（x，y）。 帧缓冲区，x位置或y位置中的任何一个都可能已被修改。
此帮助程序操作是可选的。 如果未提供，则`drm_crtc_helper_set_config`函数将退回到`mode_set`帮助程序操作。
>**注意**
>
>FIXME：为什么将x和y作为参数传递，因为可以通过`crtc->x`和`crtc->y`来访问它们？

``` C
void (*prepare)(struct drm_crtc *crtc);
```
准备CRTC以进行模式设置。 验证请求的模式后，将调用此操作。 驱动程序使用它来执行设置新模式之前所需的设备特定操作。

``` C
int (*mode_set)(struct drm_crtc *crtc, struct drm_display_mode *mode,
                struct drm_display_mode *adjusted_mode, int x, int y,
                struct drm_framebuffer *old_fb);
```
设置新的模式，位置和帧缓冲区。 取决于设备要求，该模式可以由驱动程序在内部存储，并在`commit`操作中应用，或立即编程到硬件。
成功时，`mode_set`操作将返回0，如果发生错误，则返回负错误代码。

``` C
void (*commit)(struct drm_crtc *crtc);
```
提交模式。 设置新模式后将调用此操作。 返回时，设备必须使用新模式并可以完全操作。

### Encoder Helper Operations

``` C
bool (*mode_fixup)(struct drm_encoder *encoder,
                       const struct drm_display_mode *mode,
                       struct drm_display_mode *adjusted_mode);
```
让编码器调整请求的模式或完全拒绝它。 如果模式被接受（可能在调整之后），则此操作返回true；如果模式被拒绝，则返回false。 有关允许的调整的说明，请参见mode_fixup CRTC帮助器操作。

``` C
void (*prepare)(struct drm_encoder *encoder);
```
准备编码器以进行模式设置。 验证请求的模式后，将调用此操作。 驱动程序使用它来执行设置新模式之前所需的设备特定操作。

``` C
void (*mode_set)(struct drm_encoder *encoder,
                 struct drm_display_mode *mode,
                 struct drm_display_mode *adjusted_mode);
```
设置新模式。 取决于设备要求，该模式可以由驱动程序在内部存储，并在`commit`操作中应用，或立即编程到硬件。

``` C
void (*commit)(struct drm_encoder *encoder);
```
提交模式。 设置新模式后将调用此操作。 返回时，设备必须使用新模式并可以完全操作。

### Connector Helper Operations

``` C
struct drm_encoder *(*best_encoder)(struct drm_connector *connector);
```
将指针返回到连接器的最佳编码器。 将连接器映射到编码器1：1的设备只需将指针返回到关联的编码器即可。 此操作是强制性的。

``` C
struct drm_encoder *(*best_encoder)(struct drm_connector *connector);
```
通过使用`drm_add_edid_modes`解析EDID数据或直接为每种受支持的模式调用`drm_mode_probed_add`来填充连接器的`probed_modes`列表，并返回其检测到的模式数。 此操作是强制性的。

手动添加模式时，驱动程序通过调用`drm_mode_create`来创建每种模式，并且必须填写以下字段。

- `__u32 type;`
  - `DRM_MODE_TYPE_PREFERRED` —— 连接器的首选模式（一般设置该值）

``` C
int (*mode_valid)(struct drm_connector *connector,
		  struct drm_display_mode *mode);
```
验证模式对于连接器是否有效。 对于支持的模式，返回`MODE_OK`；对于不支持的模式，返回枚举`drm_mode_status`值（MODE_ *）之一。 此操作是强制性的。

由于当前不使用模式拒绝原因来立即删除不受支持的模式，因此无论该模式无效的确切原因如何，实现都可以返回MODE_BAD。
> **注意:**
>
> 请注意，仅针对设备检测到的模式调用`mode_valid helper`操作，而不针对用户通过CRTC `set_config`操作设置的模式。

### [Modeset Helper Functions Reference](http://www.landley.net/kdocs/htmldocs/drm.html#idp5732240)

### [fbdev Helper Functions Reference](http://www.landley.net/kdocs/htmldocs/drm.html#idp5876896)

### [Display Port Helper Functions Reference](http://www.landley.net/kdocs/htmldocs/drm.html#idp6119632)

### [EDID Helper Functions Reference](http://www.landley.net/kdocs/htmldocs/drm.html#idp6149392)

### [Rectangle Utilities Reference](http://www.landley.net/kdocs/htmldocs/drm.html#idp6391776)

### [Flip-work Helper Reference](http://www.landley.net/kdocs/htmldocs/drm.html#idp6706608)

### [VMA Offset Manager](http://www.landley.net/kdocs/htmldocs/drm.html#idp6798544)

## [KMS Properties](http://www.landley.net/kdocs/htmldocs/drm.html#drm-kms-properties)

## [Vertical Blanking](http://www.landley.net/kdocs/htmldocs/drm.html#drm-vertical-blank)

## [Open/Close, File Operations and IOCTLs](http://www.landley.net/kdocs/htmldocs/drm.html#idp7217408)

### [Open and Close](http://www.landley.net/kdocs/htmldocs/drm.html#idp7218096)

### [File Operations](http://www.landley.net/kdocs/htmldocs/drm.html#idp7232368)

### [IOCTLs](http://www.landley.net/kdocs/htmldocs/drm.html#idp7244832)

# 第3章 用户态接口

## VBlank事件处理

DRM核心公开了两个垂直的空白相关的ioctl：

- `DRM_IOCTL_WAIT_VBLANK`: 它以struct drm_wait_vblank结构作为其参数，并在发生指定的vblank事件时用于阻止或请求信号。
- `DRM_IOCTL_MODESET_CTL`: 在模式设置之前和之后，应由应用程序级别的驱动程序调用此方法，因为在许多设备上，垂直空白计数器会在那时重置。 在内部，当使用_DRM_PRE_MODESET命令调用ioctl时，DRM会对最后的vblank计数进行快照，以使计数器不会向后移动（使用_DRM_POST_MODESET时将进行处理）。
