---
title: 音频接口
categories:
  - 设备驱动
  - 音频
tags:
  - audio
  - alsa
  - i2s
abbrlink: 25782
date: 2017-03-05 23:07:24
---


|  接口 | 应用  |
|:----:|:------|
| I2S  | 传输双声道数据，比如喇叭  |
| PCM  | 传输单声道数据，比如麦克风 |
| TDM  | 传输两个以上声道数据，同时区别于IIS特定格式 |

<!---more--->

## I2S

> 传输双声道数据(立体声)


I2S(Inter—IC Sound)总线, 又称 集成电路内置音频总线，是飞利浦公司为数字音频设备之间的音频数据传输而制定的一种总线标准，该总线专责于音频设备之间的数据传输，广泛应用于各种多媒体系统。它采用了沿独立的导线传输时钟与数据信号的设计，通过将数据和时钟信号分离，避免了因时差诱发的失真，为用户节省了购买抵抗音频抖动的专业设备的费用。

### 硬件接口

三个主要的信号线
![i2s-sycle](/images/audio/i2s-sycle.png)
#### BCLK

> 时钟是方波的形式

串行时钟SCLK，也叫位时钟（BCLK），即对应数字音频的每一位数据，SCLK都有1个脉冲。`SCLK的频率=2×采样频率×采样位数`。

如采样频率=44.1Khz  采样位数=24bit

SCLK = 2 * 44.1kHz * 24 = 2.1168MHz

#### LRCLK

帧时钟LRCK，(也称WS)，用于切换左右声道的数据。LRCK为“1”表示正在传输的是`右声道`的数据，为“0”则表示正在传输的是`左声道`的数据。`LRCK的频率 = 采样频率`。
在目前的测试中主要为SYNC_CLK

LRCLK=44.1kHz

#### SDATA

串行数据SDATA，就是用二进制补码表示的音频数据。

### 操作模式

#### I2S
![I2S](/images/audio/I2S.png)

#### LJ (Left Justified)
![I2S-LJ](/images/audio/I2S-LJ.png)

#### RJ (Left Justified)
![I2S-RJ](/images/audio/I2S-RJ.png)


### I2S--八声道

![i2s_channel_8](/images/2019/02/i2s_channel_8.png)
>i2s normal mode


## PCM

> 传输单声道数据，比如麦克风

![audio pcm mode a](/images/2022/08/audio_pcm_mode_a.png)


## TDM

> 传输两个以上声道数据，同时区别于IIS特定格式。


### 硬件接口信号

PCM接口与I2S相似，电路信号包括：

- PCM_CLK   数据时钟信号
- PCM_SYNC  帧同步时钟信号
- PCM_IN    接收数据信号
- PCM_OUT   发送数据信号

| PCM接口  |  I2S接口  |
|:--------:|:---------:|
| PCM_OUT  |  SD_OUT   |
|  PCM_IN  |   SD_IN   |
| PCM_SYNC | WS(LRCLK) |
| PCM_CLK  | sCK(BCLK) |



## 参考

* [16I2S/PCM Controller (8 channel)](http://www.t-firefly.com/download/firefly-rk3288/docs/TRM/rk3288-chapter-16-i2s-pcm-controller-(8-channel).pdf)