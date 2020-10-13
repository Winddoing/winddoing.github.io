---
layout: post
title: Socket recv —— Connection reset by peer (104)
date: '2018-08-21 16:14'
categories:
  - 网络
tags:
  - 网络
abbrlink: 33577
---


``` C
n = recv(socket_fd, buf, len, 0);
```
在接收数据时:

有时`recv`的返回值`n<0`，错误码：`104（Connection reset by peer）`，为啥？

有时`recv`的返回值`n=0`,对端socket关闭，如果对端socket没有关闭，为啥`n=0`？

<!--more-->

## Connection reset by peer : (ECONNRESET 104)

socket `read/recv`过程中，对方socket中断，`read/recv`会先返回已经发送的字节数,再次write时返回-1,errno号为`ECONNRESET(104)`.即：**read/recv 一个已收到`RST`的socket，系统会发SIGPIPE信号给该进程，如果将这个信号交给系统处理或者直接忽略掉了，read/recv都返回EPIPE错误**.因此对于socket通信一定要捕获此信号，进行适当处理 ，否则程序的异常退出将会给你带来灾难。

>The client's call to `readline` may happen before the server's RST is received by the client, or it may happen after.
If the readline happens before the RST is received, as we've shown in our example, the result is an unexpected EOF in the client.
But if the RST arrives first, the result is an `ECONNRESET ("Connection reset by peer")` error return from readline.
What happens if the client ignores the error return from readline and writes more data to the server?
This can happen, for example, if the client needs to perform two writes to the server before reading anything back, with the first write eliciting the RST.
The rule that applies is: When a process writes to a socket that has received an RST, the SIGPIPE signal is sent to the process.
The default action of this signal is to terminate the process, so the process must catch the signal to avoid being involuntarily terminated.
If the process either catches the signal and returns from the signal handler, or ignores the signal, the write operation returns EPIPE.

### tcp_syncookies

在高并发的情况下，内核会认为系统受到了SYN flood攻击，会发送cookies（possible SYN flooding on port 80. Sending cookies），这样会减慢影响请求的速度，所以在应用服务武器上设置下这个参数为0禁用系统保护就可以进行大并发测试了。
```
net.ipv4.tcp_syncookies = 0
```

## 返回值: n==0

> When a stream socket peer has performed an orderly shutdown, the return value will be 0 (the traditional "end-of-file" return).
> Datagram sockets in various domains (e.g., the UNIX and Internet domains) permit zero-length datagrams.  When such a datagram is received, the return value is 0.
>> form `man recv`

- 产生的原因：
对端socket关闭，但是在实际的使用中对端的socket没有进行close的情况下有时也会返回`0`，这个可能就是数据传输中对端发送了长度为`0`的数据

- 解决方法：
在实际应用开发中我们需要进行错误处理时，将返回值小于等于0的状态进行统一处理。也就是在`accept`建立一个新的连接后，创建一个独立的线程进行数据的收发，如果在收发的过程中返回值出现错误时，关闭该socket和线程进入主进程重新建立一个连接继续进行数据收发（注意C/S端均得进行这样的处理）

![Socket TCP](/images/2020/10/socket_tcp.png)

> 在Server端其实存在两socket连接，listen监听的是主的socket描述符，而当每一次accept时将会重新创建一个新的socket描述符用于数据的收发

## TCP_NODELAY

> socket编程中，`TCP_NODELAY`选项是用来控制是否开启`Nagle算法`，该算法是为了提高较慢的广域网传输效率，减小小分组的报文个数

在TCP数据传输中，如果需要提高数据的实时性需要将`Nagle算法`关闭

``` C
static void _set_tcp_nodelay(int fd) {
    int enable = 1;
    setsockopt(fd, IPPROTO_TCP, TCP_NODELAY, (void*)&enable, sizeof(enable));
}
```


## 参考

- [TCP连接的状态详解以及故障排查](https://blog.csdn.net/hguisu/article/details/38700899)
- [Linux网络编程socket错误分析](https://blog.csdn.net/uestc_huan/article/details/5863614)
- [apache ab压力测试报错（apr_socket_recv: Connection reset by peer (104)）](http://xmarker.blog.163.com/blog/static/226484057201462263815783/)
- [socket recv阻塞与非阻塞error总结](https://www.cnblogs.com/kex1n/p/7461124.html)
