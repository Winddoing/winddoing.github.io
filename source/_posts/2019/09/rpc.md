---
layout: post
title: rpc
date: '2019-09-29 21:23'
tags:
  - rpc
categories:
  - 系统应用
abbrlink: 62149
---

>`RPC`是远程过程调用（Remote Procedure Call）的缩写形式。SAP系统RPC调用的原理其实很简单，有一些类似于三层构架的C/S系统，第三方的客户程序通过接口调用SAP内部的标准或自定义函数，获得函数返回的数据进行处理后显示或打印

<!--more-->

>Since the idea of [RPC](http://en.wikipedia.org/wiki/Remote_procedure_call)  goes back to 1976 and the first business use was by Xerox in 1981, I'm  not exactly sure what qualifies as a really old tutorial.

>Here are a few resources you might find helpful.

- [Power Programming with RPC](http://books.google.com/books?id=PN2hcRD29JUC&dq=Power+Programming+with+RPC) (1992)
- [Remote Procedure Calls | Linux Journal](http://www.linuxjournal.com/article/2204) (Oct 01, 1997)
- [Remote Procedure Calls (RPC)](http://www.cs.cf.ac.uk/Dave/C/node33.html) (1999)
- [Remote Procedure Call Programming Guide](http://docs.freebsd.org/44doc/psd/23.rpc/paper.pdf) (PDF link)
- [rpc(3) - Linux man page](http://linux.die.net/man/3/rpc)

## rpcgen

```
$rpcgen --version
rpcgen (Ubuntu GLIBC 2.27-3ubuntu1) 2.27
```
## rpcinfo

> report RPC information

## Q&A

### Cannot register service: RPC: Unable to receive; errno = Connection refused

`portmap`是为RPC程序服务的。每一个RPC server程序启动的时候要向portmap程序注册。这样portmap程序就知道这些RPC server监听在哪个端口。 而RPC client在发起连接向portmap发起查询，知道了想要查询的RPC server的监听端口后再去连接server

``` shell
sudo apt install portmap rpcbind
sudo systemctl status portmap.service
```

## 示例

``` shell
$find /usr/include/ -name "*.x"
/usr/include/rpcsvc/key_prot.x
/usr/include/rpcsvc/bootparam_prot.x
/usr/include/rpcsvc/sm_inter.x
/usr/include/rpcsvc/klm_prot.x
...
```

### 结构体

```
program YPPASSWDPROG {
        version YPPASSWDVERS {
                /*
                 * Update my passwd entry
                 */
                int
                YPPASSWDPROC_UPDATE(yppasswd) = 1;
        } = 1;
} = 100009;


struct passwd {
        string pw_name<>;       /* username */
        string pw_passwd<>;     /* encrypted password */
        int pw_uid;             /* user id */
        int pw_gid;             /* group id */
        string pw_gecos<>;      /* in real life name */
        string pw_dir<>;        /* home directory */
        string pw_shell<>;      /* default shell */
};

struct yppasswd {
        string oldpass<>;       /* unencrypted old password */
        passwd newpw;           /* new passwd entry */
};
```
> https://unix.stackexchange.com/questions/344015/what-are-the-x-files-in-usr-include

### 函数指针




## 參考

- [Remote Procedure Calls](https://www.linuxjournal.com/article/2204)
- [C/C++ RPC Tutorial for Linux [closed]](https://stackoverflow.com/questions/2526227/c-c-rpc-tutorial-for-linux)
- [Linux下C语言RPC（远程过程调用）编程实例](https://blog.csdn.net/iw1210/article/details/41051779)
- [rpcgen Programming Guide](https://docs.freebsd.org/44doc/psd/22.rpcgen/paper.pdf)
- [Writing Remote Procedural Calls (RPCs) in C](https://www.cprogramming.com/tutorial/rpc/remote_procedure_call_start.html)
- [Passing character pointers from client to server in RPCGen](https://stackoverflow.com/questions/28822436/passing-character-pointers-from-client-to-server-in-rpcgen)
- [Writing RPC Applications with the rpcgen Protocol Compiler](http://neo.dmcs.pl/rso/du/onc-rpc3.html)
