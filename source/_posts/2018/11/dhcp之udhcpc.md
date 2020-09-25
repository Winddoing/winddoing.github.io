---
layout: post
title: DHCP之udhcpc
date: '2018-11-20 16:05'
tags:
  - DHCP
categories:
  - 网络
  - DHCP
abbrlink: 18609
---

> 动态主机设置协议（英语：Dynamic Host Configuration Protocol，DHCP）是一个局域网的网络协议，使用UDP协议工作，主要有两个用途：
> - 用于内部网或网络服务供应商自动分配IP地址；
> - 给用户用于内部网管理员作为对所有计算机作中央管理的手段。

DHCP从一个IP地址池中提供IP地址，该池有DHCP服务器数据库定义，称为scope。如果客户端接受这一地址，则它可在一个预定义的期限内使用该地址，称为`租约`。如果客户端无法从DHCP服务器获取IP地址，它就无法正常初始化TCP/IP。

**DHCP采用的C/S架构,客户端有`udhcpc`**
<!--more-->

## udhcpc

busybox中提供的简易的`udhcp client`

文档:[http://udhcp.busybox.net/README.udhcpc](http://udhcp.busybox.net/README.udhcpc)

```
udhcpc -b -i eth0 -p /var/run/udhcpc.pid
```
- `-b`:切换到后台指令
- `-i`:指定网络接口
- `-p`:守护进程ID存储在文件中
- `-s`:在DHCP的event中,执行脚本(default:/usr/share/udhcpc/default.script)

## udhcpc执行脚本

```
#!/bin/sh
[ -z "$1" ] && echo "Error: should be called from udhcpc" && exit 1

RESOLV_CONF="/etc/resolv.conf"
[ -n "$broadcast" ] && BROADCAST="broadcast $broadcast"
[ -n "$subnet" ] && NETMASK="netmask $subnet"

case "$1" in
        deconfig)
                /sbin/ifconfig $interface 0.0.0.0
                ;;

        renew|bound)
                /sbin/ifconfig $interface $ip $BROADCAST $NETMASK

                if [ -n "$router" ] ; then
                        echo "deleting routers"
                        while route del default gw 0.0.0.0 dev $interface ; do
                                :
                        done
                        for i in $router ; do
                                route add default gw $i dev $interface
                        done
                fi

                echo -n > $RESOLV_CONF
                [ -n "$domain" ] && echo search $domain >> $RESOLV_CONF
                for i in $dns ; do
                        echo adding dns $i
                        echo nameserver $i >> $RESOLV_CONF
                done
                ;;
esac
exit 0
```

## dhcpcd配置静态IP

配置文件`/etc/dhcpcd.conf`

追加IP配置信息：
```
interface eth0
static ip_address=172.16.xx.xx/24       #配置IP地址
static routers=172.16.xx.xx             #网关
static domain_name_servers=172.16.xx.xx #DNS
```

## 参考

* [网络基本功（三十一）：细说DHCP](https://wizardforcel.gitbooks.io/network-basic/content/30.html)
