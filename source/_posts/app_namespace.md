---
title: Namespace
date: 2018-03-27 23:07:24
categories: 进程
tags: [namespace, 进程]
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

#### PID命名空间（CLONE_NEWPID）

#### mount命名空间（CLONE_NEWNS）

## 参考

1. [网络虚拟化基础一：linux名称空间Namespaces](https://www.cnblogs.com/linhaifeng/p/6657119.html)
