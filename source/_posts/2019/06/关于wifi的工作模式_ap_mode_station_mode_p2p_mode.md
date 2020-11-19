---
layout: post
title: 关于WIFI的工作模式--AP MODE/STATION MODE/P2P MODE
date: '2019-06-14 14:07'
tags:
  - wifi
categories:
  - 网络
  - wifi
abbrlink: 49326
---

WiFi的共存模式：
- station mode + station mode
- station mode + ap mode
- station mode + p2p mode
- p2p mode + ap mode


<!--more-->


## ap mode

`ap mode`通用应用在无线局域网成员设备（即客户端）的加入，即`网络下行`。它提供以无线方式组建无线局域网WLAN，相当际WLAN的中心设备。

## station mode

`station mode`即工作站模式，可以理解为某个网格中的一个工作站即客户端。那当一个WIFI芯片提供这个功能时，它就可以连到另外的一个网络当中，如家用路由器。通常用于提供网络的数据`上行服务`

## p2p mode

`p2p mode`也为Wi-Fi Direct

Wi-Fi Direct是一种点对点连接技术，它可以在两台station之间直接建立tcp/ip链接，并不需要AP的参与；其中一台station会起到传统意义上的AP的作用，称为`Group Owner(GO)`,另外一台station则称为`Group Client(GC)`，像连接AP一样连接到GO。GO和GC不仅可以是一对一，也可以是一对多；比如，一台GO可以同时连接着多台GC



## 参考

* [WIFI Direct/WIFI P2P](https://blog.csdn.net/wirelessdisplay/article/details/53365377)
