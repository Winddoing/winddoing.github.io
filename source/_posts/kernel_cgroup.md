---
title: Cgroup框架的实现
date: 2018-03-30 23:07:24
categories: Linux内核
tags: [linux，Cgroup]
---

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

<!--more-->

### 基本应用

``` shell
# mount -t cgroup -o cpu cgroup /mnt/
# mkdir tst_cgroup
# rmdir tst_cgroup
```
在文件系统中cgroup的挂载目录,也就是cgroup虚拟文件系统的根目录用数据结构`struct cgroupfs_root`表示.而cgroup用`struct cgroup`表示.

### 数据结构

主要用于对进程不同资源的管理和配置，以及进程和cgroup之间的关系。

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
`struct task_struct`中并没有一个直接的成员指向cgroup,而是指向了`struct css_set`的结构, css_set存储路与进程相关的cgroup信息。

`cg_list`: 是一个链表结构，用于将连到同一个css_set的进程组织成一个链表。

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
	atomic_t refcount;  //引用计数，因为一个css_set可以被多个进程共用，这些进程的cgroup信息相同

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
	struct cgroup_subsys_state *subsys[CGROUP_SUBSYS_COUNT]; //是进程与一个特定子系统相关的信息

	/* For RCU-protected deletion */
	struct rcu_head rcu_head;
};
```
>file: include/linux/cgroup.h

主要用来描述一个个子系统，通过`cgroup_subsys_state`定义不同子系统的相关控制信息，`hlist`将同一个子系统下的所有css_set组织成一个hash表，方便内核查找特定的css_set.
`tasks`指向所有连到此css_set的进程连成的链表。

那从`struct css_set`怎么转换到cgroup呢? 再来看一个辅助的数据结构`struct cg_cgroup_link`

#### cgroup_subsys_state

``` C
/* Per-subsystem/per-cgroup state maintained by the system. */
struct cgroup_subsys_state {
    /*
     * The cgroup that this subsystem is attached to. Useful
     * for subsystems that want to know about the cgroup
     * hierarchy structure
     */
    struct cgroup *cgroup;

    /*
     * State maintained by the cgroup system to allow subsystems
     * to be "busy". Should be accessed via css_get(),
     * css_tryget() and css_put().
     */

    atomic_t refcnt;

    unsigned long flags;
    /* ID for this css, if possible */
    struct css_id __rcu *id;

    /* Used to put @cgroup->dentry on the last css_put() */
    struct work_struct dput_work;
};
```
>file: include/linux/cgroup.h

cgroup指针指向了一个cgroup结构，也就是进程属于的cgroup.


进程受到子系统的控制，实际上是通过加入到特定的cgroup实现的，因为cgroup在特定的层级上，而子系统又是附加到曾经上的 。通过以上三个结构，进程就可以和cgroup关联起来了 ：

>task_struct->css_set->cgroup_subsys_state->cgroup。

![task cgroup](/images/cgroup/task_cgroup_relation.png)

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

* `sibling`,`children`和`parent`三个list_head负责将同一层级的cgroup连接成一颗cgroup树。
* `subsys`是一个指针数组，存储一组指向cgroup_subsys_state的指针。这组指针指向了此cgroup跟各个子系统相关的信息
* `root`指向了一个cgroupfs_root的结构，就是cgroup所在的层级对应的结构体


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

1. [Linux Cgroups 详解](https://files.cnblogs.com/files/lisperl/cgroups%E4%BB%8B%E7%BB%8D.pdf)
2. [Cgroup框架分析](https://blog.csdn.net/zhangyifei216/article/details/49491549)
333. [Linux cgroup机制分析之框架分析1](http://www.xuebuyuan.com/624249.html)
