---
layout: post
title: RDMA网络简介
date: '2021-05-28 14:27'
categories:
  - 网络
tags:
  - 网络
  - rdma
abbrlink: f4fa9e36
---

`RDMA`(Remote Direct Memory Access)全称`远程直接数据存取`，就是为了解决网络传输中服务器端数据处理的延迟而产生的。RDMA通过网络把资料直接传入计算机的存储区，将数据从一个系统快速移动到远程系统存储器中，而不对操作系统造成任何影响，这样就不需要用到多少计算机的处理功能。它消除了外部存储器复制和上下文切换的开销，因而能解放内存带宽和CPU周期用于改进应用系统性能。

<!--more-->

## 驱动下载

> https://www.mellanox.com/products/infiniband-drivers/linux/mlnx_ofed

判断驱动是否安装成功：
``` shell
# ibdev2netdev
mlx5_0 port 1 ==> ens2f0 (Up)   #表示该网口插了网线
mlx5_1 port 1 ==> ens2f1 (Down) #表示该网口没有插网线
```
> `ibdev2netdev`命令输出以上类似信息表明网卡驱动安装成功

### CentOS7开源驱动安装与卸载

> [Working with RDMA in RedHat/CentOS 7.*](https://www.rdmamojo.com/2014/10/11/working-rdma-redhatcentos-7/#:~:text=yum%20allows%20installation%20of%20multiple%20packages%20according%20to,packages%20are%20part%20of%20the%20group%20%22Infiniband%20Support%22%3A)

- 安装：
``` shell
yum groupinfo "Infiniband Support"
yum groupinstall "Infiniband Support"
yum --setopt=group_package_types=optional groupinstall "Infiniband Support"
```
- 卸载：
``` shell
yum -y groupremove "Infiniband Support"
```
- 开启RDMA服务
``` shell
systemctl start rdma
systemctl enable rdma
```

## 吞吐量测试

### 写吞吐量

在RDMA驱动安装时会安装一些RDMA工具，可以使用`ib_send_bw`测试写吞吐量

服务器A（server）：
``` shell
ib_write_bw -a -d mlx5_0
```

服务器B（client）：
``` shell
ib_write_bw -a -d mlx5_0 192.168.2.1(server端ip)
```

### 读吞吐量

读吞吐量的测试与写吞吐量测试相同，只是使用命令换为`ib_read_bw`


## 延时测试

测试同样分为读写，测试工具为`ib_read_lat`、`ib_write_lat`

- [Performance Tuning for Mellanox Adapters](https://community.mellanox.com/s/article/performance-tuning-for-mellanox-adapters)

## 带宽统计

在使用RDMA时，发送和接收的数据带宽可以在app中自己进行收集，这样我们的程序发送和接收的数据量会很清楚。
如果想知道当前RDMA网卡所发送和接收的带宽可以通过sysfs下的相关节点获取。

- 发送数据量（byte）：`/sys/class/infiniband/mlx5_0/ports/1/counters/port_xmit_data`
- 接收数据量（byte）：`/sys/class/infiniband/mlx5_0/ports/1/counters/port_rcv_data`

**注**：`port_xmit_data`和`port_rcv_data`的数值是实际的1/4,因此实际的带宽是在其基础之上乘以`4`，应该是为了防止数据溢出

> port_xmit_data: (RO) Total number of data octets, divided by 4 (lanes), transmitted on all VLs. This is 64 bit counter
> port_rcv_data: (RO) Total number of data octets, divided by 4 (lanes), received on all VLs. This is 64 bit counter.
> > 来自： `Documentation/ABI/stable/sysfs-class-infiniband`

``` C
pma_cnt_ext->port_xmit_data =
    cpu_to_be64(MLX5_SUM_CNT(out, transmitted_ib_unicast.octets,
                 transmitted_ib_multicast.octets) >> 2);
pma_cnt_ext->port_rcv_data =
    cpu_to_be64(MLX5_SUM_CNT(out, received_ib_unicast.octets,
                 received_ib_multicast.octets) >> 2);
```
> file: drivers/infiniband/hw/mlx5/mad.c

## 网络联通性测试

由于当前网卡只支持`Ethernet`模式，因此只能使用`ibv_rc_pingpong`进行ping测试。

- https://community.mellanox.com/s/article/RoCE-Debug-Flow-for-Linux

### Server

``` shell
# ibdev2netdev
mlx4_0 port 1 ==> enp1s0 (Down)
mlx5_0 port 1 ==> ens2f0 (Up)
mlx5_1 port 1 ==> ens2f1 (Up)
```

``` shell
# ibv_rc_pingpong -d mlx5_0 -g 0
  local address:  LID 0x0000, QPN 0x00011a, PSN 0xd775ee, GID fe80::e42:a1ff:fe41:2d36
  remote address: LID 0x0000, QPN 0x0009df, PSN 0xa7f02f, GID fe80::1e34:daff:fe79:c0d
8192000 bytes in 0.01 seconds = 5126.01 Mbit/sec
1000 iters in 0.01 seconds = 12.78 usec/iter
```

### Client

``` shell
# ibdev2netdev
mlx5_0 port 1 ==> p5p1 (Down)
mlx5_1 port 1 ==> p5p2 (Up)
mlx5_2 port 1 ==> p4p1 (Down)
mlx5_3 port 1 ==> p4p2 (Down)
```

``` shell
# ibv_rc_pingpong -d mlx5_1 -g 0 192.168.2.4
  local address:  LID 0x0000, QPN 0x0009df, PSN 0xa7f02f, GID fe80::1e34:daff:fe79:c0d
  remote address: LID 0x0000, QPN 0x00011a, PSN 0xd775ee, GID fe80::e42:a1ff:fe41:2d36
8192000 bytes in 0.01 seconds = 5376.21 Mbit/sec
1000 iters in 0.01 seconds = 12.19 usec/iter
```

## ibping

测试ib模式下网络的连通性。

## mlx5计数器和状态参数

在sysfs文件系统可以查看`/sys/class/infiniband/`

> - [Understanding mlx5 Linux Counters and Status Parameters](https://community.mellanox.com/s/article/understanding-mlx5-linux-counters-and-status-parameters)
> - [InfiniBand Port Counters](https://mymellanox.force.com/mellanoxcommunity/s/article/infiniband-port-counters)

Linux内核说明文档：https://www.kernel.org/doc/html/latest/admin-guide/abi-stable.html#abi-file-stable-sysfs-class-infiniband

### counters

``` shell
# ls -lsh /sys/class/infiniband/mlx5_0/ports/1/counters/
total 0
0 -r--r--r-- 1 root root 4.0K 5月  24 15:28 excessive_buffer_overrun_errors
0 -r--r--r-- 1 root root 4.0K 5月  24 15:28 link_downed
0 -r--r--r-- 1 root root 4.0K 5月  24 15:28 link_error_recovery
0 -r--r--r-- 1 root root 4.0K 5月  24 15:28 local_link_integrity_errors
0 -r--r--r-- 1 root root 4.0K 5月  24 15:28 multicast_rcv_packets
0 -r--r--r-- 1 root root 4.0K 5月  24 15:28 multicast_xmit_packets
0 -r--r--r-- 1 root root 4.0K 5月  24 15:28 port_rcv_constraint_errors
0 -r--r--r-- 1 root root 4.0K 5月  24 15:28 port_rcv_data
0 -r--r--r-- 1 root root 4.0K 5月  24 15:28 port_rcv_errors
0 -r--r--r-- 1 root root 4.0K 5月  24 15:28 port_rcv_packets
0 -r--r--r-- 1 root root 4.0K 5月  24 15:28 port_rcv_remote_physical_errors
0 -r--r--r-- 1 root root 4.0K 5月  24 15:28 port_rcv_switch_relay_errors
0 -r--r--r-- 1 root root 4.0K 5月  24 15:28 port_xmit_constraint_errors
0 -r--r--r-- 1 root root 4.0K 5月  24 15:28 port_xmit_data
0 -r--r--r-- 1 root root 4.0K 5月  24 15:28 port_xmit_discards
0 -r--r--r-- 1 root root 4.0K 5月  24 15:28 port_xmit_packets
0 -r--r--r-- 1 root root 4.0K 5月  24 15:28 port_xmit_wait
0 -r--r--r-- 1 root root 4.0K 5月  24 15:28 symbol_error
0 -r--r--r-- 1 root root 4.0K 5月  24 15:28 unicast_rcv_packets
0 -r--r--r-- 1 root root 4.0K 5月  24 15:28 unicast_xmit_packets
0 -r--r--r-- 1 root root 4.0K 5月  24 15:28 VL15_dropped
```
Counter Description:

| **Counter**                           | **Description**                                              | **InfiniBand Spec Name**    | **Group**   |
| :------------------------------------ | :----------------------------------------------------------- | :-------------------------- | :---------- |
| port_rcv_data                         | The total number of data octets, divided by 4, (counting in double words, 32 bits), received on all VLs from the port. | PortRcvData                 | Informative |
| port_rcv_packets                      | Total number of packets (this may include packets containing Errors. This is 64 bit counter. | PortRcvPkts                 | Informative |
| port_multicast_rcv_packets            | Total number of multicast packets, including multicast packets containing errors. | PortMultiCastRcvPkts        | Informative |
| port_unicast_rcv_packets              | Total number of unicast packets, including unicast packets containing errors. | PortUnicastRcvPkts          | Informative |
| port_xmit_data                        | The total number of data octets, divided by 4, (counting in double words, 32 bits), transmitted on all VLs from the port. | PortXmitData                | Informative |
| port_xmit_packetsport_xmit_packets_64 | Total number of packets transmitted on all VLs from this port. This may include packets with errors.This is 64 bit counter. | PortXmitPkts                | Informative |
| port_rcv_switch_relay_errors          | Total number of packets received on the port that were discarded because they could not be forwarded by the switch relay. | PortRcvSwitchRelayErrors    | Error       |
| port_rcv_errors                       | Total number of packets containing an error that were received on the port. | PortRcvErrors               | Informative |
| port_rcv_constraint_errors            | Total number of packets received on the switch physical port that are discarded. | PortRcvConstraintErrors     | Error       |
| local_link_integrity_errors           | The number of times that the count of local physical errors exceeded the threshold specified by LocalPhyErrors. | LocalLinkIntegrityErrors    | Error       |
| port_xmit_wait                        | The number of ticks during which the port had data to transmit but no data was sent during the entire tick (either because of insufficient credits or because of lack of arbitration). | PortXmitWait                | Informative |
| port_multicast_xmit_packets           | Total number of multicast packets transmitted on all VLs from the port. This may include multicast packets with errors. | PortMultiCastXmitPkts       | Informative |
| port_unicast_xmit_packets             | Total number of unicast packets transmitted on all VLs from the port. This may include unicast packets with errors. | PortUnicastXmitPkts         | Informative |
| port_xmit_discards                    | Total number of outbound packets discarded by the port because the port is down or congested. | PortXmitDiscards            | Error       |
| port_xmit_constraint_errors           | Total number of packets not transmitted from the switch physical port. | PortXmitConstraintErrors    | Error       |
| port_rcv_remote_physical_errors       | Total number of packets marked with the EBP delimiter received on the port. | PortRcvRemotePhysicalErrors | Error       |
| symbol_error                          | Total number of minor link errors detected on one or more physical lanes. | SymbolErrorCounter          | Error       |
| VL15_dropped                          | Number of incoming VL15 packets dropped due to resource limitations (e.g., lack of buffers) of the port. | VL15Dropped                 | Error       |
| link_error_recovery                   | Total number of times the Port Training state machine has successfully completed the link error recovery process. | LinkErrorRecoveryCounter    | Error       |
| link_downed                           | Total number of times the Port Training state machine has failed the link error recovery process and downed the link. | LinkDownedCounter           | Error       |

### hw_counters

``` shell
# ls -lsh /sys/class/infiniband/mlx5_0/ports/1/hw_counters/
total 0
0 -r--r--r-- 1 root root 4.0K 5月  24 15:28 duplicate_request
0 -r--r--r-- 1 root root 4.0K 5月  24 15:28 implied_nak_seq_err
0 -rw-r--r-- 1 root root 4.0K 5月  28 16:42 lifespan
0 -r--r--r-- 1 root root 4.0K 5月  24 15:28 local_ack_timeout_err
0 -r--r--r-- 1 root root 4.0K 5月  24 15:28 np_cnp_sent
0 -r--r--r-- 1 root root 4.0K 5月  24 15:28 np_ecn_marked_roce_packets
0 -r--r--r-- 1 root root 4.0K 5月  24 15:28 out_of_buffer
0 -r--r--r-- 1 root root 4.0K 5月  24 15:28 out_of_sequence
0 -r--r--r-- 1 root root 4.0K 5月  24 15:28 packet_seq_err
0 -r--r--r-- 1 root root 4.0K 5月  24 15:28 req_cqe_error
0 -r--r--r-- 1 root root 4.0K 5月  24 15:28 req_cqe_flush_error
0 -r--r--r-- 1 root root 4.0K 5月  24 15:28 req_remote_access_errors
0 -r--r--r-- 1 root root 4.0K 5月  24 15:28 req_remote_invalid_request
0 -r--r--r-- 1 root root 4.0K 5月  24 15:28 resp_cqe_error
0 -r--r--r-- 1 root root 4.0K 5月  24 15:28 resp_cqe_flush_error
0 -r--r--r-- 1 root root 4.0K 5月  24 15:28 resp_local_length_error
0 -r--r--r-- 1 root root 4.0K 5月  24 15:28 resp_remote_access_errors
0 -r--r--r-- 1 root root 4.0K 5月  24 15:28 rnr_nak_retry_err
0 -r--r--r-- 1 root root 4.0K 5月  24 15:28 rp_cnp_handled
0 -r--r--r-- 1 root root 4.0K 5月  24 15:28 rp_cnp_ignored
0 -r--r--r-- 1 root root 4.0K 5月  24 15:28 rx_atomic_requests
0 -r--r--r-- 1 root root 4.0K 5月  24 15:28 rx_icrc_encapsulated
0 -r--r--r-- 1 root root 4.0K 5月  24 15:28 rx_read_requests
0 -r--r--r-- 1 root root 4.0K 5月  24 15:28 rx_write_requests
```

HW Counters Description:

| **Counter**                | **Description**                                              | **Group**   |
| :------------------------- | :----------------------------------------------------------- | :---------- |
| duplicate_request          | Number of received packets. A duplicate request is a request that had been previously executed. | Error       |
| implied_nak_seq_err        | Number of time the requested decided an ACK. with a PSN larger than the expected PSN for an RDMA read or response. | Error       |
| lifespan                   | The maximum period in ms which defines the aging of the counter reads. Two consecutive reads within this period might return the same values | Informative |
| local_ack_timeout_err      | The number of times QP's ack timer expired for RC, XRC, DCT QPs at the sender side.The QP retry limit was not exceed, therefore it is still recoverable error. | Error       |
| np_cnp_sent                | The number of CNP packets sent by the Notification Point when it noticed congestion experienced in the RoCEv2 IP header (ECN bits).The counters was added in MLNX_OFED 4.1 | Informative |
| np_ecn_marked_roce_packets | The number of RoCEv2 packets received by the notification point which were marked for experiencing the congestion (ECN bits where '11' on the ingress RoCE traffic) .The counters was added in MLNX_OFED 4.1 | Informative |
| out_of_buffer              | The number of drops occurred due to lack of WQE for the associated QPs. | Error       |
| out_of_sequence            | The number of out of sequence packets received.              | Error       |
| packet_seq_err             | The number of received NAK sequence error packets. The QP retry limit was not exceeded. | Error       |
| req_cqe_error              | The number of times requester detected CQEs completed with errors.The counters was added in MLNX_OFED 4.1 | Error       |
| req_cqe_flush_error        | The number of times requester detected CQEs completed with flushed errors.The counters was added in MLNX_OFED 4.1 | Error       |
| req_remote_access_errors   | The number of times requester detected remote access errors.The counters was added in MLNX_OFED 4.1 | Error       |
| req_remote_invalid_request | The number of times requester detected remote invalid request errors.The counters was added in MLNX_OFED 4.1 | Error       |
| resp_cqe_error             | The number of times responder detected CQEs completed with errors.The counters was added in MLNX_OFED 4.1 | Error       |
| resp_cqe_flush_error       | The number of times responder detected CQEs completed with flushed errors.The counters was added in MLNX_OFED 4.1 | Error       |
| resp_local_length_error    | The number of times responder detected local length errors.The counters was added in MLNX_OFED 4.1 | Error       |
| resp_remote_access_errors  | The number of times responder detected remote access errors.The counters was added in MLNX_OFED 4.1 | Error       |
| rnr_nak_retry_err          | The number of received RNR NAK packets. The QP retry limit was not exceeded. | Error       |
| rp_cnp_handled             | The number of CNP packets handled by the Reaction Point HCA to throttle the transmission rate.The counters was added in MLNX_OFED 4.1 | Informative |
| rp_cnp_ignored             | The number of CNP packets received and ignored by the Reaction Point HCA. This counter should not raise if RoCE Congestion Control was enabled in the network. If this counter raise, verify that ECN was enabled on the adapter. See [HowTo Configure DCQCN (RoCE CC) values for ConnectX-4 (Linux)](https://community.mellanox.com/s/article/howto-configure-dcqcn--roce-cc--values-for-connectx-4--linux-x).The counters was added in MLNX_OFED 4.1 | Error       |
| rx_atomic_requests         | The number of received ATOMIC request for the associated QPs. | Informative |
| rx_dct_connect             | The number of received connection request for the associated DCTs. | Informative |
| rx_read_requests           | The number of received READ requests for the associated QPs. | Informative |
| rx_write_requests          | The number of received WRITE requests for the associated QPs. | Informative |
| rx_icrc_encapsulated       | The number of RoCE packets with ICRC errors.This counter was added in MLNX_OFED 4.4 and kernel 4.19 | Error       |
| roce_adp_retrans           | Counts the number of adaptive retransmissions for RoCE trafficThe counter was added in MLNX_OFED rev 5.0-1.0.0.0 and kernel v5.6.0 | Informative |
| roce_adp_retrans_to        | Counts the number of times RoCE traffic reached timeout due to adaptive retransmissionThe counter was added in MLNX_OFED rev 5.0-1.0.0.0 and kernel v5.6.0 | Informative |
| roce_slow_restart          | Counts the number of times RoCE slow restart was usedThe counter was added in MLNX_OFED rev 5.0-1.0.0.0 and kernel v5.6.0 | Informative |
| roce_slow_restart_cnps     | Counts the number of times RoCE slow restart generated CNP packetsThe counter was added in MLNX_OFED rev 5.0-1.0.0.0 and kernel v5.6.0 | Informative |
| roce_slow_restart_trans    | Counts the number of times RoCE slow restart changed state to slow restartThe counter was added in MLNX_OFED rev 5.0-1.0.0.0 and kernel v5.6.0 | Informative |

- `duplicate_request`:（Duplicated packets）接收报文数，重复请求是先前已执行的请求。
- `out_of_sequence`:（Drop out of sequence）接收到的乱序包的数量，说明此时已经产生了丢包
- `packet_seq_err`：（NAK sequence rcvd）接收到的NAK序列错误数据包的数量，未超过QP重试限制。


## 带宽监测工具——netdata

`netdata`可以查看RDMA网卡的带宽，但是展示的发送和接收的数据是通过`/sys/class/infiniband`下的节点获取的，因此实际带宽数据是其展示数据的`4倍`

![netdata_rdma_ib](/images/2021/05/netdata_rdma_ib.png)

> 插件源码：https://github.com/netdata/netdata/blob/master/collectors/proc.plugin/sys_class_infiniband.c

## 网卡工作模式

``` shell
# ibstatus
Infiniband device 'mlx5_0' port 1 status:
	default gid:	 fe80:0000:0000:0000:0e42:a1ff:fe41:2d36
	base lid:	 0x0
	sm lid:		 0x0
	state:		 4: ACTIVE
	phys state:	 5: LinkUp
	rate:		 25 Gb/sec (1X EDR)
	link_layer:	 Ethernet

Infiniband device 'mlx5_1' port 1 status:
	default gid:	 fe80:0000:0000:0000:0e42:a1ff:fe41:2d37
	base lid:	 0x0
	sm lid:		 0x0
	state:		 4: ACTIVE
	phys state:	 5: LinkUp
	rate:		 25 Gb/sec (1X EDR)
	link_layer:	 Ethernet
```
- `link_layer`： 工作模式，Ethernet为IP模式，还有IB（infiniband）模式。
- 工作模式切换：[HowTo Change Port Type in Mellanox ConnectX-3 Adapter](https://community.mellanox.com/s/article/howto-change-port-type-in-mellanox-connectx-3-adapter)

## 常用命令

- `ibstat`: 查询InfiniBand设备的基本状态
- `ibstatus`： 网卡信息
- `ibv_devinfo`：网卡设备信息（ibv_devinfo -d mlx5_0 -v）
- `ibv_devices`：查看本主机的infiniband设备
- `ibnodes`：查看网络中的infiniband设备
- `show_gids`：看看网卡支持的roce版本
- `show_counters`:网卡端口统计数据，比如发送接受数据大小
- `mlxconfig`: 网卡配置（mlxconfig -d mlx5_1 q查询网卡配置信息）


## 双网口作用

`双网口`：指一个物理网卡上的两个网络接口

1. 可以捆绑，比单口效率高多了。同时上两个不同的网络网，有一个不同时，另一个也在同时工作实现网络备份。
2. 服务器必备2个或2个以上的网口，一个用于网路接入，另一个作为输入。
3. 家用PC机用2个的网口的网卡，可以实现服务器的初级功能，接入网络然后输入，并管理输入端的网路和数据。
4. 双口的可以做负载均衡，单口的无此功能。
5. 双口的可以连接两个网络，可以做网关，单口的直接无法做到此点。当然，如果用两个单口网卡，也可以实现某些双口网卡的同样效果，但在转换速度上还是和双口网卡略有差异。

## 参考

- [How to install support for Mellanox Infiniband hardware on RHEL6](https://access.redhat.com/solutions/301643)
- [Mellanox Technologies Ltd. Public Repository](https://www.mellanox.com/support/mlnx-ofed-public-repository)
- [infiniband带宽测试方法1 ib_read/write_bw/lat](https://blog.csdn.net/xztjhs/article/details/51487467)
- [ib_write_bw 和 ib_read_bw 测试 RDMA 的读写处理确定带宽](https://blog.csdn.net/ljlfather/article/details/102925954)
- [ibverbs文档翻译](https://blog.csdn.net/QiangLi_strong/article/details/81021193)
- [Introduction to Programming Infiniband RDMA](https://insujang.github.io/2020-02-09/introduction-to-programming-infiniband/)
- [NFSv4 RDMA and Session Extensions](https://datatracker.ietf.org/doc/html/draft-talpey-nfsv4-rdma-sess-00)
- [RDMA_Aware_Programming_user_manual.pdf](https://www.mellanox.com/related-docs/prod_software/RDMA_Aware_Programming_user_manual.pdf)
- [infiniband网卡安装、使用总结](https://www.cnblogs.com/sctb/p/13179542.html)
- [Port Type Management](https://docs.mellanox.com/display/VMAv883/Port+Type+Management)
