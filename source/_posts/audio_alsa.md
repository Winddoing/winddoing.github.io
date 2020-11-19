---
title: Audio驱动总结--ALSA
categories: 设备驱动
tags:
  - audio
  - alsa
  - 驱动
abbrlink: 50356
date: 2017-07-10 23:07:24
---


接触Audio的这几个月,对控制的理解和对alsa框架的理解其中学习的进行总结

<!--more-->

## 音频参数

* Sample：样本长度(位宽)，音频数据最基本的单位，常见的有8位和16位。
* Channel：声道数，分为单声道mono和立体声stereo。
* Frame：帧，构成一个声音单元，Frame = Sample * channel, sample*channel/8 Byte。
* Rate：又称Sample rate，采样率，即每秒的采样次数，针对帧而言。
* Interleaved：交错模式，一种音频数据的记录方式，在交错模式下，数据以连续桢的形式存放，即首先记录完桢1的左声道样本和右声道样本（假设为立体声），再开始桢2的记录。而在非交错模式下，首先记录的是一个周期内所有桢的左声道样本，再记录右声道样本，数据是以连续通道的方式存储。多数情况下使用交错模式。
* Period size：周期，每次硬件中断处理音频数据的帧数，对于音频设备的数据读写，以此为单位。
* Buffer size：数据缓冲区大小，这里特指runtime的buffer size，而不是snd_pcm_hardware定义的buffer_bytes_max。
* 码率: (编码速率), 码率 = 采样频率 * 位宽 * 声道个数

***采样率和实际的分频误差在5%左右***

>**Period**
>
>The interval between interrupts from the hardware. This defines the input latency, since the CPU will not have any idea that there is data waiting until the audio interface interrupts it.
>
>The audio interface has a "pointer" that marks the current position for read/write in its h/w buffer. The pointer circles around the buffer as long as the interface is running.
>
>Typically, there are an integral number of periods per traversal of the h/w buffer, but not always. There is at least one card (ymfpci)
>that generates interrupts at a fixed rate indepedent of the buffer size (which can be changed), resulting in some "odd" effects compared to more traditional designs.
>
>Note: h/w generally defines the interrupt in frames, though not always.
>
>Alsa's period size setting will affect how much work the CPU does. if you set the period size low, there will be more interrupts and the work that is done every interrupt will be done more often. So, if you don't care about low latency,
>set the period size large as possible and you'll have more CPU cycles for other things. The defaults that ALSA provides are in the middle of the range, typically.
>
>(from an old AlsaDevel thread[1], quoting Paul Davis)
>
>Retrieved from "http://alsa.opensrc.org/Period"
>
>来自：http://alsa.opensrc.org/Period
>
>**FramesPeriods**
>
>A frame is equivalent of one sample being played, irrespective of the number of channels or the number of bits. e.g.
>  * 1 frame of a Stereo 48khz 16bit PCM stream is 4 bytes.
>  * 1 frame of a 5.1 48khz 16bit PCM stream is 12 bytes.
>A period is the number of frames in between each hardware interrupt. The poll() will return once a period.
>The buffer is a ring buffer. The buffer size always has to be greater than one period size. Commonly this is 2*period size, but some hardware can do 8 periods per buffer. It is also possible for the buffer size to not be an integer multiple of the period size.
>Now, if the hardware has been set to 48000Hz , 2 periods, of 1024 frames each, making a buffer size of 2048 frames. The hardware will interrupt 2 times per buffer. ALSA will endeavor to keep the buffer as full as possible. Once the first period of samples has
>been played, the third period of samples is transfered into the space the first one occupied while the second period of samples is being played. (normal ring buffer behaviour).
>
>
>Additional example
>
>Here is an alternative example for the above discussion.
>Say we want to work with a stereo, 16-bit, 44.1 KHz stream, one-way (meaning, either in playback or in capture direction). Then we have:
>  * 'stereo' = number of channels: 2
>  * 1 analog sample is represented with 16 bits = 2 bytes
>  * 1 frame represents 1 analog sample from all channels; here we have 2 channels, and so:
>      * 1 frame = (num_channels) * (1 sample in bytes) = (2 channels) * (2 bytes (16 bits) per sample) = 4 bytes (32 bits)
>  * To sustain 2x 44.1 KHz analog rate - the system must be capable of data transfer rate, in Bytes/sec:
>      * Bps_rate = (num_channels) * (1 sample in bytes) * (analog_rate) = (1 frame) * (analog_rate) = ( 2 channels ) * (2 bytes/sample) * (44100 samples/sec) = 2*2*44100 = 176400 Bytes/sec
>Now, if ALSA would interrupt each second, asking for bytes - we'd need to have 176400 bytes ready for it (at end of each second), in order to sustain analog 16-bit stereo @ 44.1Khz.
>  * If it would interrupt each half a second, correspondingly for the same stream we'd need 176400/2 = 88200 bytes ready, at each interrupt;
>  * if the interrupt hits each 100 ms, we'd need to have 176400*(0.1/1) = 17640 bytes ready, at each interrupt.
>We can control when this PCM interrupt is generated, by setting a period size, which is set in frames.
>  * Thus, if we set 16-bit stereo @ 44.1Khz, and the period_size to 4410 frames => (for 16-bit stereo @ 44.1Khz, 1 frame equals 4 bytes - so 4410 frames equal 4410*4 = 17640 bytes) => an interrupt will be generated each 17640 bytes - that is, each 100 ms.
>  * Correspondingly, buffer_size should be at least 2*period_size = 2*4410 = 8820 frames (or 8820*4 = 35280 bytes).
>It seems (writing-an-alsa-driver.pdf), however, that it is the ALSA runtime that decides on the actual buffer_size and period_size, depending on: the requested number of channels, and their respective properties (rate and sampling resolution) - as well as the
>parameters set in the snd_pcm_hardware structure (in the driver).
>Also, the following quote may be relevant, from http://mailman.alsa-project.org/pipermail/alsa-devel/2007-April/000474.html:
>
>> > The "frame" represents the unit, 1 frame = # channels x sample_bytes.
>> > In your case, 1 frame corresponds to 2 channels x 16 bits = 4 bytes.
>> >
>> > The periods is the number of periods in a ring-buffer.  In OSS, called
>> > as "fragments".
>> >
>> > So,
>> >  - buffer_size = period_size * periods
>> >  - period_bytes = period_size * bytes_per_frame
>> >  - bytes_per_frame = channels * bytes_per_sample
>> >
>>
>> I still don't understand what 'period_size' and a 'period' is?
>
>
>The "period" defines the frequency to update the status, usually viathe invokation of interrupts.  The "period_size" defines the frame sizes corresponding to the "period time".  This term corresponds to the "fragment size" on OSS.  On major sound hardwares,
>a ring-buffer is divided to several parts and an irq is issued on each boundary. The period_size defines the size of this chunk.
>
>On some hardwares, the irq is controlled on the basis of a timer.  In this case, the period is defined as the timer frequency to invoke an irq.
>
>来自：http://alsa-project.org/main/index.php/FramesPeriods
>

## 音频处理软件

>  Audacity 2.0.5


## 硬件

主要由音频总线(I2S,PCM)和控制总线(I2C或SPI)组成。

![alsa-hardware-link](/images/audio/alsa/alsa-hardware-link.png)

![audio-hardware](/images/audio/alsa/audio-hardware.png)


## alsa - ASOC

在内核设备驱动层，ALSA提供了alsa-driver，同时在应用层，ALSA为我们提供了alsa-lib，应用程序只要调用alsa-lib提供的API，即可以完成对底层音频硬件的控制。

![alsa-struct](/images/audio/alsa/alsa-struct.png)


ASoC被分为`Machine`、`Platform`和`Codec`三大部分。其中的Machine驱动负责Platform和Codec之间的耦合和设备或板子特定的代码。Platform驱动的主要作用是完成音频数据的管理，最终通过CPU的数字音频接口（DAI）把音频数据传送给Codec进行处理，最终由Codec输出驱动耳机或者是喇叭的音信信号。


* machine
用于描述设备组件信息和特定的控制如耳机/外放等。

>是指某一款机器，可以是某款设备，某款开发板，又或者是某款智能手机，由此可以看出Machine几乎是不可重用的，每个Machine上的硬件实现可能都不一样，CPU不一样，Codec不一样，音频的输入、输出设备也不一样，Machine为CPU、Codec、输入输出设备提供了一个`载体`。

这一部分将平台驱动和Codec驱动绑定在一起，描述了板级的硬件特征。主要负责Platform和Codec之间的耦合以及部分和设备或板子特定的代码。Machine驱动负责处理机器特有的一些控件和音频事件（例如，当播放音频时，需要先行打开一个放大器）；单独的Platform和Codec驱动是不能工作的，它必须由Machine驱动把它们结合在一起才能完成整个设备的音频处理工作。ASoC的一切都从Machine驱动开始，包括声卡的注册，绑定Platform和Codec驱动等等

* Platform
用于实现平台相关的DMA驱动和音频接口等。

> 一般是指某一个SoC平台，比如pxaxxx,s3cxxxx,omapxxx等等，与音频相关的通常包含该SoC中的时钟、DMA、I2S、PCM等等，只要指定了SoC，那么我们可以认为它会有一个对应的Platform，它只与SoC相关，与Machine无关，这样我们就可以把Platform抽象出来，使得同一款SoC不用做任何的改动，就可以用在不同的Machine中。实际上，把Platform认为是某个SoC更好理解。

这一部分只关心CPU本身，不关心Codec。主要处理两个问题：`DMA引擎`和`SoC集成的PCM、I2S或AC '97数字接口控制`。主要作用是完成音频数据的管理，最终通过CPU的数字音频接口（DAI）把音频数据传送给Codec进行处理，最终由Codec输出驱动耳机或者是喇叭的音信信号。在具体实现上，ASoC有把Platform驱动分为两个部分：`snd_soc_platform_driver`和`snd_soc_dai_driver`。其中，platform_driver负责管理音频数据，把音频数据通过dma或其他操作传送至cpu dai中，dai_driver则主要完成cpu一侧的dai的参数配置，同时也会通过一定的途径把必要的dma等参数与snd_soc_platform_driver进行交互。

* Codec
用于实现平台无关的功能，如寄存器读写接口，音频接口，各widgets的控制接口和DAPM的实现等

> 字面上的意思就是编解码器，Codec里面包含了I2S接口、D/A、A/D、Mixer、PA（功放），通常包含多种输入（Mic、Line-in、I2S、PCM）和多个输出（耳机、喇叭、听筒，Line-out），Codec和Platform一样，是可重用的部件，同一个Codec可以被不同的Machine使用。嵌入式Codec通常通过I2C对内部的寄存器进行控制。

这一部分只关心Codec本身，与CPU平台相关的特性不由此部分操作。在移动设备中，Codec的作用可以归结为4种，分别是：
1. 对PCM等信号进行D/A转换，把数字的音频信号转换为模拟信号。
2. 对Mic、Linein或者其他输入源的模拟信号进行A/D转换，把模拟的声音信号转变CPU能够处理的数字信号。
3. 对音频通路进行控制，比如播放音乐，收听调频收音机，又或者接听电话时，音频信号在codec内的流通路线是不一样的。
4. 对音频信号做出相应的处理，例如音量控制，功率放大，EQ控制等等。

ASoC对Codec的这些功能都定义好了一些列相应的接口，以方便地对Codec进行控制。ASoC对Codec驱动的一个基本要求是：`驱动程序的代码必须要做到平台无关性，以方便同一个Codec的代码不经修改即可用在不同的平台上`。


![alsa-asoc-arch](/images/audio/alsa/alas-asoc-arch.png)

ASoC对于Alsa来说，就是分别注册PCM/CONTROL类型的snd_device设备，并实现相应的操作方法集。图中DAI是数字音频接口，用于配置音频数据格式等。
* Codec驱动向ASoC注册`snd_soc_codec`和`snd_soc_dai`设备。
* Platform驱动向ASoC注册`snd_soc_platform`和`snd_soc_dai`设备。
* Machine驱动通过`snd_soc_dai_link`绑定codec/dai/platform.

Widget是各个组件内部的小单元。处在活动通路上电，不在活动通路下电。ASoC的DAPM正是通过控制这些Widget的上下电达到动态电源管理的效果。
* path描述与其它widget的连接关系。
* event用于通知该widget的上下电状态。
* power指示当前的上电状态。
* control实现空间用户接口用于控制widget的音量/通路切换等。

对驱动开者来说，就可以很好的解耦了：
* codec驱动的开发者，实现codec的IO读写方法，描述DAI支持的数据格式/操作方法和Widget的连接关系就可以了;
* soc芯片的驱动开发者，Platform实现snd_pcm的操作方法集和DAI的配置如操作 DMA，I2S/AC97/PCM的设定等;
* 板级的开发者，描述Machine上codec与platform之间的总线连接， earphone/Speaker的布线情况就可以了。

### DAPM


### DPCM

>[Dynamic PCM](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/plain/Documentation/sound/soc/dpcm.rst?h=v4.16-rc5)


## PCM设备

### 放音 -- 应用

>`tinyplay`播放音乐

``` C
# strace  tinyplay  pcmrec.wav
execve("/usr/bin/tinyplay", ["tinyplay", "pcmrec.wav"], [/* 16 vars */]) = 0

...

open("pcmrec.wav", O_RDONLY)            = 3
...
//读取wav格式的音频文件的头数据
read(3, "RIFF$\342\4\0WAVEfmt \20\0\0\0\1\0\2\0@\37\0\0\0}\0\0"..., 4096) = 4096

//第一次打开`pcmC0D0p`设备节点, 重新设置硬件参数
open("/dev/snd/pcmC0D0p", O_RDWR)       = 4
//ioctl - cmd=SNDRV_PCM_IOCTL_HW_REFINE
ioctl(4, 0xc25c4110, 0x412178)          = 0
close(4)                                = 0

//第二次打开`pcmC0D0p`设备节点, 进行音频播放的准备工作和播放
open("/dev/snd/pcmC0D0p", O_RDWR)       = 4
//ioctl - cmd=`SNDRV_PCM_IOCTL_INFO`
ioctl(4, AGPIOC_ACQUIRE or APM_IOC_STANDBY, 0x7f83f3cc) = 0
//ioctl - cmd=`SNDRV_PCM_IOCTL_HW_PARAMS`
ioctl(4, 0xc25c4111, 0x7f83f170)        = 0
//ioctl - cmd=`SNDRV_PCM_IOCTL_SW_PARAMS`
ioctl(4, 0xc0684113, 0x7f83f5ec)        = 0

//在播放期间响应Ctrl+C的中断信号
rt_sigaction(SIGINT, {0x10000000, [RT_65 RT_67], 0x401240 /* SA_??? */}, {SIG_DFL, [RT_67 RT_68 RT_72 RT_74 RT_75 RT_77 RT_81 RT_89 RT_90 RT_91 RT_93 RT_94], 0}, 16) = 0

// mmap

// ioctl - cmd=`SNDRV_PCM_IOCTL_SYNC_PTR`

read(3, "\320\367\200\367\370\370`\370\220\370\330\370@\372h\371\240\371\320\374\230\373\240\374\341\5\301\1\241\5\221\25"..., 12288) = 12288
read(3, "a\0361\36\241\f\10\376\300\374\320\375\30\375\360\375\340\375\0\377\320\377(\377\370\376p\375p\374\321\0"..., 4096) = 4096
//ioctl - cmd=`SNDRV_PCM_IOCTL_PREPARE`
ioctl(4, 0x20004140, 0x7f83f648)        = 0
//ioctl - cmd=`SNDRV_PCM_IOCTL_WRITEI_FRAMES`
ioctl(4, 0x800c4150, 0x7f83f648)        = 0
read(3, "\201\21\301\27q\30\261\25\301\20Q\6x\375h\373\370\373\230\374\210\374x\374p\374\220\374\30\375 \375"..., 12288) = 12288
read(3, "\201\35\1%\241'\301\32\341\t@\377\250\374\220\372\20\373\30\374\340\373X\374H\374X\376\201\v\321\32"..., 4096) = 4096
ioctl(4, 0x800c4150, 0x7f83f648)        = 0

... //while(){ 循环读取播放 }

read(3, "\370\375\10\376 \376\210\376X\376x\376\250\376\350\376\360\376\260\376(\377H\377q\0\301\5\1\vq\21"..., 12288) = 12288
read(3, "\221\0021\n\21\f\241\5x\376\30\377\300\377(\377\1\1!\3q\4Q\3\301\4\240\377h\376\210\377"..., 4096) = 4096
ioctl(4, 0x800c4150, 0x7f83f648)        = 0
read(3, "P\377\0\377!\0\361\6Q\t\230\377@\376\250\377X\377\361\3\1\16\241\n!\0!\6A\16\241\v"..., 12288) = 4652
read(3, "", 4096)                       = 0
ioctl(4, 0x800c4150, 0x7f83f648)        = 0
read(3, "", 16384)                      = 0
ioctl(4, 0x800c4150, 0x7f83f648)        = 0
close(4)                                = 0
close(3)                                = 0
munmap(0x76fe9000, 65536)               = 0
write(1, "Playing sample: 2 ch, 8000 hz, 1"..., 38) = 38  //printf
exit_group(0)
```
#### 为什么open两次pcmC0D0p设备节点

1. 第一次打开`pcmC0D0p`,主要为了重新规范硬件
``` C
struct snd_pcm_hw_params {
    unsigned int flags;
    struct snd_mask masks[SNDRV_PCM_HW_PARAM_LAST_MASK -
                   SNDRV_PCM_HW_PARAM_FIRST_MASK + 1];
    struct snd_mask mres[5];    /* reserved masks */
    struct snd_interval intervals[SNDRV_PCM_HW_PARAM_LAST_INTERVAL -
                        SNDRV_PCM_HW_PARAM_FIRST_INTERVAL + 1];
    struct snd_interval ires[9];    /* reserved intervals */
    unsigned int rmask;     /* W: requested masks */
    unsigned int cmask;     /* R: changed masks */
    unsigned int info;      /* R: Info flags for returned setup */
    unsigned int msbits;        /* R: used most significant bits */
    unsigned int rate_num;      /* R: rate numerator */
    unsigned int rate_den;      /* R: rate denominator */
    snd_pcm_uframes_t fifo_size;    /* R: chip FIFO size in frames */
    unsigned char reserved[64]; /* reserved for future */
};
```
>file: include/uapi/sound/asound.h

主要是将用户空间的snd_pcm_hw_params信息和内核空间的进行对比和规范化

2. 第二次打开`pcmC0D0p`,主要为了进行音频播放的准备和播放音频信号


#### 为什么read音频文件两次,并且读的数据大小不一致

tinyplay中播放时,每次只读取一部分(16KB)的音频文件进行播放
``` C
size = pcm_frames_to_bytes(pcm, pcm_get_buffer_size(pcm)); //size=16384Byte=16KB
buffer = malloc(size);
...
do {
	//buffer 临时存放音频文件的数据的buf
	//size   一次读取的大小(16384Byte)
	//file   打开的音频文件描述符
    num_read = fread(buffer, 1, size, file);
    if (num_read > 0) {
        if (pcm_write(pcm, buffer, num_read)) {
            fprintf(stderr, "Error playing sample\n");
            break;
        }
    }else if(num_read == 0) {
        memset(buffer, 0, size);
        if(pcm_write(pcm, buffer, size)){
            fprintf(stderr, "Error playing sample\n");
            break;
        }
    }
} while (!close && num_read > 0);
```
在进行strace时,一次播放进行了两次的read系统调用,将每一次read数据的大小相加(12288+4096=16384Byte),正好与malloc的buffer大小一致.因此两次的read是由用户空间的函数进行数据分割的.

#### 用户空间申请buffer大小的依据

在播放当前歌曲时,所申请的buffer大小为16KB,为什么申请16K?

音频信息:

| 采样率 | 通道 | 位宽(format) |
|:----: |:----:|:-----------:|
| 44100Hz | 2  | 16bit		|


>4KB的buffer大小为`tinyplay`默认大小,`period_size = 1024`, `period_count = 4`决定了buffer大小,而`period_size`可以进行修改默认大小.

需要申请buffer的大小: 1024 * 4 * 2 * (16 / 8) = 16384

### 放音 -- 内核

#### ASOC接口

``` C
/* create a new pcm */
int soc_new_pcm(struct snd_soc_pcm_runtime *rtd, int num)
{
	...
	/* ASoC PCM operations */
	if (rtd->dai_link->dynamic) {
		rtd->ops.open       = dpcm_fe_dai_open;
		rtd->ops.hw_params  = dpcm_fe_dai_hw_params;
		rtd->ops.prepare    = dpcm_fe_dai_prepare;
		rtd->ops.trigger    = dpcm_fe_dai_trigger;
		rtd->ops.hw_free    = dpcm_fe_dai_hw_free;
		rtd->ops.close      = dpcm_fe_dai_close;
		rtd->ops.pointer    = soc_pcm_pointer;
		rtd->ops.ioctl      = soc_pcm_ioctl;
	} else {
		//回调函数
		rtd->ops.open       = soc_pcm_open;
		rtd->ops.hw_params  = soc_pcm_hw_params;
		rtd->ops.prepare    = soc_pcm_prepare;
		rtd->ops.trigger    = soc_pcm_trigger;
		rtd->ops.hw_free    = soc_pcm_hw_free;
		rtd->ops.close      = soc_pcm_close;
		rtd->ops.pointer    = soc_pcm_pointer;
		rtd->ops.ioctl      = soc_pcm_ioctl;
	}

	if (platform->driver->ops) {
		rtd->ops.ack        = platform->driver->ops->ack;
		rtd->ops.copy       = platform->driver->ops->copy;
		rtd->ops.silence    = platform->driver->ops->silence;
		rtd->ops.page       = platform->driver->ops->page;
		rtd->ops.mmap       = platform->driver->ops->mmap;
	}

	if (playback)
		snd_pcm_set_ops(pcm, SNDRV_PCM_STREAM_PLAYBACK, &rtd->ops);

	if (capture)
		snd_pcm_set_ops(pcm, SNDRV_PCM_STREAM_CAPTURE, &rtd->ops);
	...
}
```
> file: sound/soc/soc-pcm.c

##### soc_pcm_open

```
static int soc_pcm_open(struct snd_pcm_substream *substream)
{
	...
	// CPU <I2S> : jz_i2s_startup
	if (cpu_dai->driver->ops->startup) {
		 ret = cpu_dai->driver->ops->startup(substream, cpu_dai);
	}
	// Platform <DMA> : jz_pcm_open
	if (platform->driver->ops && platform->driver->ops->open) {
		 ret = platform->driver->ops->open(substream);
	}
	// Codec <idec_d3> : jz_icdc_startup
	if (codec_dai->driver->ops->startup) {
		 ret = codec_dai->driver->ops->startup(substream, codec_dai);
	}
 	// Machine <link> : phoenix_spk_sup  file:sound/soc/ingenic/asoc-board/phoenix_icdc.c
	if (rtd->dai_link->ops && rtd->dai_link->ops->startup) {
		 ret = rtd->dai_link->ops->startup(substream);
	}
	...
}
```

##### soc_pcm_hw_params

``` C
static int soc_pcm_hw_params(struct snd_pcm_substream *substream,
                struct snd_pcm_hw_params *params)
{
	 ...
	 // Machine <link> : phoenix_i2s_hw_params
	 if (rtd->dai_link->ops && rtd->dai_link->ops->hw_params) {
		 ret = rtd->dai_link->ops->hw_params(substream, params);
	 }
	 // Codec <idec_d3> : icdc_d3_hw_params
	 if (codec_dai->driver->ops->hw_params) {
		 ret = codec_dai->driver->ops->hw_params(substream, params, codec_dai);
	 }
	 // CPU <I2S> : jz_i2s_hw_params
	 if (cpu_dai->driver->ops->hw_params) {
		 ret = cpu_dai->driver->ops->hw_params(substream, params, cpu_dai);
	 }
	 // Platform <DMA> : jz_pcm_hw_params
	 if (platform->driver->ops && platform->driver->ops->hw_params) {
		 ret = platform->driver->ops->hw_params(substream, params);
 	}
 	...
}
```
##### soc_pcm_prepare

``` C
static int soc_pcm_prepare(struct snd_pcm_substream *substream)
{
	...
	// Machine <link> : phoenix_i2s_hw_params
	if (rtd->dai_link->ops && rtd->dai_link->ops->prepare) {
		ret = rtd->dai_link->ops->prepare(substream);
	}
	// Platform <DMA> :	jz_pcm_prepare
	if (platform->driver->ops && platform->driver->ops->prepare) {
		ret = platform->driver->ops->prepare(substream);
	}
   	// Codec <idec_d3> : 默认函数
	if (codec_dai->driver->ops->prepare) {
		ret = codec_dai->driver->ops->prepare(substream, codec_dai);
	}
	// CPU <I2S> : 默认函数
	if (cpu_dai->driver->ops->prepare) {
		ret = cpu_dai->driver->ops->prepare(substream, cpu_dai);
	}
    ...
}
```

##### soc_pcm_trigger

``` C
static int soc_pcm_trigger(struct snd_pcm_substream *substream, int cmd)
{
	// Codec <idec_d3> : icdc_d3_trigger
	if (codec_dai->driver->ops->trigger) {
		ret = codec_dai->driver->ops->trigger(substream, cmd, codec_dai);
	}
	// Platform <DMA> :	jz_pcm_trigger
	if (platform->driver->ops && platform->driver->ops->trigger) {
		ret = platform->driver->ops->trigger(substream, cmd);
	}
	// CPU <I2S> : jz_i2s_trigger
	if (cpu_dai->driver->ops->trigger) {
		ret = cpu_dai->driver->ops->trigger(substream, cmd, cpu_dai);
	}
    ...
}
```

##### soc_pcm_hw_free

``` C
static int soc_pcm_hw_free(struct snd_pcm_substream *substream)
{
	/* free any machine hw params */
	// Machine <link> : phoenix_i2s_hw_free
	if (rtd->dai_link->ops && rtd->dai_link->ops->hw_free)
		rtd->dai_link->ops->hw_free(substream);

	/* free any DMA resources */
	// Platform <DMA> : snd_pcm_lib_free_pages
	if (platform->driver->ops && platform->driver->ops->hw_free)
		platform->driver->ops->hw_free(substream);

	/* now free hw params for the DAIs  */
	// Codec <idec_d3> : 默认函数
	if (codec_dai->driver->ops->hw_free)
		codec_dai->driver->ops->hw_free(substream, codec_dai);
	// CPU <I2S> : 默认函数
	if (cpu_dai->driver->ops->hw_free)
		cpu_dai->driver->ops->hw_free(substream, cpu_dai);
    ...
}
```

##### soc_pcm_pointer

``` C
static snd_pcm_uframes_t soc_pcm_pointer(struct snd_pcm_substream *substream)
{
    // Platform <DMA> :
    if (platform->driver->ops && platform->driver->ops->pointer)
        offset = platform->driver->ops->pointer(substream);

    if (cpu_dai->driver->ops->delay)
        delay += cpu_dai->driver->ops->delay(substream, cpu_dai);

    if (codec_dai->driver->ops->delay)
        delay += codec_dai->driver->ops->delay(substream, codec_dai);

    if (platform->driver->delay)
        delay += platform->driver->delay(substream, codec_dai);
}

```

##### soc_pcm_close

``` C
static int soc_pcm_close(struct snd_pcm_substream *substream)
{
	 // CPU <I2S> : jz_i2s_shutdown
	if (cpu_dai->driver->ops->shutdown)
		cpu_dai->driver->ops->shutdown(substream, cpu_dai);
	// Codec <idec_d3> : jz_icdc_shutdown
	if (codec_dai->driver->ops->shutdown)
		codec_dai->driver->ops->shutdown(substream, codec_dai);
	// Machine <link> : phoenix_spk_sdown
	if (rtd->dai_link->ops && rtd->dai_link->ops->shutdown)
		rtd->dai_link->ops->shutdown(substream);
	// Platform <DMA> :	jz_pcm_close
	if (platform->driver->ops && platform->driver->ops->close)
		platform->driver->ops->close(substream);
	...
}
```

#### open

``` C
|(sound/core/pcm_native.c )
|-> snd_pcm_playback_open
  \
  |-> snd_pcm_open(file, pcm, SNDRV_PCM_STREAM_PLAYBACK);
    \
    |-> while(1){ snd_pcm_open_file(file, pcm, stream); schedule(); }
      \
      |-> snd_pcm_open_substream
		\
		|-> substream->ops->open(substream)
		  |(sound/soc/soc-pcm.c)
		  |-> soc_pcm_open
			\
			|-> cpu_dai->driver->ops->startup(substream, cpu_dai);
			  \_**snd_soc_register_component** -> snd_soc_dai_driver -> snd_soc_dai_ops (.startup = jz_i2s_startup)
			|-> codec_dai->driver->ops->startup(substream, codec_dai);
			  \_**snd_soc_register_codec** -> snd_soc_dai_driver -> snd_soc_dai_ops (.startup = jz_icdc_startup)
			|-> rtd->dai_link->ops->startup(substream);
			  \_ **snd_soc_register_card** -> snd_soc_dai_link -> snd_soc_ops (.startup = phoenix_spk_sup)
```

#### ioctl

>ioctl幻数

```C
//获取声卡信息返回给用户空间
#define SNDRV_PCM_IOCTL_INFO _IOR('A', 0x01, struct snd_pcm_info)
//硬件参数重新规范
#define SNDRV_PCM_IOCTL_HW_REFINE _IOWR('A', 0x10, struct snd_pcm_hw_params)
//设置硬件参数
#define SNDRV_PCM_IOCTL_HW_PARAMS _IOWR('A', 0x11, struct snd_pcm_hw_params)
//设置软件参数
#define SNDRV_PCM_IOCTL_SW_PARAMS _IOWR('A', 0x13, struct snd_pcm_sw_params)
//准备操作
#define SNDRV_PCM_IOCTL_PREPARE _IO('A', 0x40)
//从用户空间把音频数据拿过来，从wav文件中读出数据
#define SNDRV_PCM_IOCTL_WRITEI_FRAMES _IOW('A', 0x50, struct snd_xferi)
```

```
(`sound/core/pcm_native.c`)
|->	snd_pcm_playback_ioctl
|
|-> snd_pcm_playback_ioctl1 --> 判断cmd <SNDRV_PCM_IOCTL_WRITEI_FRAMES>
|(`sound/core/pcm_lib.c`)
|-> snd_pcm_lib_write --- > struct snd_pcm_substream *substream
|
|-> snd_pcm_lib_write1
		|_call_back-->snd_pcm_lib_write_transfer(数据传输:copy和map)
			|_.(内存和DMA之间的数据传递, 循环搬送直到播放完毕)
					char *hwbuf = runtime->dma_area + frames_to_bytes(runtime, hwoff);
					if (copy_from_user(hwbuf, buf, frames_to_bytes(runtime, frames)))
		|
		|-> snd_pcm_start(substream) //**启动传输(只是在开始时,调用一次)**
			|
			|-> snd_pcm_action
				|
				|-> snd_pcm_action_single
					|
					|-> {
							res = ops->pre_action(substream, state);
							if (res < 0)
 						   		return res;
							res = ops->do_action(substream, state);
							if (res == 0)
 						   		ops->post_action(substream, state);
							else if (ops->undo_action)
						    	ops->undo_action(substream, state);
						}
```
>file: sound/core/pcm_native.c

#### close

通过系统调用close, 到release进行关闭

```
.release =      snd_pcm_release

snd_pcm_release
  |
  |-> snd_pcm_release_substream
	|
	|-> snd_pcm_drop
	  |
	  |-> snd_pcm_stop
		|
		|-> snd_pcm_action(&snd_pcm_action_stop, substream, state)
	|
	|-> substream->ops->hw_free(substream)
	|-> substream->ops->close(substream)
```

## control设备


## codec


## 数据路由


## amixer的设置

## 调试

ASoC添加了debugfs和ftrace的调试支持。

``` shell
mount -t debugfs none /mnt/

# cat available_events | grep "asoc"
asoc:snd_soc_cache_sync
asoc:snd_soc_jack_notify
asoc:snd_soc_jack_report
asoc:snd_soc_jack_irq
asoc:snd_soc_dapm_connected
asoc:snd_soc_dapm_input_path
asoc:snd_soc_dapm_output_path
asoc:snd_soc_dapm_walk_done
asoc:snd_soc_dapm_widget_event_done
asoc:snd_soc_dapm_widget_event_start
asoc:snd_soc_dapm_widget_power
asoc:snd_soc_dapm_done
asoc:snd_soc_dapm_start
asoc:snd_soc_bias_level_done
asoc:snd_soc_bias_level_start
asoc:snd_soc_preg_read
asoc:snd_soc_preg_write
asoc:snd_soc_reg_read
asoc:snd_soc_reg_write
```

* 在DEBUGFS下，可以查看一个各个组件及widgets的状态。
* 在FTRACE下，`echo asoc > tracing/set_event`打开调试，就可以`cat /mnt/tracing/trace`查看widget的上下电顺序， 通路的切换等。

## 性能

### 频响

>频率响应 简称频响，英文名称是`Frequency Response`，在电子学上用来描述一台仪器对于不同频率的信号的处理能力的差异。

### 扫频

>利用正弦波信号的频率随时间在一定范围内反复扫描
