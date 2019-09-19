---
layout: post
title: ABRT
date: '2019-09-19 10:45'
tags:
  - dump
categories:
  - 系统服务
---

ABRT (Automated Bug Reporting Tool) Daemon:

>ABRT is an application, included in Fedora Linux Distribution, that is used to report bugs in the software packages whenever crash occurs. Due to this, ABRT also helps in creation of core dump files. Multiple packages may be needed to run various features of ABRT daemon, and their listing is as follows.

在linux调试程序，程序异常宕掉，没有core文件，很难定位问题。但是有了core文件就容易定位多了， 一般是可以通过在环境变量中设置`ulimit -c unlimited`。

但是现场实施人员有时会忘记设置这条命令， 因此可以通过设置linux的`abrt`服务来实现。


<!--more-->

系统：CentOS7


## 配置

> 配置文件： `/etc/abrt/abrt-action-save-package-data.conf`

> 配置文件：`/etc/abrt/abrt.conf`


- 重启服务
```
service abrtd restart
```

- 查看状态
```
service abrtd status
```

```
sysctl -a | grep core_pattern
```

## 操作命令

### 查看文件的包

```
abrt-cli list
```
```
# abrt-cli list
id 3c0df29571be38a595b2034cfa631d3e6b569d34
reason:         Unable to handle kernel NULL pointer dereference at virtual address 00000000
time:           2019年09月11日 星期三 20时26分26秒
uid:            0 (root)
count:          1
Directory:      /var/spool/abrt/vmcore-127.0.0.1-2019-09-05-10:31:32

The Autoreporting feature is disabled. Please consider enabling it by issuing
'abrt-auto-reporting enabled' as a user with root privileges
```

### 删除文件包

```
abrt-cli rm <ccpp folder from list >
```

```
# abrt-cli rm /var/spool/abrt/vmcore-127.0.0.1-2019-09-05-10:31:32
rm '/var/spool/abrt/vmcore-127.0.0.1-2019-09-05-10:31:32'
```

## 参考

- [Chapter 28. Automatic Bug Reporting Tool (ABRT)](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/deployment_guide/ch-abrt)
