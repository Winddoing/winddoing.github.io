---
layout: post
title: proc文件系统解析--进程
date: '2019-01-15 14:47'
tags:
  - 进程
categories:
  - 文件系统
  - proc
abbrlink: 30680
---

Linux系统上的/proc目录是一种文件系统，即proc文件系统。与其它常见的文件系统不同的是，/proc是一种伪文件系统（也即虚拟文件系统），存储的是当前内核运行状态的一系列特殊文件，用户可以通过这些文件查看有关系统硬件及当前正在运行进程的信息，甚至可以通过更改其中某些文件来改变内核的运行状态。

> 所有说明均可通过`man proc`获取

<!--more-->

系统环境：`arm64bit`， `Linux4.4.70`

## 进程

* 测试进程
``` shell
# ps
...
570 root      2728 S    top
...
```

``` shell
#ls -ls
    0 dr-xr-xr-x    2 root     root             0 Jan  1 04:14 attr
    0 -r--------    1 root     root             0 Jan  1 04:14 auxv
    0 -r--r--r--    1 root     root             0 Jan  1 04:14 cgroup
    0 --w-------    1 root     root             0 Jan  1 04:14 clear_refs
    0 -r--r--r--    1 root     root             0 Jan  1 03:31 cmdline
    0 -rw-r--r--    1 root     root             0 Jan  1 04:14 comm
    0 -rw-r--r--    1 root     root             0 Jan  1 04:14 coredump_filter
    0 -r--r--r--    1 root     root             0 Jan  1 04:14 cpuset
    0 lrwxrwxrwx    1 root     root             0 Jan  1 04:14 cwd -> /proc
    0 -r--------    1 root     root             0 Jan  1 04:14 environ
    0 lrwxrwxrwx    1 root     root             0 Jan  1 04:14 exe -> /bin/busybox
    0 dr-x------    2 root     root             0 Jan  1 04:14 fd
    0 dr-x------    2 root     root             0 Jan  1 04:14 fdinfo
    0 -rw-r--r--    1 root     root             0 Jan  1 04:14 gid_map
    0 -r--r--r--    1 root     root             0 Jan  1 04:14 limits
    0 dr-x------    2 root     root             0 Jan  1 04:14 map_files
    0 -r--r--r--    1 root     root             0 Jan  1 04:14 maps
    0 -rw-------    1 root     root             0 Jan  1 04:14 mem
    0 -r--r--r--    1 root     root             0 Jan  1 04:14 mountinfo
    0 -r--r--r--    1 root     root             0 Jan  1 04:14 mounts
    0 -r--------    1 root     root             0 Jan  1 04:14 mountstats
    0 dr-xr-xr-x   10 root     root             0 Jan  1 04:14 net
    0 dr-x--x--x    2 root     root             0 Jan  1 04:14 ns
    0 -r--------    1 root     root             0 Jan  1 04:14 oom_adj
    0 -r--r--r--    1 root     root             0 Jan  1 04:14 oom_score
    0 -r--------    1 root     root             0 Jan  1 04:14 oom_score_adj
    0 -r--------    1 root     root             0 Jan  1 04:14 pagemap
    0 -r--------    1 root     root             0 Jan  1 04:14 personality
    0 -rw-r--r--    1 root     root             0 Jan  1 04:14 projid_map
    0 lrwxrwxrwx    1 root     root             0 Jan  1 04:14 root -> /
    0 -rw-r--r--    1 root     root             0 Jan  1 04:14 sched
    0 -r--r--r--    1 root     root             0 Jan  1 04:14 schedstat
    0 -rw-r--r--    1 root     root             0 Jan  1 04:14 setgroups
    0 -r--r--r--    1 root     root             0 Jan  1 04:14 smaps
    0 -r--------    1 root     root             0 Jan  1 04:14 stack
    0 -r--r--r--    1 root     root             0 Jan  1 03:31 stat
    0 -r--r--r--    1 root     root             0 Jan  1 04:14 statm
    0 -r--r--r--    1 root     root             0 Jan  1 04:14 status
    0 -r--------    1 root     root             0 Jan  1 04:14 syscall
    0 dr-xr-xr-x    3 root     root             0 Jan  1 04:14 task
    0 -rw-rw-rw-    1 root     root             0 Jan  1 04:14 timerslack_ns
    0 -rw-r--r--    1 root     root             0 Jan  1 04:14 uid_map
    0 -r--r--r--    1 root     root             0 Jan  1 04:14 wchan
```
## 进程目录

``` shell
# ls /proc/570/
attr             fd               ns               smaps
auxv             fdinfo           oom_adj          stack
cgroup           gid_map          oom_score        stat
clear_refs       limits           oom_score_adj    statm
cmdline          map_files        pagemap          status
comm             maps             personality      syscall
coredump_filter  mem              projid_map       task
cpuset           mountinfo        root             timerslack_ns
cwd              mounts           sched            uid_map
environ          mountstats       schedstat        wchan
exe              net              setgroups
```

| 选项 | 说明  |
|:---:|:-------|
| cmdline  | 启动当前进程的完整命令，但僵尸进程目录中的此文件不包含任何信息  |
| cwd  | 指向当前进程运行目录的一个符号链接  |
| exe  | 指向启动当前进程的可执行文件（完整路径）的符号链接  |
| fd  | 指向启动当前进程的可执行文件（完整路径）的符号链接  |
| limits  | 当前进程所使用的每一个受限资源的软限制、硬限制和管理单元；此文件仅可由实际启动当前进程的UID用户读取；  |
| maps  | 当前进程关联到的每个可执行文件和库文件在内存中的映射区域及其访问权限所组成的列表；  |
| mem  | 当前进程所占用的内存空间，由open、read和lseek等系统调用使用，不能被用户读取；  |
| root  | 指向当前进程运行根目录的符号链接；在Unix和Linux系统上，通常采用chroot命令使每个进程运行于独立的根目录；|
| stat  | 当前进程的状态信息，包含一系统格式化后的数据列，可读性差，通常由ps命令使用；   |
| statm  | 当前进程占用内存的状态信息，通常以“页面”（page）表示；   |
| status  | 与stat所提供信息类似，但可读性较好  |
| task  | 包含由当前进程所运行的每一个线程的相关信息，每个`线程`的相关信息文件均保存在一个由线程号（tid）命名的目录中，这类似于其内容类似于每个进程目录中的内容  |


### /proc/[PID]/stat

> 包含了所有CPU活跃的信息，该文件中的所有值都是`从系统启动开始累计到当前时刻`。

``` shell
#cat /proc/570/stat
570 (top) S 565 570 565 34817 570 4210688 110 0 0 0 209 648 0 0 20 0 1 0 1266675 2793472 111 18446744073709551615 4194304 4867856 548828687344 548828686432 548186418324 0 0 0 58751527 1 0 0 17 3 0 0 0 0 0 4933392 4937189 1042927616 548828688219 548828688223 548828688223 548828688363 0
```
| 序号  |  表示  | 说明  |
|:----:|:-------|:---------|
| 1  | pid=570 | 进程(包括轻量级进程，即线程)号  |
| 2  | comm=top  | 应用程序或命令的名字  |
| 3  | task_state=R   | 任务的状态，R:runnign, S:sleeping (TASK_INTERRUPTIBLE), D:disk sleep (TASK_UNINTERRUPTIBLE), T: stopped, T:tracing stop,Z:zombie, X:dead  |
| 4  | ppid=565  | 父进程ID  |
| 5  | pgid=570  | 线程组ID  |
| 6  | session=565  | 该任务所在的会话组ID  |
| 7  | tty_nr=34817  | 该任务的tty终端的设备号  |
| 8  | tpgid=570  | 终端的进程组号，当前运行在该任务所在终端的前台任务(包括shell 应用程序)的PID。  |
| 9  | task->flags=4210688  | 进程标志位，查看该任务的特性  |
| 10  | min_flt=110  | 该任务不需要从硬盘拷数据而发生的缺页（次缺页）的次数  |
| 11  | cmin_flt=0  | 累计的该任务的所有的waited-for进程曾经发生的次缺页的次数目  |
| 12  | maj_flt=0  | 该任务需要从硬盘拷数据而发生的缺页（主缺页）的次数  |
| 13  | cmaj_flt=0  | 累计的该任务的所有的waited-for进程曾经发生的主缺页的次数目  |
| 14  | utime=209  | 该任务在用户态运行的时间，单位为jiffies  |
| 15  | stime=648  | 该任务在核心态运行的时间，单位为jiffies  |
| 16  | cutime=0  | 累计的该任务的所有的waited-for进程曾经在用户态运行的时间，单位为jiffies |
| 17  | cstime=0  | 累计的该任务的所有的waited-for进程曾经在核心态运行的时间，单位为jiffies |
| 18  | priority=20  | 任务的动态优先级  |
| 19  | nice=0  | 任务的静态优先级  |
| 20  | num_threads=1  | 该任务所在的线程组里线程的个数  |
| 21  | it_real_value=0   | 由于计时间隔导致的下一个 SIGALRM 发送进程的时延，以jiffy为单位.  |
| 22  | start_time=1266675  | 该任务启动的时间，单位为jiffies  |
| 23  | vsize=2793472  | 该任务的虚拟地址空间大小, 单位为page  |
| 24  | rss=111  | 该任务当前驻留物理地址空间的大小，单位为page  |
| 25  | rlim=18446744073709551615  | 该任务能驻留物理地址空间的最大值. 单位：byte  |
| 26  | start_code=4194304  | 该任务在虚拟地址空间的代码段的起始地址  |
| 27  | end_code=4867856  | 该任务在虚拟地址空间的代码段的结束地址  |
| 28  | startstack=548828687344  | 堆栈的起始地址（即底部）  |
| 29  | kstkesp=548828686432  | esp(堆栈指针) 的当前值, 与在进程的内核堆栈页得到的一致 |
| 30  | kstkeip=548186418324  | 指向将要执行的指令的指针, EIP(指令指针)的当前值.  |
| 31  | signal=0  | 待处理信号的位图，记录发送给进程的普通信号   |
| 32  | blocked=0  | 阻塞信号的位图  |
| 33  | sigignore=0  | 忽略的信号的位图  |
| 34  | sigcatch=58751527  | 被俘获的信号的位图  |
| 35  | wchan=1 | 如果该进程是睡眠状态，该值给出调度的调用点   |
| 36  | nswap=0 | 交换的页数（未维护）  |
| 37  | cnswap=0 | 子进程的累积nswap（未维护）。  |
| 38  | exit_signal=17  | 该进程结束时，向父进程所发送的信号  |
| 39  | task_cpu(task)=3  | 运行在哪个CPU上  |
| 40  | task_rt_priority=0  | 实时进程的相对优先级别  |
| 41  | task_policy=0  | 进程的调度策略，0=非实时进程，1=FIFO实时进程；2=RR实时进程   |
| 42  | delayacct_blkio_ticks=0  | 聚合块I/O延迟，以时钟周期（厘秒,百分之一秒）为单位。  |
| 43  | guest_time=0  | -  |
| 44  | cguest_time=0  | -  |
| 45  | start_data=4933392  | 放置程序数据和未初始化（BSS）数据的地址。  |
| 46  | end_data  =4937189  | -  |
| 47  | start_brk=1042927616  | 可以使用brk(2)扩展程序堆的地址。  |
| 48  | arg_start=548828688219  | 放置程序命令行参数（argv）的地址。  |
| 49  | arg_end  =548828688223  | -  |
| 50  | env_start=548828688223  | 放置程序环境变量的地址。  |
| 51  | env_end  =548828688363  | -  |
| 52  | exit_code=0  |线程的退出状态采用waitpid(2)报告的形式。 |
