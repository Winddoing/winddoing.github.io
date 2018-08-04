---
title: Windows常用工具
date: 2018-05-13 23:07:24
categories: 工具
tags: [windows]
---


Windows下的常用工具，提高使用效率

简单记录，方便以后重装系统后安装使用。

<!--more-->

## 快速搜素--Listary

官网：[http://www.listary.com/](http://www.listary.com/)
下载：[here](http://www.listary.com/download/Listary.exe?version=5.00.2843)

### 使用：

快速启动： `Ctrl+Ctrl`

## 读取Ext4分区--ext2explore

在Windows和Linux的双系统中，方便在Windows系统下获取Linux中的数据。

* [`ext2explore`](https://netix.dl.sourceforge.net/project/ext2read/Ext2read%20Version%202.2%20%28Latest%29/ext2explore-2.2.71.zip)只能读取文件，无法写入，使用时需要管理员权限运行。（Window10可以使用）
* [`Ext2fsd`](https://excellmedia.dl.sourceforge.net/project/ext2fsd/Ext2fsd/0.69/Ext2Fsd-0.69.exe)据说最好用(Windows10无法使用)
* [Paragon ExtFS for Windows](https://www.paragon-software.com/home/linuxfs-windows/)需要注册对个人免费。

使用：[在 Windows 下访问 Ext 分区](https://roov.org/2014/06/windows-ext/)

## 系统镜像下载

网站：[https://msdn.itellyou.cn/](https://msdn.itellyou.cn/)

## Windows 10 下清理 WinSxS

图形界面操作[http://www.chuyu.me/zh-Hans/index.html](http://www.chuyu.me/zh-Hans/index.html)

```
Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase
```
## 磁盘文件目录大小可视化布局

[SpaceSniffer](http://www.uderzo.it/main_products/space_sniffer/)
> SpaceSniffer_1.1.4.0.1399531007

## 同步软件--FreeFileSync

[FreeFileSync](https://freefilesync.org/download.php)
> 硬盘和U盘的同步

## esEye -- Elecard StreamEye Tools

esEye 分析264的码流结构

## edid_manager

[edid_managerv1x0](https://pan.baidu.com/s/1BPgXadM9Mnwwio1PU4jiPQ)
> EDID查询
