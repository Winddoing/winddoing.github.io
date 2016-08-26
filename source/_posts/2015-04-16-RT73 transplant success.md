---
date: 2015-04-16 01:49
layout: post
title: RT73网卡的移植
thread: 164
categories: ARM
tags: [RT73, ARM, 网卡]
---



经过对RT73类网卡驱动源码的几次编译，修改了多出报错信息之后，还是无法完成移植。最终还是用了友善之臂提供的[usb-wifi-kits-for-mini2440-linux-2.6.32.2-20100728.tar.gz](/src/toolchains/usb-wifi-kits-for-mini2440-linux-2.6.32.2-20100728.tar.gz)工具集。

	#tar zxvf usb-wifi-kits-for-mini2440-linux-2.6.32.2-20100728.tar.gz -C /
<!---more--->
根据友善之臂提供的[文档](/src/toolchains/基于mini2440的USB无线网卡使用指南-20100729.pdf)，解压完直接使用scan-wifi、start-wifi等命令就可以使用该无线网卡，可是我使用scan-wifi时搜索不到任何热点。

最后在网上找根据这篇[文章](http://linux.chinaunix.net/techdoc/install/2009/03/26/1105858.shtml),给开发板安装了[iwconfig](/src/toolchains/wireless_tools.29.tar.gz)工具，并重新配置了一下。

	# ifconfig rausb0 inet 192.168.1.77 up
	# route add default gw 192.168.1.1
	# iwconfig rausb0 essid "linuxer"
	# iwconfig rausb0 mode mananed
	# iwconfig rausb0 channel 6

scan-wifi成功

这里做简单的记录为保存这几个工具，以备日后再用
