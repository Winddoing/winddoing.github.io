---
layout: post
title: linux驱动——DMA
date: '2021-11-06 16:42'
tags:
  - dma
categories:
  - 设备驱动
abbrlink: 2cf26afe
---

`DMA`（Direct Memory Access），直接内存访问，这里的直接是和需要CPU参与的内存访问相对的概念。

主要使用场景：

- 将数据从一片内存搬到另一片内存
- 从IO设备读取数据到内存
- 将内存数据写入IO设备

<!--more-->

## DMA控制器

### 相关寄存器

DMA控制器 一般都会包含以下寄存器：

- DMA硬件描述符地址寄存器：存放DMA描述符的地址。
- DMA配置寄存器：配置DMA的burst、width、传输方向等属性。
- DMA使能寄存器：使能DMA通道
- DMA中断状态寄存器：获取DMA传输中断状态
- DMA中断使能寄存器：使能DMA通道中断

### DMA描述符

![dma_desc_llp](/images/2021/11/dma_desc_llp.png)

- `DSTATx`： 目的地址
- `SSTATx`： 源地址
- `CTLx`： 描述符配置信息，数据宽度、burst、传输方向、数据大小等
- `LLPx`： 下一个dma描述符地址（内存的物理地址）
- `DARx`/`SARx`： 目标分散寄存器/源收集寄存器（这两个配置没有使用）

DMA控制器进行数据传输时，我们需要申请一块内存（必须保证物理地址连续）用于存在dma描述符。当dma控制器进行工作时，需要将dma描述符的首地址配置到dma描述符地址寄存器中，这样当dma控制器使能正常工作时，会根据dma描述符地址寄存器中的地址读取相应的dma描述符，再根据dma描述符中的相关配置对dma控制器进行配置并进行数据传输，数据传输完成后使能dma传输完成的相应中断。

### DMA request

一般情况下，当外设驱动准备好传输数据及任务配置后，需要向DMA控制器发送`DRQ信号`(DMA request)。所以需要有`物理线`连接DMA控制器和外设，这条物理线称为`DMA request line`。发送这个信号往往是向 DMA配置寄存器中写入DRQ值。每种外设驱动都有自己的DRQ值，当启动DMA传输后，会查询DRQ值，如果当前的DRQ值 能够进行传输，则启动DMA传输。

有时`DMA request (line)`又称为`DMA port`。

### DMA channel

DMA控制器可以`同时`进行的传输个数是有限的，每一个传输都需要使用到DMA物理通道。`DMA物理通道`的数量决定了DMA控制器能够同时传输的任务量。
在软件上，DMA控制器会为外设分配一个DMA虚拟通道，这个虚拟通道是根据`DMA request信号`来区分。
通常来讲，DMA物理通道是DMA控制器提供的服务，外设通过申请DMA通道 ，如果申请成功将返回DMA虚拟通道，该DMA虚拟通道绑定了一个DMA物理通道。这样DMA控制器为外设提供了DMA服务，当外设需要传输数据时，对虚拟通道进行操作即可，但本质上的工作由物理通道来完成。

### DMA burst

dma实际上是一次一次的申请总线，把要传的数据总量分成一个一个小的数据块。比如要传64个字节，那么dma内部可能分为2次，一次传64/2=32个字节，这个2(a)次呢，就叫做`burst`。这个burst是可以设置的,这32个字节又可以分为32bit*8 或者 16bit*16来传输

- `transfer size`(data width): 数据宽度，比如8位、32位，一般跟外设的FIFO相同
- `burst size`: 一次传几个transfer size (一般是外设FIFO深度的一半)

也就是说DMA一次申请总线传输的数据量是(burst_size*data_width)位

## DMA engine

Linux内核里把DMA分为`provider`和`client`两种角色：

- `provider`: DMA控制器驱动，它直接访问寄存器，提供DMA通道，但并不提供用户态可用的系统调用或设备文件
- `client`: 申请使用DMA通道，结合具体外设实现真正的驱动功能

![dma_engine](/images/2021/11/dma_engine.png)
头文件：`include/linux/dmaengine.h`

在DMA Client驱动中粗略的讲要做下面的事情：
1. 申请一个DMA channel——dma_request_chan。
2. 根据设备（slave）的特性，配置DMA channel的参数——dmaengine_slave_config。
3. 要进行DMA传输的时候，获取一个用于识别本次传输（transaction）的描述符（descriptor）—— dmaengine_prep_slave_sg。
4. 将本次传输（transaction）提交给dma engine并启动传输 —— dmaengine_submit。
5. 等待传输（transaction）结束 —— wait_for_completion_timeout。


## Synopsys Designware DMA Controller

```
properties:
  compatible:
    const: snps,dma-spear1340

  "#dma-cells":
    minimum: 3
    maximum: 4
    description: |
      First cell is a phandle pointing to the DMA controller. Second one is
      the DMA request line number. Third cell is the memory master identifier
      for transfers on dynamically allocated channel. Fourth cell is the
      peripheral master identifier for transfers on an allocated channel. Fifth
      cell is an optional mask of the DMA channels permitted to be allocated
      for the corresponding client device.
  reg:
    maxItems: 1

  interrupts:
    maxItems: 1

  clocks:
    maxItems: 1

  clock-names:
    description: AHB interface reference clock.
    const: hclk

  dma-channels:
    description: |
      Number of DMA channels supported by the controller. In case if
      not specified the driver will try to auto-detect this and
      the rest of the optional parameters.
    minimum: 1
    maximum: 8

  dma-requests:
    minimum: 1
    maximum: 16

  dma-masters:
    $ref: /schemas/types.yaml#definitions/uint32
    description: |
      Number of DMA masters supported by the controller. In case if
      not specified the driver will try to auto-detect this and
      the rest of the optional parameters.
    minimum: 1
    maximum: 4

  chan_allocation_order:
    $ref: /schemas/types.yaml#definitions/uint32
    description: |
      DMA channels allocation order specifier. Zero means ascending order
      (first free allocated), while one - descending (last free allocated).
    default: 0
    enum: [0, 1]

  chan_priority:
    $ref: /schemas/types.yaml#definitions/uint32
    description: |
      DMA channels priority order. Zero means ascending channels priority
      so the very first channel has the highest priority. While 1 means
      descending priority (the last channel has the highest priority).
    default: 0
    enum: [0, 1]

  block_size:
    $ref: /schemas/types.yaml#definitions/uint32
    description: Maximum block size supported by the DMA controller.
    enum: [3, 7, 15, 31, 63, 127, 255, 511, 1023, 2047, 4095]

  data-width:
    $ref: /schemas/types.yaml#/definitions/uint32-array
    description: Data bus width per each DMA master in bytes.
    items:
      maxItems: 4
      items:
        enum: [4, 8, 16, 32]

```

- https://github.com/Xilinx/linux-xlnx/blob/master/Documentation/devicetree/bindings/dma/snps%2Cdma-spear1340.yaml


## 参考

- [linux驱动之DMA](https://www.jianshu.com/p/e1b622234d13)
