---
title: 组播--IGMPv2
date: 2018-06-25 23:17:24
categories: 网络
tags: [IGMP, net]
---

>IGMP 是Internet Group Management Protocol（互联网组管理协议）的简称。它是TCP/IP 协议族中负责IP 组播成员管理的协议，用来在IP 主机和与其直接相邻的组播路由器之间建立、维护组播组成员关系。

<!--more-->

* IGMPv1（由[RFC 1112](https://www.rfc-editor.org/rfc/rfc1112.txt) 定义）
* IGMPv2（由[RFC 2236](https://www.rfc-editor.org/rfc/rfc2236.txt) 定义）
* IGMPv3（由[RFC 3376](https://www.rfc-editor.org/rfc/rfc3376.txt) 定义）

所有版本的IGMP都支持ASM（Any-Source Multicast，任意信源组播）模型；IGMPv3可以直接应用于SSM（Source-Specific Multicast，指定信源组播）模型，而IGMPv1和IGMPv2则需要在IGMP SSM Mapping技术的支持下才能应用于SSM模型。


## IGMPv1

IGMPv1 主要基于查询和响应机制来完成对组播组成员的管理。

当一个网段内有多台组播路由器时，由于它们都能从主机那里收到IGMP 成员关系报告报文（Membership Report Message），因此只需要其中一台路由器发送IGMP 查询报文（Query Message）就足够了。这就需要有一个查询器（Querier）的选举机制来确定由哪台路由器作为IGMP查询器。

对于IGMPv1 来说，由组播路由协议（如PIM）选举出唯一的组播信息转发者DR（Designated Router，指定路由器）作为IGMP 查询器

![IGMPv1](/images/net/multicast/igmpv1.jpg)

IGMPv1 没有专门定义`离开组播组`的报文。当运行IGMPv1 的主机离开某组播组时，将不会向其要离开的组播组发送报告报文。当网段中不再存在该组播组的成员后，IGMP 路由器将收不到任何发往该组播组的报告报文，于是IGMP 路由器在一段时间之后便删>除该组播组所对应的组播转发项。

## IGMPv2

与IGMPv1 相比，IGMPv2 增加了`查询器选举机制`和`离开组机制`。

### 查询器选举机制

在IGMPv1 中，当某共享网段上存在多个组播路由器时，由组播路由协议（如PIM）选举的指定路由器充当查询器。

在IGMPv2 中，增加了独立的查询器选举机制，其选举过程如下：

1. 所有IGMPv2路由器在初始时都认为自己是查询器，并向本地网段内的所有主机和路由器发送IGMP普遍组查询（General Query）报文（目的地址为224.0.0.1）；
2. 本地网段中的其它IGMPv2路由器在收到该报文后，将报文的源IP地址与自己的接口地址作比较。通过比较， IP地址最小的路由器将成为查询器，其它路由器成为非查询器（Non-Querier）；
3. 所有非查询器上都会启动一个定时器（即其它查询器存在时间定时器Other Querier Present Timer）。在该定时器超时前，如果收到了来自查询器的IGMP 查询报文，则重置该定时器；否则，就认为原查询器失效，并发起新的查询器选举过程。

### 离开组机制

在IGMPv1 中，主机离开组播组时不会向组播路由器发出任何通知，导致组播路由器只能依靠组播组成员查询的响应超时来获知组播组成员的离开。

而在IGMPv2中，当一个主机离开某组播组时：

1. 该主机向本地网段内的所有组播路由器（目的地址为224.0.0.2）发送离开组（Leave Group）报文；
2. 当查询器收到该报文后， 向该主机所声明要离开的那个组播组发送特定组查询（Group-Specific Query）报文（目的地址字段和组地址字段均填充为所要查询的组播组地址）；
3. 如果该网段内还有该组播组的其它成员，则这些成员在收到特定组查询报文后，会在该报文中所设定的最大响应时间（Max Response Time）内发送成员关系报告报文；
4. 如果在最大响应时间内收到了该组播组其它成员发送的成员关系报告报文，查询器就会继续维护该组播组的成员关系；否则，查询器将认为该网段内已无该组播组的成员，于是不再维护这个组播组的成员关系。

### IGMPv2报文格式

```
0             7 8             1516                             31
+--------------+---------------+-------------------------------+-++
|    Type      | max_resp_time |           CheckSum            | |
+--------------+---------------+-------------------------------+ 8Byte
|                    Group Address                             | |
+--------------------------------------------------------------+-++
```

* `Type` :

|  Type | 							 |
| :---: | :------------: |
| 0x11  | Membership Query(成员查询) |
| 0X12	| Version 1 Membership Report(版本1成员报告) |
| 0X16	| Version 2 Membership Report(版本2成员报告) |
| 0X17	| Leave Group(离开组) |

* `max_resp_time`: 在发出响应报告前的以1/10秒为单位的最长时间，`缺省值为10秒`。新的最大响应时间（以1/10秒为单位）字段允许查询用路由器为它的查询报文指定准确的查询间隔响应时间。IGMP版本2主机在随机选择它们的应时间值时以此作为上限。

>从路由器接收到一条查询消息后，主机会为其所属的每个组播组都配置一个计时器。计时器的值在 0 到最大响应时间之间随机选定。当其中任何一个计时器的值减为 0时，主机就会发送该组播组的成员报告消息。合理配置最大响应时间，可以使主机快速响应查询信息，路由器也就能快速地掌握组播组成员的存在状况。

* `Group Address`: 组地址

```
Internet Group Management Protocol
    [IGMP Version: 2]
    Type: Membership Report (0x16)
    Max Resp Time: 0.0 sec (0x00)
    Checksum: 0xfaf3 [correct]
    [Checksum Status: Good]
    Multicast Address: 239.0.0.11
```

### 设置max_resp_time

```
ip igmp snooping query-max-response-time seconds
```

## IGMPv3

IGMPv3 在兼容和继承IGMPv1 和IGMPv2 的基础上，进一步增强了主机的控制能力，并增强了查询和报告报文的功能。

## 参考

* [IGMP技术总结](https://blog.csdn.net/livelylittlefish/article/details/4286142)
* [IGMPv3协议报文格式参考](https://blog.csdn.net/shanzhizi/article/details/7645330)
* [IGMP Snooping概念和配置方法---交换](https://blog.csdn.net/mingzznet/article/details/9253607)
* [IGMPV2基本原理](http://blog.sina.com.cn/s/blog_c079d59e0102whjg.html)
* [IGMP Snooping技术学习笔记](https://blog.csdn.net/achejq/article/details/7347214)
* [H3C F1000-S防火墙基础配置及telnet登录！](http://blog.51cto.com/rongshu/1900182)
