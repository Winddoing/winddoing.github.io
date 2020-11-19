---
date: '2015-04-17 03:49'
layout: post
title: 移植mjpg-streamer
thread: 166
categories: 嵌入式
tags:
  - arm
  - mjpg-streamer
abbrlink: 50611
---

Mjpg‐streamer是一个开源软件，用于从webcam摄像头采集图像，把它们以流的形式通过基于ip的网络传输到浏览器如Firefox，Cambozola，VLC播放器，Windows的移动设备或者其他拥有浏览器的移动设备

移植Mjpg-streamer需要libjpeg库，因此要先移植libjpeg
<!---more--->
### 1.移植jpeg
#### a. 从http:<//www.ijg.org/files/>下载jpeg源码包；
#### b. 解压，进入其目录
        tar zxvf jpegsrc.v9a.tar.gz
        cd  /work/embedded/video/jpeg-9a
#### c. 配置源码，（具体配置项可以运行命令./configure --help看看是什么意思，根据实际情况修改）
        #./configure CC=arm-linux-gcc --host=arm-unknown-linux --prefix=/work/embedded/video/jpeg --enable-shared --enable-static
其中/work/embedded/video/jpeg是编译后安装的目录，根据实际情况修改
#### d. 编译：
        #make
#### e. 安装：
        #make install
#### f. 拷贝库文件到开发板文件系统
将/work/embedded/video/jpeg-9a/jpeg
目录下全部文件拷贝到开发板文件系统/work/embedded/rootfs/usr/local/mjpg-streamer下(此目录为mjpg-streamer在开发板的安装目录，当然你也可以把它放在开发板的/lib/目录下）

        cp lib/* /work/embedded/rootfs/lib/

### 2. 移植mjpg-streamer
#### a. 下载源码，在https://sourceforge.net/projects/mjpg-streamer/下载的源码
        #tar zxvf mjpg-streamer-r63.tar.gz
#### b. 修改plugins/input_uvc/Makfile
        CFLAGS = -O2 -DLINUX -D_GNU_SOURCE -Wall -shared -fPIC
为（即添加头文件-I）

        CFLAGS += -O2 -DLINUX -D_GNU_SOURCE -Wall -shared -fPIC -I/work/embedded/v    ideo/jpeg-9a/jpeg/include

修改

        $(CC) $(CFLAGS) -ljpeg -o $@ input_uvc.c v4l2uvc.lo jpeg_utils.lo dynctrl.lo
为(即添加库文件-L)

         $(CC) $(CFLAGS) -ljpeg -L/work/embedded/video/jpeg-9a/jpeg/lib  -o $@     input_uvc.c v4l2uvc.lo jpeg_utils.lo dynctrl.lo

#### c. 编译
        #make CC=arm-linux-gcc
#### d. 建立mjpg-streamer安装目录
        mkdir /work/embedded/rootfs/usr/local/mjpg-streamer
        cp *.so /work/embedded/rootfs/usr/local/mjpg-streamer
        cp mjpg-stream /work/embedded/rootfs/usr/local/mjpg-streamer
将源码目录中的start.sh到/work/embedded/rootfs/mjpg-streamer目录下，www目录下的所有文件拷贝到/work/embedded/rootfs/www下，然后就可以测试啦
#### e. 在开发板中运行./start.sh
修改start.sh脚本文件

        ./mjpg_streamer -o "output_http.so -w ./www"
具体的修改方法可以根据start.sh文件中的注释或查看mjpg-streamer的帮助

        ./mjpg_streamer --help

参考文章：
><http://www.linuxidc.com/Linux/2012-02/54797p4.htm>
><http://blog.chinaunix.net/uid-27070031-id-3458957.html>
