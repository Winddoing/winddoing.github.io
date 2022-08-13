---
layout: post
title: ALSA驱动——DAPM
date: '2021-11-25 16:03'
tags:
  - alsa
  - dapm
  - 音频
categories:
  - 设备驱动
  - 音频
abbrlink: 1e1fc3f4
---

DAPM(Dynamic Audio Power Management):动态音频电源管理旨在允许便携式Linux设备始终使用音频子系统内的最低电量。它独立于其他内核PM，因此可以轻松与其他PM系统共存。

DAPM对所有用户空间应用程序也是完全透明的，因为所有电源切换都在ASoC内核内完成。用户空间应用程序不需要更改代码或重新编译。 DAPM根据设备内的任何音频流（录音/播放）活动和混音器设置做出电源切换决策。

DAPM跨越整个机器。它涵盖了整个音频子系统内的电源控制，包括内部编解码器电源块和机器级电源系统。

<!--more-->

DAPM中有`4`个电源域：

- Codec domain: VREF、VMID（核心编解码器和音频功率）。通常在编解码器探测/删除和暂停/恢复时进行控制，但如果侧音等不需要电源，则可以在流时间设置。
- Platform/Machine domain: 物理连接的输入和输出。特定于平台/机器和用户操作，由机器驱动程序配置并响应异步事件。例如，当插入 HP 时
- Path domain: 音频子系统信号路径。当用户更改混频器和复用器设置时自动设置。例如混合器，混合器
- Stream domain: DAC和ADC。分别在开始和停止流播放/捕获时启用和禁用。例如aplay，记录。

DAPM框架会根据音频路径，完美地对各种部件的电源进行控制，而且精确地按某种顺序进行，防止上下电过程中产生不必要的pop-pop声。

## 参考

- [DAPM](https://www.alsa-project.org/main/index.php/DAPM)
- [linux-alsa详解14之DAPM详解7上下电过程分析](https://www.cnblogs.com/xinghuo123/p/13191510.html)
