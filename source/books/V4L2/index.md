---
title: V4L2
date: 2018-07-21 8:07:24
comments: true
---

{% centerquote %} V4L2 {% endcenterquote %}

版本：`linux 4.4.1`


## 目录结构

```
.
├── built-in.o
├── common
├── dvb-core    //DVB 数字视频广播（Digital Video Broadcasting）　　　　　
├── dvb-frontends
├── firewire    
├── i2c         //I2C接口驱动
├── Kconfig
├── Makefile
├── media-device.c
├── media-devnode.c
├── media-entity.c
├── mmc         //SDIO接口
├── pci         //PCI接口
├── platform    //平台控制器相关
├── radio       //
├── rc
├── tuners
├── usb         //USB接口
└── v4l2-core   //核心代码
```
>drivers/media


## 参考平台结构

- 平台： `platform/omap3isp`
- Sensor: `i2c/ov7640`




## 参考

* [V4L2框架概述](https://blog.csdn.net/u013904227/article/details/80718831)
