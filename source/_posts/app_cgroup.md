---
title: Cgroup
date: 2018-02-28 23:07:24
categories: 进程
tags: [Linux, Cgroup]
---


CGroup 是 Control Groups 的缩写，是 Linux 内核提供的一种可以限制、记录、隔离进程组 (process groups) 所使用的物力资源 (如 cpu memory i/o 等等) 的机制。

CGroup 是将任意进程进行分组化管理的 Linux 内核功能。CGroup 本身是提供将进程进行分组化管理的功能和接口的基础结构，I/O 或内存的分配控制等具体的资源管理功能是通过这个功能来实现的。这些具体的资源管理功能称为 CGroup 子系统或控制器。CGroup 子系统有控制内存的 Memory 控制器、控制进程调度的 CPU 控制器等。运行中的内核可以使用的 Cgroup 子系统由`/proc/cgroup` 来确认，根据系统对资源的需求，这个根进程组将被进一步细分为子进程组，子进程组内的进程是根进程组内进程的子集。而这些子进程组很有可能继续被进一步细分，最终，系统内所有的进程组形成一颗具有层次等级（hierarchy）关系的进程组树。

![cgroup tree](/images/cgroup/cgroup_tree.jpeg)

<!--more-->
## Cgroup虚拟文件系统

>CGroup 提供了一个 CGroup 虚拟文件系统，作为进行分组管理和各子系统设置的用户接口。要使用 CGroup，必须挂载 CGroup 文件系统。这时通过挂载选项指定使用哪个子系统。

![cgroup stru](/images/cgroup/cgroup_struct.jpeg)

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
> 一个子系统最多只能附加到一个层级

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


## 限制cpu的资源

CPU资源的控制，主要是对CPU计算的控制，可以最大化的利用CPU资源。而`进程`是对CPU资源的利用实体。

### 实时进程控制 -- 系统整体

>控制实时进程的CPU资源占用

* 获取当前系统的设置
``` shell
# sysctl -n kernel.sched_rt_period_us   # 实时进程调度的单位CPU时间 1 秒
1000000
# sysctl -n kernel.sched_rt_runtime_us  # 实时进程在 1 秒中实际占用的CPU时间, 0.95秒
950000
```
* 设置实时进程占用CPU时间
``` shell
# sysctl -w kernel.sched_rt_runtime_us=970000 # 设置实时进程每1秒中只占0.97秒的CPU时间
kernel.sched_rt_runtime_us = 970000
```
>sysctl -w : 临时修改指定参数的值

### 实时进程控制 -- 系统部分

>通过cgroup对一组进程中的实时进程的CPU资源进行控制.

``` shell
# mount -t cgroup cgroup -o cpu /mnt/
# ls
cgroup.clone_children  cpu.cfs_quota_us       notify_on_release
cgroup.event_control   cpu.rt_period_us       release_agent
cgroup.procs           cpu.rt_runtime_us      tasks
cgroup.sane_behavior   cpu.shares
cpu.cfs_period_us      cpu.stat
# cat cpu.rt_period_us cpu.rt_runtime_us
1000000
950000
```

通过虚拟文件系统mount出CPU子系统，为CPU子系统的根节点，其可以控制整个系统的进程`tasks`,因此如果想对部分实时进程进行控制，需要创建子cgroup，并将需要控制的进程搬到新的cgroup中。

``` shell
# mkdir rt_ctl
# cd rt_ctl/
# echo PID > tasks
# echo 1000000 > cpu.rt_period_us
# echo 920000 > cpu.rt_runtime_us
```
通过配置`cpu.rt_period_us`和`cpu.rt_runtime_us`就可以对` rt_ctl cgroup` 中的进程组中的实时进程进行CPU使用时间的控制.

在子cgroup中，对相关子系统进行修改时，该子系统的相关属性小于父cgroup属性的相应值。

``` shell
# echo 960000 > cpu.rt_runtime_us
sh: write error: Invalid arguments
```

## 限制进程的内存资源

内核配置：

```
Location:
  -> General setup
    -> Control Group support (CGROUPS [=y])
      -> Resource counters (RESOURCE_COUNTERS [=y])
        -> Memory Resource Controller for Control Groups (MEMCG [=y])
```

``` shell
# mount -t cgroup -o memory cgroup /mnt/
#
# cd /mnt/
# ls
cgroup.clone_children               memory.kmem.usage_in_bytes
cgroup.event_control                memory.limit_in_bytes
cgroup.procs                        memory.max_usage_in_bytes
cgroup.sane_behavior                memory.move_charge_at_immigrate
memory.failcnt                      memory.oom_control
memory.force_empty                  memory.pressure_level
memory.kmem.failcnt                 memory.soft_limit_in_bytes
memory.kmem.limit_in_bytes          memory.stat
memory.kmem.max_usage_in_bytes      memory.swappiness
memory.kmem.slabinfo                memory.usage_in_bytes
memory.kmem.tcp.failcnt             memory.use_hierarchy
memory.kmem.tcp.limit_in_bytes      notify_on_release
memory.kmem.tcp.max_usage_in_bytes  release_agent
memory.kmem.tcp.usage_in_bytes      tasks
```
>`memsw`:表示虚拟内存，不带`memsw`的仅包括物理内存

* `limit_in_bytes` 是用来限制内存使用 ,memory.memsw.limit_in_bytes 必须大于或等于 memory.limit_in_byte。要解除内存限制，对应的值设为 -1
>这种方式限制进程内存占用会有个风险。当进程试图占用的内存超过限制时，会触发 oom ，导致进程直接被杀，从而造成可用性问题。即使关闭控制组的 oom killer，在内存不足时，进程虽然不会被杀，但是会长时间进入 D 状态（等待系统调用的不可中断休眠），并被放到 OOM-waitqueue 等待队列中， 仍然导致服务不可用。因此，用 memory.limit_in_bytes 或 memory.memsw.limit_in_bytes 限制进程内存占用仅应当作为一个保险，避免在进程异常时耗尽系统资源

* `memory.oom_control`：内存超限之后的OOM行为控制
``` shell
# cat memory.oom_control
oom_kill_disable 0
under_oom 0
```
>关闭oom killer： `oom_kill_disable为1`

* `memory.soft_limit_in_bytes`: memory.limit_in_bytes 的不同是，这个限制并不会阻止进程使用超过限额的内存，只是在系统内存足够时，会优先回收超过限额的内存，使之向限定值靠拢。

* `memory.usage_in_bytes`: 当前使用量
* `memory.max_usage_in_bytes`: 最高使用量
* `memory.failcnt`: 发生的缺页次数（申请内存失败的次数)
* `memory.stat`: 就是内存使用情况报告了。包括当前资源总量、使用量、换页次数、活动页数量等等

## 进程迁移

在多核处理器时，如果想将一个进程指定到特定的CPU上进行执行，可通过`cpuset`子系统实现。

>`cpuset`:针对 CPU 核心进行隔离，其实就是把要运行的进程绑定到指定的核心上运行，通过让不同的进程占用不同的核心，以达到运算资源隔离的目的。为cgroup中的任务分配独立`CPU（在多核系统）`和`内存节点`。

1. 挂载 cgroup 文件系统, 并指定 -o cpuset
2. 指定 A 的物理CPU为 0 (双核CPU的每个核编号分别是 CPU0, CPU1)
3. 指定 B 的物理CPU也为 1

``` shell
# mount -t cgroup -o cpuset cgroup /mnt/
# cat cpuset.cpus cpuset.mems
0-1
0
# cd /mnt/
# mkdir A B # 创建子cgroup A 和 B
# cat A/cpuset.cpus

# cat B/cpuset.cpus

# echo 0 > A/cpuset.cpus # 设置A组绑定到CPU0
# echo 1 > B/cpuset.cpus # 设置B组绑定到CPU1
# echo 0 > A/cpuset.mems # 设置A组绑定内存
# echo 0 > B/cpuset.mems # 设置A组绑定内存
# echo pid1 > A/tasks #将B组进程迁入A组
# echo pid2 > B/tasks #将A组进程迁入B组
```
>``` shell
># echo $$ > tasks
>sh: write error: No space left on devices
>```
>**原因**：没有配置`cpuset.mems`

### 应用实例

>ltp-full-20140115/testcases/kernel/controllers/cpuctl/cpuctl_test02.c

## Cgroup框架的实现

### Linux内核配置：

```
Symbol: CGROUPS [=y]
Type  : boolean
Prompt: Control Group support
  Location:
      -> General setup

Symbol: CGROUP_SCHED [=y]
Type  : boolean
Prompt: Group CPU scheduler
  Location:
      -> General setup
	        -> Control Group support (CGROUPS [=y])
```

通过`CONFIG_CGROUPS`配置cgroup框架的实现,`CONFIG_CGROUP_SCHED`控制CPU子系统。

### 基本应用

``` shell
# mount -t cgroup -o cpu cgroup /mnt/
# mkdir tst_cgroup
```
在文件系统中cgroup的挂载目录,也就是cgroup虚拟文件系统的根目录用数据结构`struct cgroupfs_root`表示.而cgroup用`struct cgroup`表示.

### 数据结构

#### cgroupfs_root

``` C
/*
 * A cgroupfs_root represents the root of a cgroup hierarchy, and may be
 * associated with a superblock to form an active hierarchy.  This is
 * internal to cgroup core.  Don't access directly from controllers.
 */
struct cgroupfs_root {
	struct super_block *sb;  //cgroup文件系统的超级块

	/*
	 * The bitmask of subsystems intended to be attached to this
	 * hierarchy
	 */
	unsigned long subsys_mask; //hierarchy相关联的subsys 位图

	/* Unique id for this hierarchy. */
	int hierarchy_id;

	/* The bitmask of subsystems currently attached to this hierarchy */
	unsigned long actual_subsys_mask;

	/* A list running through the attached subsystems */
	struct list_head subsys_list; //hierarchy中的subsys链表

	/* The root cgroup for this hierarchy */
	struct cgroup top_cgroup;

	/* Tracks how many cgroups are currently defined in hierarchy.*/
	int number_of_cgroups;

	/* A list running through the active hierarchies */
	struct list_head root_list;

	/* All cgroups on this root, cgroup_mutex protected */
	struct list_head allcg_list;

	/* Hierarchy-specific flags */
	unsigned long flags;

	/* IDs for cgroups in this hierarchy */
	struct ida cgroup_ida;

	/* The path to use for release notifications. */
	char release_agent_path[PATH_MAX];

	/* The name for this hierarchy - may be empty */
	char name[MAX_CGROUP_ROOT_NAMELEN];
};
```
#### cgroup

``` C
struct cgroup {
	unsigned long flags;		/* "unsigned long" so bitops work */

	/*
	 * count users of this cgroup. >0 means busy, but doesn't
	 * necessarily indicate the number of tasks in the cgroup
	 */
	atomic_t count;

	int id;				/* ida allocated in-hierarchy ID */

	/*
	 * We link our 'sibling' struct into our parent's 'children'.
	 * Our children link their 'sibling' into our 'children'.
	 */
	struct list_head sibling;	/* my parent's children */
	struct list_head children;	/* my children */
	struct list_head files;		/* my files */

	struct cgroup *parent;		/* my parent */
	struct dentry *dentry;		/* cgroup fs entry, RCU protected */

	/*
	 * This is a copy of dentry->d_name, and it's needed because
	 * we can't use dentry->d_name in cgroup_path().
	 *
	 * You must acquire rcu_read_lock() to access cgrp->name, and
	 * the only place that can change it is rename(), which is
	 * protected by parent dir's i_mutex.
	 *
	 * Normally you should use cgroup_name() wrapper rather than
	 * access it directly.
	 */
	struct cgroup_name __rcu *name;

	/* Private pointers for each registered subsystem */
	struct cgroup_subsys_state *subsys[CGROUP_SUBSYS_COUNT];

	struct cgroupfs_root *root;

	/*
	 * List of cg_cgroup_links pointing at css_sets with
	 * tasks in this cgroup. Protected by css_set_lock
	 */
	struct list_head css_sets;

	struct list_head allcg_node;	/* cgroupfs_root->allcg_list */
	struct list_head cft_q_node;	/* used during cftype add/rm */

	/*
	 * Linked list running through all cgroups that can
	 * potentially be reaped by the release agent. Protected by
	 * release_list_lock
	 */
	struct list_head release_list;

	/*
	 * list of pidlists, up to two for each namespace (one for procs, one
	 * for tasks); created on demand.
	 */
	struct list_head pidlists;
	struct mutex pidlist_mutex;

	/* For RCU-protected deletion */
	struct rcu_head rcu_head;
	struct work_struct free_work;

	/* List of events which userspace want to receive */
	struct list_head event_list;
	spinlock_t event_list_lock;

	/* directory xattrs */
	struct simple_xattrs xattrs;
};
```

`struct cgroupfs_root`和`struct cgroup`就是表示了一种空间层次关系,它就对应着挂载点下面的文件示意图。

但是，cgroup主要是管理进程，是进程的行为控制，因此`struct task_struct`和`struct cgroup`之间存在着一定的关系？

#### task_struct

``` C
struct task_struct {
    ...
#ifdef CONFIG_CGROUP_SCHED
	struct task_group *sched_task_group;
#endif
    ...
#ifdef CONFIG_CGROUPS
	/* Control Group info protected by css_set_lock */
	struct css_set __rcu *cgroups;
	/* cg_list protected by css_set_lock and tsk->alloc_lock */
	struct list_head cg_list;
#endif
    ...
};
```
`struct task_struct`中并没有一个直接的成员指向cgroup,而是指向了`struct css_set`的结构

#### css_set

``` C
/*
 * A css_set is a structure holding pointers to a set of
 * cgroup_subsys_state objects. This saves space in the task struct
 * object and speeds up fork()/exit(), since a single inc/dec and a
 * list_add()/del() can bump the reference count on the entire cgroup
 * set for a task.
 */

struct css_set {

	/* Reference count */
	atomic_t refcount;

	/*
	 * List running through all cgroup groups in the same hash
	 * slot. Protected by css_set_lock
	 */
	struct hlist_node hlist;

	/*
	 * List running through all tasks using this cgroup
	 * group. Protected by css_set_lock
	 */
	struct list_head tasks;

	/*
	 * List of cg_cgroup_link objects on link chains from
	 * cgroups referenced from this css_set. Protected by
	 * css_set_lock
	 */
	struct list_head cg_links;

	/*
	 * Set of subsystem states, one for each subsystem. This array
	 * is immutable after creation apart from the init_css_set
	 * during subsystem registration (at boot time) and modular subsystem
	 * loading/unloading.
	 */
	struct cgroup_subsys_state *subsys[CGROUP_SUBSYS_COUNT];

	/* For RCU-protected deletion */
	struct rcu_head rcu_head;
};
```
那从`struct css_set`怎么转换到cgroup呢? 再来看一个辅助的数据结构`struct cg_cgroup_link`

#### cg_cgroup_link

``` C
/* Link structure for associating css_set objects with cgroups */            
struct cg_cgroup_link {                                                      
    /*                                                                       
     * List running through cg_cgroup_links associated with a                
     * cgroup, anchored on cgroup->css_sets                                  
     */                                                                      
    struct list_head cgrp_link_list;                                         
    struct cgroup *cgrp;                                                     
    /*                                                                       
     * List running through cg_cgroup_links pointing at a                    
     * single css_set object, anchored on css_set->cg_links                  
     */                                                                      
    struct list_head cg_link_list;                                           
    struct css_set *cg;                                                      
};                                                                                                                     
```

#### 关系

![cgroup data struct](/images/cgroup/cgroup_data_struct.jpeg)

### cgroup初始化

### cgroup文件系统的挂载

### 创建子cgroup

## CPU子系统实现



## 参考

1. [CGroup 介绍、应用实例及原理描述](https://www.ibm.com/developerworks/cn/linux/1506_cgroup/)
2. [控制族群（CGROUP）](https://access.redhat.com/documentation/zh-cn/red_hat_enterprise_linux/6/html/resource_management_guide/ch01)
3. [Linux内核工程导论——CGroup子系统](http://blog.csdn.net/ljy1988123/article/details/48032577)
4. [Linux资源控制-使用cgroup控制CPU和内存](http://blog.csdn.net/arnoldlu/article/details/52945252)
5. [cgroup实践-资源控制](https://www.jianshu.com/p/dc3140699e79)
6. [cgroup原理简析:vfs文件系统](https://www.cnblogs.com/acool/p/6852250.html)
7. [Cgroup简介-概述](https://blog.csdn.net/woniu_slowly/article/details/38317973)
8. [Linux cgroup机制分析之框架分析](https://blog.csdn.net/jk198310/article/details/9288877)
9. [Linux cgroup机制分析之框架分析1](http://www.xuebuyuan.com/624249.html)
