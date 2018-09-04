---
layout: post
title: 多媒体硬件接口-HDMI、VGA
date: '2018-08-23 16:11'
categories:
  - 多媒体
---

常用的多媒体硬件接口的特性和基本数据传输原理

<!--more-->

## HDMI

>H-High，D-Definition，M-Multimedia，I-Interface；高清晰度多媒体接口

### 硬件接口

![hdmi_hardware_port](/images/2018/08/hdmi_hardware_port.png)

>19pin脚
* `TMDS` data channels (6 pins)
* `TMDS` clock channel (2 pins)
* Consumer Electronics Control (CEC) (1 pin)
* Display Data Channel (DDC)(1 pin)
* +5V power (1 pin)
* Hot Plug Detect (1 pin)
* TMDS Shield Lines (4 pins designated in yellow)
* CEC/DDC Ground (1 pin)


### 逻辑接口

![hdmi_in_out](/images/2018/08/hdmi_in_out.png)

信号介绍：
1. 4对`TMDS差分信号`：1对时钟+3对数据:
    - TMDS通道0传输B信号，同时H信号和V信号也嵌入该通道
    - TMDS通道1传输G信号
    - TMDS通道2传输R信号，R和G通道的多余位置用来传输音频信号
2. `CEC`：消费电子控制通道，通过这条通道可以控制设备之间的交互
3. `DDC`：就是`I²C信号`，主要是获取显示器的基本信息(比如EDID信息)
4. `HPD`：热插拔信号，该信号比较重要，当HPD引脚大于2V，TMDS才会输出。因此，如果屏幕没有显示，首先要测量该信号

> - `DCC`遵守的是I2C协议，EDID 存储在一个ROM 芯片中，HDMI协议规定ROM的I2C 地址必须是`0xA0`.电路设计中DDC端口上需要安装上拉电阻，电阻值最小要求达到1.3K。
> - `CEC`是一套完整的协议，电子设备可以借着CEC信号让用者可控制HDMI接口上所连接的装置。如单键播放(One Touch Play)，系统待机(System Standby)。 即是如果用者将影碟放进蓝光播放器时，电视会由于CEC信号的通知而自动开机，然后视频通道亦会自动切换到播放器连接的通道上。而当用者关掉电视时，CEC信号亦会通知HDMI相连接的装置一同进入待机。由于这样，所以就可以完全变成单一遥控器控制所有HDMI连接的装置。

HDMI接口中的数据信号采用的是S最小化传输`差分信号`协议。这种协议会将标准8bit数据转换为10bit信号，并且在转换过程中使用`微分传送`。

### CEC

CEC是`单总线协议`，通过Phsical address Discovery Process机制来分配物理地址，DDC信号把物理地址传输到设备中。当一个带CEC功能的设备获取到一个物理地址的时候，他将进行以下处理：

1. 主动申请分配与设备类型相应的逻辑地址
2. 通过广播的方式来报告物理地址和对应的逻辑地址，实现绑定。


### 最大分辨率

![hdmi_interface_max_pix](/images/2018/08/hdmi_interface_max_pix.png)
>接口所支持的协议不同，最大分辨率将不同

## VGA

VGA（Video Graphics Array）即`视频图形阵列`，是IBM在1987年随PS/2（PS/2 原是“Personal System 2”的意思，“个人系统2”.

VGA接口就是显卡上面输出模拟信号的接口。VGA接口是一种`D型接口`，上面共有`15针孔`，分成3排，每排5个，

![vga_hardware_port](/images/2018/08/vga_hardware_port.png)

DDC:Display Data Channel(显示数据通道)， 用于EDID信息的传送，其实就是`I2C`数据线。


### 信号

VGA显示中，FPGA需要产生５个信号分别是：行`同步信号HS`、`场同步信号VS`、`R`、`G`、`B`三基色信号。

| 信号 | 定义                         |
|:----:|:-----------------------------|
|  HS  | 行同步信号（3.3V）           |
|  VS  | 场 / 帧 同步信号（3.3V）     |
|  R   | 红基色 （0~0.714V 模拟信号） |
|  G   | 绿基色 （0~0.714V 模拟信号） |
|  B   | 蓝基色 （0~0.714V 模拟信号） |

### 最大分辨率

VGA接口所能支持的最大分辨率是`2048X1536px`

## DVI

DVI（Digital Visual Interface），即数字视频接口.

DVI是基于`TMDS(Transition Minimized Differential Signaling)`，转换`最小差分信号`技术来传输数字信号，TMDS运用先进的编码算法把8bit数据(R、G、B中的每路基色信号)通过最小转换编码为10bit数据(包含行场同步信息、时钟信息、数据DE、纠错等)，经过DC平衡后，采用差分信号传输数据，它和LVDS、TTL相比有较好的电磁兼容性能，可以用低成本的专用电缆实现长距离、高质量的数字信号传输。


### 分类

1. DVI-A（12+5）
2. DVI-D（24+1/18+1）: 只有数字接口
3. DVI-I（24+5）: 有数字和模拟接口

### 最大分辨率

* DVI-I单通道最大分辨率:`1920x1200,60Hz`
* DVI-I双通道最大分辨率:`2560x1600,60Hz/1920x1200,120Hz`
* DVI-D单通道最大分辨率:`1920x1200,60Hz`
* DVI-D双通道最大分辨率:`2560x1600,60Hz/1920x1080,120Hz`

## 参考

* [HDMI接口基础知识及硬件设计](https://blog.csdn.net/huangyangquan/article/details/77487116)
