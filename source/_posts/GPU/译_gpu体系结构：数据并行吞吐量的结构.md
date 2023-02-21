---
layout: post
title: '[译]GPU体系结构：数据并行吞吐量的结构'
date: '2021-03-05 15:42'
tags:
  - gpu
  - nvidia
categories:
  - GPU
abbrlink: b5b80551
---

根据Wikipedia的说法，GPU卡（也称为图形卡或视频卡）是一种专用的电子电路。 它是专门为快速处理和更改内存而设计的，以加快在帧缓冲区中创建图像的速度，因此可以输出到诸如计算机监视器或电视屏幕之类的显示设备。

现代GPU架构在处理图形以及图像处理方面非常有效。 高度并行的结构使其比用于并行处理大型数据块的通用CPU（中央处理单元）体系结构更有效。

在PC内，GPU可以嵌入扩展卡（视频卡）中，预先安装在主板上（专用GPU）或集成到CPU裸片（集成GPU）中。
<!--more-->

## GPU架构

在谈到视频卡体系结构时，它总是涉及CPU体系结构或与之比较。

### GPU vs CPU架构

![CPU vs GPU](/images/2021/03/cpu_vs_gpu.png)


GPU的功能是优化数据吞吐量。它允许一次通过其内部推送尽可能多的任务，这比CPU一次可以处理的任务多得多。这是因为通常情况下，图形卡具有比CPU多得多的内核。

但是，实际上，我们称内核为CUDA（计算统一设备体系结构）内核，该内核由GPU中的全流水线整数ALU（算术逻辑单元）和FPU（浮点单元）组成。在NVIDIA GPU架构中，ALU支持所有指令的完整32位精度。并且，对整数ALU进行了优化，以有效地支持64位扩展精度运算以及各种指令，例如布尔运算，比较，转换，移动，移位，位反向插入，位域提取和填充计数。

通常，GPU的体系结构与CPU的体系结构非常相似。它们都利用高速缓存层，全局内存和内存控制器的内存构造。

高级GPU架构仅涉及数据并行吞吐量计算，并使可用的内核正常工作，而不是像CPU那样专注于低延迟高速缓存的访问。

> 注意：详细的图形卡体系结构在很大程度上取决于不同制造商的品牌和型号。 Nvidia GPU架构与AMD GPU架构不同。


## GPU体系结构基础

在GPU设备中，有多个处理器集群（PC），其中包含多个流式多处理器（SM）。 并且，每个SM都包含一个1层指令高速缓存层及其相关的内核。 通常，一个SM在从全局GDDR-5存储器中提取数据之前，会采用专用的第1层高速缓存和共享的第2层高速缓存。 因此，GPU处理器体系结构可容忍内存延迟。

![Nvidia GPU Architecture](/images/2021/03/nvidia_gpu_architecture.png)


### GCA (Graphics Compute Array)

通常，GCA（也称为3D引擎）由像素着色器，顶点着色器或统一着色器，流处理器（CUDA核心），纹理映射单元（TMU），渲染输出单元（ROP），二级缓存，几何处理器， 等等。

### GMC (Graphics Memory Controller)

GMC，也称为内存芯片控制器（MCC）或内存控制器单元（MCU），是一种数字电路，用于控制进出计算机图形内存的数据流。 它可以是单独的芯片； 它也可以集成到另一个芯片中，例如放置在同一芯片上或作为微处理器的组成部分。 如果GMC作为组成部分存在，则称为IMC（集成内存控制器）。
内存GMC控件包括VRAM，WRAM，MDRAM，DDR，GDDR和HBM。

### VGA BIOS (Video Graphics Array Basic Input/Output System)

VGA BIOS，也称为视频BIOS，是计算机中图形卡的BIOS。 它是位于图形卡上的独立芯片，不是GPU的一部分。

### BIF (Bus Interface)

总线接口（BI）是用于将小型外围设备（例如闪存）与处理器接口的计算机总线。 通常，它包括SA，VLB，PCI，AGP和PCIe。

### PMU (Power Management Unit)

PMU是控制数字平台电源功能的微控制器（微芯片）。 它具有许多与普通计算机类似的组件，例如CPU，内存，固件，软件等。PMU是为数不多的几个组件之一，即使计算机完全关闭，该组件仍由备用电池供电，这些组件仍可以保持活动状态。

在便携式计算机中，PMU协调以下功能：

- 监视电源连接和电池电量。
- 闲置时，请关闭不必要的系统部件。
- 控制睡眠和电源功能（打开或关闭）。
- 控制其他集成电路的电源。
- 管理内置键盘或触控板的界面。
- 必要时给电池充电。
- 调节实时时钟（RTC）。

### VPU (Video Processing Unit)

VPU是一种专用处理器，将视频流作为输入，并且可以对输入流执行非常复杂的过程。 它通常用于机器学习应用程序和设备中，并充当那些设备中的辅助组件。

VPU是负责视频编码和解码的视频编解码器。 因此，它也被称为视频编码器和解码器。 VPU执行MPEG2，Theora，VP8，H.264，H.265，VP9，VC-1等的压缩或解压缩。

### DIF (Display Interface)

显示接口，也称为显示控制器，定义了主机，图像数据源和目标设备之间的串行总线和通信协议。 它包括RAMDAC，HDMI音频，DP音频，视频底图（VGA，DVI，HDMI，DisplayPort，S-Video，复合视频，分量视频），PHY（LVDS，TIMDS）和EDID。

## 参考

- [GPU Architecture: A Structure for Data Parallel Throughput](https://www.partitionwizard.com/partitionmagic/gpu-architecture.html)
