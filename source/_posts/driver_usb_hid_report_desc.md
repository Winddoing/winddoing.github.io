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
| logical_maximum |	取值范围	|
| physical_minimum|	取值范围	|
| physical_maximum|	取值范围	|
| report size | report输入字节宽度	|
| report count | report总数	|


## 获取描述符

* 工具： `USBlyzer` （Bus Hound同样也可以抓取，但是需要自己解析）

## 实例分析（鼠标）

```
HID Descriptor
Offset Field Size Value Description
0 bLength 1 09h  
1 bDescriptorType 1 21h HID
2 bcdHID 2 0111h 1.11
4 bCountryCode 1 00h  
5 bNumDescriptors 1 01h  
6 bDescriptorType 1 22h Report
7 wDescriptorLength 2 002Eh 46 bytes  <-------描述符大小

Endpoint Descriptor 81 1 In, Interrupt, 10 ms
Offset Field Size Value Description
0 bLength 1 07h  
1 bDescriptorType 1 05h Endpoint
2 bEndpointAddress 1 81h 1 In
3 bmAttributes 1 03h Interrupt
 1..0: Transfer Type  ......11  Interrupt
 7..2: Reserved  000000..   
4 wMaxPacketSize 2 0004h 4 bytes  <-----------包数据宽度
6 bInterval 1 0Ah 10 ms

Interface 0 HID Report Descriptor Mouse
Item Tag (Value) Raw Data
Usage Page (Generic Desktop) 05 01  
Usage (Mouse) 09 02  
Collection (Application) A1 01  
    Usage (Pointer) 09 01  
    Collection (Physical) A1 00  
        Usage Page (Button) 05 09  
        Usage Minimum (Button 1) 19 01  
        Usage Maximum (Button 3) 29 03  
        Logical Minimum (0) 15 00  
        Logical Maximum (1) 25 01  
        Report Count (8) 95 08  
        Report Size (1) 75 01  
        Input (Data,Var,Abs,NWrp,Lin,Pref,NNul,Bit) 81 02

        Usage Page (Generic Desktop) 05 01  
        Usage (X) 09 30  
        Usage (Y) 09 31  
        Usage (Wheel) 09 38  
        Logical Minimum (-127) 15 81  
        Logical Maximum (127) 25 7F  
        Report Size (8) 75 08  
        Report Count (3) 95 03  
        Input (Data,Var,Rel,NWrp,Lin,Pref,NNul,Bit) 81 06  
    End Collection C0  
End Collection C0  
```

### 获取数据格式--Input

从Report描述符可以获取信息，鼠标输入的数据可以分两部分：

| 序号 | 设备类型 | 格式 | 宽度 | 大小 | 取值范围 |
| :-:| :---:| :--:| :--: | :--: | :-------:|
| 1 | Usage Page (Button) | Input (Data,Var,Abs,NWrp,Lin,Pref,NNul,Bit) | Report Size (1) | Report Count (8) | Logical Minimum (0) ~ Logical Maximum (1) |
| 2 | Usage Page (Generic Desktop) |Input (Data,Var,Rel,NWrp,Lin,Pref,NNul,Bit) | Report Size (8) | Report Count (3) | Logical Minimum (-127) ~ Logical Maximum (127) |

数据格式：
```
+---------------+---------------+--------------------------------+
| Usage (Wheel) |   Usage (Y)   |   Usage (X)   |7|6|5|4|3|2|1||0|
+---------------+---------------+--------------------------+-+--++
                                                           | |  v
                                                           | v  Usage Page (Button)
                                                           v Usage Minimum (Button 1)
                                                           Usage Maximum (Button 3)

```
* 第一部分：一个字节（Byte），其中每个bit代表一种含义, `Usage Page (Button)`,`Usage Minimum (Button 1)`,`Usage Maximum (Button 3) `
* 第二部分：三个字节（Byte），其中一个字节代表一种含义，`Usage (X)`,`Usage (Y)`,`Usage (Wheel)`



## 相关文件

* [Device Class Definition for HID 1.11](http://www.usb.org/developers/hidpage/HID1_11.pdf)
* [HID Usage Tables 1.12](http://www.usb.org/developers/hidpage/Hut1_12v2.pdf)
* [USB HID to PS2 Scan Code Translation Table.pdf](http://d1.amobbs.com/bbs_upload782111/files_41/ourdev_651088NZ5EKW.pdf)
* [USB HID usage table](http://www.freebsddiary.org/APC/usb_hid_usages.php)


## 总结

在设备识别阶段多使用`bus hound`抓取数据包进行分析，在开发板作device时，host可能会获取部分数据（比如触摸屏，需要得到支持几点的触摸操作，默认单点），此时可能会获取失败。


## 参考

* [Linux HID 驱动开发(2) USB HID Report 描述及usage 概念](http://blog.chinaunix.net/xmlrpc.php?r=blog/article&uid=20587912&id=2984380)
* [USB HID报告及报告描述符简介](https://my.oschina.net/xuwa/blog/2062)
* [浅析linux下usb鼠标和usb键盘usbhid驱动hid_parse_report报告描述符](http://blog.chinaunix.net/uid-23159239-id-2535119.html)