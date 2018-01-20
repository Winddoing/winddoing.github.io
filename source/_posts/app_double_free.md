---
title: double free or corruption (fasttop)
date: 2018-01-15 23:07:24
categories: 程序设计
tags: [app, free]
---

```
*** Error in `./rixitest-static-ok': double free or corruption (fasttop): 0x76e006f0 ***`
```

>在进行多线程编程的时候，可能出现`double free` 问题。主要是在多线程函数中有个对`new`出来的变量进行操作，但是未加锁同步导致的。只要在在对new变量进行读写操作之前，加个锁，就可以避免该问题的产生。

`0x76e006f0` : 多次`free`的变量地址，变量（或对象）通过`new`得到的，地址空间在堆里。

在多线程测试中，由于其中一个线程因为异常而exit(-1)退出时，另外的线程也可能因为异常对象的生命周期结束而执行析构函数去delete同一个变量。
<!--more-->

## `exit` and `_exit`

>用于终止一个程序

``` C
void exit(int status);
void _exit(int status);
```
![exit_and__exit](/images/app/exit_and__exit.png)

`_exit`直接进入内核，`exit`则先执行一些清除处理（在进程退出之前要检查文件状态，将文件缓冲区中的内容写回文件）再进入内核


调用`_exit`函数时，其会关闭进程所有的文件描述符，清理内存以及其他一些内核清理函数，但不会刷新流（stdin,stdout,stderr…）.`exit`函数是在`_exit`函数之上增加了一个封装，写回文件缓存区中的内容


## 析构函数何时被调用

析构函数在下边3种情况时被调用：

1. 对象生命周期结束，被销毁时；
2. delete指向对象的指针时，或delete指向对象的基类类型指针，而其基类虚构函数是虚函数时；
3. 对象i是对象o的成员，o的析构函数被调用时，对象i的析构函数也被调用。

## 固定程序的加载地址

关闭`ASLR`，每次执行时，进程的加载地址将被固定。

``` C
echo 0 > /proc/sys/kernel/randomize_va_space
```
>ASLR（Address space layout randomization）是一种针对缓冲区溢出的安全保护技术，通过对堆、栈、共享库映射等线性区布局的随机化，通过增加攻击者预测目的地址的难度，防止攻击者直接定位攻击代码位置，达到阻止溢出攻击的目的。

## 信号处理

``` C
void Exception::InstallException(){
	memset(&mCurrentAction,0,sizeof(struct sigaction));
	mCurrentAction.sa_handler = Exception::segv_handler;
	mCurrentAction.sa_flags = SA_RESTART | SA_SIGINFO;
	sigemptyset(&mCurrentAction.sa_mask);

	sigaction (SIGSEGV, &mCurrentAction, NULL);
}
void Exception::unInstallException(){
	sigaction (SIGSEGV, &mOldAction, NULL);
}
void Exception::segv_handler(int sig)
{
	...
	exit(-1); //Error
	...
}
```
在自定义捕获异常信号时，对异常的处理中不能使用`exit()`来结束进程。

原因：
1. 在异常处理中，系统已经陷入内核态进行`do_singal`的操作，而测试的异常处理函数中存在`exit()`，执行exit并等待其完成需要等异常信号的完成，而测试正在进行异常信号的处理，因此将造成死锁现象。
2. 异常处理的多次重入，如果在执行exit时，产生新的相同的异常信号，但是此时由于系统的性能下降（存在多个进程执行，压力测试），使其exit的执行需要一定的CPU周期后才可以完成，这时将进行可能在一次进入异常处理，并再一次执行exit，可能将对相同的资源进行再一次的释放，从而造成`double free`的错误


### 疑问？？？

1. 如果在信号处理中调用exit可以造成死锁，为啥不是必现？

2. 两次重入可能对资源造成二次释放的现象，为啥每次释放的地址相同？


## 进程号

``` C
struct task_struct {
    ...
    pid_t pid;
    pid_t tgid;
    ...
}
```

用户空间获取`pid`和`tgid`, 分别是`syscall(SYS_gettid)`和`getpid`

在linux系统中，我们用pid区分每一个进程，linux给每一个进程和轻量级进程都分配一个pid，但是linux程序员希望由一个进程产生的轻量级进程具有相同的pid，这样当我们向进程发送信号时，此信号可以影响进程及进程产生的轻量级进程。
为了做到这一点，linux用了线程组（可以理解为轻量级进程组）的概念，在线程组内，每个线程都使用此线程组内第一个线程(thread group leader)的pid，并将此值存入tgid

### pid和tgid的关系

>The four threads will have the same PID but only when viewed from above. What you (as a user) call a PID is not what the kernel (looking from below) calls a PID.

>In the kernel, each thread has it's own ID, called a PID (although it would possibly make more sense to call this a TID, or thread ID) and they also have a TGID (thread group ID) which is the PID of the thread that started the whole process.

>Simplistically, when a new process is created, it appears as a thread where both the PID and TGID are the same (new) number.

>When a thread starts another thread, that started thread gets its own PID (so the scheduler can schedule it independently) but it inherits the TGID from the original thread.

>That way, the kernel can happily schedule threads independent of what process they belong to, while processes (thread group IDs) are reported to you.

```
              USER VIEW
 <-- PID 43 --> <----------------- PID 42 ----------------->
                     +---------+
                     | process |
                    _| pid=42  |_
                  _/ | tgid=42 | \_ (new thread) _
       _ (fork) _/   +---------+                  \
      /                                        +---------+
+---------+                                    | process |
| process |                                    | pid=44  |
| pid=43  |                                    | tgid=42 |
| tgid=43 |                                    +---------+
+---------+
 <-- PID 43 --> <--------- PID 42 --------> <--- PID 44 --->
                     KERNEL VIEW
```


## example

``` C
#include <iostream>
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <pthread.h>

using namespace std;

class Test
{
	public:
		Test(int i)
		{
			m_i = i;
			printf("%s: construct %d\n", __func__, m_i);
		};
		~Test()
		{
			printf("%s: destruct %d\n", __func__,  m_i);
		};
	private:
		int m_i;
};

Test t_1(1);

void *threadFunc(void *arg)
{
	Test t_3(3);

/*	exit(1);*/
	return NULL;
}

int main(int argc, char* argv[])
{
	pthread_t thread;
	int err;
	Test t_2(2);

	err = pthread_create(&thread, NULL, threadFunc, NULL);
	if (err != 0)
		printf("pthread_create fail!!!\n");

	pthread_join(thread,NULL);
	printf("Hello World\n");

	return 0;
/*	exit (0);*/
/*	_exit(0);*/
}
```

### main(return), threadFunc(return)

```
Test: construct 1
Test: construct 2
Test: construct 3
~Test: destruct 3
Hello World
~Test: destruct 2
~Test: destruct 1
```
### main(return)，threadFunc(exit)

```
Test: construct 1
Test: construct 2
Test: construct 3
~Test: destruct 1
```

### main(exit)，threadFunc(return)

```
Test: construct 1
Test: construct 2
Test: construct 3
~Test: destruct 3
Hello World
~Test: destruct 1
```

### main(_exit)，threadFunc(return)

```
Test: construct 1
Test: construct 2
Test: construct 3
~Test: destruct 3
Hello World
```

## 参考

1. [The Linux Process Principle，NameSpace, PID、TID、PGID、PPID、SID、TID、TTY](https://www.cnblogs.com/LittleHann/p/4026781.html)
2. [task_struct解析(三) 进程id ](http://blog.chinaunix.net/uid-21718047-id-3069416.html)

