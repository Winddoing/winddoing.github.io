


## 多播

```
//设置接受缓冲区大小  
int size = 512 * 1024;   
setsockopt(s, SOL_SOCKET, SO_RCVBUF, &size, sizeof(size));

//设置发送缓冲区大小  
setsockopt(s, SOL_SOCKET, SO_SNDBUF, &size, sizeof(size));  

//设置地址可重用  
int yes=1;  
setsockopt(s, SOL_SOCKET, SO_REUSEADDR, &yes,sizeof(yes));


setsockopt(s, IPPROTO_IP, IP_MULTICAST_LOOP, (char *)&loop, sizeof(loop));
```

getsockopt()/setsockopt()的选项

含    义

IP_MULTICAST_TTL  设置多播组数据的TTL值
IP_ADD_MEMBERSHIP 在指定接口上加入组播组
IP_DROP_MEMBERSHIP 退出组播组
IP_MULTICAST_IF 获取默认接口或设置接口
IP_MULTICAST_LOOP 禁止组播数据回送



## C++

两个构造函数




## 组播

[组播学习笔记](https://blog.csdn.net/samtaoys/article/details/51981323)

[单播，组播(多播)，广播以及任播](http://colobu.com/2014/10/21/udp-and-unicast-multicast-broadcast-anycast/#0-tsina-1-67000-397232819ff9a47a7b7e80a40613cfe1)


组播使用TCPUDP


# S

rtsp_server

监听 TCP  0.0.0.0


[Miracast/RTSP](https://blog.csdn.net/wirelessdisplay/article/details/53869560)

[wifi-display specification）RTSP交互信息详解](https://blog.csdn.net/lele_cheny/article/details/20220921)

https://blog.csdn.net/wirelessdisplay

Miracast

insmod /lib/modules/bcmdhd.ko firmware_path=/etc/wifi/ap6354/fw_bcm4354a1_ag.bin nvram_path=/etc/wifi/ap6354/nvram_ap6354.txt
wpa_supplicant -iwlan0 -s -Dnl80211 -O/var/run/sockets -c/etc/wifi/ap6354/p2p_supplicant.conf &   


WIFI连接配置


作用：　（ＲＴＳＰ）

告诉连接到的所有R设备他要加入的组播　


## 疑惑

1. S和AP怎么进行连接
2. R和AP怎么进行连接
3. S和R之间存在连接吗





## 基本流程

1. S监听0.0.0.0的7236端口
2. R发送广播，广播自己的IP地址（S端存在udp server）
3. S按切换键（获取R端IP）
4. RTSP连接






##抓包

```
tcpdump -i wlan0 -w file.pcap
```

解析：wireshark






在服务器端，启动数据包捕获：

tcpdump -i wlan0 –n multicast




如果仍收不到组播数据，使用dropwatch来分析那个系统函数把数据包丢掉了

#dropwatch -l kas




# 调试

## 数据验证

1. 排除混杂模式，确保网卡进入组播模式
```
tcpdump -i wlan0 -p -nnn
```
>`-p`：    将网卡设置为非混杂模式

2. 写小应用进行简单的测试


recv接收不到数据


UDP调用connect()的作用



```
# netstat -n
Active Internet connections (w/o servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       
tcp        0      0 192.168.100.3:47518     192.168.100.2:7236      ESTABLISHED
udp        0      0 239.0.0.11:15550        192.168.100.2:42152     ESTABLISHED
udp        0      0 239.0.0.11:15551        192.168.100.2:42153     ESTABLISH
```

## inet_pton

>linux-3.18.24

内核配置：


```
# netstat -n
Active Internet connections (w/o servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       
tcp        0      0 192.168.100.3:40964     192.168.100.2:7236      ESTABLISHED
netstat: /proc/net/tcp6: No such file or directory
udp        0      0 239.0.0.11:15550        192.168.100.2:*         ESTABLISHED
udp        0      0 239.0.0.11:15551        192.168.100.2:1         ESTABLISHED
```

IGMPv2通过查询器选举机制为所连网段选举唯一的查询器。查询器周期性的发送普遍组查询消息进行成员关系查询；主机发送报告消息来应答查询。当要加入组播组时，主机不必等待查询消息，主动发送报告消息。当要离开组播组时，主机发送离开组消息；收到离开组消息后，查询器发送特定组查询消息来确定是否所有组成员都已离开。

* [IGMPV2基本原理](http://blog.sina.com.cn/s/blog_c079d59e0102whjg.html)
* [IGMP Snooping概念和配置方法---交换](https://blog.csdn.net/mingzznet/article/details/9253607)
