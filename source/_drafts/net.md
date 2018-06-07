


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