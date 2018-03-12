
title: Audio驱动总结--ALSA
date: 2017-07-10 23:07:24
categories: 设备驱动
tags: [Audio, alsa, 驱动]
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


## alsa

在内核设备驱动层，ALSA提供了alsa-driver，同时在应用层，ALSA为我们提供了alsa-lib，应用程序只要调用alsa-lib提供的API，即可以完成对底层音频硬件的控制。

![alsa-struct](/images/audio/alsa/alsa-struct.png)


### ASOC

ASoC被分为`Machine`、`Platform`和`Codec`三大部分。其中的Machine驱动负责Platform和Codec之间的耦合和设备或板子特定的代码。Platform驱动的主要作用是完成音频数据的管理，最终通过CPU的数字音频接口（DAI）把音频数据传送给Codec进行处理，最终由Codec输出驱动耳机或者是喇叭的音信信号。


#### machine

用于描述设备组件信息和特定的控制如耳机/外放等。

>是指某一款机器，可以是某款设备，某款开发板，又或者是某款智能手机，由此可以看出Machine几乎是不可重用的，每个Machine上的硬件实现可能都不一样，CPU不一样，Codec不一样，音频的输入、输出设备也不一样，Machine为CPU、Codec、输入输出设备提供了一个`载体`。

#### Platform

用于实现平台相关的DMA驱动和音频接口等。

> 一般是指某一个SoC平台，比如pxaxxx,s3cxxxx,omapxxx等等，与音频相关的通常包含该SoC中的时钟、DMA、I2S、PCM等等，只要指定了SoC，那么我们可以认为它会有一个对应的Platform，它只与SoC相关，与Machine无关，这样我们就可以把Platform抽象出来，使得同一款SoC不用做任何的改动，就可以用在不同的Machine中。实际上，把Platform认为是某个SoC更好理解。

#### Codec

用于实现平台无关的功能，如寄存器读写接口，音频接口，各widgets的控制接口和DAPM的实现等

> 字面上的意思就是编解码器，Codec里面包含了I2S接口、D/A、A/D、Mixer、PA（功放），通常包含多种输入（Mic、Line-in、I2S、PCM）和多个输出（耳机、喇叭、听筒，Line-out），Codec和Platform一样，是可重用的部件，同一个Codec可以被不同的Machine使用。嵌入式Codec通常通过I2C对内部的寄存器进行控制。

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
* 在FTRACE下，`echo asoc > tracing/set_event`打开调试，就可以查看widget的上下电顺序， 通路的切换等。

## 性能

### 频响

>频率响应 简称频响，英文名称是`Frequency Response`，在电子学上用来描述一台仪器对于不同频率的信号的处理能力的差异。

### 扫频

>利用正弦波信号的频率随时间在一定范围内反复扫描



