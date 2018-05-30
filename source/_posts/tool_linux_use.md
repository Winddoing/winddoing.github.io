---
title: Linux下常用工具
date: 2018-05-13 23:37:24
categories: 常用工具
tags: [工具]
---

Linux下常用工具：

<!--more-->

## wps

[http://community.wps.cn/download/](http://community.wps.cn/download/)

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

[https://pan.baidu.com/s/1eS6xIzo](https://pan.baidu.com/s/1eS6xIzo)

wps_symbol_fonts.zip

```
unzip wps_symbol_fonts.zip 
sudo cp mtextra.ttf  symbol.ttf  WEBDINGS.TTF  wingding.ttf  WINGDNG2.ttf  WINGDNG3.ttf  /usr/share/fonts
```

## 福昕阅读

[https://www.foxitsoftware.cn/downloads/](https://www.foxitsoftware.cn/downloads/)

## 搜狗输入法

[https://pinyin.sogou.com/linux/?r=pinyin](https://pinyin.sogou.com/linux/?r=pinyin)

## 微信

## 钉钉 for Linux

* [钉钉Linux版](https://club.doui.cc/t/view/15c8b0ea25957196a9156b2d.html)

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
