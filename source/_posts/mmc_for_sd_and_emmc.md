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

## 初始化控制器

## 数据读写

##  总结
