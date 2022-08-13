---
title: Audio ALSA数据传输
categories:
  - 设备驱动
  - 音频
tags:
  - audio
  - alsa
  - 驱动
abbrlink: 6516
date: 2018-03-13 23:07:24
---

在ALSA数据传输中，主要出现错误`underrun`和`overrun`

> DDR ---> buffer ---> digital singal

<!--more-->

## overrun

```
MIC --> DMIC(控制器) --> DDR(RAM) --> Flash
```
在`录音`时由于录音数据过快会产生`overrun`现象

## underrun

```
Flash --> DDR --> I2S --> Codec --> spk
```
在`放音`时由于用户层的音频数据到DDR中的速度比控制器到codec放出的速度慢,出现`underrun`

### 断音

```
+------+        +----+
|      |        |    |       +---------+    +-----+
|      |        |    | DMA   |         |    |     |
| flash+--------> DDR+-------> buffer  +---->codec|
|      |        |    |       +---------+    +-----+
+------+        +----+
```
>从flash到DDR的速度，比数据从DDR通过DMA到buffer的速度慢，导致出现断音`underrun`

1. DMA没有及时的从DDR中将数据搬到FIFO
2. DDR中申请的buffer不够大
3. DDR中的buffer没有数据

假如播放的是音乐格式是采样率为192KHz，采样宽度为24bit，声道为2，驱动中的buffer大小为1M bytes（256 pages），FIFO深度为64 entry，DDR为150MHz（假如cpu和DDR间的数据拷贝仅仅为200M bytes/s）

* DDR

那么1s播放出去的声音数据为192000 * 24 * 2/8(bytes)=1152000 bytes，而拷贝到buffer的数据为200Mbytes，即每10ms播放1152bytes,进入buffer的数据为2M bytes,而buffer仅仅有1M空间，所以播放完1 * 1024 * 1024 / 1152 =910次，即910 * 10ms=9s中内需要将程序调度回来，显然这是没有太大问题，因为我们的系统中不可能跑910个线程的。也就是说驱动中的buffer为1M byte的空间是没有问题的。

* FIFO

fifo为64个entry，那么存放的音频数据仅仅是64 * 24=1536 bits=192bytes，播放完这些数据需要的时间是192/115.2 (ms)=1.67ms, 也就是说需要播放完fifo中的数据后的2ms内就要把数据添加到fifo中，如果这段时间没有做到这一点，那么就断音了

## xrun
