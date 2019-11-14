---
layout: post
title: 网络带宽测试
date: '2018-07-25 16:42'
categories:
  - 网络
tags:
  - 网络
abbrlink: 21135
---

`iperf`是一个网络性能测试工具。Iperf可以测试TCP和UDP带宽质量。Iperf可以测量最大TCP带宽，具有多种参数和UDP特性。 Iperf可以报告带宽，延迟抖动和数据包丢失。利用Iperf这一特性，可以用来测试一些网络设备如路由器，防火墙，交换机等的性能。

<!--more-->

## 安装

### PC

下载地址： [here](https://iperf.fr/iperf-download.php)

### 交叉编译

``` shell
#!/bin/bash

IPERF_VERSION="3.1.3"
ARM_GCC="arm-linux-gnueabihf-gcc"
PWD=`pwd`

wget https://iperf.fr/download/source/iperf-${IPERF_VERSION}-source.tar.gz

tar zxvf iperf-${IPERF_VERSION}-source.tar.gz

cd iperf-${IPERF_VERSION}/
mkdir install

./configure  --host=arm-linux CC=${ARM_GCC} --prefix=${PWD}/install

make

make install
```

## iperf

``` shell
# iperf --help
Usage: iperf [-s|-c host] [options]
       iperf [-h|--help] [-v|--version]

Client/Server:
  -f, --format    [kmKM]   format to report: Kbits, Mbits, KBytes, MBytes
  -i, --interval  #        seconds between periodic bandwidth reports
  -l, --len       #[KM]    length of buffer to read or write (default 8 KB)
  -m, --print_mss          print TCP maximum segment size (MTU - TCP/IP header)
  -o, --output    <filename> output the report or error message to this specified file
  -p, --port      #        server port to listen on/connect to
  -u, --udp                use UDP rather than TCP
  -w, --window    #[KM]    TCP window size (socket buffer size)
  -B, --bind      <host>   bind to <host>, an interface or multicast address
  -C, --compatibility      for use with older versions does not sent extra msgs
  -M, --mss       #        set TCP maximum segment size (MTU - 40 bytes)
  -N, --nodelay            set TCP no delay, disabling Nagle's Algorithm
  -V, --IPv6Version        Set the domain to IPv6

Server specific:
  -s, --server             run in server mode
  -U, --single_udp         run in single threaded UDP mode
  -D, --daemon             run the server as a daemon

Client specific:
  -b, --bandwidth #[KM]    for UDP, bandwidth to send at in bits/sec
                           (default 1 Mbit/sec, implies -u)
  -c, --client    <host>   run in client mode, connecting to <host>
  -d, --dualtest           Do a bidirectional test simultaneously
  -n, --num       #[KM]    number of bytes to transmit (instead of -t)
  -r, --tradeoff           Do a bidirectional test individually
  -t, --time      #        time in seconds to transmit for (default 10 secs)
  -F, --fileinput <name>   input the data to be transmitted from a file
  -I, --stdin              input the data to be transmitted from stdin
  -L, --listenport #       port to receive bidirectional tests back on
  -P, --parallel  #        number of parallel client threads to run
  -T, --ttl       #        time-to-live, for multicast (default 1)
  -Z, --linux-congestion <algo>  set TCP congestion control algorithm (Linux only)

Miscellaneous:
  -x, --reportexclude [CDMSV]   exclude C(connection) D(data) M(multicast) S(settings) V(server) reports
  -y, --reportstyle C      report as a Comma-Separated Values
  -h, --help               print this message and quit
  -v, --version            print version information and quit

[KM] Indicates options that support a K or M suffix for kilo- or mega-

The TCP window size option can be set by the environment variable
TCP_WINDOW_SIZE. Most other options can be set by an environment variable
IPERF_<long option name>, such as IPERF_BANDWIDTH.

Report bugs to <iperf-users@lists.sourceforge.net>
```
| 命令行选项        | 描述                                                                                                            |
|:------------------|:----------------------------------------------------------------------------------------------------------------|
| -i, --interval    | 设置每次报告之间的时间间隔，单位为秒。如果设置为非零值，就会按照此时间间隔输出测试报告。默认值为零。            |
| -l, --len #[KM]   | 设置读写缓冲区的长度。TCP方式默认为8KB，UDP方式默认为1470字节。                                                 |
| -p, --port        | 设置端口，与服务器端的监听端口一致。默认是5001端口，与ttcp的一样。                                              |
| -u, --udp         | 使用UDP方式而不是TCP方式。参看-b选项。                                                                          |
| Server            |                                                                                                                 |
| -s, --server      | Iperf服务器模式                                                                                                 |
| -c, --client host | 如果Iperf运行在服务器模式，并且用-c参数指定一个主机，那么Iperf将只接受指定主机的连接。此参数不能工作于UDP模式。 |
| Client            |                                                                                                                 |
| -c, --client host | 运行Iperf的客户端模式，连接到指定的Iperf服务器端。                                                              |
| -t, --time #      | 设置传输的总时间。Iperf在指定的时间内，重复的发送指定长度的数据包。默认是10秒钟。参考-l与-n选项。               |
| -P, --parallel #  | 线程数。指定客户端与服务端之间使用的线程数。默认是1线程。需要客户端与服务器端同时使用此参数。   |
| -d, --dualtest    | 运行双测试模式。这将使服务器端反向连接到客户端，使用-L 参数中指定的端口（或默认使用客户端连接到服务器端的端口）。这些在操作的同时就立即完成了。如果你想要一个交互的测试，请尝试-r参数。   |


## 示例

带宽测试通常采用`UDP模式`，因为能测出极限带宽、时延抖动、丢包率。在进行测试时，首先以链路理论带宽作为数据发送速率进行测试，例如，从客户端到服务器之间的链路的理论带宽为100Mbps，先用`-b 100M`进行测试，然后根据测试结果（包括实际带宽，时延抖动和丢包率），再以实际带宽作为数据发送速率进行测试，会发现时延抖动和丢包率比第一次好很多，重复测试几次，就能得出稳定的实际带宽。

### TCP

服务器端：
```
iperf -s
```
客户端：
```
iperf -c 192.168.1.1 -t 60
```
>在tcp模式下，客户端到服务器192.168.1.1上传带宽测试，测试时间为60秒。

```
iperf -c 192.168.1.1  -P 30 -t 60
```
>客户端同时向服务器端发起30个连接线程。

```
iperf -c 192.168.1.1  -d -t 60
```
>进行上下行带宽测试。

### UDP

服务器端：
```
iperf -u -s
```

客户端：
```
iperf -u -c 192.168.1.1 -b 100M -t 60
```
>在udp模式下，以100Mbps为数据发送速率，客户端到服务器192.168.1.1上传带宽测试，测试时间为60秒。

```
iperf -u -c 192.168.1.1 -b 5M -P 30 -t 60
```
>客户端同时向服务器端发起30个连接线程，以5Mbps为数据发送速率。

```
iperf -u -c 192.168.1.1 -b 100M -d -t 60
```
>以100M为数据发送速率，进行上下行带宽测试。
