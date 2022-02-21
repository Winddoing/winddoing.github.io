---
layout: post
title: 音频codec——耳机电路
date: '2021-11-09 16:00'
tags:
  - codec
  - i2s
  - 音频
categories:
  - 电子电路
abbrlink: 86a98cff
---

![耳机接头](/images/2021/11/耳机接头.png)

<!--more-->

## 耳机接口原理图

![耳机接口原理图](/images/2021/11/耳机接口原理图.png)
> 该原理图为`国标`耳机插座
>
> 四段式耳机插头: `第1节——1pin`：接地，`第2节——2、5pin`：接MIC，`第3节——3、6pin`：接右声道，`第4节——4、7pin`：接左声道

- `MIC_IN1P`： Single-end input for microphone 1（麦克风单端输入 1）
- `MICBIAS1`： Bias voltage output for microphone（麦克风偏置电压输出）
- 耳机插座说明，原理图中带箭头的表示开关，默认耳机没有插入时处理连接状态（比如pin2和pin5），但是一旦耳机插入后会将其断开。

## Single-ended输入模式

对于每一个信号源，都有一根线，连接到你所用到的数据采集接口上。


## 耳机的类型

从主观来看，耳机分三段耳机和四段耳机，而四段耳机又分为欧标和美标两种。具体的区别如下图：
![耳机类型](/images/2021/11/耳机类型.png)

- `三段耳机`：线序分别为，L、R、G，没有MIC端，所以三段耳机无法使用mic，只能接受声音，另外，三段耳机L,R线序长度正常，G端比较长
- `四段-美标(CTIA)耳机`：线序分别为L,R,G,M，第三阶为GND
- `四段-欧标（OMTP）耳机`：线序分别为L,R,M,G，第四段为GND

> 由于`CTIA`和`OMTP`在MIC和GND是相反的，所以会出现有些耳机插入手机上声音很小，按住HOOK将恢复正常，说明耳机和手机不匹配造成。
> `国内大部分厂商都使用欧标，所以也有把OMTP叫做国标`

### 如何区分欧标和美标耳机

区分美标或者欧标，可以简单的用万能表来测量耳机电阻，确定线序中的GND是在第三段或者第四段


## Jack结构

一般常见的Jack都是由5PIN or 6PIN组成，其中PIN脚分别作为`HP_OUTL`(左声道输出)、`HP_OUTR`(右声道输出)、`HP_DET`#(耳机检测)、`GROUND`(地) & `MIC`(麦克风)使用


### 声卡驱动中耳机检测流程

- `插入（PLUG IN）`： HP_DET#信号由`High->Low`，触发IRQ到SOC，进入中断处理函数（即耳机类型检测）；当检测到耳机为4环耳机时，直接上报给系统，并Enable butten press功能；若检测到为3环耳机时，继续检测，直到检测为4环耳机或则检测次数已满，然后将当前耳机状态上报给系统。

- `拔出（PLUG OUT）`： HP_DET#信号由`Low->High`，触发IRQ到SOC，将当前耳机状态上报系统，并Disable那些和耳机相关的工作；

### 耳机线控按键

通常耳机上的线控按钮会有一个或者三个，分别是`HOOK`，`音量+`，`音量-`

`HOOK`的作用是由上层负责，底层只需要确保上报了对应的`HOOK event`事件给上层应用

## ALSA中耳机检测 —— ASoC jack detection

https://www.kernel.org/doc/html/v4.16/sound/soc/jack.html

## 参考

- [手机耳机接线图的工作原理，各种耳机插头接线图](http://www.elecfans.com/baike/waijiepeijian/erji/20190522940004.html)
- [单端（Single-Ended）模式与差分（Differential）模式的区别](https://blog.csdn.net/sunflowerfsw/article/details/50442396)
- [rk3399调试alc5651(audio模块)之操作方法](https://blog.csdn.net/huang_165/article/details/85321945)
- [ALC5651_DataSheet_V0.92](http://www.armdesigner.com/download/ALC5651_DataSheet_V0.92.pdf) —— codec
- [【audio】耳机插拔/线控按键识别流程](https://blog.csdn.net/sinat_34606064/article/details/77932816)
- [耳机jack构造及在应用时可能出现的问题](https://www.cnblogs.com/Peter-Chen/p/3999212.html)
