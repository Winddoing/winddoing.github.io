---
layout: post
title: Socket recv —— Connection reset by peer (104)
date: '2018-08-21 16:14'
categories:
  - 网络
tags:
  - 网络
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



## 返回值: n==0


## TCP_NODELAY


## 参考

- [TCP连接的状态详解以及故障排查](https://blog.csdn.net/hguisu/article/details/38700899)
- [Linux网络编程socket错误分析](https://blog.csdn.net/uestc_huan/article/details/5863614)
- [apache ab压力测试报错（apr_socket_recv: Connection reset by peer (104)）](http://xmarker.blog.163.com/blog/static/226484057201462263815783/)
- [socket recv阻塞与非阻塞error总结](https://www.cnblogs.com/kex1n/p/7461124.html)
