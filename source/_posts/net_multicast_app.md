---
title: 组播（多播）
date: 2018-06-21 23:07:24
categories: 网络
tags: [组播]
---

>组播是指在IP网络中将数据包以尽力传送的形式发送到某个确定的节点集合（即组播组），其基本思想是：源主机（即组播源）只发送一份数据，其目的地址为组播组地址；组播组中的所有接收者都可收到同样的数据拷贝，并且只有组播组内的主机可以接收该数据，而其它主机则不能收到。

组播技术有效地解决了`单点发送、多点接收`的问题，实现了IP网络中点到多点的高效数据传送，能够大量节约网络带宽、降低网络负载。作为一种与单播和广播并列的通信方式，组播的意义不仅在于此。更重要的是，可以利用网络的组播特性方便地提供一些新的增值业务，包括在线直播、网络电视、远程教育、远程医疗、网络电台、实时视频会议等互联网的信息服务领域

![组播](/images/net/multicast/multicast.png)

<!--more-->

## 组播技术实现
组播技术的实现需要解决以下几方面问题：

1. 组播源向一组确定的接收者发送信息，而如何来标识这组确定的接收者？——这需要用到`组播地址机制`；
2. 接收者通过加入组播组来实现对组播信息的接收，而接收者是如何动态地加入或离开组播组的？——即如何进行`组成员关系管理`；
3. 组播报文在网络中是如何被转发并最终到达接收者的？——即`组播报文转发`的过程；
4. 组播报文的转发路径（即组播转发树）是如何构建的？——这是由各`组播路由协议`来完成的。

## 组播地址机制

### IP组播地址

![ip format](/images/net/multicast/ip_format.gif)

IP组播地址前四位均为“1110”

IP组播地址用于标识一个IP组播组。IANA把D类地址空间分配给组播使用，范围从`224.0.0.0`到`239.255.255.255`。


![ip class](/images/net/multicast/ip_class.gif)

**组播地址划分:**

1. 224.0.0.0到224.0.0.255被IANA预留，地址224.0.0.0保留不做分配，其它地址供路由协议及拓扑查找和维护协议使用。该范围内的地址属于局部范畴，不论TTL为多少，都不会被路由器转发；
2. 224.0.1.0到238.255.255.255为用户可用的组播地址，在全网范围内有效。其中232.0.0.0/8为SSM组地址，而其余则属于ASM组地址。有关ASM和SSM的详细介绍，请参见“2.5  组播模型分类”一节；
3. 239.0.0.0到239.255.255.255为本地管理组播地址，仅在特定的本地范围内有效，也属于ASM组地址。使用本地管理组地址可以灵活定义组播域的范围，以实现不同组播域之间的地址隔离，从而有助于在不同组播域内重复使用相同组播地址而不会引起冲突。

***说明：***
>`224.0.1.0/24`网段内的一些组播地址也被IANA预留给了某些组播应用。譬如，`224.0.1.1`被预留给NTP（Network Time Protocol，网络时间协议）所使用。


## 组成员关系管理

组成员关系管理是指在`路由器/交换机`上建立直联网段内的组成员关系信息，具体说，就是各接口/端口下有哪些组播组的成员。

### IGMP

IGMP运行于`主机和与主机直连的路由器`之间，其实现的功能是双向的：

* 一方面，主机通过IGMP通知路由器希望接收某个特定组播组的信息；
* 另一方面，路由器通过IGMP周期性地查询局域网内的组播组成员是否处于活动状态，实现所连网段组成员关系的收集与维护。

通过IGMP，在路由器中记录的信息是某个组播组是否在本地有组成员，而不是组播组与主机之间的对应关系。

目前IGMP有以下三个版本：

1. `IGMPv1（RFC 1112）`中定义了基本的组成员查询和报告过程；
2. `IGMPv2（RFC 2236）`在IGMPv1的基础上添加了组成员快速离开的机制等；
3. `IGMPv3（RFC 3376）`中增加的主要功能是成员可以指定接收或拒绝来自某些组播源的报文，以实现对SSM模型的支持。

#### IGMPv2的工作原理

![IGMPv2](/images/net/multicast/IGMPv2.gif)

当同一个网段内有多个IGMP路由器时，IGMPv2通过查询器选举机制从中选举出唯一的查询器。查询器周期性地发送普遍组查询消息进行成员关系查询，主机通过发送报告消息来响应查询。而作为组成员的路由器，其行为也与普通主机一样，响应其它路由器的查询。

当主机要加入组播组时，不必等待查询消息，而是主动发送报告消息；当主机要离开组播组时，也会主动发送离开组消息，查询器收到离开组消息后，会发送特定组查询消息来确定该组的所有组成员是否都已离开。

通过上述机制，在路由器里建立起一张表，其中记录了路由器各接口所对应子网上都有哪些组的成员。当路由器收到发往组G的组播数据后，只向那些有G的成员的接口转发该数据。至于组播数据在路由器之间如何转发则由组播路由协议决定，而不是IGMP的功能。

#### 抓包信息

![组播初始化数据包](/images/net/multicast/multicast_start_package.png)

组播相关的含义：
1. IGMPv2: Membership Query, general

2. IGMPv2: Membership Report group 239.0.0.11

### IGMP Snooping

IGMP是针对IP层设计的，只能记录路由器上的三层接口与IP组播地址的对应关系。但在很多情况下，组播报文不可避免地要经过一些交换机，如果没有一种机制将二层端口与组播MAC地址对应起来，组播报文就会转发给交换机的所有端口，这显然会浪费大量的系统资源。

IGMP Snooping的出现就可以解决这个问题，其工作原理为：主机发往IGMP查询器的报告消息经过交换机时，交换机对这个消息进行监听并记录下来，为端口和组播MAC地址建立起映射关系；当交换机收到组播数据时，根据这样的映射关系，只向连有组成员的端口转发组播数据。


## 实例--视频会议

![组播实例](/images/net/multicast/multicast_r_s_samp.png)

1. 路由器新建两个AP（AP-S和AP-R），其中均开启组播功能，为什么建两个，作用，关系
2. R1和R2两个加入组播（239.0.0.1）


## 注意

1. 接收组播的网络端口（也就是R端），必须设置该组播的IP，负责接收不到组播数据


## 测试代码

R端加入组播的实现：  

[Code：](https://raw.githubusercontent.com/Winddoing/CodeWheel/master/socket/multicast/multicast-tst.c)

``` C
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <sys/types.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <errno.h>
#include <unistd.h>
#include <fcntl.h>

#define BUFLEN 255

#if 0
#define VX_RTP_MUL_IP	"239.0.0.11"
#define VX_RTP_LOCAL_PORT 15550
#else
#define VX_RTP_MUL_IP	"225.0.0.37"
#define VX_RTP_LOCAL_PORT 12345
#endif

static int socket_set_nonblock(int s)
{
	int flags, res;

	flags = fcntl(s, F_GETFL, 0);
	if (flags < 0) {
		flags = 0;
	}

	res = fcntl(s, F_SETFL, flags | O_NONBLOCK);
	if (res < 0) {
		printf( "fcntl return err:%d!\n", res);
		return -1;
	}

	return 0;
}

int main (int argc, char **argv)
{
	int fd = -1;
	int ret = -1, n = 0, sock_len = 0;
	char recmsg[BUFLEN + 1];
	fd_set rfds;
	struct sockaddr_in addr;
	struct timeval tv;
	struct ip_mreq mreq;
	int yes=1;
	int loop = 0;

	/*UDP*/
	fd = socket(AF_INET, SOCK_DGRAM, 0);
	if(fd == -1) {
		printf("create udp socket error %d", -errno);
		return -1;
	}

	socket_set_nonblock(fd);

	/* 允许多个应用绑定同一个本地端口接收数据包 */
	ret = setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, &yes,sizeof(yes));
	if (ret < 0) {
		printf("setsockopt: SO_REUSEADDR error, ret=%d\n", ret);
		goto failed;
	}

	/* 禁止组播数据回环 */
	if( setsockopt(fd, IPPROTO_IP, IP_MULTICAST_LOOP, (char *)&loop, sizeof(loop)) < 0 ){
		printf("setsockopt: IP_MULTICAST_LOOP error, ret=%d\n", ret);
		goto failed;
	}

	/* 加入组播 */
	mreq.imr_multiaddr.s_addr=inet_addr(VX_RTP_MUL_IP);
	mreq.imr_interface.s_addr=htonl(INADDR_ANY);
	ret = setsockopt(fd,IPPROTO_IP,IP_ADD_MEMBERSHIP,&mreq,sizeof(mreq));
	if (ret < 0) {
		printf("setsockopt: IP_ADD_MEMBERSHIP error, ret=%d\n", ret);
		goto failed;
	}

	memset(addr.sin_zero, 0, sizeof(addr.sin_zero));
	addr.sin_family = AF_INET;
	addr.sin_addr.s_addr = htonl(INADDR_ANY);
	addr.sin_port = htons(VX_RTP_LOCAL_PORT);

	/* 设置网卡的组播IP !!! */
	ret = inet_pton(AF_INET, VX_RTP_MUL_IP, &addr.sin_addr);
	if (ret <= 0) {
		printf("Set network card multicast ip error, ret=%d\n", ret);
		goto failed;
	}

	/* 绑定网卡 */
	ret = bind(fd, (const struct sockaddr *)&addr, sizeof(addr));
	if (ret < 0) {
		printf("Bind socket error, ret=%d\n", ret);
		goto failed;
	}

	printf("create rtp udp socket %d ok\n",fd);

	sock_len = sizeof(addr);
	/* 循环接收网络上来的组播消息 */
	for (;;)
	{
		tv.tv_sec = 1;
		tv.tv_usec = 0;

		FD_ZERO(&rfds);
		FD_SET(fd, &rfds);

		ret = select(fd + 1, &rfds, NULL, NULL, &tv);
		if (-1 == ret) {
			printf("===> func: %s, line: %d, Socket select error\n", __func__, __LINE__);
			return -1;
		} else if (0 == ret) {
			printf("===> func: %s, line: %d, select timeout\n", __func__, __LINE__);
			continue;
		}
		//struct sockaddr_in tmp_addr;
		//socklen_t addr_len = sizeof(tmp_addr);
		//bzero (recmsg, BUFLEN + 1);

eagain:
		//n = recvfrom(fd, recmsg, BUFLEN, 0, (struct sockaddr*) &addr, (socklen_t*)&sock_len);
		//n = recvfrom(fd, recmsg, BUFLEN, 0, (struct sockaddr*) &tmp_addr, &addr_len);
		n = recv(fd, recmsg, BUFLEN, 0);
		if (n < 0) {
			printf("recvfrom err in udptalk!, n: %d, errno: %d\n", n, -errno);
			if (EAGAIN == errno)
				goto eagain;
			else
				return -1;
		} else if (n == 0) {
			printf("recv data siez: %d\n", n);
		} else {
			/* 成功接收到数据报 */
			unsigned int * tmp = (unsigned int*)recmsg;

			printf ("s: %d, peer: 0x%08x\n", n, tmp[0]);
		}

	}

	return 0;

failed:
	if(fd > 0)
		close(fd);
	return -1;
}
```

## 参考

* [组播技术](https://blog.csdn.net/jianchaolv/article/details/7909948)
* [组播学习笔记](https://blog.csdn.net/samtaoys/article/details/51981323)
* [单播，组播(多播)，广播以及任播](http://colobu.com/2014/10/21/udp-and-unicast-multicast-broadcast-anycast/#0-tsina-1-67000-397232819ff9a47a7b7e80a40613cfe1)