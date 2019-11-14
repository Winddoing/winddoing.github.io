---
layout: post
title: 网络-ping命令
date: '2018-08-02 15:27'
abbrlink: 51638
---

判断网络的连通性和延时情况，通常使用`ping`命令。

ping发送一个`ICMP回声请求`消息给目的地并报告是否收到所希望的`ICMP回声应答`。它是用来检查网络是否通畅或者网络连接速度的命令

<!--more-->

## ping

```
$ping -help
Usage: ping [-aAbBdDfhLnOqrRUvV64] [-c count] [-i interval] [-I interface]
            [-m mark] [-M pmtudisc_option] [-l preload] [-p pattern] [-Q tos]
            [-s packetsize] [-S sndbuf] [-t ttl] [-T timestamp_option]
            [-w deadline] [-W timeout] [hop1 ...] destination
Usage: ping -6 [-aAbBdDfhLnOqrRUvV] [-c count] [-i interval] [-I interface]
             [-l preload] [-m mark] [-M pmtudisc_option]
             [-N nodeinfo_option] [-p pattern] [-Q tclass] [-s packetsize]
             [-S sndbuf] [-t ttl] [-T timestamp_option] [-w deadline]
             [-W timeout] destination
```
| 参数 | 说明               |
|:----:|:-------------------|
| -c  | ping的次数         |
| -W  | 一次ping的超时时间 |
| -s  | 发送数据包的大小，默认为32字节，最大可以定义到65500字节  |

## 实现

网络上的机器都有唯一确定的IP地址，我们给目标IP地址发送一个数据包，对方就要返回一个同样大小的数据包，根据返回的数据包我们可以确定目标主机的存在，可以初步判断目标主机的操作系统等。

## 数据包

```
--> 28	26.646884	192.168.100.3	192.168.100.2	ICMP	98	Echo (ping) request  id=0xdc04, seq=0/0, ttl=64 (reply in 29)
<-- 29	26.646957	192.168.100.2	192.168.100.3	ICMP	98	Echo (ping) reply    id=0xdc04, seq=0/0, ttl=64 (request in 28）
```

## 应用

* 判断本地tcp/ip协议是否正常
```
ping 127.0.0.1
```
* 程序中判断网络连接情况
``` C
for (i = 0; i < MAX_S_CONNECT_NUM; i++) {
    if (rIpList[i].valid == 1) {
        retry_num = 5;
        memset(cmd, 0, 120 * sizeof(char));
        sprintf(cmd, "ping %s -c 1 -W 1 > /dev/null", rIpList[i].ipstr);
retry:
        ret = system(cmd);
        if (ret != 0 && retry_num) {
            retry_num--;
            goto retry;
        }

        if (ret != 0 || !retry_num) {
            printf("ip: %s, disconnected retry:%d !!!\n", rIpList[i].ipstr, retry_num);
            VXLOG("ip: %s, disconnected retry:%d !!!\n", rIpList[i].ipstr, retry_num);
            rIpList[i].valid = 0;
            alive--;
        }
    }
}
```
