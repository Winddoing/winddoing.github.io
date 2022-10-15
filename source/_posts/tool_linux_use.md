---
title: Linux下常用工具
categories:
  - 工具
  - linux
tags:
  - linux
abbrlink: 36295
date: 2018-05-13 23:37:24
---

Linux下常用工具：

<!--more-->

## Zeal

各种语言的离线开发文档

https://zealdocs.org/

``` shell
sudo apt install zeal
```

## yuv rgba player

- https://github.com/IENT/YUView

> ubuntu 18.04

## wps

- [http://community.wps.cn/download/](http://community.wps.cn/download/)

字体：[http://wps-community.org/download.html?vl=fonts#download](http://wps-community.org/download.html?vl=fonts#download)

``` shell
sudo dpkg -i wps-office_10.1.0.5672~a21_amd64.deb
sudo apt -f install
```

>wps-office 依赖于 libpng12-0；然而：未安装软件包 libpng12-0。

``` shell
wget http://ftp.cn.debian.org/debian/pool/main/libp/libpng/libpng12-0_1.2.49-1+deb7u2_amd64.deb

sudo dpkg -i libpng12-0_1.2.49-1+deb7u2_amd64.deb

sudo dpkg -i wps-office_10.1.0.5672~a21_amd64.deb

sudo dpkg -i wps-office-fonts_1.0_all.deb
```

### 缺失字体

- [https://pan.baidu.com/s/1eS6xIzo](https://pan.baidu.com/s/1eS6xIzo)

wps_symbol_fonts.zip

``` shell
unzip wps_symbol_fonts.zip
sudo cp mtextra.ttf  symbol.ttf  WEBDINGS.TTF  wingding.ttf  WINGDNG2.ttf  WINGDNG3.ttf  /usr/share/fonts
```

## 主题

``` shell
sudo apt install gnome-tweak-tool
```

### 插件

- `dash-to-panel`： 任务栏合并，类似window
- `workspace-grid`： 多工作区


## 下载器

### Free Download Manager

可以快速下载，相同的下载链接比浏览器下载速度快。

> https://www.freedownloadmanager.org/zh/


## 画图

``` shell
sudo apt-get install  kolourpaint4
```

## 虚拟机 —— VirtualBox

``` shell
sudo apt install virturlbox virtualbox-ext-pack
```

### 无缝模式

快捷键： `Host + l`


### 虚拟机启动时异常终止

版本：6.1

virtualbox升级后造成的现象，错误码：NS_ERROR_FAILURE (0x80004005)

解决方法：

关闭`USB控制器`或将其切换到USB1.1上，虚拟机就可以正常启动。

根本原因是virtualbox升级后Extension Pack没有跟着升级所致。

重新执行以下命令即可：
```
sudo apt update
sudo apt install virtualbox virtualbox-ext-pack
```

### ubuntu虚拟机中访问共享文件夹，无权限

解决权限不足问题的方法就是将自己登录的用户，添加到vboxsf组中

```
sudo usermod -aG vboxsf $(whoami)
sudo reboot
```
> 说明：`usermod -aG <group> <user>`将用户加入到（追加到）组中，其中选项[-aG]是追加到组的意思


## 音视频文件分析工具 -- MediaInfo

``` shell
sudo apt-get install mediainfo mediainfo-gui
```

## 词典

- [翻译工具 ——GoldenDict](https://winddoing.github.io/post/eba28245.html)


## 画图--结构图流程图

- **draw.io**: [draw.io](https://www.draw.io/) —— 在线开源免费的画流程图，思维导图，界面设计等

  - 桌面版： https://github.com/jgraph/drawio-desktop


## ASCII流程图

官网：https://asciiflow.com
Github：https://github.com/lewish/asciiflow

默认官网可以使用但是无法输入中文，因此可以使用下面这个链接

- https://asciiflow.cn


## 思维导图 —— XMind

- https://www.xmind.cn/ 【[下载](https://www.xmind.cn/download/)】


## vooya

vooya – Raw YUV/RGB Video Player

- [http://www.offminor.de/downloads.html](http://www.offminor.de/downloads.html)


## gedit汉字乱码

``` shell
gsettings set org.gnome.gedit.preferences.encodings candidate-encodings "['GB18030', 'GB2312', 'GBK', 'UTF-8', 'BIG5', 'CURRENT', 'UTF-16']"
```
> ubntu 18.04

## 数据库:sqlitebrowser

- 官网地址：[http://sqlitebrowser.org/](http://sqlitebrowser.org/)
- 开源地址：[https://github.com/sqlitebrowser/sqlitebrowser](https://github.com/sqlitebrowser/sqlitebrowser)

DB Browser for SQLite (DB4S) 是一款面向开发者的高质量的，可视化的开源的工具，他可以创建，设计，以及修改SQlite数据库。

``` shell
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

## remmina

可以管理常用的SSH登录和远程桌面。

- 支持 RDP、VNC、NX、XDMCP 和 SSH

``` shell
sudo apt install remmina
```

## ubuntu工作区配置

### Alt+Tab不跨工作区

``` shell
gsettings set org.gnome.shell.app-switcher current-workspace-only true
```

### Ubuntu Dock不跨工作区

``` shell
gsettings set org.gnome.shell.extensions.dash-to-dock isolate-workspaces true
```
> https://askubuntu.com/questions/992558/how-can-i-configure-the-ubuntu-dock-to-show-windows-only-from-the-current-worksp


## Ubuntu文件夹中文改为英文

在系统选择中文后，Home目录下的默认文件夹名也为中文，在终端中使用很不方便，因此将其设置为英文。

``` shell
export LANG=en_US
xdg-user-dirs-gtk-update
```
