---
title: Linux下常用工具
date: 2018-05-13 23:37:24
categories: 工具
tags: [Linux]
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

## 福昕阅读

- [https://www.foxitsoftware.cn/downloads/](https://www.foxitsoftware.cn/downloads/)

## 搜狗输入法

- [https://pinyin.sogou.com/linux/?r=pinyin](https://pinyin.sogou.com/linux/?r=pinyin)

## 微信

- https://github.com/geeeeeeeeek/electronic-wechat/releases/download/V2.0/linux-x64.tar.gz

## 钉钉 for Linux

* [https://github.com/nashaofu/dingtalk](https://github.com/nashaofu/dingtalk)

## Teamviewer

* [下载](https://www.teamviewer.com/zhcn/download/linux/)
* 安装：
```
sudo dpkg -i teamviewer_13.1.3026_amd64.deb
sudo apt-get remove teamviewer
```
如果安装失败，可以更新ubuntu的源，参考：[Ubuntu 16.04 安装 TeamViewer 13](https://blog.csdn.net/u011292539/article/details/79249027/)


## 主题

```
sudo apt install gnome-tweak-tool
```

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


### 中文输入法

1. 修改/usr/share/applications/dia.desktop文件
> 把`Exec=dia %F`改成`Exec=env GTK_IM_MODULE=xim dia %F`


2. 在终端启动时增加启动设置
> 设置别名alias，执行命令`alias dia="env GTK_IM_MODULE=xim dia"`

3. 文字输入框右键
> 选择输入文字模式—>在文字输入框右键—>输入法(Input Methods)—>X输入法



## 实时显示上下行网速、CPU及内存使用率

```
sudo add-apt-repository ppa:fossfreedom/indicator-sysmonitor
sudo apt-get install indicator-sysmonitor
```

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

## Motirx

[Motirx](https://github.com/agalwood/Motrix)是一款全能的下载工具，支持下载 HTTP、FTP、BT、磁力链、百度网盘（百度云）等资源

- 官网： [https://motrix.app](https://motrix.app)


## Deepin-Wine

> 安装deepin_QQ、deepin_微信、deepin_迅雷和deepin_百度网盘

- https://github.com/wszqkzqk/deepin-wine-ubuntu

## VS Code


## franz

>即时通讯聚合一一Franz：微信、钉钉、QQ

- https://meetfranz.com/#download

## Nitroshare

> 跨平台局域网传输软件

- https://nitroshare.net/
