---
layout: post
title: '进程状态-Z:僵尸进程产生的原因'
date: '2018-12-20 17:36'
tags:
  - 进程
categories:
  - 进程
  - 进程状态
abbrlink: 5718
---

`Z (zombie)`:僵死状态是一个比较特殊的状态。进程在退出的过程中，处于`TASK_DEAD`状态。
> 在这个退出过程中，进程占有的所有资源将被回收，除了task_struct结构（以及少数资源）以外。于是进程就只剩下task_struct这么个空壳，故称为僵尸。

``` shell
# ps
  PID USER       VSZ STAT COMMAND
    1 root      3100 S    init
    2 root         0 SW   [kthreadd]
    3 root         0 SW   [ksoftirqd/0]
    4 root         0 SW   [kworker/0:0]
    5 root         0 SW<  [kworker/0:0H]
    6 root         0 SW   [kworker/u8:0]
    ...
    1380 root      0 Z    [view]     #僵尸进程
    ...
    1392 root   3104 S    -/bin/sh
    1404 root      0 SW<  [kworker/2:1H]
    1429 root      0 SW<  [kworker/0:1H]
    1444 root      0 SW<  [kworker/1:1H]
```
- 僵尸进程产生的原因???
- 如何确定根本原因???
- 如何避免???

<!--more-->

## 僵尸进程产生的原因

>**僵尸进程**: 是当子进程比父进程先结束，而父进程又没有回收子进程，释放子进程占用的资源（也就是子进程先于父进程结束），此时子进程将成为一个僵尸进程。如果父进程先退出 ，子进程被init接管，子进程退出后init会回收其占用的相关资源

原因:
1. 子进程被直接杀死
2. 子进程无法正常关闭

场景:主进程创建的线程在进行数据搬运时,搬运数据的大小超过了放置数据buffer的大小,导致部分数据被污染,最终导致子线程在运行过程中出现段错误,将其直接杀死,没有等到父进程回收,而产生了僵尸进程.

## 为什么子进程结束时，不直接退出

因为父进程有时候需要获取到子进程的退出状态，如果是正常退出，可以直接将其释放，如果是异常退出，又可以根据异常信息进行进一步的相关操作。

## 调试&&Debug

- 查找子进程被杀死的原因,如,段错误可以重新定义段错误信号的处理打印部分信息.
- 排查显示fork和隐式fork,对子进程的操作.
- 子进程退出信号`signal(SIGCHLD,sig_child)`的自定义处理

## 设计时的预防

* 父进程通过wait和waitpid等函数等待子进程结束，这会导致父进程挂起。
    - 执行wait（）或waitpid（）系统调用，则子进程在终止后会立即把它在进程表中的数据返回给父进程，此时系统会立即删除该进入点。在这种情形下就不会产生defunct进程。

* 如果父进程很忙，那么可以用signal函数为SIGCHLD安装handler。在子进程结束后，父进程会收到该信号，可以在handler中调用wait回收。

* 如果父进程不关心子进程什么时候结束，那么可以用`signal(SIGCLD, SIG_IGN)`或`signal(SIGCHLD, SIG_IGN)`通知内核，自己对子进程的结束不感兴趣，那么子进程结束后，内核会回收，并不再给父进程发送信号
  - signal(SIGCHLD, SIG_IGN): 通过信号回收子进程的SIGCHLD. 子进程要终止了，发个SIGCHLD信号告诉父进程, 设置`SIG_IGN`忽略信号，则表示父进程不关心子进程退出，子进程退出后内核把资源回收即可。
  - signal(SIGCLD, SIG_IGN): 子进程状态改变后产生此信号，该信号的配置为SIG_IGN, 子进程状态信息会被丢弃，也就是自动回收了，则调用进程的子进程将不产生僵死进程

* fork两次，父进程fork一个子进程，然后继续工作，子进程fork一个孙进程后退出，那么孙进程被init接管，孙进程结束后，init会回收。不过子进程的回收还要自己做


## 父进程退出时通知子进程退出

- 方法1：在子进程和父进程之间建立通信管道(`socketpair(PF_LOCAL, SOCK_STREAM, 0, fd)`)，一旦通信异常，则认为父进程退出，子进程自己也回收资源退出。
- 方法2：借助`prctl`函数中的`PR_GET_PDEATHSIG`参数, 在子进程中添加`prctl(PR_SET_PDEATHSIG,SIGKILL);`，这样父进程退出时，子进程将会收到SIGKILL信号，而进程收到该信号的默认动作则是退出。

```
PR_SET_PDEATHSIG (since Linux 2.1.57)
       Set the parent-death signal of the calling process to arg2 (either a signal value in the range 1..maxsig, or 0 to clear).  This is the signal that the calling process will get when its parent dies.

       Warning:  the  "parent"  in this case is considered to be the thread that created this process.  In other words, the signal will be sent when that thread terminates (via, for example, pthread_exit(3)), rather than
       after all of the threads in the parent process terminate.

       The parent-death signal is sent upon subsequent termination of the parent thread and also upon termination of each subreaper process (see the description of PR_SET_CHILD_SUBREAPER above) to  which  the  caller  is
       subsequently reparented.  If the parent thread and all ancestor subreapers have already terminated by the time of the PR_SET_PDEATHSIG operation, then no parent-death signal is sent to the caller.

       The  parent-death  signal is process-directed (see signal(7)) and, if the child installs a handler using the sigaction(2) SA_SIGINFO flag, the si_pid field of the siginfo_t argument of the handler contains the PID
       of the terminating parent process.

       The parent-death signal setting is cleared for the child of a fork(2).  It is also (since Linux 2.4.36 / 2.6.23) cleared when executing a set-user-ID or set-group-ID binary, or a binary that has  associated  capa‐
       bilities (see capabilities(7)); otherwise, this value is preserved across execve(2).
```

## 子进程状态变为`Zl`

``` shell
# ps aux | grep enc-test
vx        132525  0.0  0.0      0     0 pts/0    Zl   02:14   0:00 [enc-test-16] <defunct>
vx        132586  0.0  0.0      0     0 pts/0    Zl   02:14   0:00 [enc-test-56] <defunct>

$ ps -A -ostat,ppid,pid,cmd | grep -e '^[Zz]'
Zl         1  132525 [enc-test-16] <defunct>
Zl         1  132586 [enc-test-56] <defunct>
```

当前系统无法使用gdb和strace，但是系统配置均正常，是否为僵尸进程就无法被attach。

出现错误信息：
```
strace: Could not attach to process. If your uid matches the uid of the target process, check the setting of /proc/sys/kernel/yama/ptrace_scope, or try again as the root user. For more details, see /etc/sysctl.d/10-ptrace.conf: Operation not permitted
strace: attach: ptrace(PTRACE_SEIZE, 132525): Operation not permitted
```
> 注：系统已经正确配置将`/etc/sysctl.d/10-ptrace.conf`文件中修改`kernel.yama.ptrace_scope = 0`并且系统进行了重启，重启后`/proc/sys/kernel/yama/ptrace_scope`为`0`,但是还是无法使用。
> (strace系统中的其他正常进程是正常的)


### 栈信息

通过proc文件系统查看进程当前栈信息

```
$ sudo cat /proc/132525/stack
$
```
没有输出如何栈信息，也就是说当前出问题的进程没有运行，正是僵尸进程的表现。

### 该僵尸进程如何产生

一个进程使用fork创建子进程，如果子进程退出，而父进程并没有调用wait或waitpid获取子进程的状态信息，那么子进程的进程描述符仍然保存在系统中。这种进程称之为`僵死进程`。

其实就是子进程退出的时候父进程不知道，因此解决方法就是在子进程退出时，告诉父进程一下（参考：设计时的预防）。

而该测试中的僵尸进程是由于测试进程在循环测试中，Ctrl+C终止测试时，偶尔会产生僵尸进程，应该是在测试程序运行过程中，子进程和父进程先后收到了Ctrl+c信号（可能信号处理的时序问题）导致部分子进程退出时，父进程已经退出没有来的即调用wait接口，无人回收资源变为僵尸进程。

### 解决方法

在进程中忽略INT信号（也就是Ctrl+c），如果实际业务流程需要，可以自己实现INT信号的处理函数。
