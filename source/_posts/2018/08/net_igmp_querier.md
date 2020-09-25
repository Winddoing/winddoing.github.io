---
layout: post
title: IGMP snooping 查询器
date: '2018-08-11 14:23'
abbrlink: 51576
---

IGMP在本地网络上的`主机`和`路由器`之间传达组成员信息，路由器定时向所有主机组多播IGMP查询。主机多播IGMP报告报文以响应查询。

```
00:43:16.580029 IP (tos 0x0, ttl 1, id 0, offset 0, flags [DF], proto IGMP (2), length 28)
     192.168.99.112 > 224.0.0.1: igmp query v1
00:43:17.460173 IP (tos 0xc0, ttl 1, id 0, offset 0, flags [DF], proto IGMP (2), length 32, options (RA))
     192.168.99.64 > 239.0.0.11: igmp v1 report 239.0.0.11
```

<!--more-->

## IGMPv1报文格式

```
0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+---------------------------------------------------------------
|Version| Type  |    Unused     |           Checksum            |
+---------------------------------------------------------------
|                         Group Address                         |
+---------------------------------------------------------------
```
|     字段      |  长度  | 描述                                                                                                                                                      |
|:-------------:|:------:|:----------------------------------------------------------------------------------------------------------------------------------------------------------|
|    Version    | 4比特  | IGMP版本号，在IGMPv1中应为0x1。                                                                                                                           |
|     Type      | 4比特  | 即IGMP报文类型： 1 = Host Membership Query 主机成员查询; 2 = Host Membership Report 主机成员报告                                                          |
|    Unused     | 8比特  | 未使用的字段，发送时必须填0，接收时忽略。                                                                                                                 |
|   Checksum    | 16比特 | IGMP消息的校验和。该字段在进行校验计算时设为0。当传送报文的时候，必须计算该校验字并插入到该字段中去。当接收包的时候，该校验字必须在处理该包之前进行检验。 |
| Group Address | 32比特 | 组播地址。                                                                                                                                                |

>IGMPv1协议主要基于查询和响应机制完成组播组管理，支持查询和加入报文，处理过程与IGMPv2相同。IGMPv1与IGMPv2的不同之处是：主机离开组播组时不主动发送离开报文，收到查询消息后不反馈Report消息，待维护组成员关系的定时器超时后，路由器删除组记录。

##  协议栈结构

```
+-------------------------------+
|             IGMPv1            |
+-------------------------------+
|      IP (Protocol = 0x02)     |
+-------------------------------+
|              L2               |
+-------------------------------+
|              L1               |
+-------------------------------+
```
IGMPv1消息封装在`IP报文`中。IP头部的Protocol字段值为0x02，用来`标识数据部分封装了IGMP消息`。

IP报文头的目的地址字段用来标识该IGMP消息的目的接收端。IP报文头的TTL字段值为1，表示IGMP消息只在本地网段传播。


格式：
```
                            +---------------------+------------------------+
                            |type|code|   cksum   |       group addr       |
                            +---------------------+------------------------+
                            ^                                              ^
                            |                                              |
                            |                                              |
                            +-------+                          +----------+
                                    |                          |
                                    |                          |
+--------------------------------------------------------------+
|                                   |                          |
|              IP首部                |                          |
|                                   |                          |
+-----------------------------------+--------------------------+
<------------------------ IP数据包     ------------------------->

```

## 数据结构

``` C
struct igmp {
  uint8_t igmp_type;             /* IGMP type */
  uint8_t igmp_code;             /* routing code */
  uint16_t igmp_cksum;           /* checksum */
  struct in_addr igmp_group;     /* group address */
};
/*
 * Message types, including version number.
 */
#define IGMP_MEMBERSHIP_QUERY       0x11    /* membership query         */
#define IGMP_V1_MEMBERSHIP_REPORT   0x12    /* Ver. 1 membership report */
#define IGMP_V2_MEMBERSHIP_REPORT   0x16    /* Ver. 2 membership report */
#define IGMP_V2_LEAVE_GROUP     0x17    /* Leave-group message      */

#define IGMP_DVMRP          0x13    /* DVMRP routing message    */
#define IGMP_PIM            0x14    /* PIM routing message      */
#define IGMP_TRACE          0x15

#define IGMP_MTRACE_RESP        0x1e    /* traceroute resp.(to sender)*/
#define IGMP_MTRACE         0x1f    /* mcast traceroute messages  */

#define IGMP_MAX_HOST_REPORT_DELAY  10  /* max delay for response to     */
                        /*  query (in seconds) according */
                        /*  to RFC1112                   */
#define IGMP_TIMER_SCALE        10  /* denotes that the igmp code field */
                        /* specifies time in 10th of seconds */
```
> /usr/include/netinet/igmp.h

**校验**：`TCP`、`UDP`、`ICMP`、`IGMP`包首部中的检验和都是针对整个包（首部和数据部分）做检验的。

### IGMP_MEMBERSHIP_QUERY

成员关系查询，RFC1075推荐多播路由器每`120秒`至少发布一次IGMP成员关系查询。把查询发给224.0.0.1组（所有主机组）。

### IGMP_HOST_MEMEBER_REPORT && IGMP_V2_MEMBERSHIP_REPORT

成员关系报告

## 实现

```C
uint16_t cksum(void *buf, size_t len)
{
    uint32_t cksum = 0;
    int i;
    int short_len = len / 2;

    for (i = 0; i < short_len; i++) {
        cksum += ((uint16_t*)buf)[i];
    }
    if (len % 2) {
        cksum += ((uint8_t*)buf)[len - 1];
    }
    cksum = (cksum >> 16) + (cksum & 0xFFFF);
    cksum = cksum + (cksum >> 16);

    return (~cksum & 0xFFFF);
}
```
> IP数据报的检验和：
>
> 为了计算一份数据报的I P检验和，首先把检验和字段置为0。然后，对首部中每个16 bit进行二进制反码求和（整个首部看成是由一串16 bit的字组成），结果存在检验和字段中。当收到一份I P数据报后，同样对首部中每个16 bit进行二进制反码的求和。由于接收方在计算过程中包含了发送方存在首部中的检验和，因此，如果首部在传输过程中没有发生任何差错，那么接收方计算的结果应该为全1。

``` C
   struct igmp igmp;
   struct in_addr mgroup, allhosts;
   struct sockaddr_in dst;

   /* Create socket */
   sockfd = socket(PF_INET, SOCK_RAW, IPPROTO_IGMP);

   /* Multicast groups */
   mgroup.s_addr = inet_addr("0.0.0.0");
   if (mgroup.s_addr == INADDR_NONE) {
        printf("Invalid multicast group '0.0.0.0'");
        goto fail;
    }
    allhosts.s_addr = inet_addr("224.0.0.1");
    if (allhosts.s_addr == INADDR_NONE) {
        printf("Invalid multicast group '224.0.0.1'");
        goto fail;
    }

    /* IGMPv1 query */
    igmp.igmp_type = IGMP_MEMBERSHIP_QUERY;
    igmp.igmp_code = 0;
    igmp.igmp_cksum = 0;
    igmp.igmp_group = mgroup;
    igmp.igmp_cksum = cksum(&igmp, sizeof(igmp));

    /* Destination */
    dst.sin_family = AF_INET;
    dst.sin_port = htons(0);
    dst.sin_addr = allhosts;

    /* Transmit loop */
    while (1) {
        if (sendto(sockfd, &igmp, sizeof(igmp), 0, (struct sockaddr*)&dst, sizeof(dst)) == -1) {
            printf("Could not send IGMP query: %s", strerror(errno));
        }
        sleep(options->interval);
    }
```
