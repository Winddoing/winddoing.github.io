---
title: Hung Task
date: 2018-03-15 23:07:24
categories: Linux内核
tags: [Task]
---


```
[10505.024599] INFO: task ps:26540 blocked for more than 120 seconds.
[10505.199520] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[10507.707796] ps              D 804059d4     0 26540    110 0x00100000
[10510.574054] Stack : 00000000 8ba75900 807d2ff0 8008c99c 8052c27c 8057e800 00000003 880022

	8ba75900 80402e34 880180a0 00000001 880180a4 80580000 804bac00 8ba75900
	804be4ec 880180c4 80ab0000 804059d4 ffffff69 8ba75900 004bb030 880180a0
	00000001 80402dc8 8aa7cb80 00000001 8a531df8 800f6b3c 00000002 00000000
	800f7c84 8a531df8 8bc8bd60 880180c4 8ba75900 8a531d00 8a531df8 00000001
	...
[10530.536867] Call Trace:
[10532.061092] [<80405324>] __schedule+0x5d4/0x814
[10533.833196] [<804059d4>] schedule_preempt_disabled+0x18/0x30
[10535.744720] [<80402dc8>] mutex_lock_nested+0x264/0x468
[10537.733761] [<800f7c84>] lookup_slow+0x44/0xd4
[10539.417797] [<800f9590>] path_lookupat+0x13c/0x804
[10541.347068] [<800f9c8c>] filename_lookup.isra.10+0x34/0xa0
[10543.326101] [<800fbd70>] user_path_at_empty+0x60/0xa0
[10545.166088] [<800fbdc4>] user_path_at+0x14/0x20
[10546.921821] [<800f1fe8>] vfs_fstatat+0x64/0xc4
[10548.672953] [<800f25a4>] SyS_stat64+0x18/0x3c
[10550.256996] [<800250b4>] stack_done+0x20/0x44
[10551.912049]
[10552.654893] 1 lock held by ps/26540:
[10553.986958]  #0:  (&sb->s_type->i_mutex_key){+.+.+.}, at: [<800f7c84>] lookup_slow+0x44/0xd4
```

<!--more-->

>Detecting hung tasks in Linux

>Sometimes tasks under Linux are blocked forever (essentially hung). Recent Linux kernels have an infrastructure to detect hung tasks. When this infrastructure is active it will periodically get activated to find out hung tasks and present a stack dump of those hung tasks (and maybe locks held). Additionally we can choose to panic the system when we detect atleast one hung task in the system. I will try to explain how khungtaskd works.

>The infrastructure is based on a single kernel thread named as “khungtaskd”. So if you do a ps in your system and see that there is entry like [khungtaskd] you know it is there. I have one in my system: "136 root SW [khungtaskd]"

>The loop of the khungtaskd daemon is a call to the scheduler for waking it up after ever 120 seconds (default value). The core algorithm is like this:

>1. Iterate over all the tasks in the system which are marked as `TASK_UNINTERRUPTIBLE` (additionally it does not consider UNINTERRUPTIBLE frozen tasks & UNINTERRUPTIBLE tasks that are newly created and never been scheduled out).

>2. If a task has not been switched out by the scheduler atleast once in the last 120 seconds it is considered as a hung task and its stack dump is displayed. If CONFIG_LOCKDEP is defined then it will also show all the locks the hung task is holding.

>One can change the sampling interval of khungtaskd through the sysctl interface `/proc/sys/kernel/hung_task_timeout_secs`.

该现象是内核的保护机制造成, D状态即无法中断的休眠进程，是由于在等待IO，比如磁盘IO，网络IO，其他外设IO，如果进程正在等待的IO在较长的时间内都没有响应.

检测每一个进程控制块；当进程处于TASK_UNINTERRUPTIBLE状态时，调用check_hung_task；
内核通过khungtaskd线程在`hung_task_timeout_secs`时间内唤醒，并检测每一个进程控制块，判断该进程是否挂起(TASK_UNINTERRUPTIBLE),如果存在挂起的任务，将调用`check_hung_task`。

## 错误日志输出原因：

通过栈的dump信息，可以得到出错的主要原因是由于`SyS_stat64`系统调用引起。在C语言库里的函数是stat, fstat, lstat. 获取文件的状态。

```
$man stat64
NAME
       stat, fstat, lstat - get file status
DESCRIPTION
       These  functions  return  information about a file.  No permissions are required on the file itself, but—in the case of stat() and lstat() — execute (search) permission is required on all of the  directories  in  path  that lead to the file.
```

## 产生的原因

- IO阻塞
- 内核模块出错

## amdgpu

```
23:02:20 localhost.localdomain kernel: amdgpu 0001:01:00.0: GPU fault detected: 146 0x0080442c
23:02:20 localhost.localdomain kernel: amdgpu 0001:01:00.0:   VM_CONTEXT1_PROTECTION_FAULT_ADDR   0x00101A10
23:02:20 localhost.localdomain kernel: amdgpu 0001:01:00.0:   VM_CONTEXT1_PROTECTION_FAULT_STATUS 0x0804402C
23:02:20 localhost.localdomain kernel: amdgpu 0001:01:00.0: VM fault (0x2c, vmid 4) at page 1055248, read from 'TC1' (0x54433100) (68)
23:02:34 localhost.localdomain kernel: amdgpu 0001:01:00.0: GPU fault detected: 146 0x00183d0c
23:02:34 localhost.localdomain kernel: amdgpu 0001:01:00.0:   VM_CONTEXT1_PROTECTION_FAULT_ADDR   0x00101A03
23:02:34 localhost.localdomain kernel: amdgpu 0001:01:00.0:   VM_CONTEXT1_PROTECTION_FAULT_STATUS 0x0A03D00C
23:02:34 localhost.localdomain kernel: amdgpu 0001:01:00.0: VM fault (0x0c, vmid 5) at page 1055235, read from 'SDM1' (0x53444d31) (61)
23:05:11 localhost.localdomain kernel: INFO: task qemu-system-aar:8361 blocked for more than 120 seconds.
23:05:11 localhost.localdomain kernel:       Tainted: G        W      ------------   4.14.0-115.10.1.el7a.aarch64 #1
23:05:11 localhost.localdomain kernel: "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
23:05:11 localhost.localdomain kernel: qemu-system-aar D    0  8361  30794 0x00000200
23:05:11 localhost.localdomain kernel: Call trace:
23:05:11 localhost.localdomain kernel: [<ffff000008085eb4>] __switch_to+0x8c/0xa8
23:05:11 localhost.localdomain kernel: [<ffff00000885f9f0>] __schedule+0x340/0x914
23:05:11 localhost.localdomain kernel: [<ffff00000885fff8>] schedule+0x34/0x8c
23:05:11 localhost.localdomain kernel: [<ffff000005aac1f8>] amd_sched_entity_push_job+0x98/0x148 [amdgpu]
23:05:11 localhost.localdomain kernel: [<ffff000005aacfa4>] amdgpu_job_submit+0x88/0xa4 [amdgpu]
23:05:11 localhost.localdomain kernel: [<ffff000005a233ac>] amdgpu_vm_bo_update_mapping.constprop.21+0x2b0/0x354 [amdgpu]
23:05:11 localhost.localdomain kernel: [<ffff000005a23b38>] amdgpu_vm_clear_freed+0xc8/0x1d0 [amdgpu]
23:05:11 localhost.localdomain kernel: [<ffff000005a0efe8>] amdgpu_gem_va_ioctl+0x400/0x478 [amdgpu]
23:05:11 localhost.localdomain kernel: [<ffff0000057b63c4>] drm_ioctl_kernel+0x74/0xd8 [drm]
23:05:11 localhost.localdomain kernel: [<ffff0000057b6710>] drm_ioctl+0x2b4/0x3ec [drm]
23:05:11 localhost.localdomain kernel: [<ffff0000059f0054>] amdgpu_drm_ioctl+0x54/0x90 [amdgpu]
23:05:11 localhost.localdomain kernel: [<ffff0000082c2ee8>] do_vfs_ioctl+0xcc/0x8f0
23:05:11 localhost.localdomain kernel: [<ffff0000082c379c>] SyS_ioctl+0x90/0xa4
23:05:11 localhost.localdomain kernel: Exception stack(0xffff0000379cfec0 to 0xffff0000379d0000)
23:05:11 localhost.localdomain kernel: fec0: 0000000000000014 00000000c0286448 0000fffffb7cfbb0 00000000c0286400
23:05:11 localhost.localdomain kernel: fee0: 00000000c0006400 000000000000000e 0000000000000002 0000000000410000
23:05:11 localhost.localdomain kernel: ff00: 000000000000001d 0000000017a53200 0000000000000289 000000002e6d71d2
23:05:11 localhost.localdomain kernel: ff20: 0000000000000018 000000005d731dca 0021ee150a5f677c 0000e05d5e15bff7
23:05:11 localhost.localdomain kernel: ff40: 0000ffffa16802a8 0000ffffa17660e0 0000000000000a00 0000ffff9c81f000
23:05:11 localhost.localdomain kernel: ff60: 0000fffffb7cfbb0 00000000c0286448 0000000000000014 0000000000000040
23:05:11 localhost.localdomain kernel: ff80: 0000000017a53818 000000001ad84f30 00000000000003e8 0000000017a53858
23:05:11 localhost.localdomain kernel: ffa0: 000000001ad84f10 0000fffffb7cfb50 0000ffffa1655c48 0000fffffb7cfb50
23:05:11 localhost.localdomain kernel: ffc0: 0000ffffa17660ec 0000000080000000 0000000000000014 000000000000001d
23:05:11 localhost.localdomain kernel: ffe0: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
23:05:11 localhost.localdomain kernel: [<ffff00000808392c>] __sys_trace_return+0x0/0x4
```

```
$ ps aux | grep "qemu"
root      8361  9.4  6.8 11088576 4540480 pts/2 Dl+ 11:56  67:19 qemu-system-aarch64 -m 8192 -enable-kvm -machine virt-4.0,accel=kvm,gic-version=3 -cpu host -smp 8,sockets=2,cores=4,threads=1 -append console=ttyAMA0,38400 earlycon=pl011,0x09000000 nosmp drm.debug=0x0 rootwait rootdelay=5 androidboot.selinux=permissive -serial mon:stdio -kernel Image -initrd ramdisk.img -drive index=0,if=none,id=system,file=system.img -device virtio-blk-pci,drive=system -drive index=1,if=none,id=cache,file=cache.img -device virtio-blk-pci,drive=cache -drive index=2,if=none,id=userdata,file=userdata.img -device virtio-blk-pci,drive=userdata -netdev user,id=mynet,hostfwd=tcp::5550-:5555 -device virtio-net-pci,netdev=mynet -device virtio-gpu-pci,id=video0,virgl=on,max_outputs=1 -vnc :3 -device virtio-serial-pci -display gtk,gl=on -device qemu-xhci,id=usb -device usb-kbd -device usb-mouse
```
>进程状态：`Dl+`


## 参考

1. [khungtaskd 检测处于TASK_UNINTERRUPTIBLE状态的进程](http://blog.chinaunix.net/xmlrpc.php?r=blog/article&uid=25564582&id=5204177)
2. [Linux内核调试技术——进程D状态死锁检测](http://blog.csdn.net/luckyapple1028/article/details/51931210)
