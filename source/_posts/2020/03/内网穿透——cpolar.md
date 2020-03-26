---
layout: post
title: 内网穿透——cpolar
date: '2020-03-05 11:12'
tags:
  - cpolar
  - 网络
categories:
  - 工具
abbrlink: 28389
---

`cpolar`工具从家庭或本地网络外部访问内网设备，比如树莓派、群晖等。

<!--more-->


## cpolar

cpolar是一种安全的隧道服务，可以在任何地方在线提供您的设备。 隧道是一种在两台计算机之间通过互联网等公共网络建立专线的方法。 当您在两台计算机之间设置隧道时，它应该是安全且私有的，并且能够通过网络障碍，如端口阻塞路由器和防火墙。 这是一个方便的服务，允许您在安全的无线网络或防火墙后面将请求从公共互联网连接到本地计算机。

## 安装

``` shell
wget https://www.cpolar.com/static/downloads/cpolar-stable-linux-amd64.zip

unzip cpolar-stable-linux-amd64.zip
```

## 注册

在[cpolar官网](https://dashboard.cpolar.com)注册账户，以获取authtoken密钥。使用免费版本，您每次希望建立远程连接并与远程用户共享地址时，都必须从本地生成主机地址。


- 本地添加token认证

``` shell
./cpolar authtoken  <yourauthtoken>
```
> 执行一次认证，它就会存储在配置文件中`/home/user/.cpolar/cpolar.yml`


## SSH穿透

``` shell
./cpolar tcp 22
```

```
cpolar by @bestexpresser                                                          

Tunnel Status                 online                                              
Account                       xxx (Plan: Free)                              
Version                       2.62/2.58                                           
Web Interface                 127.0.0.1:4040                                      
Forwarding                    tcp://1.tcp.cpolar.io:1111 -> tcp://127.0.0.1:22   
# Conn                        0                                                   
Avg Conn Time                 0.00ms                                              
```

### 远程连接访问

``` shell
ssh -p <cpolar公网端口号>  <用户名@1.tcp.cpolar.io>
```

``` shell
ssh -p 1111 username@1.tcp.cpolar.io
```
