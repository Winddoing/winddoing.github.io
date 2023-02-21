---
title: ALSA-xrun
categories:
  - 设备驱动
  - 音频
tags:
  - audio
  - alsa
  - 驱动
abbrlink: bf06e0bf
date: 2017-07-16 23:07:24
---

`overrun`和`underrun`通过snd_pcm_period_elapsed()接口进行控制

流程: stop->start->stop->start->


<!--more-->

### overrun

在录音时由于录音数据过快会产生overrun现象

### underrun

在放音时由于用户层的音频数据到DDR中的速度比控制放的速度满,出现underrun


## snd_pcm_period_elapsed正常更新位置

正常录音: 应用层使用poll的调用关系

``` C
snd_pcm_period_elapsed
    |
    |-> snd_pcm_update_hw_ptr0
        |
        |-> pos = substream->ops->pointer(substream); // 回调pladform中的.pointer接口
        |
        |-> snd_pcm_update_state
            |-> snd_pcm_capture_avail
            |-> wake_up(&runtime->sleep);
```

## read进程

**overrun以后不能通过wakeup唤醒, 正常要通过wake_up(&runtime->sleep)唤醒什么?**

通过wake_up(&runtime->sleep)唤醒核心层core中的`read`进程

### read进程的由来

``` C
用户空间      arecord -f cd 1.wav  --- 产生read进程

           ioctl - SNDRV_PCM_IOCTL_READI_FRAMES
                        |
-------------------------------------------------
                        |
内核空间        snd_pcm_capture_ioctl
```


### 内核空间的数据处理


数据的调用关系:
``` C
snd_pcm_capture_ioctl
    |-> snd_pcm_capture_ioctl1
        |-> snd_pcm_lib_read (SNDRV_PCM_IOCTL_READI_FRAMES)
            |-> snd_pcm_lib_read1
                |-> snd_pcm_capture_avail
                |------> wait_for_avail
                |-> transfer(substream, appl_ofs, data, offset, frames)
```

wait_for_avail的实现逻辑:

``` C
wait_for_avail
    |-> init_waitqueue_entry(&wait, current);
    |-> set_current_state(TASK_INTERRUPTIBLE);
    |-> add_wait_queue(&runtime->tsleep, &wait);
    |
    |-> for(;;)
        |-> signal_pending(current)
        |//wait_time等待时间和具体的采样率相关
        |-> tout = schedule_timeout(wait_time);    //等待数据处理
        |-> 上报用户空间当前stream流的状态
```

### sleep队列的工作


通过打印调试信息可以判断在使用`snd_pcm_period_elapsed`更新位置信息后,是通过`wake_up(&runtime->sleep)`将当前进程唤醒

> 什么时候对sleep队列进行的初始化,什么时候将当前进程加入的sleep队列

1. 初始化

``` C
snd_pcm_capture_open
    |-> snd_pcm_open
        |-> snd_pcm_open_file
            |-> snd_pcm_open_substream
                |-> snd_pcm_attach_substream
                    |-> init_waitqueue_head(&runtime->sleep);
```

2. 将当前进程加入sleep队列

``` C
.poll =         snd_pcm_capture_poll
    |->  poll_wait(file, &runtime->sleep, wait); //将进程添加到sleep队列

```
> poll()该接口用户空间arecord应用有调用


3. poll的作用;

* **判断该文件是否可读**
* **将该进程挂到等待队列中**


### read进程的控制机制

通过源码中的wakeup可以判断对read进程的唤醒存在两种方式

``` C
 if (runtime->twake) {
     if (avail >= runtime->twake)
         wake_up(&runtime->tsleep); //核心层自己维护
 } else if (avail >= runtime->control->avail_min)
     wake_up(&runtime->sleep);    //通过poll机制实现
```

通过核心层core中自己控制(唤醒)read进程,必须`runtime->twake=1`

``` C
1. snd_pcm_lib_read1
    |-> runtime->twake = runtime->control->avail_min ? : 1;

2. snd_pcm_hw_params
    |-> runtime->period_size = params_period_size(params);
    |-> runtime->control->avail_min = runtime->period_size;

3. params_period_size(params)
    |-> 解析用户空间参数SNDRV_PCM_HW_PARAM_PERIOD_SIZE

4. arecord参数选项:
    --period-size=#     distance between interrupts is # frames
```

## stop

> 出现overrun或underrun后,alsa什么时候在那进行stop

### 时间

在对每个DMA描述符进行处理时,也就是DMA描述符中断的callback中.

### 位置

``` C
snd_pcm_period_elapsed()
```
> sound/core/pcm_lib.c

> Description:
> This function is called from the interrupt handler when the PCM has processed the period size. It will update the current pointer, set up the tick, wake up sleepers, etc.
> Even if more than one periods have elapsed since the last call, you have to call this only once.

作用: 通知缓冲区空闲（对应回放）或者有效（对应录音）


### 条件

实现逻辑: 主要以`overrun`为例

``` C
snd_pcm_period_elapsed
    |
    |-> snd_pcm_update_hw_ptr0
        |
        |-> pos = substream->ops->pointer(substream); // 回调pladform中的.pointer接口
            if (pos == SNDRV_PCM_POS_XRUN) {   // SNDRV_PCM_POS_XRUN = -1
                xrun(substream);
                return -EPIPE;  // EPIPE --  Broken pipe
            }
        |-> 更新指针(hw_ptr_base,hw_ptr_interrupt, status->hw_ptr), (hw_ptr_jiffies)
        |-> snd_pcm_update_state
            |
            |-> snd_pcm_playback_avail(/snd_pcm_capture_avail) //得到录放有效数据大小
            |--> snd_pcm_drain_done() // state == SNDRV_PCM_STATE_DRAINING
```

> 当`pos == SNDRV_PCM_POS_XRUN`时,出现overrun

### 出现overrun后的处理

``` C
xrun
  |-> snd_pcm_stop(substream, SNDRV_PCM_STATE_XRUN);
```


## start

> 出现overrun或underrun, 并且数据准备完成后,alsa什么时候在那进行start


### 时间


### 位置
