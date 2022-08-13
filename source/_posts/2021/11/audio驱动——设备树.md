---
layout: post
title: Audio驱动——设备树
date: '2021-11-13 15:44'
categories:
  - 设备驱动
  - 音频
tags:
  - audio
  - alsa
  - 驱动
  - 设备树
abbrlink: a482f327
---

```
sound {                                       
    compatible = "simple-audio-card";         
    ...                                       
    simple-audio-card,widgets =               
        "Headphone", "Headphone Jack";        
    simple-audio-card,routing =               
        "Headphone Jack", "HPLEFT",           
        "Headphone Jack", "HPRIGHT",          
        "LEFTIN", "HPL",                      
        "RIGHTIN", "HPR";                     
    simple-audio-card,aux-devs = <&amp>;      
    simple-audio-card,cpu {                   
        sound-dai = <&ssi2>;                  
    };                                        
    simple-audio-card,codec {                 
        sound-dai = <&codec>;                 
        clocks = ...                          
    };                                        
};                                            
```
> From： Documentation/devicetree/bindings/sound/simple-card.txt

<!--more-->

## simple-audio-card

简单通用的`machine driver`, 是一个为了简化音频框架，在alsa上面的一个封装。如果simple-audio-card框架足够满足需求, 建议优先使用simple-audio-card框架。

```
status: 声卡目前的状态，目前是未激活；
compatible: 设备文件中的的名字，系统靠这个去匹配驱动代码中的simple-audio-card层的驱动程序；
simple-audio-card,name: 声卡在系统中的名字；
simple-audio-card,format： CPU/CODEC 通用音频格式"i2s", "right_j", "left_j"等
simple-audio-card,mclk-fs： 流速率和编解码器mclk之间的乘法因子。 定义时，在 dai-link 子节点中定义的 mclk-fs 属性将被忽略
simple-audio-card,hp-det-gpio： 对连接耳机时发出信号的GPIO检测，检查耳机接入的GPIO配置端口
simple-audio-card,mic-det-gpio： 对连接麦克风时发出信号的GPIO检测
simple-audio-card,widgets：主要指定音频非编解码器 DAPM 小部件。
                每个条目都是DT中的一对字符串："template-wname", "user-supplied-wname"。
                “template-wname”是模板小部件名称，目前包括："Microphone", "Line","Headphone" and "Speaker"。
                “user-supplied-wname”是用户指定的小部件名称。
simple-audio-card,routing： 音频组件之间的连接列表。每个条目都是一对字符串，第一个是连接的接收器，第二个是连接的源。
simple-audio-card,cpu {
      sound-dai: soc端的dai配置，i2s接口的配置；
}
simple-audio-card,codec {
      sound-dai:codec端的dai配置，就是soc外界codec的接口的配置，这里是虚拟声卡；
}
```
