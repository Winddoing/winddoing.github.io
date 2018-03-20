---
title: Cgroup
date: 2018-02-28 23:07:24
categories: 进程
tags: [Linux, Cgroup]
---


CGroup 是 Control Groups 的缩写，是 Linux 内核提供的一种可以限制、记录、隔离进程组 (process groups) 所使用的物力资源 (如 cpu memory i/o 等等) 的机制。

CGroup 是将任意进程进行分组化管理的 Linux 内核功能。CGroup 本身是提供将进程进行分组化管理的功能和接口的基础结构，I/O 或内存的分配控制等具体的资源管理功能是通过这个功能来实现的。这些具体的资源管理功能称为 CGroup 子系统或控制器。CGroup 子系统有控制内存的 Memory 控制器、控制进程调度的 CPU 控制器等。运行中的内核可以使用的 Cgroup 子系统由`/proc/cgroup` 来确认

<!--more-->
## Cgroup虚拟文件系统

>CGroup 提供了一个 CGroup 虚拟文件系统，作为进行分组管理和各子系统设置的用户接口。要使用 CGroup，必须挂载 CGroup 文件系统。这时通过挂载选项指定使用哪个子系统。

``` shell
[root@buildroot /]# mount -t cgroup cgroup /mnt/
[root@buildroot /]# ls /mnt/
blkio.reset_stats                cpuset.mem_exclusive
cgroup.clone_children            cpuset.mem_hardwall
cgroup.event_control             cpuset.memory_migrate
cgroup.procs                     cpuset.memory_pressure
cgroup.sane_behavior             cpuset.memory_pressure_enabled
cpu.cfs_period_us                cpuset.memory_spread_page
cpu.cfs_quota_us                 cpuset.memory_spread_slab
cpu.rt_period_us                 cpuset.mems
cpu.rt_runtime_us                cpuset.sched_load_balance
cpu.shares                       cpuset.sched_relax_domain_level
cpu.stat                         devices.allow
cpuacct.stat                     devices.deny
cpuacct.usage                    devices.list
cpuacct.usage_percpu             notify_on_release
cpuset.cpu_exclusive             release_agent
cpuset.cpus                      tasks
```
各个子系统的挂载：
```
mount -t cgroup -o cpu cgroup /mnt/
mount -t cgroup -o cpu,cpuset cgroup /mnt/
mount -t cgroup -o cpu,cpuset,devices cgroup /mnt/
```

CGroup 支持的文件种类:

| 文件 | R/W | 用途 |
| :--: | :-: | :--: |
| release_agent | RW | 删除分组时执行的命令，这个文件只存在于根分组 |
| notify_on_release | RW | 设置是否执行 release_agent。为 1 时执行 |
| tasks | RW | 属于分组的线程 TID 列表(进程ID) |
| cgroup.procs | R | 属于分组的进程 PID 列表。仅包括多线程进程的线程 leader 的 TID，这点与 tasks 不同 |
| cgroup.event_control | RW | 监视状态变化和分组删除事件的配置文件 |


## 基础概念

* 子系统（subsystem）
一个子系统就是一个资源控制器，比如 cpu 子系统就是控制 cpu 时间分配的一个控制器。子系统必须附加（attach）到一个层级上才能起作用，一个子系统附加到某个层级以后，这个层级上的所有控制族群都受到这个子系统的控制。
```
[root@buildroot ~]# cat /proc/cgroups
#subsys_name      hierarchy       num_cgroups     enabled
cpuset    1       1       1
cpu       1       1       1
cpuacct   1       1       1
devices   1       1       1
freezer   1       1       1
blkio     1       1       1
```
>Version: Linux-3.10.14

1.`cpuset`: 为cgroup中的任务分配独立CPU（SMP多核）和内存节点
2.`cpu`： 提供调度程序对CPU的cgroup任务访问
3.`cpuacct`： 自动生成cgroup中任务所使用的CPU报告
4.`devices`: 允许或拒绝cgroup中的任务访问设备
5.`freezer`：挂起或者恢复cgroup中的任务
6.`blkio`： 块设备输入输出的限制
7.`perf_event`：  增加了对每group的监测跟踪的能力，即可以监测属于某个特定的group的所有线程以及运行在特定CPU上的线程，此功能对于监测整个group非常有用，[https://lwn.net/Articles/421574/](https://lwn.net/Articles/421574/)

* 层级（hierarchy）
控制族群可以组织成 hierarchical 的形式，既一颗控制族群树。控制族群树上的子节点控制族群是父节点控制族群的孩子，继承父控制族群的特定的属性；
```
[root@buildroot ~]# cat /proc/cgroups
#subsys_name      hierarchy       num_cgroups     enabled
cpuset    0       1       1
cpu       0       1       1
cpuacct   0       1       1
devices   0       1       1
freezer   0       1       1
blkio     0       1       1
[root@buildroot ~]# mount -t cgroup -o cpu cgroup /mnt/cpu/
[root@buildroot ~]# mount -t cgroup -o cpuset cgroup /mnt/cpuset/
[root@buildroot ~]# mount -t cgroup -o devices cgroup /mnt/blkio/
[root@buildroot ~]# mount -t cgroup -o blkio cgroup /mnt/blkio/
[root@buildroot ~]# cat /proc/cgroups
#subsys_name      hierarchy       num_cgroups     enabled
cpuset    0       1       1
cpu       4       1       1
cpuacct   0       1       1
devices   0       1       1
freezer   0       1       1
blkio     0       1       1
```
> 一子系统最多只能附加到一个层级

* 控制族群（control group）

控制族群就是一组按照某种标准划分的进程。Cgroups 中的资源控制都是以控制族群为单位实现。一个进程可以加入到某个控制族群，也从一个进程组迁移到另一个控制族群。一个进程组的进程可以使用 cgroups 以控制族群为单位分配的资源，同时受到 cgroups 以控制族群为单位设定的限制.
``` shell
[root@buildroot cpu]# mkdir aaa
[root@buildroot cpu]# mkdir bbb
[root@buildroot cpu]# ls
aaa/                   cgroup.sane_behavior   cpu.shares
bbb/                   cpu.cfs_period_us      cpu.stat
cgroup.clone_children  cpu.cfs_quota_us       notify_on_release
cgroup.event_control   cpu.rt_period_us       release_agent
cgroup.procs           cpu.rt_runtime_us      tasks
[root@buildroot cpu]# ls aaa/ bbb/
aaa/:
cgroup.clone_children  cpu.cfs_quota_us       cpu.stat
cgroup.event_control   cpu.rt_period_us       notify_on_release
cgroup.procs           cpu.rt_runtime_us      tasks
cpu.cfs_period_us      cpu.shares

bbb/:
cgroup.clone_children  cpu.cfs_quota_us       cpu.stat
cgroup.event_control   cpu.rt_period_us       notify_on_release
cgroup.procs           cpu.rt_runtime_us      tasks
cpu.cfs_period_us      cpu.shares
```

* 任务（task）
在 cgroups 中，任务就是系统的一个进程
``` shell
[root@buildroot cpu]# cat tasks
1
2
3
```

### 关系

* 每次在系统中创建新层级时，该系统中的所有任务都是那个层级的默认 cgroup（我们称之为 `root cgroup`，此cgroup在创建层级时自动创建，后面在该层级中创建的cgroup都是此cgroup的后代）的初始成员;

`root cgroup:`
```
[root@buildroot mnt]# cat tasks
1
2
3
...
```

`subsys cgroup:`
```
[root@buildroot mnt]# mkdir aaa
[root@buildroot mnt]# cd aaa/
[root@buildroot aaa]# cat tasks
```
* 一子系统最多只能附加到一个层级;
* 一个层级可以附加多个子系统;
* 一个任务可以是多个cgroup的成员，但是这些cgroup必须在不同的层级;
* 系统中的进程（任务）创建子进程（任务）时，该子任务自动成为其父进程所在 cgroup的成员。然后可根据需要将该子任务移动到不同的 cgroup 中，但开始时它总是继承其父任务的cgroup。


## CPU资源控制

CPU资源的控制，主要是对CPU计算的控制，可以最大化的利用CPU资源。而`进程`是对CPU资源的利用实体。

CPU资源控制的体现方式：
1. 时间片
2. 调度策略


## 进程迁移


## CPU子系统实现

## 参考

1. [CGroup 介绍、应用实例及原理描述](https://www.ibm.com/developerworks/cn/linux/1506_cgroup/)
2. [控制族群（CGROUP）](https://access.redhat.com/documentation/zh-cn/red_hat_enterprise_linux/6/html/resource_management_guide/ch01)
3. [Linux内核工程导论——CGroup子系统](http://blog.csdn.net/ljy1988123/article/details/48032577)
4. [Linux资源控制-使用cgroup控制CPU和内存](http://blog.csdn.net/arnoldlu/article/details/52945252)
