---
layout: post
title: HDMI/DVI接口显示器热插拔原理（HPD）
date: '2019-03-19 16:16'
tags:
  - hdmi
categories:
  - 多媒体
abbrlink: 57591
---

![hdmi_cable_link](/images/2019/03/hdmi_cable_link.png)

> 硬件接口， `HDMI(19Pin)/DVI（16 pin）`的功能是热插拔检测`（HPD）`，这个信号将作为主机系统是否对HDMI/DVI是否发送`TMDS`信号的依据

<!--more-->
![hdmi_and_vdi_interface](/images/2019/03/hdmi_and_vdi_interface.png)


## HPD - (Hot Plug Detection)

HPD是从`显示器`输出送往`计算机主机`的一个检测信号.

作用：
> 当显示器等数字显示器通过HDMI或DVI接口与计算机主机相连或断开连接时，计算机主机能够通过HDMI/DVI的HPD引脚检测出这一事件，并做出响应


## 热插拔时的信号变化

- HDMI/DVI接口插入
  - HPD: `low --> high`

> 主机上的显卡检测到HPD引脚被拉高（电压大于2V），主机认为此时显示设备已连接成功。主机中的显卡将发生一个信号，通过DDC读取显示器中的存储的EDID数据，通过读取到的EDID中显示器的工作模式范围与显卡相适应，则显卡将激活TMDS信号进行数据传输。

- HDMI/DVI接口拔出
  - HPD: `high --> low`

> 主机上的显卡检测到HPD引脚被拉低（电压小于0.8V），表示显示设备与主机断开连接。此时主机中的显卡也会发一个信号，通知显卡关闭TMDS信号的工作。


## 参考

* [HDMI Demystified](https://www.fpga4fun.com/files/HDMI_Demystified_rev_1_02.pdf)
