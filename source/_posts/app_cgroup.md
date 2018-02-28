---
title: Cgroup
date: 2018-02-28 23:07:24
categories: 进程
tags: [Linux, Cgroup]
---


CGroup 是 Control Groups 的缩写，是 Linux 内核提供的一种可以限制、记录、隔离进程组 (process groups) 所使用的物力资源 (如 cpu memory i/o 等等) 的机制。

>CGroup 是将任意进程进行分组化管理的 Linux 内核功能。CGroup 本身是提供将进程进行分组化管理的功能和接口的基础结构，I/O 或内存的分配控制等具体的资源管理功能是通过这个功能来实现的。这些具体的资源管理功能称为 CGroup 子系统或控制器。CGroup 子系统有控制内存的 Memory 控制器、控制进程调度的 CPU 控制器等。运行中的内核可以使用的 Cgroup 子系统由`/proc/cgroup` 来确认

```
[root@buildroot /]# cat /proc/cgroups
#subsys_name    hierarchy       num_cgroups     enabled
cpuset  3       1       1
debug   3       1       1
cpu     3       1       1
cpuacct 3       1       1
devices 3       1       1
freezer 3       1       1
blkio   3       1       1
perf_event      3       1       1
```

<!--more-->

## Cgroup虚拟文件系统

>CGroup 提供了一个 CGroup 虚拟文件系统，作为进行分组管理和各子系统设置的用户接口。要使用 CGroup，必须挂载 CGroup 文件系统。这时通过挂载选项指定使用哪个子系统。

``` shell
[root@buildroot /]# mount -t cgroup cgroup /mnt/
[root@buildroot /]# ls /mnt/
blkio.reset_stats                cpuset.memory_spread_page
cgroup.clone_children            cpuset.memory_spread_slab
cgroup.event_control             cpuset.mems
cgroup.procs                     cpuset.sched_load_balance
cgroup.sane_behavior             cpuset.sched_relax_domain_level
cpu.rt_period_us                 debug.cgroup_css_links
cpu.rt_runtime_us                debug.cgroup_refcount
cpu.shares                       debug.current_css_set
cpuacct.stat                     debug.current_css_set_cg_links
cpuacct.usage                    debug.current_css_set_refcount
cpuacct.usage_percpu             debug.releasable
cpuset.cpu_exclusive             debug.taskcount
cpuset.cpus                      devices.allow
cpuset.mem_exclusive             devices.deny
cpuset.mem_hardwall              devices.list
cpuset.memory_migrate            notify_on_release
cpuset.memory_pressure           release_agent
cpuset.memory_pressure_enabled   tasks
```

CGroup 支持的文件种类:

| 文件 | R/W | 用途 |
| :--: | :-: | :--: |
| release_agent | RW | 删除分组时执行的命令，这个文件只存在于根分组 |
| notify_on_release | RW | 设置是否执行 release_agent。为 1 时执行 |
| tasks | RW | 属于分组的线程 TID 列表(进程ID) |
| cgroup.procs | R | 属于分组的进程 PID 列表。仅包括多线程进程的线程 leader 的 TID，这点与 tasks 不同 |
| cgroup.event_control | RW | 监视状态变化和分组删除事件的配置文件 |



## 参考

1. [CGroup 介绍、应用实例及原理描述](https://www.ibm.com/developerworks/cn/linux/1506_cgroup/)
2. [控制族群（CGROUP）](https://access.redhat.com/documentation/zh-cn/red_hat_enterprise_linux/6/html/resource_management_guide/ch01)
