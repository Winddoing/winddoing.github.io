---
title: UDP调用connect的作用
categories:
  - 网络
tags:
  - udp
abbrlink: 33300
date: 2018-06-21 23:57:24
---

> 问： UDP中可以使用`connect`系统调用吗?

> 答： 可以

> 问： 为什么使用？

> 答： 提高效率

<!--more-->

## UDP中connect操作与TCP中connect操作有着本质区别？

> 1. TCP中调用connect会引起三次握手,client与server建立连结
> 2. UDP中调用connect内核仅仅把对端`ip&port`记录下来.

## UDP中可以`多次`调用connect,TCP只能调用`一次`onnect

> UDP多次调用connect有两种用途:
>> 1. 指定一个新的ip&port连结.
>> 2. 断开和之前的ip&port的连结.

``` C
struct sockaddr_in remoteAddr;

memset(remoteAddr.sin_zero, 0, sizeof(remoteAddr.sin_zero));
remoteAddr.sin_family = AF_INET;  /* 建立新的连接 */
//remoteAddr.sin_family = AF_INET;  /* 断开旧的连接 */
inet_pton(AF_INET,player->rtpUdp.rip, &remoteAddr.sin_addr);
remoteAddr.sin_port = htons(player->rtpUdp.rport);
do {
    ret = connect(player->rtpUdp.fd,(struct sockaddr *)&remoteAddr,remoteAddrLen);
} while(ret == -1 && errno == EINTR);
```

## UDP中使用connect可以提高效率原因

* 普通的UDP发送两个报文内核处理如下:
```
#1:建立连结 -> #2:发送报文 -> #3:断开连结 -> #4:建立连结 -> #5:发送报文 -> #6:断开连结
```
* 采用connect方式的UDP发送两个报文内核处理如下：
```
#1:建立连结 -> #2:发送报文 -> #3:发送另外一个报文
```
> 每次发送报文内核都由可能要做路由查询

## UDP中使用connect的好处：

1. 会提升效率
2. 高并发服务中会增加系统稳定性.
>原因: ???
>
>假设client A 通过非connect的UDP与server B,C通信.B,C提供相同服务.为了负载均衡,我们让A与B,C交替通信.A 与 B通信IPa:PORTa ---- IPb:PORTb；
>
>A 与 C通信IPa:PORTa'--- IPc:PORTc
>
>假设PORTa 与 PORTa'相同了(在大并发情况下会发生这种情况),那么就有可能出现A等待B的报文,却收到了C的报文.导致收报错误.解决方法内就是采用connect的UDP通信方式.在A中创建两个udp,然后分别connect到B,C.

## 参考

1. [UDP 调用 connect](https://blog.csdn.net/u013920085/article/details/44834815)
