---
title: NTP服务
date: 2018-05-24 23:07:24
categories: 系统服务
tags: [NTP]
---

NTP是网络时间协议(Network Time Protocol)，它是用来同步网络中各个计算机的时间的协议。
通俗：Ntp是一种授时的软件
用途是把计算机的时钟同步到世界协调时UTC，其精度在`局域网内可达0.1ms`，在互联网上绝大多数的地方其精度可以达到`1-50ms`。

<!--more-->

## 搭建NTP Server

### ubuntu/deepin平台安装

```
sudo apt-get install ntp
```

### 配置NTP

修改`/etc/ntp.conf`文件。

```
sudo vim /etc/ntp.conf

driftfile /var/lib/ntp/ntp.drift
statistics loopstats peerstats clockstats
filegen loopstats file loopstats type day enable
filegen peerstats file peerstats type day enable
filegen clockstats file clockstats type day enable
server ntp.ubuntu.com
restrict -4 default kod notrap nomodify nopeer noquery
restrict -6 default kod notrap nomodify nopeer noquery
restrict 192.168.1.0 mask 255.255.255.0 nomodify   #<+++++主要是允许能同步的服务器所在的内部网段
restrict 127.0.0.1
restrict ::1V
```

#### 权限设定部分

权限设定主要以`restrict`这个参数来设定，主要的语法为：
```
restrict IP mask netmask_IP parameter
```
>其中IP可以是软体位址，也可以是 default ，default 就类似0.0.0.0
>如果 paramter完全没有设定，那就表示该 IP (或网域) 『没有任何限制！』

paramter:
* ignore：关闭所有的NTP 连线服务
* nomodify：表示Client 端不能更改 Server 端的时间参数，不过Client端仍然可以透过Server 端來进行网络较时。
* notrust：该 Client 除非通过认证，否则该 Client 来源将被视为不信任网域
* noquery：不提供 Client 端的时间查询

### 重启NTP服务

```
sudo /etc/init.d/ntp restart
```

### 使用-对时

```
ntpdate cn.pool.ntp.org
```

## 移植NTP服务

移植其中包括客户端和服务端

``` shell
#!/bin/bash                                                                                                                              
wget https://www.eecis.udel.edu/~ntp/ntp_spool/ntp4/ntp-4.2/ntp-4.2.8p11.tar.gz              
tar zxvf ntp-4.2.8p11.tar.gz                                                                                                                                     
cd ntp-4.2.8p11                                                                                                                          
PWD=`pwd`                                                                                                                                
echo "xxxxxxxxxxxx$PWD"                                                                                                                  
rm $PWD/install -rf                                                                                                                      
mkdir $PWD/install                                                                                                                       
echo "./configure --host=arm-linux CC=arm-gcc49-linux-gnueabi-gcc --prefix=$PWD/install/  --with-yielding-select=yes"                    
./configure --host=arm-linux CC=arm-gcc49-linux-gnueabi-gcc --prefix=$PWD/install/  --with-yielding-select=yes                           
make                                                                                                                                     
make install                                                                                                                             
```

### 同步

```
ntpdate 192.168.1.11
```

### 修改时区

>注意：用`date`命令查看之后显示的是UTC时间（世界标准时间），比北京时间（CST=UTC+8）相差8个小时，所以需要设置时区

设置时区为CST时间, 把redhat或者ubuntu系统目录`/usr/share/zoneinfo/Asia`中的文件`Shanghai`拷贝到开发板目录/etc中并且改名为`localtime`之后，用命令reboot重启即可


## busybox--ntpd

[busybox:ntpd](https://elixir.bootlin.com/busybox/1.28.4/source/examples/var_service/ntpd)

```
BusyBox v1.25.1 (2018-05-24 14:59:56 CST) multi-call binary.

Usage: ntpd [-dnqNwl -I IFACE] [-S PROG] [-p PEER]...

NTP client/server

        -d      Verbose
        -n      Do not daemonize
        -q      Quit after clock is set
        -N      Run at high priority
        -w      Do not set time (only query peers), implies -n
        -S PROG Run PROG after stepping time, stratum change, and every 11 mins
        -p PEER Obtain time from PEER (may be repeated)
        -l      Also run as server on port 123
        -I IFACE Bind server to IFACE, implies -l
```

### clinet
```
ntpd -p 192.168.1.11 -qNn
```
### Server
```
ntpd -ddnNl
```

## 参考

* [移植ntp服务到arm-linux平台](https://blog.csdn.net/zgrjkflmkyc/article/details/45098831)
* [So Easy-Ntp嵌入式软件移植](https://www.cnblogs.com/smartxuchao/p/6440524.html)
* [ubuntu搭建NTP服务器](https://blog.csdn.net/mmz_xiaokong/article/details/8700979)
