---
title: 流媒体之RTSP/RTP/RTCP
categories:
  - 多媒体
tags:
  - rtp
abbrlink: 34052
date: 2018-06-23 23:07:24
---

![media_c_s](/images/media/media_C_S.jpg)

>用一句简单的话总结：RTSP发起/终结流媒体、RTP传输流媒体数据 、RTCP对RTP进行控制，同步。

<!--more-->

![流媒体协议](/images/media/media_protocol.png)

-  RTP：实时传输协议（Real-time Transport Protocol）

	* RTP/RTCP是实际传输数据的协议
	* RTP传输音频/视频数据，如果是PLAY，Server发送到Client端，如果是RECORD，可以由Client发送到Server
	* 整个RTP协议由两个密切相关的部分组成：RTP数据协议和RTP控制协议（即RTCP）

- RTSP：实时流协议（Real Time Streaming Protocol，RTSP）

	* RTSP的请求主要有DESCRIBE,SETUP,PLAY,PAUSE,TEARDOWN,OPTIONS等，顾名思义可以知道起对话和控制作用
	* RTSP的对话过程中SETUP可以确定RTP/RTCP使用的端口，PLAY/PAUSE/TEARDOWN可以开始或者停止RTP的发送，等等

-  RTCP：RTP 控制协议（RTP Control Protocol）

	* RTP/RTCP是实际传输数据的协议
	* RTCP包括Sender Report和Receiver Report，用来进行音频/视频的同步以及其他用途，是一种控制协议


## RTP

RTP数据协议负责对流媒体数据进行封包并实现媒体流的实时传输，每一个RTP数据报都由`头部（Header）`和`负载（Payload）`两个部分组成，其中头部前***12个字节***的含义是固定的，而负载则可以是`音频`或者`视频`数据。RTP数据报的头部格式如图：

```
  0                   1                   2                   3
  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
 +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 |V=2|P|X|   CC  |M|     PT      |      sequence number          |
 +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 |                         timestamp                             |
 +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 |           synchronization source (SSRC) identifier            |
 +=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
 |            contributing source (CSRC) identifiers             |
 |                            ....                               |
 +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
```

从RTP数据报的格式不难看出，它包含了传输媒体的`类型`、`格式`、`序列号`、`时间戳`以及是否有附加数据等信息，这些都为实时的流媒体传输提供了相应的基础。

### 字段解析

|       字段     	 | 位宽 |                  含义                          |
| :-------------: | :--: | :--------------------------------------------: |
|      V				  |   2	 | RTP协议的版本号，当前协议版本号为2。|
|			 P          |   1  | 填充标志, 如果P=1，则在该报文的尾部填充一个或多个额外的八位组，它们不是有效载荷的一部分。|
|      X					|   1  | 扩展标志，如果X=1，则在RTP报头后跟有一个扩展报头。|
|     CC          |   4  | CSRC计数器， 指示CSRC 标识符的个数。|
|      M          |   1  | 标记，不同的有效载荷有不同的含义，对于`视频`，标记一帧的结束；对于`音频`，标记会话的开始。|
|     PT          |   7  | 有效载荷类型，用于说明RTP报文中有效载荷的类型，如GSM音频、JPEM图像等。|
| sequence number |   16 | 用于标识发送者所发送的RTP报文的序列号，每发送一个报文，序列号增1。接收者通过序列号来检测报文丢失情况，重新排序报文，恢复数据。|
|    timestamp    |   32 | 时戳反映了该RTP报文的第一个八位组的采样时刻。接收者使用时戳来计算延迟和延迟抖动，并进行同步控制。 |
|   SSRC          |   32 | 用于标识同步信源。该标识符是随机选择的，参加同一视频会议的两个同步信源不能有相同的SSRC。|
|   CSRC          |   32 | 每个CSRC标识符占32位，可以有0～15个。每个CSRC标识了包含在该RTP报文有效载荷中的所有特约信源。 |

### 实现

RTP协议的目的是提供实时数据（如交互式的音频和视频）的端到端传输服务，因此在`RTP中没有连接的概念`，它可以`建立在底层的面向连接或面向非连接的传输协议之上`；RTP也不依赖于特别的网络地址格式，而仅仅只需要底层传输协议支持组帧（Framing）和分段（Segmentation）就足够了；另外RTP本身还不提供任何可靠性机制，这些都要由传输协议或者应用程序自己来保证。在典型的应用场合下，RTP一般是在传输协议之上作为应用程序的一部分加以实现的，

```
+-----------------------------------------------------------------+
|                     Application Layer                           |
+-----------------------------------------------------------------+
|                           RTP/RTCP                              |
+--------------------------------+--------------------------------+
|              UDP               |              TCP               |
+--------------------------------+--------------------------------+
|                         IPv4/IPv6                               |
+-----------------------------------------------------------------+
|                          LAN/WAN                                |
+-----------------------------------------------------------------+
```

## RTSP

作为一个应用层协议，RTSP提供了一个可供扩展的框架，它的意义在于使得`实时流媒体数据的受控和点播变得可能`。总的说来，RTSP是一个流媒体表示协议，主要用来控制具有实时特性的数据发送，但它本身并不传输数据，而是必须依赖于下层传输协议所提供的某些服务。

**RTSP可以对流媒体提供诸如播放、暂停、快进等操作，它负责定义具体的控制消息、操作方法、状态码等，此外还描述了与RTP间的交互操作（RFC2326）。**

由RTSP控制的媒体流集合可以用表示描述（Presentation  Description）来定义，所谓表示是指流媒体服务器提供给客户机的一个或者多个媒体流的集合，而表示描述则包含了一个表示中各个媒体流的相关信 息，如数据编码/解码算法、网络地址、媒体流的内容等。虽然RTSP服务器同样也使用标识符来区别每一流连接会话（Session），但RTSP连接并没有被绑定到传输层连接（如TCP等），也就是说在整个 RTSP连接期间，RTSP用户可打开或者关闭多个对RTSP服务器的可靠传输连接以发出RTSP  请求。此外，RTSP连接也可以基于面向无连接的传输协议（如UDP等）。

>[Real Time Streaming Protocol (RTSP)](https://www.ietf.org/rfc/rfc2326.txt)

```
=======================================================================================================================================
RTSP/Packet Counter:
Topic / Item            Count         Average       Min val       Max val       Rate (ms)     Percent       Burst rate    Burst start
---------------------------------------------------------------------------------------------------------------------------------------
Total RTSP Packets      18                                                      0.0005        100%          0.0700        5.792
 RTSP Response Packets  0                                                       0.0000        0.00%         -             -
  ???: broken           0                                                       0.0000                      -             -
  5xx: Server Error     0                                                       0.0000                      -             -
  4xx: Client Error     0                                                       0.0000                      -             -
  3xx: Redirection      0                                                       0.0000                      -             -
  2xx: Success          0                                                       0.0000                      -             -
  1xx: Informational    0                                                       0.0000                      -             -
 RTSP Request Packets   9                                                       0.0002        50.00%        0.0400        5.848
  SET_PARAMETER         2                                                       0.0001        22.22%        0.0200        5.859
  SETUP                 1                                                       0.0000        11.11%        0.0100        5.933
  PLAY                  1                                                       0.0000        11.11%        0.0100        5.986
  OPTIONS               2                                                       0.0001        22.22%        0.0200        5.751
  GET_PARAMETER         3                                                       0.0001        33.33%        0.0100        5.848
 Other RTSP Packets     9                                                       0.0002        50.00%        0.0400        5.792

---------------------------------------------------------------------------------------------------------------------------------------
```

>RTSP是一种基于`文本`的协议，用`CRLF`作为一行的结束符。使用基于文本协议的好处在于我们可以随时在使用过程中的增加自定义的参数，也可以随便将协议包抓住很直观的进行分析。

### 报文

RTSP有两类报文：`请求报文`和`响应报文`

* 请求报文:指从客户端向服务器发送请求报文
* 响应报文:指从服务器到客户端的回答

RTSP报文由三部分组成，即`开始行`、`首部行`和`实体主体`。

#### 请求报文

在请求报文中，开始行就是请求行，RTSP请求报文的结构如图

![请求报文](/images/media/rtsp_request_message.jpg)

RTSP请求报文的常用方法及作用：

|     方法      | 作用                                            |
|:-------------:|:------------------------------------------------|
|    OPTIONS    | 获得服务器提供的可用方法                        |
|   DESCRIBE    | 得到会话描述信息                                |
|     SETUP     | 客户端提醒服务器建立会话，并确定传输模式        |
|   TEARDOWN    | 客户端发起关闭请求                              |
|     PLAY      | 客户端发送播放请求                              |
| SET_PARAMETER | 给URI指定的表示或媒体流设置参数值               |
| GET_PARAMETER | 获取URI中指定的表示或流的任何指定参数或参数的值 |
#### 响应报文

响应报文的`开始行`是`状态行`，RTSP响应报文的结构如图：

![响应报文](/images/media/rtsp_answer_message.jpg)


#### 示例-交互

```
OPTIONS * RTSP/1.0
Date: Thu, 01 Jan 1970 00:11:07 +0000
Server: linux
CSeq: 1
Require: org.wfa.wfd1.0

RTSP/1.0 200 OK
Date: Thu, 01 Jan 1970 00:00:49 +0000
User-Agent: stagefright/1.1 (Linux;Android 4.1)
CSeq: 1
Public: org.wfa.wfd1.0, GET_PARAMETER, SET_PARAMETER

OPTIONS * RTSP/1.0
Date: Thu, 01 Jan 1970 00:00:49 +0000
User-Agent: stagefright/1.1 (Linux;Android 4.1)
CSeq: 1
Require: org.wfa.wfd1.0

RTSP/1.0 200 OK
Date: Thu, 01 Jan 1970 00:11:07 +0000
Server: linux
CSeq: 1
Public: org.wfa.wfd1.0, SETUP, TEARDOWN, PLAY, PAUSE, GET_PARAMETER, SET_PARAMETER

GET_PARAMETER rtsp://localhost/wfd1.0 RTSP/1.0
Date: Thu, 01 Jan 1970 00:11:07 +0000
Server: linux
CSeq: 2
Content-Type: text/parameters
Content-Length: 90

wfd_video_formats
wfd_audio_codecs
wfd_client_rtp_ports
wfd_rtp_multicast: 239.0.0.11
RTSP/1.0 200 OK
Date: Thu, 01 Jan 1970 00:00:49 +0000
User-Agent: stagefright/1.1 (Linux;Android 4.1)
CSeq: 2
Content-Type: text/parameters
Content-Length: 259

wfd_video_formats: 28 00 02 02 0001DEFF 157C7FFF 00000FFF 00 0000 0000 11 none none, 01 02 0001DEFF 157C7FFF 00000FFF 00 0000 0000 11 none none
wfd_audio_codecs: LPCM 00000002 00, AAC 00000001 00
wfd_client_rtp_ports: RTP/AVP/UDP;unicast 15550 0 mode=play
SET_PARAMETER rtsp://localhost/wfd1.0 RTSP/1.0
Date: Thu, 01 Jan 1970 00:11:07 +0000
Server: linux
CSeq: 3
Content-Type: text/parameters
Content-Length: 203

wfd_video_formats: wfd_audio_codecs: LPCM 00000002 00
wfd_presentation_URL: rtsp://192.168.100.2/wfd1.0/streamid=0 none
wfd_client_rtp_ports: RTP/AVP/UDP;unicast 15550 0 mode=play
wfd_display_edid:
RTSP/1.0 200 OK
Date: Thu, 01 Jan 1970 00:00:49 +0000
User-Agent: stagefright/1.1 (Linux;Android 4.1)
CSeq: 3

SET_PARAMETER rtsp://localhost/wfd1.0 RTSP/1.0
Date: Thu, 01 Jan 1970 00:11:07 +0000
Server: linux
CSeq: 4
Content-Type: text/parameters
Content-Length: 27

wfd_trigger_method: SETUP
RTSP/1.0 200 OK
Date: Thu, 01 Jan 1970 00:00:49 +0000
User-Agent: stagefright/1.1 (Linux;Android 4.1)
CSeq: 4

SETUP rtsp://192.168.100.2/wfd1.0/streamid=0 RTSP/1.0
Date: Thu, 01 Jan 1970 00:00:49 +0000
User-Agent: stagefright/1.1 (Linux;Android 4.1)
CSeq: 2
Transport: RTP/AVP/UDP;unicast;client_port=15550-15551

RTSP/1.0 200 OK
Date: Thu, 01 Jan 1970 00:11:07 +0000
Server: linux
CSeq: 2
Session: 1649760492;timeout=319201969439387
Transport: RTP/AVP/UDP;unicast;client_port=15550-15551;server_port=22648-22649

PLAY rtsp://192.168.100.2/wfd1.0/streamid=0 RTSP/1.0
Date: Thu, 01 Jan 1970 00:00:49 +0000
User-Agent: stagefright/1.1 (Linux;Android 4.1)
CSeq: 3
Session: 1649760492

RTSP/1.0 200 OK
Date: Thu, 01 Jan 1970 00:11:07 +0000
Server: linux
CSeq: 3
Session: 1649760492;timeout=319201969439387
Range: npt=now-

GET_PARAMETER rtsp://localhost/wfd1.0 RTSP/1.0
Date: Thu, 01 Jan 1970 00:11:27 +0000
Server: linux
CSeq: 5
Session: 1649760492

RTSP/1.0 200 OK
Date: Thu, 01 Jan 1970 00:01:08 +0000
User-Agent: stagefright/1.1 (Linux;Android 4.1)
CSeq: 5
Content-Type: text/parameters
Content-Length: 0

GET_PARAMETER rtsp://localhost/wfd1.0 RTSP/1.0
Date: Thu, 01 Jan 1970 00:11:47 +0000
Server: linux
CSeq: 6
Session: 1649760492

RTSP/1.0 200 OK
Date: Thu, 01 Jan 1970 00:01:28 +0000
User-Agent: stagefright/1.1 (Linux;Android 4.1)
CSeq: 6
Content-Type: text/parameters
Content-Length: 0
```

## RTCP

RTCP控制协议需要与RTP数据协议一起配合使用，**当应用程序启动一个RTP会话时将同时占用两个端口，分别供RTP和RTCP使用**。`RTP本身并不能为按序传输数据包提供可靠的保证，也不提供流量控制和拥塞控制，这些都由RTCP来负责完成`。通常RTCP会采用与RTP相同的分发机制，向会话中的所有成员周期性地发送控制信息，应用程序通过接收这些数据，从中获取会话参与者的相关资料，以及网络状况、分组丢失概率等反馈信息，从而能够对服务质量进行控制或者对网络状况进行诊断。

## 开源代码

- C++
	* [JRTPLIB](http://research.edm.uhasselt.be/jori/page/CS/Jrtplib.html)【[Code](https://github.com/j0r1/JRTPLIB.git)】
	* [myRtspClient](https://github.com/Ansersion/myRtspClient)



## 参考

* [RTSP/RTP 媒体传输和控制协议](https://blog.csdn.net/ww506772362/article/details/52609379)
* [RTP Payload Format for H.264 Video](https://tools.ietf.org/pdf/rfc6184.pdf)【[html](https://tools.ietf.org/html/rfc6184)】
* [Real-Time Streaming Protocol (RTSP) 2.0 Parameters](https://www.iana.org/assignments/rtspv2-parameters/rtspv2-parameters.xhtml)
* [RTP/RTSP/RTCP的区别](http://www.txrjy.com/thread-357928-1-1.html)
* [RTSP协议介绍](https://yq.aliyun.com/articles/229295)
