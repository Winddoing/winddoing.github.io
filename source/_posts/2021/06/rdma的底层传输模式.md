---
layout: post
title: RDMA的底层传输模式
date: '2021-06-07 14:17'
tags:
  - rdma
  - 网络
categories:
  - 网络
---

![rdma_protocol](/images/2021/06/rdma_protocol.png)

常见的RDMA实现有`InfiniBand (IB)`,`RDMA over Converged Etherent (RoCE)`以及`iWARP`

<!--more-->

## RDMA协议

### InfiniBand

InfiniBand (IB) 是一组高性能网络通信标准，由 InfiniBand Trade Association (IBTA) 制定并推动。InfiniBand 架构规范的 1.0 版本发布于 2000 年，其中原生地支持了 RDMA，大概也是最早的 RDMA 实现。然而，IB 架构并不兼容以太网，在部署时除了需要支持 IB 的网卡外，还需要购买相应的交换设备。

### RoCE

RoCE 是基于以太网的 RDMA 标准，同样由 IBTA 制定，允许在以太网网络中实现远程直接内存访问。RoCE 有两个版本：`RoCE v1`与`RoCE v2`。RoCE v1 是链路层协议（L2），可以实现在同一广播域中任意两台主机之间的通信。RoCE v2 是网络层协议（L3），这意味着 RoCE v2 的数据包可以被路由，也就是说可以通过传统的以太网交换机来使用 RDMA。

RoCE v2 构筑于 UDP/IP 协议之上，这种简单快乐的连接虽然保证了高性能与低 CPU 开销，但不能提供可靠传输。一种解决方案是，在 L2 对网络中的流传输进行控制，通过实现无损的以太网传输来保证数据传输的可靠性。另一种解决方案是增加 RoCE 协议的可靠性，向 RoCE 中添加握手，以牺牲性能为代价提供可靠性。业内似乎更倾向于第一种解决方案，即在不丢包的前提下，尽可能提高通信性能，或者说“拥塞控制”。随着大型企业将 RDMA 技术应用到数据中心，各种拥塞控制算法也在不断被提出，比如微软的 DCQCN，谷歌的 Swift，阿里的 HPCC… 其实有关数据中心的拥塞控制也是杀意已决一直想写的话题，不过我还是不给自己挖坑了（喂喂…

### iWARP

iWARP 是基于 TCP/IP 协议、面向连接的 RDMA 传输。由 IEFT 在 2007 年提出。与 RoCE v2 一样，iWARP 数据包可以路由，但在大规模数据中心或大规模应用程序中使用 iWARP 时，大量的 TCP 连接与可靠传输将导致凄惨的性能，在此也不打算过多介绍。牙膏厂曾写过一篇名为“Understanding iWARP”的文章，各位可以访问这里参详。

## 协议对比

### RoCEv2 vs InfiniBand

网络架构：InfiniBand 只能在 IB 架构规范中实现，RoCE 可以在以太网架构中实现。
链路级的流量控制：InfiniBand 使用一个积分算法（credit-based，不是 integral-based）来保证无损的 HCA-to-HCA 通信。RDMA 需要通过无损的 L2 网络（DCB: PFC + ECN）实现可靠的数据传输。
拥塞控制：InfiniBand 使用基于 FECN/BECN 的拥塞控制，RoCE v2 定义了一个拥塞控制协议，通过 ECN 与 CNP 进行拥塞控制。

### RoCEv2 vs RoCEv1

![RDMA_rocev1_vs_rocev2](/images/2021/06/rdma_rocev1_vs_rocev2.png)
路由：RoCE v1只能在广播域内通信，RoCE v2支持L3路由。

### iWARP vs RoCEv2

底层：iWARP基于TCP/IP协议，RoCE v2基于UDP/IP协议。
iWARP 支持传输层的拥塞控制。
不需要无损的L2网络。
性能表现可能会比RoCE糟糕。

## 链路层模式

链路层主要分为两类：`InfiniBand`和`Ethernet`

查看链路类型
```
# ibstat
CA 'mlx4_0'
	CA type: MT4099
	Number of ports: 1
	Firmware version: 2.36.5000
	Hardware version: 1
	Node GUID: 0x001e670300bd84ec
	System image GUID: 0x001e670300bd84ef
	Port 1:
		State: Down
		Physical state: Disabled
		Rate: 10
		Base lid: 0
		LMC: 0
		SM lid: 0
		Capability mask: 0x00010000
		Port GUID: 0x021e67fffebd84ed
		Link layer: Ethernet
```

## InfiniBand与Ethernet之间的区别

- InfiniBand模式的延时更低，带宽更高
  - ConnectX-4 Lx EN （Ethernet）提供 1、10、25、40 和50GbE带宽、`亚微秒级延迟`
  - ConnectX-5 具备 Virtual Protocol Interconnect®,支持具有 100Gb/s InfiniBand 和以太网连接、小于`600纳秒的延迟`
- InfiniBand采用Cut-Through转发模式，减少转发时延，基于Credit流控机制，保证无丢包。RoCE性能与IB网络相当，DCB特性保证无丢包，需要网络支持DCB特性，但时延比IB交换机时延稍高一些
- Ethernet模式可能存在丢包，而导致数据重传的延时


## InfiniBand与Ethernet链路层切换

通过`ibstatus`命令可以查看当前网卡的工作模式

``` shell
Infiniband device 'mlx5_1' port 1 status:
	default gid:	 fe80:0000:0000:0000:0e42:a1ff:fe41:2d37
	base lid:	 0x0
	sm lid:		 0x0
	state:		 4: ACTIVE
	phys state:	 5: LinkUp
	rate:		 25 Gb/sec (1X EDR)
	link_layer:	 Ethernet    （工作模式：IP模式）
```
> 网卡现在处于`Ethernet`的工作模式，如果想要切换成`infiniband`模式

参考：https://community.mellanox.com/s/article/howto-change-port-type-in-mellanox-connectx-3-adapter

ConnectX®-5 端口可以单独配置为用作`InfiniBand`或`Ethernet`端口，使用命令`mlxconfig`

### 启动mst工具
需要安装官方驱动，以下配置用于ConnectX-4网卡。

``` shell
systemctl start mst
```
查看mst设备
``` shell
# mst status
MST modules:
------------
    MST PCI module is not loaded
    MST PCI configuration module loaded

MST devices:
------------
/dev/mst/mt4117_pciconf0         - PCI configuration cycles access.
                                   domain:bus:dev.fn=0000:f7:00.0 addr.reg=88 data.reg=92 cr_bar.gw_offset=-1
                                   Chip revision is: 00
```
> MST devices: /dev/mst/mt4117_pciconf0

注：ConnectX-4网卡无法进行IB与eth模式之间切换，因为该网卡只支持Ethernet模式。只有VPI卡支持IB模式与以太网模式切换。
```
# lspci -s 02:00.0 -v
02:00.0 Ethernet controller: Mellanox Technologies MT27710 Family [ConnectX-4 Lx]
	Subsystem: Mellanox Technologies Stand-up ConnectX-4 Lx EN, 25GbE dual-port SFP28, PCIe3.0 x8, MCX4121A-ACAT
	Physical Slot: 2
	Flags: bus master, fast devsel, latency 0, IRQ 46, NUMA node 0
	Memory at 38007a000000 (64-bit, prefetchable) [size=32M]
	...
```
> ` ConnectX-4 Lx EN`:代表以太网卡，只支持Ethernet模式，ConnectX®-4 Lx EN 支持 RDMA、叠加 (Overlay) 网络封装/解封等功能的1/10/25/40/50 Gb 以太网适配器卡
>  https://www.mellanox.com/files/doc-2020/pb-connectx-4-lx-en-card.pdf


### 查看网卡的配置信息

``` shell
# mlxconfig -d /dev/mst/mt4117_pciconf0 q | grep "LINK"
         KEEP_ETH_LINK_UP_P1                 True(1)
         KEEP_IB_LINK_UP_P1                  False(0)
         KEEP_LINK_UP_ON_BOOT_P1             False(0)
         KEEP_LINK_UP_ON_STANDBY_P1          False(0)
         AUTO_POWER_SAVE_LINK_DOWN_P1        False(0)
         KEEP_ETH_LINK_UP_P2                 True(1)
         KEEP_IB_LINK_UP_P2                  False(0)
         KEEP_LINK_UP_ON_BOOT_P2             False(0)
         KEEP_LINK_UP_ON_STANDBY_P2          False(0)
         AUTO_POWER_SAVE_LINK_DOWN_P2        False(0)
```

### ConnectX-5网卡

> 注： 以下命令适用于`ConnectX-5`，只有VPI卡支持模式切换

例如：ConnectX®-5 VPI 卡 100Gb/s InfiniBand 和以太网适配器卡

- Ethernet模式： `mlxconfig -d /dev/mst/mt4119_pciconf0 set LINK_TYPE_P1=2`
- IB模式： `mlxconfig -d /dev/mst/mt4119_pciconf0 set LINK_TYPE_P1=1`


## 参考

- [Towards Hyperscale High Performance Computing with RDMA](https://pc.nanog.org/static/published/meetings/NANOG76/1999/20190612_Cardona_Towards_Hyperscale_High_v1.pdf)
- [RoCE and InfiniBand: Which should I choose?](https://www.infinibandta.org/roce-and-infiniband-which-should-i-choose/)
- [RDMA简介相关内容](https://blog.csdn.net/github_33873969/article/details/83017820)
- [HowTo Configure RoCE on ConnectX-4](https://mymellanox.force.com/mellanoxcommunity/s/article/howto-configure-roce-on-connectx-4)
- [RDMA over Converged Ethernet (RoCE)](https://docs.mellanox.com/pages/viewpage.action?pageId=39284930)
- [RDMA/RoCE Solutions](https://community.mellanox.com/s/article/rdma-roce-solutions)
- [Recommended Network Configuration Examples for RoCE Deployment](https://community.mellanox.com/s/article/recommended-network-configuration-examples-for-roce-deployment)
- [Mellanox ConnectX-4 Adapters](https://lenovopress.com/lp0098.pdf)
