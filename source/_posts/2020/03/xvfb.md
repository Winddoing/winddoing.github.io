---
layout: post
title: Xvfb —— 虚拟X server
date: '2020-03-13 11:23'
tags:
  - xvfb
  - x11
categories:
  - 软件测试
---

> Xvfb − virtual framebuffer X server for X Version 11


`Xvfb`是一个X server，主要用于在没有显示设备的主机上，进行拥有图形界面程序的运行。比如自动化测试

> Xvfb is an X server that can run on machines with no display hardware and no physical input devices. It emulates a dumb framebuffer using virtual memory.

<!--more-->

## 安装

``` shell
sudo apt install xvfb
```

## 启动

``` shell
Xvfb -ac :3 -screen 0 1280x1024x24 > /dev/null 2>&1
export DISPLAY=:3
```

## VNC测试


``` shell
x11vnc -display :3 -N -forever -shared -reopen -passwd 123456 -desktop 1 -bg -q
```
输出：
```
The VNC desktop is:      xxx-pc:3
PORT=5903
```

由于是本地测试，通过`remmina`登录VNC`127.0.0.1:5903`，将获取到`DISPLAY=:3`窗口的所有屏幕输出。比如此时在终端执行glxgears，将在vnc远端获取到图像。


测试脚本：

``` shell
#!/bin/bash

killall x11vnc
killall glxgears

Xvfb -ac :3 -screen 0 1280x1024x24 > /dev/null 2>&1
export DISPLAY=:3

x11vnc -display :3 -N -forever -shared -reopen -passwd 123456 -desktop 1 -bg -q
echo "Password: 123456"

glxgears &
```

VNC登录：
``` shell
vncviewer 127.0.0.1:5903
```
