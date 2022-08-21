---
layout: post
title: Linux死锁检测——Lockdep
date: '2022-06-21 17:05'
tags:
  - linux
  - lock
  - 死锁
  - 进程
categories:
  - Linux内核
  - 同步
abbrlink: 1a6384db
---

`Lockdep`是内核提供协助发现死锁问题的功能，主要是跟踪每个锁的自身状态和各个锁之间的依赖关系，经过一系列的验证规则来确保锁之间依赖关系是正确的。

`Lockdep`检测的锁包括`spinlock`、`rwlock`、`mutex`、`rwsem`的死锁，锁的错误释放，原子操作中睡眠等错误行为。

```
Kernel hacking  --->
  Lock Debugging (spinlocks, mutexes, etc...)  --->
    [*] Lock debugging: prove locking correctness
    [ ] Lock usage statistics
    -*- RT Mutex debugging, deadlock detection
    -*- Spinlock and rw-lock debugging: basic checks
    -*- Mutex debugging: basic checks
    -*- Wait/wound mutex debugging: Slowpath testing
    -*- RW Semaphore debugging: basic checks
    -*- Lock debugging: detect incorrect freeing of live locks
    [*] Lock dependency engine debugging
    [ ] Sleep inside atomic section checking
    [ ] Locking API boot-time self-tests
    < > torture tests for locking
    < > Wait/wound mutex selftests
```

<!--more-->

## 内核配置说明

- CONFIG_DEBUG_RT_MUTEXES=y
  - 检测rt mutex的死锁，并自动报告死锁现场信息。

- CONFIG_DEBUG_SPINLOCK=y
  - 检测spinlock的未初始化使用等问题。配合NMI watchdog使用，能发现spinlock死锁。

- CONFIG_DEBUG_MUTEXES=y
  - 检测并报告mutex错误

- CONFIG_DEBUG_WW_MUTEX_SLOWPATH=y
  - 检测wait/wound类型mutex的slowpath测试。

- CONFIG_DEBUG_LOCK_ALLOC=y
  - 检测使用中的锁(spinlock/rwlock/mutex/rwsem)被释放，或者使用中的锁被重新初始化，或者在进程退出时持有锁。

- CONFIG_PROVE_LOCKING=y
  - 使内核能在死锁发生前报告死锁详细信息。参见/proc/lockdep_chains。

- CONFIG_LOCKDEP=y
 - 整个Lockdep的总开关。参见/proc/lockdep、/proc/lockdep_stats。

- CONFIG_LOCK_STAT=y
  - 记锁持有竞争区域的信息，包括等待时间、持有时间等等信息。参见/proc/lock_stat。

- CONFIG_DEBUG_LOCKDEP=y
  - 会对Lockdep的使用过程中进行更多的自我检测，会增加很多额外开销。

- CONFIG_DEBUG_ATOMIC_SLEEP=y
  - 在atomic section中睡眠可能造成很多不可预测的问题，这些atomic section包括spinlock持锁、rcu读操作、禁止内核抢占部分、中断处理中等等。


## 死锁

`死锁`是指多个进程（线程）因为长时间等待已被其他进程（线程）占有的的资源而陷入阻塞的一种状态。

当等待的资源一直得不到释放，死锁会一直持续下去。死锁一旦发生，程序本身是解决不了的，只能依靠外部力量使得程序恢复运行，例如重启，开门狗复位等

Linux 提供了检测死锁的机制，主要分为`D状态死锁`和`R状态死锁`。

- D状态死锁

  进程等待I/O资源无法得到满足，长时间（系统默认配置 120 秒）处于TASK_UNINTERRUPTIBLE睡眠状态，这种状态下进程不响应异步信号（包括 kill -9）。如：进程与外设硬件的交互（如 read），通常使用这种状态来保证进程与设备的交互过程不被打断，否则设备可能处于不可控的状态。对于这种死锁的检测Linux提供的是hung task机制，MTK也提供hang detect机制来检测Android系统 hang 机问题。触发该问题成因比较复杂多样，可能因为 synchronized_irq、mutex lock、内存不足等。D 状态死锁只是局部多进程间互锁，一般来说只是 hang 机、冻屏，机器某些功能没法使用，但不会导致没喂狗，而被狗咬死。

  内核D状态死锁检测就是`hung_task机制`，主要代码就在kernel/hung_task.c文件。

- R状态死锁

  进程长时间（系统默认配置 60 秒）处于TASK_RUNNING状态垄断CPU而不发生切换，一般情况下是进程`关抢占`或`关中断`后长时候执行任务、死循环，此时往往会导致多CPU间互锁，整个系统无法正常调度，导致喂狗线程无法执行，无法喂狗而最终看门狗复位的重启。该问题多为原子操作，spinlock等CPU间并发操作处理不当造成。

  内核R状态死锁检测机制就是`lockdep机制`，入口即是lockup_detector_init函数


## lockdep

死锁:指两个或多个进程因争夺资源而造成的互相等待的现象。

常见的死锁有如下两种：

- `递归死锁`：中断等延迟操作中使用了锁，和外面的锁构成了递归死锁。
- `AB-BA死锁`：多个锁因处理不当而引发死锁，多个内核路径上的所处理顺序不一致也会导致死锁。


## Runtime locking correctness validator（运行时锁的正确性验证器）

> https://www.kernel.org/doc/html/latest/locking/lockdep-design.html





## 实际示例

在ioctl调用的函数路径中的__snd_pcm_lib_xfer接口函数中使用了spinlock锁，而在其接口的更下一级接口中使用了msleep，导致锁的状态不一致。


```
# arecord -D hw:3,0 -d 5 -r 48000 -f S16_LE -c 2 -t wav /tmp/aaa.wav
Recording WAVE '/tmp/aaa.wav' : Signed 16 bit Little Endian, Rate 48000 Hz, Stereo
[   41.781083]
[   41.782590] ================================
[   41.786859] WARNING: inconsistent lock state
[   41.791131] 5.4.197-00339-g5ce0e26a142d-dirty #80 Not tainted
[   41.796875] --------------------------------
[   41.801145] inconsistent {SOFTIRQ-ON-W} -> {IN-SOFTIRQ-W} usage.
[   41.807152] swapper/0/0 [HC0[0]:SC1[1]:HE0:SE0] takes:
[   41.812290] ffffff801ece85a0 (&(&group->lock)->rlock){+.?.}, at: _snd_pcm_stream_lock_irqsave+0x4c/0x50
[   41.821696] {SOFTIRQ-ON-W} state was registered at:
[   41.826581]   lockdep_hardirqs_on+0x198/0x1a8
[   41.830943]   trace_hardirqs_on+0x78/0x88
[   41.834957]   _raw_spin_unlock_irq+0x44/0x54
[   41.839229]   finish_task_switch+0x130/0x1b8
[   41.843501]   __schedule+0x534/0x674
[   41.847078]   schedule+0x74/0x98
[   41.850309]   schedule_timeout+0xd4/0xf4
[   41.854234]   schedule_timeout_uninterruptible+0x30/0x3c
[   41.859549]   msleep+0x3c/0x40
[   41.862610]   es8311_pcm_trigger+0x54/0x68
[   41.866708]   snd_soc_dai_trigger+0x48/0x60
[   41.870894]   soc_pcm_trigger+0xbc/0xe8
[   41.874733]   snd_pcm_do_start+0x3c/0x50
[   41.878658]   snd_pcm_action_single+0x50/0x88
[   41.883017]   snd_pcm_action+0x80/0x84
[   41.886768]   snd_pcm_start+0x34/0x40
[   41.890434]   __snd_pcm_lib_xfer+0x1a4/0x618
[   41.894705]   snd_pcm_common_ioctl+0xa88/0xbd8
[   41.899149]   snd_pcm_ioctl+0x4c/0x68
[   41.902815]   vfs_ioctl+0x5c/0x6c
[   41.906132]   do_vfs_ioctl+0xc0/0x6d8
[   41.909796]   ksys_ioctl+0x54/0x84
[   41.913199]   __arm64_sys_ioctl+0x2c/0x60
[   41.917212]   el0_svc_common.constprop.0+0xac/0x140
[   41.922090]   el0_svc_handler+0x94/0xa0
[   41.925928]   el0_svc+0x8/0x640
[   41.929070] irq event stamp: 109041
[   41.932563] hardirqs last  enabled at (109040): [<ffffffc010a5874c>] _raw_spin_unlock_irqrestore+0x74/0x80
[   41.942216] hardirqs last disabled at (109041): [<ffffffc010a58420>] _raw_spin_lock_irqsave+0x30/0x74
[   41.951437] softirqs last  enabled at (109034): [<ffffffc0100b6da4>] _local_bh_enable+0x30/0x38
[   41.960135] softirqs last disabled at (109035): [<ffffffc0100b7570>] irq_exit+0xac/0x10c
[   41.968222]
[   41.968222] other info that might help us debug this:
[   41.974747]  Possible unsafe locking scenario:
[   41.974747]
[   41.980664]        CPU0
[   41.983110]        ----
[   41.985555]   lock(&(&group->lock)->rlock);
[   41.989740]   <Interrupt>
[   41.992360]     lock(&(&group->lock)->rlock);
[   41.996718]
[   41.996718]  *** DEADLOCK ***
[   41.996718]
[   42.002628] no locks held by swapper/0/0.
[   42.006636]
[   42.006636] stack backtrace:
[   42.010996] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 5.4.197-00339-g5ce0e26a142d-dirty #80
[   42.019343] Hardware name: Van_xum Tequila Evaluation Board (DT)
[   42.025261] Call trace:
[   42.027714]  dump_backtrace+0x0/0x164
[   42.031377]  show_stack+0x28/0x34
[   42.034695]  dump_stack+0xd0/0x134
[   42.038100]  print_usage_bug+0x1b0/0x1c8
[   42.042024]  mark_lock+0x1b8/0x278
[   42.045428]  __lock_acquire+0x360/0xda8
[   42.049265]  lock_acquire+0x164/0x194
[   42.052930]  _raw_spin_lock_irqsave+0x58/0x74
[   42.057291]  _snd_pcm_stream_lock_irqsave+0x4c/0x50
[   42.062170]  snd_pcm_period_elapsed+0x2c/0xa8
[   42.066529]  dmaengine_pcm_dma_complete+0x6c/0x78
[   42.071236]  dmaengine_desc_callback_invoke.constprop.0+0x5c/0x68
[   42.077330]  dw_dma_tasklet+0x1b0/0x420
[   42.081169]  tasklet_action_common.constprop.0+0xb8/0x11c
[   42.086569]  tasklet_action+0x34/0x40
[   42.090232]  __do_softirq+0x2d4/0x3f4
[   42.093896]  irq_exit+0xac/0x10c
[   42.097128]  __handle_domain_irq+0x7c/0xa8
[   42.101226]  gic_handle_irq+0x84/0xc8
[   42.104890]  el1_irq+0xbc/0x140
[   42.108034]  arch_cpu_idle+0x44/0x64
[   42.111613]  default_idle_call+0x34/0x38
[   42.115538]  do_idle+0x144/0x27c
[   42.118770]  cpu_startup_entry+0x2c/0x48
[   42.122694]  rest_init+0x170/0x180
[   42.126100]  arch_call_rest_init+0x18/0x20
[   42.130199]  start_kernel+0x458/0x490


^CAborted by signal Interrupt...
```

## 参考

- [Documentation/locking/](https://www.kernel.org/doc/html/latest/locking/index.html)
- [Linux 死锁检测模块 Lockdep 简介](http://kernel.meizu.com/linux-dead-lock-detect-lockdep.html)
