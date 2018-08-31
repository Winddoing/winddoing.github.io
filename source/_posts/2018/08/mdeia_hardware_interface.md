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
2. `CEC`：消费电子控制通道，通过这条通道可以控制设备
3. `DDC`：就是`I²C信号`，主要是获取显示器的基本信息(比如EDID信息)
4. `HPD`：热插拔信号，该信号比较重要，当HPD引脚大于2V，TMDS才会输出。因此，如果屏幕没有显示，首先要测量该信号

HDMI接口中的数据信号采用的是S最小化传输`差分信号`协议。这种协议会将标准8bit数据转换为10bit信号，并且在转换过程中使用`微分传送`。


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

## DVI

DVI（Digital Visual Interface），即数字视频接口.

DVI是基于`TMDS(Transition Minimized Differential Signaling)`，转换`最小差分信号`技术来传输数字信号，TMDS运用先进的编码算法把8bit数据(R、G、B中的每路基色信号)通过最小转换编码为10bit数据(包含行场同步信息、时钟信息、数据DE、纠错等)，经过DC平衡后，采用差分信号传输数据，它和LVDS、TTL相比有较好的电磁兼容性能，可以用低成本的专用电缆实现长距离、高质量的数字信号传输。


### 分类

1. DVI-A（12+5）
2. DVI-D（24+1/18+1）: 只有数字接口
3. DVI-I（24+5）: 有数字和模拟接口

## 参考

* [HDMI接口基础知识及硬件设计](https://blog.csdn.net/huangyangquan/article/details/77487116)
