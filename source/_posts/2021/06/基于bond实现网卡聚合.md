---
layout: post
title: 基于bonding实现网卡聚合
date: '2021-06-03 10:07'
tags:
  - 网卡
  - bond
  - 聚合
categories:
  - 网络
abbrlink: c9919005
---

`bonding`是一个linux kernel的driver，加载了它以后，linux支持将多个物理网卡捆绑成一个虚拟的bond网卡

``` shell
# lsmod | grep bond
bonding               155648  0
```

利用bonding技术与交换机的端口动态聚合实现双网口的绑定

![网口聚合bond](/images/2021/06/网口聚合bond.png)

<!--more-->

## bond模式

|  mode  | 别名               | 描述 | 参数 | 交换机                             |
|:------:|:-------------------|:-----|:-----|:-----------------------------------|
| mode=0 | mode=balance-rr    | 平衡抡循环策略，传输数据包顺序是依次传输，此模式提供负载平衡和容错能力  |      |                                    |
| mode=1 | mode=active-backup | 主-备份策略，只有一个设备处于活动状态，当一个宕掉另一个马上由备份转换为主设备，其中一条线若断线，其他线路将会自动备援  |      |                                    |
| mode=2 | mode=balance-xor   | 平衡策略，基于指定的传输HASH策略传输数据包。缺省的策略是：(源MAC地址 XOR 目标MAC地址)% slave数量     |   传输策略可以通过xmit_hash_policy选项指定   |                                    |
| mode=3 | mode=broadcast     | 广播策略，在每个slave接口上传输每个数据包，此模式提供了容错能力     |      |                                    |
| mode=4 | mode=802.3ad       | IEEE802.3ad 动态链接聚合（LACP）     |  xmit_hash_policy选项从缺省的XOR策略改变到其他策略    | 交换机支持IEEE 802.3ad动态链路聚合，及开启LACP功能 |
| mode=5 | mode=balance-tlb   | 适配器传输负载均衡     |      |        不需要交换机支持                            |
| mode=6 | mode=balance-alb   | 适配器适应性负载均衡     |      |                                    |

注： 除了`balance-rr`模式外的其它bonding负载均衡模式一样，任何连接都不能使用多于一个接口的带宽。

## 配置实例（802.3ad/mode4）

> 802.3ad or 4
>
>    IEEE 802.3ad Dynamic link aggregation.  Creates
>    aggregation groups that share the same speed and
>    duplex settings.  Utilizes all slaves in the active
>    aggregator according to the 802.3ad specification.
>
>    Slave selection for outgoing traffic is done according
>    to the transmit hash policy, which may be changed from
>    the default simple XOR policy via the xmit_hash_policy
>    option, documented below.  Note that not all transmit
>    policies may be 802.3ad compliant, particularly in
>    regards to the packet mis-ordering requirements of
>    section 43.2.4 of the 802.3ad standard.  Differing
>    peer implementations will have varying tolerances for
>    noncompliance.
>
>    Prerequisites:
>
>    1. Ethtool support in the base drivers for retrieving
>    the speed and duplex of each slave.
>
>    2. A switch that supports IEEE 802.3ad Dynamic link
>    aggregation.
>
>    Most switches will require some type of configuration
>    to enable 802.3ad mode.
>
> 来自内核文档： [Documentation/networking/bonding.rst](https://elixir.bootlin.com/linux/latest/source/Documentation/networking/bonding.rst)


### bond0

``` shell
cat /etc/sysconfig/network-scripts/ifcfg-bond0
DEVICE=bond0
NAME=bond0
TYPE=Bond
BONDING_MASTER=yes
IPADDR=192.168.1.1
PREFIX=24
BOOTPROTO=none
ONBOOT=yes
NM_CONTROLLED="no"
```

### 网卡eth1

``` shell
# cat /etc/sysconfig/network-scripts/ifcfg-eth1
TYPE=Ethernet
DEVICE=eth1
NAME=eth1
ONBOOT=yes
MASTER=bond0
SLAVE=yes
BOOTPROTO=none
NM_CONTROLLED="no"
```

### 网卡eth2

``` shell
# cat /etc/sysconfig/network-scripts/ifcfg-eth2
TYPE=Ethernet
DEVICE=eth2
NAME=eth2
ONBOOT=yes
MASTER=bond0
SLAVE=yes
BOOTPROTO=none
NM_CONTROLLED="no"
```

- 重启网络或者bond0虚拟机网卡

``` shell
ifdown bond0 && ifup bond0
```

- 查看bond0虚拟网卡信息

``` shell
cat /proc/net/bonding/bond0
```

## RDMA网卡

RoCE LAG是一种用于模拟IB设备的以太网绑定的功能，仅适用于双端口卡。部分网卡支持一下3种模式

- active-backup (mode 1)
- balance-xor (mode 2)
- 802.3ad (LACP) (mode 4)

> 在mode4模式下，进行数据传输的始终只有一个端口，带宽与一个端口传输一样，但是将其中任意一个端口拔掉后，数据传输切换到另一个端口，实际业务不受影响。也是一种主备模式，在IB模式下只支持主备模式

## 参考

- [七种网卡绑定模式详解](http://blog.sina.com.cn/s/blog_d83f9fc50102v8fe.html)
- [RDMA over Converged Ethernet (RoCE)](https://docs.mellanox.com/pages/viewpage.action?pageId=39284930)
- [7.4. USING THE COMMAND LINE INTERFACE (CLI)](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/networking_guide/sec-network_bonding_using_the_command_line_interface)
- [How to Configure RoCE over LAG (ConnectX-4/ConnectX-5-/ConnectX-6)](https://community.mellanox.com/s/article/How-to-Configure-RoCE-over-LAG-ConnectX-4-ConnectX-5-ConnectX-6)
- [双25GE网卡做bond4测试，其中一个网口没有流量一个网口可以打满的问题分享](https://bbs.huaweicloud.com/forum/thread-42234-1-1.html)
- [链路层的网卡聚合-基于Linux bonding](https://m.linuxidc.com/Linux/2011-05/35326.htm)
