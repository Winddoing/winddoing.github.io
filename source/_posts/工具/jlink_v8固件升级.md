---
layout: post
title: jlink v8固件升级
date: '2022-04-10 18:19'
tags:
  - jlink
  - 调试
  - firware
categories:
  - 工具
abbrlink: ec73df9d
---

翻出以前在学校用过几次的jlink，想看看还能不能用，插电脑上可以正常识别，安装完驱动打算试试时提示固件升级，没有多想就直接升级了。但是固件升级失败，重新插拔指示灯不亮也无法识别。在网上搜索一番后确定已经变砖块不能用了，如果想让其正常工作必须重新刷固件，在linux下试了一下，无法写入固件，最终只能安装xp虚拟机操作，折腾了一天将固件升级成功。在这里记录一下升级的过程和中间遇到的问题。

<!--more-->

> 丢失固件的表现：Jlink的指示灯不亮
> **在linux下使用Jlink时，遇到提示固件升级的情况，建议不进行升级，因为Linux系统下由于USB相关驱动的问题，可能导致升级失败，原固件丢失变“砖头”**

## 我的Jlink v8

![jlink_v8](/images/2022/04/jlink_v8.jpg)

- 主芯片：`AT91SAM7S64`
- ERASE: 删除旧的固件
- TST: 使其进入可编程模式


## 升级环境

jlink固件升级网上教程很多，也有很多人说自己操作成功的，但是很多都没有说明操作系统环境。我最开始是在win10虚拟机中操作，SAM-BA刷固件时总是无法弹出升级界面，更好多个软件版本和驱动都不行，最后经过网上搜索基本确定是jlink在编程模式下的驱动安装问题。
win10不行就直接安装win xp虚拟机，网上很多人提到xp下升级，包括一些问题上面的截图也是xp风格就选择了xp。在xp下驱动安装也存在问题，没有正确的驱动程序，最后也是试了多个版本后才成功。

操作系统：`Windows XP`
升级所需[软件包](https://github.com/Winddoing/jlink_v8_firware_upgrade)：
```
$tree -L 1
.
├── Install_AT91-ISP_v1.13.exe   #安装出现sam-ba v2.9（固件升级需要）和SAM-PROG v2.4（不需要）两个软件
├── jlink-v8.bin                 #处理好的升级固件，网上找的https://blog.csdn.net/best_xiaolong/article/details/117173826
├── JLink_Windows_V760_i386.exe  #比较新的jlink工具，第一次使用提示升级固件，固件版本Firmware: J-Link ARM V8 compiled Nov 28 2014 13:44:46
├── SAM-BA v2.18 for Windows.exe #安装后只需要安装目录下的驱动，因为sam-ba v2.9的驱动无法使用
├── Setup_JLinkARM_V450l.zip     #jlink工具可以修改SN号，他也会进行固件升级版本在2012
└── 编程模式下驱动来自SAM-BAv2.18   #SAM-BAv2.18安装后的驱动，在这里备份是为了下次可以直接使用
```

## 固件升级流程

### 使jlink进入编程状态

第一步：
1. 用 USB 线连接 JLink 与 PC，JLink供电
2. 可靠短接，图中“ERASE”处的两个过孔，保持 30 秒
3. 拔掉 JLink 与 PC 间的 USB 线，JLink断电
4. 断开“ERASE”处的短接

第二步：
1. 可靠短接，图中“TST”处的两个过孔       
2. 用 USB 线连接 JLink 与 PC，JLink 供电
3. 保持 120 秒（不要放开“TST”处短接）       
4. 拔掉 JLink 与 PC 间的 USB 线（不要放开“TST”处短接）       
5. 至此，断开“TST”处的短接

经过以上两个步骤后，重新连接jlink，可以看到以下usb信息，表明已经进入编程模式
```
$lsusb
Bus 001 Device 019: ID 03eb:6124 Atmel Corp. at91sam SAMBA bootloader
```

### 查看并更新驱动

驱动来源：
一种：直接拷贝升级包中的`编程模式下驱动来自SAM-BAv2.18`目录下驱动
另一种：安装`SAM-BA v2.18 for Windows.exe`,在其安装目录下驱动，二者为相同的文件

在设备管理中找到`usb转串口的设备`或者`没有驱动的设备`，`更新驱动`(如果更新不成功可以先卸载再安装)选择`从列表指定位置安装`，下一步，`选择sam-ba-2.18的安装目录中的drv`确定，下一步，弹出驱动列表选择驱动`atm6124开头的驱动`，进行下一步安装
驱动安装成功后将在`通用串口总线控制器`中显示，表明这个时候驱动已经安装成功并且可以使用

![jlink可编程模式驱动](/images/2022/04/jlink可编程模式驱动.png)
> 驱动安装成功后，如上图并在红框处出现包含`atm6124`的驱动名字

### 刷固件

安装`Install_AT91-ISP_v1.13.exe`,打开`sam-ba v2.9`

1. 选择板级`at91sam7s64-ek`与主芯片一致。
2. 弹出固件升级界面，在`Send File Name`处选择升级的固件，并点击`Send File`
3. 弹出`Unlock regions`界面，选择`是`
4. 弹处`Lock regions`界面，选择`否`（也就是第一次选择Y，第二次选择N）
5. 等没有日志输出，基本上升级完成了

### 修改jlink V8 S/N并升级固件

1. 安装`Setup_JLinkARM_V450l.zip`(其他版本可能无法设置SN)
2. 打开JLINK 4.50l的`jlink commander`，这时会跳出一个界面叫我们更新最新的firmware，到这里一定先不要更新，我们需要做的工作是修改jlink的SN码，输入指令`exec setsn=20060125`,提示OK.

到这里固件基本刷完了，现在在jlink是可以正常使用的，但是默认的固件版本过低，为了支持更多芯片选择升级一个新的固件

安装`JLink_Windows_V760_i386.exe`,再一次其打开`jlink commander`，提示升级固件时可以进行升级了，升级成功后固件版本是2014


## 注意点

在整个固件升级的过程中需要注意的有亮点，一是驱动的安装，一般无法进入下载界面主要原因在于驱动；另一个就是SAM-BA软件的选择，在启动安装正常的情况下，打开SAM-BA可以识别出连接USB的就可以进行固件升级。

## 参考

- [JLink V8刷固件方式 转载整合](https://blog.csdn.net/u013381608/article/details/116715455)
- [J-Link该如何升级固件？](https://blog.csdn.net/best_xiaolong/article/details/117173826)
