---
title: USB HID Report描述符
date: 2018-05-15 23:07:24
categories: 设备驱动
tags: [HID, 驱动]
---


在USB的枚举后，即交互完 设备描述符(device descriptor),配置描述符(configure descriptor),接口描述符(interface descriptor)和终端描述符(endpointer desciptor)。如果是HID设备，即class值为3设备交互还会发送一系统的特殊包来描述HID设备的特性。

这一些描述HID的特性称为Report Descriptor,报告描述符，可以理解它们是HID设备的上传的包，或者接收的包的格式。`设备能包含多个report`(测试出错)

主要参考官网文档：[HID Information](http://www.usb.org/developers/hidpage#Class_Definitions)

<!--more-->

对于每种HID动作的编码，HID有一个专用术语usage (用法），USB协议中支持所有编码表称为usage tables.这里有全部编码表[HID Usage Tables 1.12](http://www.usb.org/developers/hidpage/Hut1_12v2.pdf)

## Report Descriptor

在usb.org网站有HID decriptor tools工具下载 可以用创建和解析report descriptor包格式
[http://www.usb.org/developers/hidpage/dt2_4.zip](http://www.usb.org/developers/hidpage/dt2_4.zip)

>一个完整的report 分为二部分，一部分定长的头，另一部分就是变长的定义, 每个collection由若干个usage组成. 在Collection中，每一个组成部分以称为item,item就是usage.
`A1 01` 与 `C0`之间表示`Application Collection`的.


| usage 	|  说明		   |
| :---: 	| :------------: |
| input 	| 输入数据格式	|
| output	| 输出数据格式	|
| Logical Minimum | 取值范围	|
| logical_maximum |		|
| physical_minimum|		|
| physical_maximum|		|
| report size | report输入字节宽度	|
| report count | report总数	|


## 获取描述符

* 工具： `USBlyzer` （Bus Hound同样也可以抓取，但是需要自己解析）

## 实例分析（鼠标）

## 相关文件

* [Universal Serial Bus HID Usage Tables](http://www.usb.org/developers/hidpage/Hut1_12v2.pdf)
* [USB HID to PS2 Scan Code Translation Table.pdf](http://d1.amobbs.com/bbs_upload782111/files_41/ourdev_651088NZ5EKW.pdf)


## 总结

在设备识别阶段多使用`bus hound`抓取数据包进行分析，在开发板作device时，host可能会获取部分数据（比如触摸屏，需要得到支持几点的触摸操作，默认单点），此时可能会获取失败。


## 参考

* [Linux HID 驱动开发(2) USB HID Report 描述及usage 概念](http://blog.chinaunix.net/xmlrpc.php?r=blog/article&uid=20587912&id=2984380)
* [USB HID报告及报告描述符简介](https://my.oschina.net/xuwa/blog/2062)
* [浅析linux下usb鼠标和usb键盘usbhid驱动hid_parse_report报告描述符](http://blog.chinaunix.net/uid-23159239-id-2535119.html)
