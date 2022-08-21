---
layout: post
title: Linux中进程的状态
date: '2022-08-15 11:14'
tags:
  - linux
  - 进程
categories:
  - 进程
abbrlink: a4fafb29
---


Linux进程一共有`6`种状态，分别是：`R`、`S`、`D`、`T`、`Z`、`X`

<!--more-->

## 进程状态值

### R:正在运行或处于就绪状态（Running）—— TASK_RUNNING

`R状态`，表示该进程（任务）可以被CPU执行，但是不一定被CPU正在执行中，因为系统中同一时刻可能存在多个进程在可运行状态。

所有R状态的进程，都在`运行队列`中，由于一个CPU核关联了一个运行队列，因此一个进程只能出现在一个运行队列中。而何时被所属CPU执行取决于调度器。


### S:可中断的睡眠状态（Sleeping) —— TASK_INTERRUPTIBLE

`S状态`，表示该进程由于等待某一事件（比如socket连接，等待信号量），而被挂起。

所有S状态的进行，将被放入对应事件的`等待队列`（等待队列可能存在很多,因为CPU是有限的，因此系统中的大多数进程处于睡眠状态，被放入相应的等待队列）中，当这些事件发生（由外部中断触发或其他进程触发）时，对应的等待队列中的一个或多个进程将被唤醒。


### D:不可中断的睡眠状态（Disk sleep）—— TASK_UNINTERRUPTIBLE

与`S状态`类似，进程处于睡眠状态，但是此时进程是`不可中断的`。

`不可中断`：指的是该进程不响应异步信号，而不是CPU不响应外部信号。比如有些进程处于`D状态`时，我们无法通过kill -9将其杀死，也就是在ps中看到的进程状态几乎没有`D状态`。

`D状态`（TASK_UNINTERRUPTIBLE）存在的意义： 内核中某些处理流程是不能被打断的，比如进程（任务）对某些硬件进行操作时（比如：I/O读写操作等），可能需要使用TASK_UNINTERRUPTIBLE状态对进程进行保护，避免进程与外设交互的过程别打断，造成外设陷入不可控状态。


#### vfork

linux系统中也存在容易捕捉的`TASK_UNINTERRUPTIBLE`状态。执行vfork系统调用后，父进程将进入TASK_UNINTERRUPTIBLE状态，直到子进程调用exit或exec（参见《神奇的vfork》）

``` C
#include <stdio.h>

void main()
{
	if (!vfork()) sleep(100);
}
```

```
$ ps aux | grep "a\.out"
xx    396037  0.0  0.0   2364   508 pts/1    D+   17:10   0:00 ./a.out
xx    396038  0.0  0.0   2364   508 pts/1    S+   17:10   0:00 ./a.out
```


### T:暂停或跟踪状态（stopped）—— TASK_STOPPED/TASK_TRACED

向进程发送一个`SIGSTOP`信号，它就会因响应该信号而进入`TASK_STOPPED`状态（除非该进程本身处于`TASK_UNINTERRUPTIBLE`状态而不响应信号）。（SIGSTOP与SIGKILL信号一样，是强制的。不允许用户进程通过signal系列的系统调用重新设置对应的信号处理函数。）

向进程发送一个`SIGCONT`信号，可以让其从`TASK_STOPPED`状态恢复到`TASK_RUNNING`状态。

当进程正在被跟踪时，它处于`TASK_TRACED`这个特殊的状态。“正在被跟踪”指的是进程暂停下来，等待跟踪它的进程对它进行操作。比如在gdb中对被跟踪的进程下一个断点，进程在断点处停下来的时候就处于TASK_TRACED状态。而在其他时候，被跟踪的进程还是处于前面提到的那些状态。

对于进程本身来说，`TASK_STOPPED`和`TASK_TRACED`状态很类似，都是表示进程暂停下来。而`TASK_TRACED`状态相当于在`TASK_STOPPED`之上多了一层保护，处于`TASK_TRACED`状态的进程不能响应SIGCONT信号而被唤醒。只能等到调试进程通过`ptrace`系统调用执行PTRACE_CONT、PTRACE_DETACH等操作（通过ptrace系统调用的参数指定操作），或调试进程退出，被调试的进程才能恢复`TASK_RUNNING`状态。


### Z:僵尸状态（Zombies）—— TASK_DEAD-EXIT_ZOMBIE

进程在退出的过程中，处于`TASK_DEAD`状态。

在这个退出过程中，进程占有的所有资源将被回收，除了task_struct结构（以及少数资源）以外。于是进程就只剩下task_struct这么个空壳，故称为`僵尸`。

之所以保留task_struct，是因为task_struct里面保存了进程的`退出码`、以及一些统计信息。而其父进程很可能会关心这些信息。比如在shell中，$?变量就保存了最后一个退出的前台进程的退出码，而这个退出码往往被作为if语句的判断条件。

当然，内核也可以将这些信息保存在别的地方，而将task_struct结构释放掉，以节省一些空间。但是使用task_struct结构更为方便，因为在内核中已经建立了从pid到task_struct查找关系，还有进程间的父子关系。释放掉task_struct，则需要建立一些新的数据结构，以便让父进程找到它的子进程的退出信息。

父进程可以通过wait系列的系统调用（如wait4、waitid）来等待某个或某些子进程的退出，并获取它的退出信息。然后wait系列的系统调用会顺便将子进程的尸体（task_struct）也释放掉。

子进程在退出的过程中，内核会给其父进程发送一个信号，通知父进程来“收尸”。这个信号默认是`SIGCHLD`，但是在通过clone系统调用创建子进程时，可以设置这个信号。

只要父进程不退出，这个僵尸状态的子进程就一直存在。那么如果父进程退出了呢，谁又来给子进程“收尸”？
- 当进程退出的时候，会将它的所有子进程都托管给别的进程（使之成为别的进程的子进程）。托管给谁呢？可能是退出进程所在进程组的下一个进程（如果存在的话），或者是1号进程。所以每个进程、每时每刻都有父进程存在。除非它是1号进程。


> `1号进程`（init进程）的作用：
> 1. 执行系统初始化脚本，创建一系列进程
> 2. 在一个死循环中等待子进程的退出事件，并通过调用waitid系统调用来完成“收尸”工作。
> init进程不会被暂停、也不会被杀死（这是由内核来保证的）。它在等待子进程退出的过程中处于TASK_INTERRUPTIBLE状态，“收尸”过程中则处于TASK_RUNNING状态。

#### 制作一个僵尸进程

``` C
#include <stdio.h>

void main()
{
	if (fork())
		while(1) sleep(100);
}
```

```
$ ps aux | grep "a\.out"
xx    399198  0.0  0.0   2364   508 pts/1    S    17:35   0:00 ./a.out
xx    399201  0.0  0.0      0     0 pts/1    Z    17:35   0:00 [a.out] <defunct>
```
杀死僵尸进程时，必须杀死其父进程，让父进程回收僵尸进程。


### X:退出状态（dead）—— TASK_DEAD-EXIT_DEAD

进程在退出过程中也可能不会保留它的task_struct。比如这个进程是多线程程序中被detach过的进程

此时，进程将被置于`EXIT_DEAD`退出状态，这意味着接下来的代码立即就会将该进程彻底释放。所以EXIT_DEAD状态是非常短暂的，几乎不可能通过ps命令捕捉到。


## 进程的初始状态

进程是通过`fork`系列的系统调用（fork、clone、vfork）来创建的，内核（或内核模块）也可以通过`kernel_thread`函数创建内核进程。这些创建子进程的函数本质上都完成了相同的功能——将调用进程复制一份，得到子进程。（可以通过选项参数来决定各种资源是共享、还是私有）

那么既然调用进程处于`TASK_RUNNING`状态（否则，它若不是正在运行，又怎么进行调用？），则子进程默认也处于`TASK_RUNNING`状态。

另外，在系统调用调用clone和内核函数kernel_thread也接受CLONE_STOPPED选项，从而将子进程的初始状态置为 TASK_STOPPED。


## 进程状态变迁

原则：进程状态的变迁却只有两个方向
- **从`TASK_RUNNING`状态变为`非TASK_RUNNING`状态**
- **从`非TASK_RUNNING`状态变为`TASK_RUNNING`状态**

也就是说，如果给一个`TASK_INTERRUPTIBLE`状态的进程发送SIGKILL信号，这个进程将先被唤醒（进入`TASK_RUNNING`状态），然后再响应SIGKILL信号而退出（变为`TASK_DEAD`状态）; 并不会从`TASK_INTERRUPTIBLE`状态直接退出。

进程从`非TASK_RUNNING`状态变为`TASK_RUNNING`状态，是由别的进程（也可能是中断处理程序）执行唤醒操作来实现的。执行唤醒的进程设置被唤醒进程的状态为TASK_RUNNING，然后将其task_struct结构加入到某个CPU的可执行队列中。于是被唤醒的进程将有机会被调度执行。

而进程从`TASK_RUNNING`状态变为`非TASK_RUNNING`状态，则有两种途径：
- 响应信号而进入TASK_STOPED状态、或TASK_DEAD状态；
- 执行系统调用主动进入TASK_INTERRUPTIBLE状态（如nanosleep系统调用）、或TASK_DEAD状态（如exit系统调用）；或由于执行系统调用需要的资源得不到满足，而进入TASK_INTERRUPTIBLE状态或TASK_UNINTERRUPTIBLE状态（如select系统调用）

### 状态转换

![进程状态转换图](/images/2022/08/进程状态转换图.png)


## 查看进程状态

我们可以通过`ps`命令查看系统中各个进程的状态

- 在busybox中可以使用以下命令参数：
``` shell
ps -o comm,pid,ppid,pgid,vsz,sid,stat,rss
```
- 在正常系统中可以使用：
``` shell
ps -elf
```


```
# ps -o comm,pid,ppid,pgid,vsz,sid,stat,rss
COMMAND          PID   PPID  PGID  VSZ  SID   STAT RSS
init                 1     0     1 2792     1 S     456
kthreadd             2     0     0    0     0 SW      0
rcu_gp               3     2     0    0     0 IW<     0
rcu_par_gp           4     2     0    0     0 IW<     0
kworker/u4:0-ev      7     2     0    0     0 IW      0
mm_percpu_wq         8     2     0    0     0 IW<     0
ksoftirqd/0          9     2     0    0     0 SW      0
rcu_sched           10     2     0    0     0 IW      0
migration/0         11     2     0    0     0 SW      0
kworker/0:1-eve     12     2     0    0     0 IW      0
cpuhp/0             13     2     0    0     0 SW      0
cpuhp/1             14     2     0    0     0 SW      0
migration/1         15     2     0    0     0 SW      0
ksoftirqd/1         16     2     0    0     0 SW      0
kdevtmpfs           19     2     0    0     0 SW      0
netns               20     2     0    0     0 IW<     0
khungtaskd          21     2     0    0     0 SW      0
oom_reaper          22     2     0    0     0 SW      0
writeback           23     2     0    0     0 IW<     0
```

### STAT状态位

| STAT | 描述  |
|:----:|:-----|
| `I`  | 空闲内核线程（idle）  |
| `R`  | 运行或可运行（在运行队列上） |
| `S`  | 可中断睡眠（等待事件完成） |
| `D`  | 不可中断睡眠（通常是IO）  |
| `T`  | 由job控制信号停止  |
| `Z`  | 僵尸进程，终止但未被其父进程收割  |
| `X`  | 进程死了（永远不应该被看到）  |
| `W`  | 分页（自 2.6.xx 内核起无效）  |
| `t`  | 在跟踪（tracing）期间被调试器停止  |
| `<`  | 高优先级  |
| `N`  | 低优先级  |
| `L ` | 将页面锁定到内存中（用于实时和自定义IO）  |
| `s`  | 会话负责  |
| `\|` | 多线程（使用 CLONE_THREAD，就像 NPTL pthreads 一样）  |
| `+`  | 在前台进程组中  |



## 其他

### 孤儿进程

所谓孤儿进程，顾名思义，跟现实中的孤儿类似，当一个进程的父进程结束时，但是他自己还没有结束，那么该进程就变为孤儿进程。

孤儿进程会被init进程（1号进程）的进程收养，当然在子进程结束时也会由init进程完成对它的状态收集工作，因此一般来说，孤儿进程并不会有什么危害。


## 参考

1. [Linux中进程的六种状态](https://blog.csdn.net/qq_49613557/article/details/120294908)
2. [进程资源和进程状态 TASK_RUNNING TASK_INTERRUPTIBLE TASK_UNINTERRUPTIBLE ](https://www.cnblogs.com/yfceshi/p/6800069.html#:~:text=TASK_STO,NING%E7%8A%B6%E6%80%81%EF%BC%89%E3%80%82)
3. [Linux进程状态(ps stat)详解](https://www.cnblogs.com/programmer-tlh/p/11593330.html)
