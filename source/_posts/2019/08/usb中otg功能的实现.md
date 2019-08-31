---
layout: "post"
title: "USB中OTG功能的实现"
date: "2019-08-01 14:49"
---

>USB OTG(On-The-Go)标准在完全兼容USB2.0标准的基础上，增添了电源管理（节省功耗）功能，它允许设备既可作为主机，也可作为外设操作（两用OTG）。OTG两用设备完全符合USB2.0标准，并可提供一定的主机检测能力，支持主机通令协议（HNP）和对话请求协议（SRP）。在OTG中，初始主机设备称为A设备，外设称为B设备。可用电缆的连接方式(ID pin)来决定初始角色

<!--more-->

## 硬件接口

![usb_otg_id_pin](/images/2019/08/usb_otg_id_pin.png)


## 数据传输

### 中断传输

> An interrupt transfer is complete when the endpoint does one of the following:
> - Has transferred exactly the amount of data expected
> - Transfers a packet with a payload size less than `wMaxPacketSize` or transfers a zero-length packet

中断传输完成时，端点执行的操作：
- 已传输完成预期的数据量
- 传输的有效数据负载小于wMaxPacketSize大小或者传输0长度的数据包（ZLP）

在HID设置中对report描述符的传输使用中断传输（数据量小），如果wMaxPacketSize的值为64Byte（控制器可配），而此时该设备的report描述符大小也为64Byte，在数据发送完后需要发送一个ZLP，否则host端无法确定数据是否传输完成。


## 参考

- [DesignWare USB 2.0 OTG Controller (DWC_otg) Device Driver Documentation](https://www.cl.cam.ac.uk/~atm26/ephemeral/rpi/dwc_otg/doc/html/main.html)
- [USB OTG插入检测识别](https://www.cnblogs.com/LoongEmbedded/p/5298173.html)
