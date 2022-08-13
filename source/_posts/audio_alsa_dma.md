---
title: ALSA-DMA
categories:
  - 设备驱动
  - 音频
tags:
  - audio
  - alsa
  - 驱动
date: 2017-07-11 23:07:24
---


>dma数据传输块的组织和应用

<!-- more --->

## 数据类型

``` C
/*                                                                                         
 * info for buffer allocation                                                              
 */                                                                                        
struct snd_dma_buffer {                                                                    
    struct snd_dma_device dev;  /* device type */                                          
    unsigned char *area;    /* virtual pointer */                                          
    dma_addr_t addr;    /* physical address */                                             
    size_t bytes;       /* buffer size in bytes */                                         
    void *private_data; /* private for allocator; don't touch */                           
};                                                                                         
```

## 申请

在通过machine将每一条声卡链路建立完成后.将通过`pcm_new`申请dma_buffer

### 申请当前的stream支持的最大的DMA buffer内存空间.

``` C
snd_pcm_lib_preallocate_pages_for_all(pcm, SNDRV_DMA_TYPE_DEV,       
    card->dev, buffer_size, buffer_bytes_max);                       
```
>dma buffer获得后，即是获得了dma操作的源地址，那么目的地址在哪里？

### 实际使用的DMA buffer空间大小,跟实际的采样率,位宽,通道有关.

``` C
snd_pcm_lib_malloc_pages(substream, params_buffer_bytes(params));
```

## DMA buffer的管理

环形缓冲区正好适合用于这种情景的buffer管理，理想情况下，大小为Count的缓冲区具备一个读指针和写指针，我们期望他们都可以闭合地做环形移动，但是实际的情况确实：缓冲区通常都是一段连续的地址，他是有开始和结束两个边界，每次移动之前都必须进行一次判断，当指针移动到末尾时就必须人为地让他回到起始位置。在实际应用中，我们通常都会把这个大小为Count的缓冲区虚拟成一个大小为n*Count的逻辑缓冲区，相当于理想状态下的圆形绕了n圈之后，然后把这段总的距离拉平为一段直线，每一圈对应直线中的一段，因为n比较大，所以大多数情况下不会出现读写指针的换位的情况（如果不对buffer进行扩展，指针到达末端后，回到起始端时，两个指针的前后相对位置会发生互换）。扩展后的逻辑缓冲区在计算剩余空间可条件判断是相对方便。alsa driver也使用了该方法对dma buffer进行管理：

![rang buffer]()


1. Period size：周期，每次硬件中断处理音频数据的帧数，对于音频设备的数据读写，以此为单位。

2. Buffer size：数据缓冲区大小，这里特指runtime的buffer size，而不是snd_pcm_hardware定义的buffer_bytes_max。
一般来说Buffer size = period_size * period_count(periods)，**period_count相当于处理完一个buffer数据所需的硬件中断次数(在DMA传输中,相当于DMA描述符的个数)。**

大小:
``` C
runtime->period_size = params_period_size(params);    
runtime->periods = params_periods(params);            
runtime->buffer_size = params_buffer_size(params);
```

> period_size的大小确认为,sample_rate / channel / frame Byte
> frame = channel*bit/8 Byte

`snd_pcm_runtime`结构中，使用了四个相关的字段来完成这个逻辑缓冲区的管理：

* `snd_pcm_runtime.hw_ptr_base`  环形缓冲区每一圈的基地址，当读写指针越过一圈后，它按buffer size进行移动；
* `snd_pcm_runtime.status->hw_ptr`  硬件逻辑位置，播放时相当于读指针，录音时相当于写指针；
* `snd_pcm_runtime.control->appl_ptr`  应用逻辑位置，播放时相当于写指针，录音时相当于读指针；
* `snd_pcm_runtime.boundary`  扩展后的逻辑缓冲区大小，通常是(2^n)*size；







### 播放

以播放(playback)为例，至少有3个途径可以完成对dma buffer的写入：

1. 应用程序调用alsa-lib的snd_pcm_writei、snd_pcm_writen函数；
2. 应用程序使用ioctl：SNDRV_PCM_IOCTL_WRITEI_FRAMES或SNDRV_PCM_IOCTL_WRITEN_FRAMES；
3. 应用程序使用alsa-lib的snd_pcm_mmap_begin/snd_pcm_mmap_commit;

以上几种方式最终把数据写入dma buffer中，然后修改runtime->control->appl_ptr的值。

播放过程中，通常会配置成每一个period size生成一个dma中断，中断处理函数最重要的任务就是：更新dma的硬件的当前位置，该数值通常保存在runtime->private_data中；
调用`snd_pcm_period_elapsed`函数，该函数会进一步调用`snd_pcm_update_hw_ptr0`函数更新上述所说的4个缓冲区管理字段，然后**唤醒相应的等待进程**；


三个指针


## snd_psnd_pcm_period_elapsed




## 驱动控制器层的数据关系

* buffer大小: snd_pcm_lib_buffer_bytes(substream) = 32768 = 32KB
* period : snd_pcm_lib_period_bytes(substream) = 8192 = 8KB
* DMA描述符的个数: snd_pcm_lib_buffer_bytes(substream) / snd_pcm_lib_period_bytes(substream) = 4

## 设置运行时的硬件参数

>snd_soc_set_runtime_hwparams



## DMA buffer 大小


**DMA buffer的大小必须时frame和dma burst的倍数,也就是二者大最小公倍数的倍数**

限制buffer的大小关系,当然最特定的播放条件可以通过手动设置buffer最大值和周期的大小进行设置.

根本性的解决

### 数据结构

```
struct snd_interval {                      
    unsigned int min, max;  //最小,最大值               
    unsigned int openmin:1, //最小值的开区间,使能,默认闭区间               
             openmax:1,                    
             integer:1,     //使能后取范围内的整数               
             empty:1;                      
};                                         
```

### 实现
```
int xxx_open()
{

 ret = snd_pcm_hw_constraint_integer(runtime, SNDRV_PCM_HW_PARAM_PERIOD_BYTES);                
 if (ret < 0)                                                                                  
     return ret;                                                                               

 if (as_dma->dma_fth_quirk) {                                                                  
     snd_pcm_hw_rule_add(substream->runtime, 0,                                                
             SNDRV_PCM_HW_PARAM_PERIOD_BYTES,                                                  
             ingenic_as_dma_period_bytes_quirk,                                                
             NULL,                                                                             
             SNDRV_PCM_HW_PARAM_FRAME_BITS,                                                    
             SNDRV_PCM_HW_PARAM_PERIOD_BYTES,                                                  
             -1);                                                                              
 }
}                                                                                             
```

```
static int ingenic_as_dma_period_bytes_quirk(struct snd_pcm_hw_params *params,                               
        struct snd_pcm_hw_rule *rule)                                                                        
{                                                                                                            
    struct snd_interval *iperiod_bytes = hw_param_interval(params,                                           
            SNDRV_PCM_HW_PARAM_PERIOD_BYTES);                                                                
    struct snd_interval *iframe_bits = hw_param_interval(params,                                             
            SNDRV_PCM_HW_PARAM_FRAME_BITS);                                                                  
    int align_bytes = DCM_TSZ_MAX_WORD << 2; //32 world                                                                
    int min_frame_bytes = iframe_bits->min >> 3;                                                             
    int max_frame_bytes = iframe_bits->max >> 3;                                                             
    int min_period_bytes = iperiod_bytes->min;                                                               
    int max_period_bytes = iperiod_bytes->max;                                                               
    int min_align_bytes, max_align_bytes;                                                                    
    struct snd_interval nperiod_bytes;                                                                       

    snd_interval_any(&nperiod_bytes);                                                                        
    min_align_bytes = lcm(align_bytes, min_frame_bytes);                                                     
    min_period_bytes = (min_period_bytes + min_align_bytes - 1) / min_align_bytes;                           
    nperiod_bytes.min = min_period_bytes * min_align_bytes;                                                  

    max_align_bytes = lcm(align_bytes, max_frame_bytes);                                                     
    max_period_bytes = max_period_bytes / max_align_bytes;                                                   
    nperiod_bytes.max = max_period_bytes * max_align_bytes;                                                  

    DMA_DEBUG_MSG("==> %s %d : align_bytes = %d \n\                                                          
            frame_bytes.min (%d)\t\tframe_bytes.max (%d) \n\                                                 
            period_bytes.min  [%d]\tperiod_bytes.max  [%d] \n\                                               
            nperiod_bytes.min [%d]\tnperiod_bytes.max [%d]\n",                                               
            __func__, __LINE__, align_bytes,                                                                 
            min_frame_bytes, max_frame_bytes, iperiod_bytes->min,                                            
            iperiod_bytes->max, nperiod_bytes.min, nperiod_bytes.max);                                       
    return snd_interval_refine(iperiod_bytes, &nperiod_bytes);                                               
}                                                                                                            
```

### 调用过程

```
int snd_pcm_hw_refine(struct snd_pcm_substream *substream,                
              struct snd_pcm_hw_params *params)                           
{                                                                         
    ...
    changed = r->func(params, r);        
    ...
}
```
> sound/core/pcm_native.c








## 参考

1. [内核Alsa之pcm](http://kuafu80.blog.163.com/blog/static/12264718020148511458729/)
2. [ALSA lib基本概念](http://www.cnblogs.com/fellow1988/p/6195233.html)
