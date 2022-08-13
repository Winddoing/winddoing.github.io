---
title: ALSA-DMA
categories:
  - 设备驱动
  - 音频
tags:
  - audio
  - alsa
  - 驱动
abbrlink: 8df01b06
date: 2017-07-13 23:07:24
---

>S/PDIF，全名为Sony/Philips Digital Interconnect Format，是Sony和Philips这两大巨头在80年代为一般家用器材所定制出来的一种数字讯号传输接口，基本上是以AES/EBU(也称为AES3)专业用数字接口为参考然后做了一些小变动而成的家用版本，可以使用成本比较低的硬件来实现数字讯号传输。为了定制一个统一的接口规格，在现今以IEC 60958标准规范来囊括取代AES/EBU与S/PDIF规范，而IEC 60958定义了三种主要型态：

<!-- more -->

* IEC 60958 TYPE 1 Balanced ─ 三线式传输，使用110 Ohm阻抗的线材以及XLR接头，使用于专业场合。
* IEC 60958 TYPE 2 Unbalanced ─ 使用75 Ohm阻抗的铜轴线以及RCA接头，使用于一般家用场合。
* IEC 60958 TYPE 2 Optical ─ 使用光纤传输以及F05光纤接头，也是使用于一般家用场合

事实上，IEC 60958有时会简称为IEC958，而IEC 60958 TYPE 1即为AES/EBU(或著称为AES3)界面，而IEC 60958 TYPE 2即为S/PDIF接口，而虽然在IEC 60958 TYPE 2的接头规范里是使用RCA或着光纤接头，不过近年来一些使用S/PDIF的专业器材改用BNC接头搭配上75 Ohm的同轴线以得到比较好的传输质量，下表为AES/EBU与S/PDIF的比较表。

|   |     AES/EBU    |  S/PDIF   |
|:-:|      :---:     |  :----:   |
| 线材    |   110 Ohm屏蔽绞线     | 75 Ohm同轴线或是光纤线 |
| 接头    |   XLR 3 Pin接头     | RCA或BNC接头 |
| 最大位数 |    24 Bits     | 标准为20 Bits(可支持到24 Bits) |
| 讯号电平 |    3 ~ 10V     |   0.5 ~ 1V |
| 编码    |   双相符号编码(Biphase Mark Code)| 双相符号编码(Biphase Mark Code) |
