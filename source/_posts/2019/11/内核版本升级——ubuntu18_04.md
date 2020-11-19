---
layout: post
title: 内核版本升级——ubuntu18.04
date: '2019-11-23 12:01'
tags:
  - 内核
categories:
  - linux内核
abbrlink: 15332
---

linux内核升级笔记：

<!--more-->

## 内核升级

- HWE
> https://www.sysgeek.cn/ubuntu-1804-install-linux-kernel-50/

Ubuntu 18.04.2 版本包含一个新的「硬件启用堆栈」，即 HWE，该堆栈由较新的Linux Kernel、X.org 图形服务器和图形驱动程序等组成。然而毕竟 LTS 长期支持版本主打的是稳定性，用户不一定希望经常有新内核更新，所以 HWE 不会自动安装到现有系统上，以确保不会破坏任何内容。

``` shell
sudo apt install --install-recommends linux-generic-hwe-18.04 xserver-xorg-hwe-18.04
```

- 手动升级

> https://kernel.ubuntu.com/~kernel-ppa/mainline/

升级脚本：https://raw.githubusercontent.com/Winddoing/work_env/master/tools/auto-install/upgrade_latest_kernel.sh


- ubuntu HWE 支持

>1. 获取5.3.0内核版本 sudo apt list | grep linux-generic*
>2. 能够获取到5.3.0版本之后直接安装 sudo apt install linux-generic-hwe-18.04-edge

``` shell
$sudo apt list | grep linux-generic*

WARNING: apt does not have a stable CLI interface. Use with caution in scripts.

linux-generic/bionic-updates,bionic-security,now 4.15.0.70.72 amd64 [installed]
linux-generic-hwe-16.04/bionic-updates,bionic-security 4.15.0.70.72 amd64
linux-generic-hwe-16.04-edge/bionic-updates,bionic-security 4.15.0.70.72 amd64
linux-generic-hwe-18.04/bionic-updates,bionic-security 5.0.0.36.94 amd64
linux-generic-hwe-18.04-edge/bionic-updates,bionic-security,now 5.3.0.23.90 amd64 [installed]

sudo apt install linux-generic-hwe-18.04-edge
```

更新grub启动配置文件：`/boot/grub/grub.cfg`
```
sudo update-grub
```
> 如果系统没有该命令通过`sudo apt install grub-efi-amd64 grub-efi-amd64-bin`安装

- 下载当前内核源码

``` shell
sudo apt-get source linux-image-$(uname -r)
```

## 启动模式

- 文本模式
``` shell
systemctl set-default multi-user.target
```

- 图形模式
``` shell
systemctl set-default graphical.target
```

## 源码编译升级

> 系统：ubuntu18.04

- 依赖软件
``` shell
sudo apt install libssl-dev
```

- 编译升级
``` shell
cp -v /boot/config-$(uname -r) .config
sh -c 'yes "" | make oldconfig'
make -j4
sudo make modules_install
sudo make install
reboot
```
> 重启时选择最新安装内核启动，通过`uname -a`确定内核升级是否成功

## 列出系统中的所有已安装内核

``` shell
sudo dpkg --get-selections|grep linux
sudo dpkg --list | grep linux-image
sudo dpkg --list | grep linux-headers
```

## 删除不要的内核镜像

``` shell
sudo apt-get purge linux-headers-3.13.0-24-generic
sudo apt-get purge linux-image-3.13.0-24-generic
```
