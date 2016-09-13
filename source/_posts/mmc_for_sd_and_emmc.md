---
title: MMC子系统
date: 2016-08-23 23:07:24
categories: 驱动
tags: [驱动, MMC, SD, EMMC]
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
```
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
