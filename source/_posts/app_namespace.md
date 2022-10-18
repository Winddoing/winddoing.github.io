---
title: Namespace
categories:
  - 进程
tags:
  - namespace
  - 进程
abbrlink: 31401
date: 2018-03-27 23:07:24
---

容器，cgroup，namespace之间的关系：
```
       +-------------------------------------+
       |                                     |
       |            容器                     |   用户空间
       +-------------------------------------+
+-------------------------------------------------------+
       +--------------+  +-------------------+
       |  cgroup fs   |  |  syscall（clone） |
       +------+-------+  +---------+---------+
              ^                    ^
       +------+------+   +---------+---------+
       |  cgroup     |   |    namespace      |   内核空间
       +-------------+   +-------------------+
       +-------------+   +-------------------+
       |             |   |                   |
       |     CPU     |   |    PID，IPC，     |
       |    内存资源 |   |    网络等资源     |
       |             |   |                   |
       |             |   |                   |
       +-------------+   +-------------------+

```
<!--more-->

## Cgroup


## Namespace

Namespace又称为命名空间，它主要做访问隔离。其原理是针对一类资源进行抽象，并将其封装在一起提供给一个容器使用，对于这类资源，因为每个容器都有自己的抽象，而他们彼此之间是不可见的，所以就可以做到访问隔离。可以让每一个进程具有独立的`PID`，`IPC`和`网络空间`。

>通过执行clone系统调用可以划分命名空间，主要是根据clone的第3个参数flags标志进行设置

### 系统调用

* `clone()`: 实现线程的系统调用，用来创建一个新的进程，并可以通过设计上述参数达到隔离。
* `unshare()`: 使某进程脱离某个namespace
* `setns()`: 把某进程加入到某个namespace

### 资源划分

|    名 称	    |		说明	|
| :-----------: | :-----------: |
| CLONE_NEWIPC	| 划分IPC（进程间通信）命名空间，信号量，共享内存，消息队列，等进程间通信的资源	|
| CLONE_NEWNET	| 划分网络命令空间，分配网络接口 |
| CLONE_NEWNS	| 划分挂载命名空间。与chroot同样分配新的根文件系统	|
| CLONE_NEWPID	| 划分PID命名空间。分配新的进程ID空间 |
| CLONE_NEWUTS	| 划分UTS(主机名)命名空间。分配新的UTS空间	|


#### clone

创建一个子进程，后续的命名空间的划分在此基础上操作。

``` C
#define _GNU_SOURCE
#include <sys/types.h>
#include <sys/wait.h>
#include <stdio.h>
#include <sched.h>
#include <signal.h>
#include <unistd.h>

#define STACK_SIZE (1024*1024)
static char child_stack[STACK_SIZE];

char *const child_args[] = {
    "/bin/bash",
    NULL
};

int child_main(void *args)
{
    printf("in child process \n");
    execv(child_args[0], child_args);
    return 1;
}

int main()
{
    printf("process start: \n");
    int child_pid = clone(child_main, child_stack + STACK_SIZE, SIGCHLD, NULL);
    waitpid(child_pid, NULL, 0);
    printf("end \n");
    return 0;
}
```

#### UTS命名空间（CLONE_NEWUTS）

UTS命名空间，提供了主机名和域名的隔离。

``` C
#define _GNU_SOURCE
#include <sys/types.h>
#include <sys/wait.h>
#include <stdio.h>
#include <sched.h>
#include <signal.h>
#include <unistd.h>

#define STACK_SIZE (1024*1024)
static char child_stack[STACK_SIZE];

char *const child_args[] = {
	"/bin/bash",
	NULL
};

int child_main(void *args)
{
	printf("in child process \n");
	sethostname("NewNameSpace", 20); //设置新的主机名
	execv(child_args[0], child_args);
	return 1;
}

int main()
{
	printf("process start: \n");
	int child_pid = clone(child_main, child_stack + STACK_SIZE, CLONE_NEWUTS|SIGCHLD, NULL);
	waitpid(child_pid, NULL, 0);
	printf("end \n");

	return 0;
}
```

结果：
>```
>user@ingenic-xxx:~/namespace$ sudo ./a.out
>process start:
>in child process
>root@NewNameSpace:~/namespace# echo $HOSTNAME
>NewNameSpace
>root@NewNameSpace:~/namespace# exit
>exit
>end
>```

#### IPC命名空间（CLONE_NEWIPC）

IPC Namespace 是用来隔离 System V IPC 和POSIX message queues.每一个IPC Namespace都有他们自己的System V IPC 和POSIX message queue。

验证：消息队列

* ipcs查看队列
```
$ ipcs -q
```
* ipcmk创建队列
```
$ ipcmk -Q
```
* ipcrm删除队列
```
$ ipcrm -q 0
```

#### PID命名空间（CLONE_NEWPID）

PID namespace是用来隔离进程 id。同样的一个进程在不同的 PID Namespace 里面可以拥有不同的 PID。空间内的PID 是独立分配的，意思就是命名空间内的虚拟 PID 可能会与命名空间外的 PID 相冲突，于是命名空间内的 PID 映射到命名空间外时会使用另外一个 PID。比如说，命名空间内第一个 PID 为1，而在命名空间外就是该 PID 已被 init 进程所使用。

验证： `echo $$`

>在子进程的shell里输入ps,top等命令，我们还是可以看得到所有进程。说明并没有完全隔离。这是因为，像ps, top这些命令会去读/proc文件系统，所以，因为/proc文件系统在父进程和子进程都是一样的，所以这些命令显示的东西都是一样的。

#### mount命名空间（CLONE_NEWNS）

进程运行时可以将挂载点与系统分离，使用这个功能时，我们可以达到 chroot 的功能进程运行时可以将挂载点与系统分离，使用这个功能时，可以达到 chroot 的功能

>在通过`CLONE_NEWNS`创建mount namespace后，父进程会把自己的文件结构复制给子进程中。而子进程中新的namespace中的所有mount操作都只影响自身的文件系统，而不对外界产生任何影响。这样可以做到比较严格地隔离。

### 小应用



## 参考

1. [网络虚拟化基础一：linux名称空间Namespaces](https://www.cnblogs.com/linhaifeng/p/6657119.html)
