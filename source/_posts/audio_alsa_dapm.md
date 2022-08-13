---
title: ALSA-DAPM
categories:
  - 设备驱动
  - 音频
tags:
  - audio
  - alsa
  - 驱动
abbrlink: 69425dfa
date: 2017-07-12 23:07:24
---


>所谓widget，其实可以理解为是kcontrol的进一步升级和封装，她同样是指音频系统中的某个部件，比如mixer，mux，输入输出引脚，电源供应器等等，甚至，我们可以定义虚拟的widget，例如playback stream widget。widget把kcontrol和动态电源管理进行了有机的结合，同时还具备音频路径的连结功能，一个widget可以与它相邻的widget有某种动态的连结关系。在DAPM框架中，widget用结构体snd_soc_dapm_widget来描述：

<!--more-->

## amixer工作流程

>参考tinymix的使用流程

## 常用操作

```
#define SNDRV_CTL_IOCTL_CARD_INFO _IOR('U', 0x01, struct snd_ctl_card_info)
#define SNDRV_CTL_IOCTL_ELEM_LIST _IOWR('U', 0x10, struct snd_ctl_elem_list)
#define SNDRV_CTL_IOCTL_ELEM_INFO _IOWR('U', 0x11, struct snd_ctl_elem_info)
```

## 驱动的注册

```
snd_ctl_create  //创建控件管理结构
    |-> snd_device_new [SNDRV_DEV_CONTROL]
        |
        |-> struct file_operations
```


## 控件(元素)的添加

```
snd_soc_add_codec_controls
    |-> snd_soc_add_controls
        |-> snd_ctl_add   <---- snd_soc_cnew
            |-> list_add_tail
```

## kcontrol


``` C
struct snd_kcontrol_new {
    snd_ctl_elem_iface_t iface; /* interface identifier */
    unsigned int device;        /* device/client number */
    unsigned int subdevice;     /* subdevice (substream) number */
    const unsigned char *name;  /* ASCII name of item */
    unsigned int index;     /* index of item */
    unsigned int access;        /* access rights */
    unsigned int count;     /* count of same elements */
    snd_kcontrol_info_t *info;
    snd_kcontrol_get_t *get;
    snd_kcontrol_put_t *put;
    union {
        snd_kcontrol_tlv_rw_t *c;
        const unsigned int *p;
    } tlv;
    unsigned long private_value;
};
```
### kcontrol的命名

> kcontrol的作用由名称来区分，对于名称相同的kcontrol，则使用index区分。name定义的标准是“SOURCE DIRECTION FUNCTION”即“源 方向 功能”，SOURCE定义了kcontrol的源，如“Master”、“PCM”等；DIRECTION 则为“Playback”、“Capture”等，如果DIRECTION忽略，意味着Playback和capture双向；FUNCTION则可以是“Switch”、“Volume”和“Route”等。


内核说明文档:

```
This document describes standard names of mixer controls.

Syntax: SOURCE [DIRECTION] FUNCTION

DIRECTION:
  <nothing>	(both directions)
  Playback
  Capture
  Bypass Playback
  Bypass Capture

FUNCTION:
  Switch	(on/off switch)
  Volume
  Route		(route control, hardware specific)

SOURCE:
  Master
  Master Mono
  Hardware Master
  Speaker	(internal speaker)
  Headphone
  Beep		(beep generator)
  Phone
  Phone Input
  Phone Output
  Synth
  FM
  Mic
  Line
  CD
  Video
  Zoom Video
  Aux
  PCM
  PCM Front
  PCM Rear
  PCM Pan
  Loopback
  Analog Loopback	(D/A -> A/D loopback)
  Digital Loopback	(playback -> capture loopback - without analog path)
  Mono
  Mono Output
  Multi
  ADC
  Wave
  Music
  I2S
  IEC958

Exceptions:
  [Digital] Capture Source
  [Digital] Capture Switch	(aka input gain switch)
  [Digital] Capture Volume	(aka input gain volume)
  [Digital] Playback Switch	(aka output gain switch)
  [Digital] Playback Volume	(aka output gain volume)
  Tone Control - Switch
  Tone Control - Bass
  Tone Control - Treble
  3D Control - Switch
  3D Control - Center
  3D Control - Depth
  3D Control - Wide
  3D Control - Space
  3D Control - Level
  Mic Boost [(?dB)]

PCM interface:

  Sample Clock Source	{ "Word", "Internal", "AutoSync" }
  Clock Sync Status	{ "Lock", "Sync", "No Lock" }
  External Rate		/* external capture rate */
  Capture Rate		/* capture rate taken from external source */

IEC958 (S/PDIF) interface:

  IEC958 [...] [Playback|Capture] Switch	/* turn on/off the IEC958 interface */
  IEC958 [...] [Playback|Capture] Volume	/* digital volume control */
  IEC958 [...] [Playback|Capture] Default	/* default or global value - read/write */
  IEC958 [...] [Playback|Capture] Mask		/* consumer and professional mask */
  IEC958 [...] [Playback|Capture] Con Mask	/* consumer mask */
  IEC958 [...] [Playback|Capture] Pro Mask	/* professional mask */
  IEC958 [...] [Playback|Capture] PCM Stream	/* the settings assigned to a PCM stream */
  IEC958 Q-subcode [Playback|Capture] Default	/* Q-subcode bits */
  IEC958 Preamble [Playback|Capture] Default	/* burst preamble words (4*16bits) */
```
> Documentation/sound/alsa/ControlNames.txt



## widget


1. codec域

比如VREF和VMID等提供参考电压的widget，这些widget通常在codec的probe/remove回调中进行控制，当然，在工作中如果没有音频流时，也可以适当地进行控制它们的开启与关闭。

2. platform域

位于该域上的widget通常是针对平台或板子的一些需要物理连接的输入/输出接口，例如耳机、扬声器、麦克风，因为这些接口在每块板子上都可能不一样，所以通常它们是在machine驱动中进行定义和控制，并且也可以由用户空间的应用程序通过某种方式来控制它们的打开和关闭。

3. 音频路径域

一般是指codec内部的mixer、mux等控制音频路径的widget，这些widget可以根据用户空间的设定连接关系，自动设定他们的电源状态。

4. 音频数据流域

是指那些需要处理音频数据流的widget，例如ADC、DAC等等。



## 数据结构

### snd_soc_dapm_type

``` C
/* dapm widget types */
enum snd_soc_dapm_type {
    snd_soc_dapm_input = 0,     /* input pin */
    snd_soc_dapm_output,        /* output pin */
    snd_soc_dapm_mux,           /* selects 1 analog signal from many inputs */
    snd_soc_dapm_virt_mux,          /* virtual version of snd_soc_dapm_mux */
    snd_soc_dapm_value_mux,         /* selects 1 analog signal from many inputs */
    snd_soc_dapm_mixer,         /* mixes several analog signals together */
    snd_soc_dapm_mixer_named_ctl,       /* mixer with named controls */
    snd_soc_dapm_pga,           /* programmable gain/attenuation (volume) */
    snd_soc_dapm_out_drv,           /* output driver */
    snd_soc_dapm_adc,           /* analog to digital converter */
    snd_soc_dapm_dac,           /* digital to analog converter */
    snd_soc_dapm_micbias,       /* microphone bias (power) */
    snd_soc_dapm_mic,           /* microphone */
    snd_soc_dapm_hp,            /* headphones */
    snd_soc_dapm_spk,           /* speaker */
    snd_soc_dapm_line,          /* line input/output */
    snd_soc_dapm_switch,        /* analog switch */
    snd_soc_dapm_vmid,          /* codec bias/vmid - to minimise pops */
    snd_soc_dapm_pre,           /* machine specific pre widget - exec first */
    snd_soc_dapm_post,          /* machine specific post widget - exec last */
    snd_soc_dapm_supply,        /* power/clock supply */
    snd_soc_dapm_regulator_supply,  /* external regulator */
    snd_soc_dapm_clock_supply,  /* external clock */
    snd_soc_dapm_aif_in,        /* audio interface input */
    snd_soc_dapm_aif_out,       /* audio interface output */
    snd_soc_dapm_siggen,        /* signal generator */
    snd_soc_dapm_dai_in,        /* link to DAI structure */
    snd_soc_dapm_dai_out,
    snd_soc_dapm_dai_link,      /* link between two DAI structures */
};
```
### snd_soc_dapm_widget

``` C
/* dapm widget */
struct snd_soc_dapm_widget {
    enum snd_soc_dapm_type id;   //该widget的类型值，比如snd_soc_dapm_output，snd_soc_dapm_mixer等等。
    const char *name;       /* widget name */
    const char *sname;  /* stream name */
    struct snd_soc_codec *codec;
    struct snd_soc_platform *platform;
    struct list_head list;		//所有注册到系统中的widget都会通过该list，链接到代表声卡的snd_soc_card结构的widgets链表头字段中
    struct snd_soc_dapm_context *dapm;	//snd_soc_dapm_context结构指针，ASoc把系统划分为多个dapm域，每个widget属于某个dapm域，同一个域代表着同样的偏置电压供电策略，
										//比如，同一个codec中的widget通常位于同一个dapm域，而平台上的widget可能又会位于另外一个platform域中。

    void *priv;             /* widget specific data */
    struct regulator *regulator;        /* attached regulator */	// 对于snd_soc_dapm_regulator_supply类型的widget，该字段指向与之相关的regulator结构指针。
    const struct snd_soc_pcm_stream *params; /* params for dai links */ //目前对于snd_soc_dapm_dai_link类型的widget，指向该dai的配置信息的snd_soc_pcm_stream结构

    /* dapm control */
    int reg;                /* negative reg = no direct dapm */
    unsigned char shift;            /* bits to shift */
    unsigned int value;             /* widget current value */
    unsigned int mask;          /* non-shifted mask */
    unsigned int on_val;            /* on state value */
    unsigned int off_val;           /* off state value */
    unsigned char power:1;          /* block power status */
    unsigned char invert:1;         /* invert the power bit */
    unsigned char active:1;         /* active stream on DAC, ADC's */
    unsigned char connected:1;      /* connected codec pin */
    unsigned char new:1;            /* cnew complete */
    unsigned char ext:1;            /* has external widgets */
    unsigned char force:1;          /* force state */
    unsigned char ignore_suspend:1;         /* kept enabled over suspend */
    unsigned char new_power:1;      /* power from this run */
    unsigned char power_checked:1;      /* power checked this run */
    int subseq;             /* sort within widget type */

    int (*power_check)(struct snd_soc_dapm_widget *w);

    /* external events */
    unsigned short event_flags;     /* flags to specify event types */
    int (*event)(struct snd_soc_dapm_widget*, struct snd_kcontrol *, int);

    /* kcontrols that relate to this widget */
    int num_kcontrols;
    const struct snd_kcontrol_new *kcontrol_news;
    struct snd_kcontrol **kcontrols;

    /* widget input and outputs */
    struct list_head sources;
    struct list_head sinks;

    /* used during DAPM updates */
    struct list_head power_list;
    struct list_head dirty;
    int inputs;			//该widget的所有有效路径中，连接到输入端的路径数量。
    int outputs;		//该widget的所有有效路径中，连接到输出端的路径数量。

    struct clk *clk;
};
```

## dapm

先注册widget,而后逐一进行初始化处理


### 注册


```
int snd_soc_register_component(struct device *dev,
                   const struct snd_soc_component_driver *cmpnt_drv,
                   struct snd_soc_dai_driver *dai_drv,
                   int num_dai)
```

数据结构:


```
struct snd_soc_component_driver {
    const char *name;

    /* Default control and setup, added after probe() is run */
    const struct snd_kcontrol_new *controls;
    unsigned int num_controls;
    const struct snd_soc_dapm_widget *dapm_widgets;
    unsigned int num_dapm_widgets;
    const struct snd_soc_dapm_route *dapm_routes;
    unsigned int num_dapm_routes;
    ....
}
```

注册流程:

```
snd_soc_register_component
    |-> snd_soc_component_initialize
        |->
            {   component->controls = driver->controls;
                component->num_controls = driver->num_controls;
                component->dapm_widgets = driver->dapm_widgets;
                component->num_dapm_widgets = driver->num_dapm_widgets;
                component->dapm_routes = driver->dapm_routes;
                component->num_dapm_routes = driver->num_dapm_routes;

                INIT_LIST_HEAD(&component->dai_list);
            }
   |-> snd_soc_register_dais
        |-> list_add(&dai->list, &component->dai_list);
   |-> snd_soc_component_add
        |-> snd_soc_component_add_unlocked
            |-> list_add(&component->list, &component_list);
```

初始化流程:

```
snd_soc_register_card
    |-> snd_soc_instantiate_card
        |-> soc_probe_link_components
            |-> soc_probe_component
                |-> snd_soc_dapm_new_dai_widgets
                    |-> snd_soc_dapm_new_control_unlocked
                        |-> dapm_cnew_widget
```


连接:

```
snd_soc_register_card
    |-> snd_soc_instantiate_card
        |-> soc_probe_link_dais
            |-> soc_link_dai_widgets
                |-> snd_soc_dapm_new_pcm

```


更新寄存器:

```
dapm_power_widgets
    |-> dapm_widget_update
        |-> soc_dapm_update_bits(struct snd_soc_dapm_context *dapm,int reg,
                                unsigned int mask, unsigned int value)
```


### Add Controls

```
snd_soc_add_codec_controls
    |-> snd_soc_add_controls
        |
        |-> for { snd_ctl_add(card, snd_soc_cnew(control, data,control->name, prefix)); }
```
>sound/soc/soc-core.c

作用:

### Add Widgets

### Add Route


## 相关术语

### MIXER

> Mixer      - Mixes several analog signals into a single analog signal.

>Mixer可以混合多个输入到输出

### MUX

> Mux        - An analog switch that outputs only one of many inputs.

>Mux只能从多个输入里选择一个作为输出



## dapm widget链表更新

1. 初始化的时候，snd_soc_instantiate_card里调用snd_soc_dapm_new_widgets，最终会调用dapm_power_widgets
2. 在用户空间通过tinymix设置路径，在SOC_DAPM_ENUM中的put或者get函数最终会调用dapm_power_widgets
3. 在用户空间通过tinyplay播放或者录音是的soc_pcm_prepare和soc_pcm_close，最终会调用dapm_power_widgets


## 参考

1. [ALSA声卡驱动中的DAPM详解之二：widget-具备路径和电源管理信息的kcontrol](http://blog.csdn.net/droidphone/article/details/12906139)
2. [ linux alsa 音频路径切换](http://blog.csdn.net/xiaojsj111/article/details/25601777)
3. [ALSA声卡驱动中的DAPM详解之三：如何定义各种widget](http://blog.csdn.net/DroidPhone/article/details/12978287)
4. [codec--wm8960](http://www.sunnyqi.com/upLoad/product/month_1306/WM8960.pdf)
5. [snd_kcontrol_new名称中的SOURCE字段](http://blog.csdn.net/azloong/article/details/6324901)
6. [Asoc dapm(三) - dapm widgets & dapm kcontrol & dapm route](http://blog.csdn.net/luckywang1103/article/details/50151649)
7. [ALSA声卡驱动中的DAPM详解之六：精髓所在，牵一发而动全身](http://blog.csdn.net/droidphone/article/details/14146319)
8. [DAPM](https://www.alsa-project.org/main/index.php/DAPM)
