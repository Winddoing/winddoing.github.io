---
title: 网络调试
date: 2018-06-21 23:17:24
categories: 网络
tags: [debug]
---

网络调试的手段工具：
<!--more-->


## 抓包--tcpdump

```
tcpdump -i wlan0 -p  -w file.pcap
```
参数：

| arg   |       |
| :---: | :----:|
| -p    |  将网卡设置为非混杂模式 |

## 分析--wireshark


## netstat

```
# netstat -n
Active Internet connections (w/o servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       
tcp        0      0 192.168.100.3:40964     192.168.100.2:7236      ESTABLISHED
udp        0      0 239.0.0.11:15550        192.168.100.2:*         ESTABLISHED
udp        0      0 239.0.0.11:15551        192.168.100.2:1         ESTABLISHED
```
