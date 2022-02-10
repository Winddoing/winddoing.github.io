---
layout: "post"
title: ASOC之DAPM
categories: 设备驱动
tags:
  - audio
  - alsa
  - dapm
date: "2022-02-10 19:52"
---

动态音频电源管理 (DAPM-Dynamic Audio Power Management) 旨在让便携式Linux设备始终使用音频子系统内的最低电量。 它独立于其他内核PM，因此可以轻松地与其他PM系统共存。

> [Dynamic Audio Power Management for Portable Devices](https://www.kernel.org/doc/html/latest/sound/soc/dapm.html)

<!--more-->

DAPM对所有用户空间应用程序也是完全透明的，因为所有电源切换都在 ASoC 内核内完成。 用户空间应用程序不需要更改代码或重新编译。 DAPM 根据设备内的任何音频流（捕获/播放）活动和混音器设置做出电源切换决策。

DAPM横跨整台机器。 它涵盖了整个音频子系统内的电源控制，其中包括内部编解码器电源模块和机器级电源系统。

DAPM中有4个电源域:

- Codec bias domain
  - VREF、VMID（核心编解码器和音频功率）
  - 通常在编解码器探测/删除和挂起/恢复时控制，但如果侧音不需要电源等，可以在流时设置。

- Platform/Machine domain
  - 物理连接的输入和输出
  - 特定于平台/机器和用户操作，由机器驱动程序配置并响应异步事件，例如插入 HP 时

- Path domain
  - 音频子系统信号路径
  - 当用户更改混音器和复用器设置时自动设置。例如alsamixer，混合器。

- Stream domain
  - DAC 和 ADC。
  - 分别在流播放/捕获开始和停止时启用和禁用。例如播放，录音。


所有DAPM电源切换决策都是通过查阅整台机器的`音频路由图`自动做出的。此映射特定于每台机器，由每个音频组件（包括内部编解码器组件）之间的互连组成。所有影响电源的音频组件在下文中都称为小部件。

dapm最核心的部分大概就是`widgets`、`paths`和`routes`，其中widgets是DAPM的基本单元，paths是widget之间的连接器，routes表示widget的连接关系，在一个声卡中由三者构成了一个`音频路由图`

> widgets是dapm所控制的最小单元，如果把n个widgets比作是n个村庄，那么在这n个村庄之间修铁路就是route所需要做的工作，相同等级的村庄之间也没必要修铁路，修铁路的目的当然是为了能从起始地(source)到目的地(sink)，而到底走哪条路，也不是随机的，这个可以理解成kcontrol所干的活


## DAPM Widgets

在DAPM框架中，widget用结构体`snd_soc_dapm_widget`来描述。 头文件`include/sound/soc-dapm.h`

将codec中的各个组件以widget来描述，比如

``` C
/* ASRC */                                                                  
SND_SOC_DAPM_SUPPLY_S("I2S1 ASRC", 1, RT5651_PLL_MODE_2,                    
              15, 0, NULL, 0),                                              
SND_SOC_DAPM_SUPPLY_S("I2S2 ASRC", 1, RT5651_PLL_MODE_2,                    
              14, 0, NULL, 0),                                              
SND_SOC_DAPM_SUPPLY_S("STO1 DAC ASRC", 1, RT5651_PLL_MODE_2,                
              13, 0, NULL, 0),                                              
SND_SOC_DAPM_SUPPLY_S("STO2 DAC ASRC", 1, RT5651_PLL_MODE_2,                
              12, 0, NULL, 0),                                              
SND_SOC_DAPM_SUPPLY_S("ADC ASRC", 1, RT5651_PLL_MODE_2,                     
              11, 0, NULL, 0),                                              

/* micbias */                                                               
SND_SOC_DAPM_SUPPLY("LDO", RT5651_PWR_ANLG1,                                
        RT5651_PWR_LDO_BIT, 0, NULL, 0),                                    
SND_SOC_DAPM_SUPPLY("micbias1", RT5651_PWR_ANLG2,                           
        RT5651_PWR_MB1_BIT, 0, NULL, 0),                                    
/* Input Lines */                                                           
SND_SOC_DAPM_INPUT("MIC1"),                                                 
SND_SOC_DAPM_INPUT("MIC2"),                                                 
SND_SOC_DAPM_INPUT("MIC3"),                                                 

SND_SOC_DAPM_INPUT("IN1P"),                                                 
SND_SOC_DAPM_INPUT("IN2P"),                                                 
SND_SOC_DAPM_INPUT("IN2N"),                                                 
SND_SOC_DAPM_INPUT("IN3P"),                                                 
SND_SOC_DAPM_INPUT("DMIC L1"),                                              
SND_SOC_DAPM_INPUT("DMIC R1"),                                              
SND_SOC_DAPM_SUPPLY("DMIC CLK", RT5651_DMIC, RT5651_DMIC_1_EN_SFT,          
            0, set_dmic_clk, SND_SOC_DAPM_PRE_PMU),                         
```



## DAPM paths

## DAPM routes



## 参考

- [DAPM_widget_route_path简介](https://www.cnblogs.com/-glb/p/14411301.html)
