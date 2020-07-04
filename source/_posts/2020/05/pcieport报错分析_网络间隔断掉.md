---
layout: post
title: pcieport报错分析--网络间隔断掉
date: '2020-05-22 17:27'
tags:
  - pcie
  - 网络
  - 网卡
categories:
  - 设备驱动
abbrlink: 7a90000d
---

有线网络间隔断开,查看系统日志pcie端口存在错误打印

```
kernel: pcieport 0000:00:1c.0: AER: Multiple Corrected error received: 0000:00:1c.0
kernel: pcieport 0000:00:1c.0: AER: PCIe Bus Error: severity=Corrected, type=Data Link Layer, (Transmitter ID)
kernel: pcieport 0000:00:1c.0: AER:   device [8086:a115] error status/mask=00001000/00002000
kernel: pcieport 0000:00:1c.0: AER:    [12] Timeout               
```

<!--more-->

## 错误信息

在错误信息中指出PCIE总线`0000:00:1c.0`的设备`[8086:a115]`存在错误


## 确定出错设备

``` shell
$lspci -nn | grep "8086:a115"
00:1c.0 PCI bridge [0604]: Intel Corporation 100 Series/C230 Series Chipset Family PCI Express Root Port #6 [8086:a115] (rev f1)
```
获取出错总线的具体信息

``` shell
$lspci -s 00:1c.0 -v
00:1c.0 PCI bridge: Intel Corporation 100 Series/C230 Series Chipset Family PCI Express Root Port #6 (rev f1) (prog-if 00 [Normal decode])
	Flags: bus master, fast devsel, latency 0, IRQ 121
	Bus: primary=00, secondary=02, subordinate=02, sec-latency=0
	I/O behind bridge: 0000d000-0000dfff [size=4K]
	Memory behind bridge: dfd00000-dfdfffff [size=1M]
	Prefetchable memory behind bridge: 00000000d0000000-00000000d00fffff [size=1M]
	Capabilities: <access denied>
	Kernel driver in use: pcieport
```

## 跟踪端口

``` shell
$lspci -t
-[0000:00]-+-00.0
           +-01.0-[01]--+-00.0
           |            \-00.1
           +-14.0
           +-16.0
           +-17.0
           +-1c.0-[02]----00.0
           +-1f.0
           +-1f.2
           +-1f.3
           \-1f.4
```
pci的树状接口图，这里可以看到`1c.0`接到`02`设备

## 查找设备

``` shell
=====>$lspci -nn | grep "02"
02:00.0 Ethernet controller [0200]: Realtek Semiconductor Co., Ltd. RTL8111/8168/8411 PCI Express Gigabit Ethernet Controller [10ec:8168] (rev 0c)
```
出错设备应该是网卡,设备型号`RTL8111/8168/8411`

## 原因分析

其实类型的错误都可以分析为cpu寻址错误，
部分类型设备可以通过在grub.cfg里面给引导内核时添加参数`pci=nocer`, `pci=nomsi`之类解决，
实际上在正式运行的系统里面不应该有此错误，因为理论上驱动都是经测试正常的
那我们就只能得出一个结论，驱动不适合此设备

> 一般情况下得先确认设备驱动是否合适

## 查看网卡驱动


``` shell
$sudo lshw -C network
  *-network                 
       description: Ethernet interface
       product: RTL8111/8168/8411 PCI Express Gigabit Ethernet Controller
       vendor: Realtek Semiconductor Co., Ltd.
       physical id: 0
       bus info: pci@0000:02:00.0
       logical name: enp2s0
       version: 0c
       serial: c8:5b:76:dc:a4:80
       size: 1Gbit/s
       capacity: 1Gbit/s
       width: 64 bits
       clock: 33MHz
       capabilities: pm msi pciexpress msix vpd bus_master cap_list ethernet physical tp 10bt 10bt-fd 100bt 100bt-fd 1000bt-fd autonegotiation
       configuration: autonegotiation=on broadcast=yes driver=r8168 driverversion=8.048.02-NAPI duplex=full ip=172.16.200.52 latency=0 link=yes multicast=yes port=twisted pair speed=1Gbit/s
       resources: irq:124 ioport:d000(size=256) memory:dfd00000-dfd00fff memory:d0000000-d0003fff
```

**网卡驱动为`r8168`,但是网卡设备是`RTL8111/8168/8411`,出现的错误应该是设备驱动不匹配造成的**

## 更换网卡驱动

``` shell
wget https://codeload.github.com/mtorromeo/r8168/tar.gz/8.048.02
tar zxvf r8168-8.048.02.tar.gz && r8168-8.048.02
sudo ./autorun.sh
```
> 更新完设备驱动后,网络连接正常,系统日志不再出现pcie错误打印
