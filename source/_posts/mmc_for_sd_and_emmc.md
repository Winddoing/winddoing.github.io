---
title: MMC子系统
categories:
  - 设备驱动
tags:
  - 驱动
  - mmc
  - sd
  - emmc
abbrlink: 24681
date: 2016-08-23 23:07:24
---


## MMC子系统

系统框架：

![mmc子系统](/images/mmc_framework.png)

<!---more--->

Linux MMC子系统主要分成三个部分：

- MMC核心层：完成不同协议和规范的实现，为host层和设备驱动层提供接口函数。MMC核心层由三个部分组成：MMC，SD和SDIO，分别为三类设备驱动提供接口函数；
- Host 驱动层：针对不同主机端的SDHC、MMC控制器的驱动；
- Client 驱动层：针对不同客户端的设备驱动程序。如SD卡、T-flash卡、SDIO接口的GPS和wi-fi等设备驱动。

## 代码结构

```
.
├── card
├── core
└── host
```
MMC子系统代码主要在drivers/mmc目录下，共有三个目录：

- Card：与块设备调用相关驱动，如MMC/SD卡设备驱动，SDIOUART；
- Core：整个MMC的核心层，这部分完成不同协议和规范的实现，为host层和设备驱动层提供接口函数。
- Host：针对不同主机端的SDHC、MMC控制器的驱动，这部分需要由驱动工程师来完成；

## 注册流程

在linux系统中，系统启动时将加载相关配置的驱动模块，而各模块的加载将通过各自之间相应的结构关系进行先后顺序进行[设备注册](/posts/linux_kernel_initcall.md)，下面是mmc子系统的注册流程

> core ---> host ---> card

1. core层的注册主要创建两条虚拟总线mmc_bus和sdio_bus，为host层
2. host注册主要为相关控制器的初始化及配置参数
3. card层主要用于与block设备进行绑定，为数据读写准备

## MMC控制器驱动的软件框架

在这里主要以符合sdhci标准的mmc控制器为例，结合sdhci驱动说明mmc的工作流程。

驱动的总体框架：

![mmc驱动软件框架](/images/mmc_software_struct.png)

## 数据结构

mmc子系统是将msc（mobile storage controller）控制器及其该控制器适配的相关外设中的细节屏蔽掉而抽象出来的一种框架。
主要将控制器和卡抽象成为不同的结构mmc_host和mmc_card.

### mmc_host
  该结构体主要为msc控制器所抽象化的一个对象，用于对当前控制器的描述。
``` C
struct mmc_host {
struct device		*parent;
struct device		class_dev;
int			index;
const struct mmc_host_ops *ops;

struct mmc_ios		ios;		/* current io bus settings */

struct mmc_card		*card;		/* device attached to this host */

const struct mmc_bus_ops *bus_ops;	/* current bus driver */
    .
    .
    .
unsigned long		private[0] ____cacheline_aligned;
};
```
以上为该结构体的主要成员（由于成员变量过多省略部分）

1.  struct mmc_host_ops *ops

该接口主要为控制器的操作函数，用于控制器各种行为的控制，由于不同的控制器的设计和使用流程不同，mmc子系统将控制器的实际操作抽象出来，为驱动开发人员，根据实际要求进行功能实现。
主要功能：
  1）request
    为mmc子系统中的request请求进行数据处理，其中包含对cmd命令的发送和data数据的传输（PIO，DMA）
  2）set_ios
    主要设置控制器的各种参数，包括时钟，电压，总线宽度及驱动类型（驱动类型跟卡自身的属性相关）等。
  3）get_sd
    主要由于对卡的探测，实现热插拔功能（一般可能过gpio中断实现）

2. struct mmc_bus_ops

主要为mmc子系统中的一条虚拟总线的操作接口函数，该接口的实现由mmc子系统自己完成。

3. struct mmc_ios		ios

主要为当前总线的设置参数，该总线指控制器和卡实际相接的数据线（cmd，lck，data），主要参数包含set_ios所设置的时钟，电压，总线宽度及驱动类型（驱动类型跟卡自身的属性相关）等参数。

### mmc_card

  主要是与msc控制相连的相关卡的抽象对象，其中主要描述了卡自身的一些属性

## 初始化控制器

## 数据读写

在mmc驱动的核心是数据的读写，根据sd协议数据的读写流程基本一致。

>cmd + data
>cmd_line   先发送读写命令
>data_line  进行数据传输

### 读流程

数据读命令:CMD17和CMD18（single block和multiple block）
![数据读](/images/mmc_single_read.png)
**注**:多个block和多根数据线读，流程基本一致，主要是在数据传输时，将读的数据分配给了4根数据线。

### 写流程

数据读命令:CMD24和CMD25（single block和multiple block）
![数据写](/images/mmc_single_write.png)

注：

- S: start 起始位[0]
- E: end   结束位[1]

| status | 说明 |
| ------ | ---- |
|“010”   | 数据被接受写入卡中 |
|“101”   | 由于CRC错误，数据不被卡接受 |
|“110”   | 由于写错误，数据不被卡接受 |

>在写的过程中由于控制器需要等到卡将数据全部写完，才视一次传输完成。而在卡写的过程中，
>只有数据完全写入后，标志数据传输完成的busy位才会返回。同时返回的还有此次写数据后的状态status(CRC校验值)。
>如果CRC的校验值大于"010",将代表数据传输失败（如果status为“101”， 表示写数据出现CRC错误）

## mmc中的request处理

在mmc子系统中将msc控制器和卡初始化完成后，进入数据传输阶段。在此阶段主要维护一个属于当前控制器的一个线程kthread_run(mmc_queue_thread, mq, "mmcqd/%d%s",host->index, subname ? subname : "")，mmc_queue_thread线程在一个while(1)循环中现实对block层的request请求队列的数据处理。

### 维护mmc_queue_thread线程状态

1. 进入该线程将其设置为set_current_state(TASK_INTERRUPTIBLE)
2. 处理request请求数据，set_current_state(TASK_RUNNING)
3. 数据处理完毕后，如果没有需要处理的数据，调用schedule()

### Block层的request请求队列

请求队列的组成方式：
![request请求队列](/images/block_request_queue.png)
具体的实现方式在block设备驱动继续。

### request请求队列的处理

1. 通过blk_fetch_request(q)从request请求队列中取出一个request请求。
2. 如果request请求队列中有需要处理的数据，调用issue_fn(mq, req)的回调函数进行数据处理。

### 一个request请求的处理流程

这里以multiple block的读写为例进行说明：
#### 写数据的处理

在一个写操作中的request基本可以分为三类:
* a. 使用写命令CMD25写1024block的数据写操作
* b. 先进行数据同步操作，接着使用cmd13获取卡的状态,判断没有错误后,再使用CMD25写1024block数据
* c. 先进行数据同步操作，再单独发送cmd13命令检测卡的状态

>注: 一次request请求所传输的数据量有block层设置.在注册card层初始化mmc_queue时,根据block的设置进行配置.
mmc_blk_probe->mmc_blk_alloc->mmc_blk_alloc_req->mmc_init_queue->blk_queue_max_hw_sectors->blk_limits_max_hw_sectors->BLK_DEF_MAX_SECTORS=1024

#### 读数据的处理

在进行读操作时的request,分为两类:
* a. 携带数据和读命令的request， 及CMD18 + data（512block）
* b. 进行数据同步的request



## 总结

## 附：相关简写

1. mmc
  mmc（Multi-Media Card）主要指mmc子系统
2. sd
  sd（Secure Digital）拥有两层含义：一种指sd卡，另一种指sd卡协议
3. emmc
  emmc（Embedded Multi Media Card)）同样一种指emmc卡，另一种指emmc协议，该卡的主要存储介质为nand flash，因此也称e-nand
3.sdio
  sdio（Secure Digital Input and Output Card）一种在sd标准上定义的外设接口。不过其有自己的特有协议标准。主要由于sdio接口的wifi，蓝牙等
