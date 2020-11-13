---
layout: "post"
title: "「翻译」Linux DRM开发人员指南"
date: "2020-11-13 17:05"
tags:
  - GPU
  - DRM
categories:
  - 设备驱动
---

最近在看DRM驱动相关的代码，但是总有一种盲人摸象的感觉，今天看到[Linux DRM Developer's Guide](http://www.landley.net/kdocs/htmldocs/drm.html#idp4969552)文档，在这里简单翻译一下,可以对DRM驱动有一个整体的认识。

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



## 模式设置（Mode Setting）



## KMS初始化和清理
