---
title: Linux下常用工具
categories: 工具
tags:
  - Linux
abbrlink: 36295
date: 2018-05-13 23:37:24
---

Linux下常用工具：

<!--more-->

> ubuntu 18.04

## wps

- [http://community.wps.cn/download/](http://community.wps.cn/download/)

字体：[http://wps-community.org/download.html?vl=fonts#download](http://wps-community.org/download.html?vl=fonts#download)

```
sudo dpkg -i wps-office_10.1.0.5672~a21_amd64.deb
sudo apt -f install
```

>wps-office 依赖于 libpng12-0；然而：未安装软件包 libpng12-0。

```
wget http://ftp.cn.debian.org/debian/pool/main/libp/libpng/libpng12-0_1.2.49-1+deb7u2_amd64.deb

sudo dpkg -i libpng12-0_1.2.49-1+deb7u2_amd64.deb

sudo dpkg -i wps-office_10.1.0.5672~a21_amd64.deb

sudo dpkg -i wps-office-fonts_1.0_all.deb
```

### 缺失字体

- [https://pan.baidu.com/s/1eS6xIzo](https://pan.baidu.com/s/1eS6xIzo)

wps_symbol_fonts.zip

```
unzip wps_symbol_fonts.zip
sudo cp mtextra.ttf  symbol.ttf  WEBDINGS.TTF  wingding.ttf  WINGDNG2.ttf  WINGDNG3.ttf  /usr/share/fonts
```

## Teamviewer

* [下载](https://www.teamviewer.com/zhcn/download/linux/)
* 安装：
```
sudo dpkg -i teamviewer_13.1.3026_amd64.deb
sudo apt-get remove teamviewer
```
如果安装失败，可以更新ubuntu的源，参考：[Ubuntu 16.04 安装 TeamViewer 13](https://blog.csdn.net/u011292539/article/details/79249027/)

### 设置开机自启

``` shell
sudo systemctl enable teamviewerd.service
```

### ubuntu18.04系统重启后，TeamViewer无法连接


修改`/etc/gdm3/custom.conf`文件：

将如下行取消注释
```
WaylandEnable=false
```
> 使通过TeamViewer进行的远程桌面会话请求由GNOME桌面的xorg处理，来代替Wayland显示管理器。

- https://community.teamviewer.com/t5/Linux/Teamviewer-13-not-connecting-in-Ubuntu-18-04-Login-Screen/td-p/35342

## 主题

```
sudo apt install gnome-tweak-tool
```

### 插件

- `dash-to-panel`： 任务栏合并，类似window
- `workspace-grid`： 多工作区

## 邮件

Evolution

## 画图

```
sudo apt-get install  kolourpaint4
```

## 虚拟机

VirtualBox

## 音视频文件分析工具 -- MediaInfo

```
sudo apt-get install mediainfo mediainfo-gui
```

## 词典

stardict(星际译王)

```
sudo apt install stardict
```

词典的词库网站下载词库：[下载](http://download.huzheng.org/)

- [linux下StarDict和词典的安装](https://blog.csdn.net/suyingshipp/article/details/7736297)

### 有道词典---命令行

- https://github.com/TimothyYe/ydict

```
ydict
```


## 画图--结构图流程图

1. ~~亿图：[http://www.edrawsoft.cn/download-edrawmax.php](http://www.edrawsoft.cn/download-edrawmax.php) —— 收费~~

2. **draw.io**: [draw.io](https://www.draw.io/) —— 在线开源免费的画流程图，思维导图，界面设计等

  - 桌面版： https://github.com/jgraph/drawio-desktop
3. dia 流程图
```
sudo apt install dia
```

## vooya

vooya – Raw YUV/RGB Video Player

- [http://www.offminor.de/downloads.html](http://www.offminor.de/downloads.html)


## gedit汉字乱码

```
gsettings set org.gnome.gedit.preferences.encodings candidate-encodings "['GB18030', 'GB2312', 'GBK', 'UTF-8', 'BIG5', 'CURRENT', 'UTF-16']"
```
> ubntu 18.04

## Albert

全局搜索软件

## 数据库:sqlitebrowser

- 官网地址：[http://sqlitebrowser.org/](http://sqlitebrowser.org/)
- 开源地址：[https://github.com/sqlitebrowser/sqlitebrowser](https://github.com/sqlitebrowser/sqlitebrowser)

DB Browser for SQLite (DB4S) 是一款面向开发者的高质量的，可视化的开源的工具，他可以创建，设计，以及修改SQlite数据库。

```
sudo apt-get install sqlitebrowser
```

## PyCharm

>python编辑器

- [http://www.jetbrains.com/pycharm/](http://www.jetbrains.com/pycharm/)


## 7yuv

查看yuv格式的文件

- 官网：[http://datahammer.de](http://datahammer.de/)


## Nitroshare

> 跨平台局域网传输软件

- https://nitroshare.net/


## Alt+Tab不跨工作区

``` shell
gsettings set org.gnome.shell.app-switcher current-workspace-only true
```
