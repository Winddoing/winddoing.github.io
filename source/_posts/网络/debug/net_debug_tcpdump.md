---
title: 网络调试--tcpdump
categories:
  - 网络
  - debug
tags:
  - debug
abbrlink: 18035
date: 2018-06-21 23:17:24
---

网络调试的手段工具：`tcpdump`、`wireshark`

<!--more-->


## 抓包--tcpdump

下载：[http://www.tcpdump.org](http://www.tcpdump.org)

```
tcpdump -i wlan0 -p  -w file.pcap
```
常用参数：

| arg   |       |
| :---: | :----|
| -p    |  将网卡设置为非混杂模式 |
| -n    | 对地址以数字方式显式，否则显式为主机名，也就是说-n选项不做主机名解析。|
| -nn   | 除了-n的作用外，还把端口显示为数值，否则显示端口服务名。  |
| -c    | 指定要抓取的包数量  |
| -v    | 当分析和打印的时候，产生详细的输出  |
| -vv   | 产生比-v更详细的输出   |
| -w    | 将抓包数据输出到文件中而不是标准输出。可以同时配合`-G time`选项使得输出文件每time秒就自动切换到另一个文件 |


### Install for arm

``` shell
#!/bin/bash

# host

# for libpcap error: configure: error: Neither flex nor lex was found.
#sudo apt install flex bison

PWD=$(pwd)

TCPDUMP="tcpdump-4.9.2"
LIBPCAP="libpcap-1.9.0"

export CC=arm-linux-gnueabihf-gcc

# http://www.tcpdump.org

for software in ${TCPDUMP} ${LIBPCAP}
do
	echo "Download $software ..."
	echo "wget http://www.tcpdump.org/release/${software}.tar.gz"
	wget http://www.tcpdump.org/release/${software}.tar.gz
	echo "tar xvf ${software}.tar.gz"
	tar xvf ${software}.tar.gz
done

cd ${LIBPCAP}
./configure --host=arm-linux --with-pcap=linux --prefix=${PWD}/out
make; make install
cd -

cd ${TCPDUMP}
./configure --host=arm-linux --with-system-libpcap=${PWD}/../${LIBPCAP}/out/lib --prefix=${PWD}/out
make; make install
cd -

cp ${PWD}/${TCPDUMP}/out/sbin/tcpdump .
```

### 示例

> `-n`：直接打印，`-w`：保存文件

* 抓取wlan0中的所有数据包
``` shell
# tcpdump -i wlan0 -v -n
```

* 抓取wlan0中的udp包
``` shell
# tcpdump -i wlan0 -v -n udp
```

* 抓取wlan中的5个udp包
``` shell
# tcpdump -i wlan0 -v -n udp -c 5
```

* 指定端口号
``` shell
tcpdump -i wlan0 tcp port 7236 -w rrrr.pcap
```
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
