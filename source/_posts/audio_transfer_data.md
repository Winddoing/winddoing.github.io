---
title: Audio ALSA数据传输
date: 2018-03-13 23:07:24
categories: 设备驱动
tags: [Audio, alsa, 驱动]
---

在ALSA数据传输中，主要出现错误`underrun`和`overrun`

> DDR ---> buffer ---> digital singal

<!--more-->

## overrun

```
MIC --> DMIC(控制器) --> DDR(RAM) --> Flash
```
在录音时由于录音数据过快会产生`overrun`现象

## underrun

```
Flash --> DDR --> I2S --> Codec --> spk
```
在放音时由于用户层的音频数据到DDR中的速度比控制器到codec放出的速度慢,出现`underrun`

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
2. 


## xrun


