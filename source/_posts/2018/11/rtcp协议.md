---
layout: post
title: RTCP协议
date: '2018-11-29 09:28'
tags:
  - rtcp
categories:
  - 多媒体
  - 传输
---

>Real-time Transport Control Protocol或RTP Control Protocol或简写RTCP）是实时传输协议（RTP）的一个姐妹协议。RTCP由[RFC 3550](https://tools.ietf.org/html/rfc3550)定义（取代作废的RFC 1889）。RTP 使用一个 偶数 UDP port ；而RTCP 则使用 RTP 的下一个 port，也就是一个奇数 port。RTCP与RTP联合工作，RTP实施实际数据的传输，RTCP则负责将控制包送至电话中的每个人。其主要功能是就RTP正在提供的服务质量(Quality of Service)做出反馈。

RTCP协议将控制包周期发送给所有连接者，应用与数据包相同的分布机制。低层协议提供数据与控制包的复用，如使用单独的UDP端口号。

作用:
- 主要是提供数据发布的质量反馈
- RTCP带有称作规范名字（CNAME）的RTP源持久传输层标识
- 传送最小连接控制信息，如参加者辨识

<!--more-->

## RTCP分类

| 类型 |               缩写               |    用途    |
|:----:|:--------------------------------:|:----------:|
| 200  |       SR（Sender Report）        | 发送端报告 |
| 201  |      RR（Receiver Report）       | 接收端报告 |
| 202  | SDES（Source Description Items） |  源点描述  |
| 203  |               BYE                |  结束传输  |
| 204  |               APP                |  特定应用  |

### RTCP的扩展

| 类型 |            缩写            |      用途      | 所在RFC  |
|:----:|:--------------------------:|:--------------:|:--------:|
| 195  | 1J(Extended Jitter Report) | 扩展Jitter报告 | RFC 5450 |
| 205  |    RTPFB(Transport FB)     |   传输层反馈   | [RFC 4585](https://tools.ietf.org/html/rfc4585) |
| 206  | PSFB(Payload-specific FB)  |  负载相关反馈  | RFC 5104 |
| 207  |    XR(Exteneded Report)    |    扩展报告    | RFC 3611 |

> - FB: Feedback(反馈)

## 反馈报文

类型:
- Transport layer FB messages
- Payload-specific FB messages
- Application layer FB messages

### 报文格式

```
0                   1                   2                   3
  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
 +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 |V=2|P|   FMT   |       PT      |          length               |
 +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 |                  SSRC of packet sender                        |
 +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 |                  SSRC of media source                         |
 +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 :            Feedback Control Information (FCI)                 :
 :                                                               :
```

* version(V), 2bits : 标识当前RTP版本2
* padding(P), 1bit : 填充位标识
* Feedback message type(FMT), 5bits : 标识反馈消息的类型
* Payload type (PT), 8 bits : rtcp包的类型
* Length, 16 bits :

### FMT报文子类型

| 类型 | 子类型 |     缩写     |                        用途                         |
|:----:|:------:|:------------:|:---------------------------------------------------:|
| 205  |   1    | Generic NACK |                     RTP丢包重传                     |
|  -   |   3    |    TMMBR     |   Temporary Maximum Media Stream Bitrate Request    |
|  -   |   4    |    TMMBN     | Temporary Maximum Media Stream Bitrate Notification |
| 206  |   1    |     PLI      |               Picture Loss Indication               |

### Generic NACK

> The Generic NACK message is identified by `PT=RTPFB` and `FMT=1`.

消息语法:
```
0                   1                   2                   3
  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
 +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 |            PID                |             BLP               |
 +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
```

- PID: Packet ID (PID): 16 bits
    - 丢失RTP包的ID
- BLP:  bitmask of following lost packets (BLP): 16 bits
    - 从PID开始接下来16个RTP数据包的丢失情况,一个NACK报文可以携带多个RTP序列号，NACK接收端对这些序列号逐个处理。


## 丢包重传

如果在接收端检查到出现丢包现象,通过RTCP发送丢包ID接可以让丢包重传.

``` C
static void RequestLostPacket(rtp_t *rtp, unsigned int rtpSsrc, int seqNo)
{
    char FB_msg_packet[128] = {0};
    unsigned int srcId = rtpSsrc;
    int blp = 0; //表示一个只处理一个丢包

    FB_msg_packet[0] = 0x80 | 1;  // version=2, Generic NACK
    FB_msg_packet[1] = 205;       // RTPFB
    FB_msg_packet[2] = 0;
    FB_msg_packet[3] = 3;         //length = 3

    // SSRC of packet sender
    FB_msg_packet[4] = 0xde;      
    FB_msg_packet[5] = 0xad;
    FB_msg_packet[6] = 0xbe;
    FB_msg_packet[7] = 0xef;

    //SSRC of media source
    FB_msg_packet[8] = (srcId >> 24) & 0xff;      
    FB_msg_packet[9] = (srcId >> 16) & 0xff;
    FB_msg_packet[10] = (srcId >> 8) & 0xff;
    FB_msg_packet[11] = (srcId & 0xff);

    //lost packet ID
    FB_msg_packet[12] = (seqNo >> 8) & 0xff;
    FB_msg_packet[13] = (seqNo & 0xff);

    //BLP
    FB_msg_packet[14] = (blp >> 8) & 0xff;        
    FB_msg_packet[15] = (blp & 0xff);

    net_session_write(&rtp->rtcp_net, FB_msg_packet, 16);
}
```

## 其他格式

### SR: Sender Report RTCP Packet

```
0                   1                   2                   3
        0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
       +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
header |V=2|P|    RC   |   PT=SR=200   |             length            |
       +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
       |                         SSRC of sender                        |
       +=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
sender |              NTP timestamp, most significant word             |
info   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
       |             NTP timestamp, least significant word             |
       +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
       |                         RTP timestamp                         |
       +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
       |                     sender's packet count                     |
       +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
       |                      sender's octet count                     |
       +=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
report |                 SSRC_1 (SSRC of first source)                 |
block  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
  1    | fraction lost |       cumulative number of packets lost       |
       +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
       |           extended highest sequence number received           |
       +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
       |                      interarrival jitter                      |
       +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
       |                         last SR (LSR)                         |
       +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
       |                   delay since last SR (DLSR)                  |
       +=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
report |                 SSRC_2 (SSRC of second source)                |
block  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
  2    :                               ...                             :
       +=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
       |                  profile-specific extensions                  |
       +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
```


### RR: Receiver Report RTCP Packet

```
0                   1                   2                   3
      0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
header |V=2|P|    RC   |   PT=RR=201   |             length            |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |                     SSRC of packet sender                     |
     +=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
report |                 SSRC_1 (SSRC of first source)                 |
block  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
1    | fraction lost |       cumulative number of packets lost       |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |           extended highest sequence number received           |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |                      interarrival jitter                      |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |                         last SR (LSR)                         |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |                   delay since last SR (DLSR)                  |
     +=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
report |                 SSRC_2 (SSRC of second source)                |
block  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
2    :                               ...                             :
     +=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
     |                  profile-specific extensions                  |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
```
