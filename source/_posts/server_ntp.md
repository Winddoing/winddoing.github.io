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

## 应用--RTP网络延时

### 场景

有A和B两个开发板并且通过WIFI直连（P2P）使用TCP协议搭建了RTP，使用RTP进行视频传输，计算其中的网络延时

> A --- 服务器 --- 接收端 --- R
> B --- 客户端 --- 发射端 --- S

### 时间戳

#### 打时间戳

`gettimeofday`获取的时间存放在`unsigned long long`中需要64bit的空间

``` C
struct timeval now;
unsigned long long rtp_time_r = 0;

gettimeofday(&now, NULL);
rtp_time_r = 1000000 * now.tv_sec + now.tv_usec;
```

#### long long和char转换

``` C
int main(int argc, const char *argv[])
{
	char dst[30];
	unsigned long long rtpTime = 0x1234567898765;
	unsigned long long rtp_time_s = 0;
	int i = 0, j = 56;

	memset(dst, 0, sizeof(char) * 30);

	for (i = 0;  i < sizeof(rtpTime);  i++) {
		dst[19 - i] = （unsigned char）((rtpTime >> j) & 0xFF);
		//printf("===> func: %s, line: %d, rtpTime: %016llx, %d, dst[%d]=%02x\n",
				__func__, __LINE__, (rtpTime >> j) & 0xFF, j, 19 - i, dst[19 - i]);
		j -= 8;
	}

	//printf("===> func: %s, line: %d\n", __func__, __LINE__);
	j = 56;
	for (i = 0;  i < sizeof(rtp_time_s);  i++) {
		rtp_time_s |= (unsigned long long)dst[19 - i] << j;
		j -= 8;
	}

	printf("===> func: %s, line: %d,  old: %016llx\n", __func__, __LINE__, rtpTime);
	printf("===> func: %s, line: %d,  new: %016llx\n", __func__, __LINE__, rtp_time_s);

	return 0;
}
```
>不同的gcc编译器，编译完的运行结果不一样，测试`gcc version 6.4.0 20170724 (Debian 6.4.0-2)`编译运行结果错误


在嵌入式交叉编译中，测试结果正常：

>===> func: main, line: 38,  old: 0001234567898765
>===> func: main, line: 39,  new: 0001234567898765


### 测试方法

>一帧数据将会被拆分成多个RTP包进行传输

1. 在S端对每一帧数据中的RTP打入相同的时间戳Ts
2. 在R端将接收到的S端头中的时间戳解析Ts，并且此时获取R端的时间戳Tr
3. 判断一帧的数据，并计算R和S的网络延时

``` C
static unsigned long long t_count_t = 0;
static unsigned long long t_count_r = 0;
static unsigned long long t_count_s = 0;
static unsigned long long time_sum_r = 0;
static unsigned long long time_sum_s = 0;
static unsigned long long rtp_time_s_t = 0;
static unsigned long long rtp_time_r_t = 0;
static unsigned long long rtp_time_diff = 0;
static unsigned long long rtp_time_max = 0;
static unsigned long long rtp_time_min = 0xffffff;

void parse_rtp_head_time(unsigned char *data, int line)
{
    struct timeval now;
    unsigned long long rtp_time_r = 0;
    unsigned long long rtp_time_s = 0;

    //1. 获取Ｓ端的时间戳
    int i = 0, j = 56;
    for (i = 0;  i < sizeof(rtp_time_s);  i++) {
        rtp_time_s |= (unsigned long long)data[19 - i] << j;
        j -= 8;
    }

	//2. 获取Ｒ端的时间戳
    memset(&now, 0, sizeof(now));
    gettimeofday(&now, NULL);
    rtp_time_r = 1000000 * now.tv_sec + now.tv_usec;

	//3. 判断并计算一帧数据的时间
    if (rtp_time_s_t != rtp_time_s) {
        t_count_t++;
        if (t_count_t > 3000) {
            if (rtp_time_r_t >= rtp_time_s_t) {
                t_count_r++;
                rtp_time_diff = rtp_time_r_t - rtp_time_s_t;
                time_sum_r += rtp_time_diff;
                rtp_time_max = (rtp_time_max > rtp_time_diff) ? rtp_time_max : rtp_time_diff;
                rtp_time_min = (rtp_time_min < rtp_time_diff) ? rtp_time_min : rtp_time_diff;
            } else {
                t_count_s++;
                time_sum_s += (rtp_time_s_t - rtp_time_r_t);
            }
        }
        rtp_time_s_t = rtp_time_s;
    }
    rtp_time_r_t = rtp_time_r;

	//4. 判断一万帧数据后打印结果
    if (!(t_count_t % 10000)) {
        printf("%llu, t_count_r=%llu, time_sum_r=%llu, v=%llu, max:%llu, min:%llu\n",
                t_count_t, t_count_r, time_sum_r, (t_count_r != 0) ? (time_sum_r / t_count_r):111111, rtp_time_max, rtp_time_min);
        printf("%llu, t_count_s=%llu, time_sum_s=%llu, v=%llu\n",
                t_count_t, t_count_s, time_sum_s, (t_count_s != 0) ? (time_sum_s / t_count_s):111111);
    }
}
```

### 操作流程

1. 先启动Ｒ，并进行授时
2. 启动Ｓ端，并进行授时
3. 视频传输，等待计算结果

### 注意事项

* R端必须先启动授时，然后启动S端进行授时，方可进行正常的测试
* **如果S端先进行授时，而R端后进行授时，那么在R端解析到的S端时间有可能比R端的时间小，导致计算出现负数（越界），最后的结果偏差离谱**

## 参考

* [移植ntp服务到arm-linux平台](https://blog.csdn.net/zgrjkflmkyc/article/details/45098831)
* [So Easy-Ntp嵌入式软件移植](https://www.cnblogs.com/smartxuchao/p/6440524.html)
* [ubuntu搭建NTP服务器](https://blog.csdn.net/mmz_xiaokong/article/details/8700979)
