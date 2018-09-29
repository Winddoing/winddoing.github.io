---
layout: post
title: 线程--pthread
date: '2018-09-29 13:53'
tags:
  - 线程
categories:
  - 程序设计
---

Linux系统下的多线程遵循`POSIX线程`接口，称为`pthread`。编写Linux下的多线程程序，需要使用头文件`<pthread.h>`，链接时需要使用库libpthread.so。Linux下pthread的实现是通过系统调用`clone()`来实现的。

``` shell
gcc pthread_create.c -o pthread_create -lpthread
```
- pthread
``` C
$ldd pthread_create
	linux-vdso.so.1 (0x00007fff45dfe000)
	libpthread.so.0 => /lib/x86_64-linux-gnu/libpthread.so.0 (0x00007f5a42a08000)
	libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f5a42617000)
	/lib64/ld-linux-x86-64.so.2 (0x00007f5a42e29000)
```

<!--more-->

## 线程

`进程`是程序执行时的一个`实例`，即它是程序已经执行到何种程度的数据结构的汇集。从内核的观点看，进程的目的就是担当`分配系统资源`（CPU时间、内存等）的基本单位。

`线程`是进程的一个`执行流`，是CPU调度和分派的基本单位，它是比进程更小的能独立运行的基本单位。一个进程由几个线程组成（拥有很多相对独立的执行流的用户程序共享应用程序的大部分数据结构），线程与同属一个进程的其他的线程共享进程所拥有的全部资源。

> "进程——资源分配的最小单位，线程——程序执行的最小单位"

> 进程有独立的地址空间，线程没有单独的地址空间（同一进程内的线程共享进程的地址空间）

优点：
- 提高应用程序响应。这对图形界面的程序尤其有意义，当一个操作耗时很长时，整个系统都会等待这个操作，此时程序不会响应键盘、鼠标、菜单的操作，而使用多线程技术，将耗时长的操作（time consuming）置于一个新的线程，可以避免这种尴尬的情况。
- 使多CPU系统更加有效。操作系统会保证当线程数不大于CPU数目时，不同的线程运行于不同的CPU上。
- 改善程序结构。一个既长又复杂的进程可以考虑分为多个线程，成为几个独立或半独立的运行部分，这样的程序会利于理解和修改。


## 使用多线程的理由

1. 理由之一是和进程相比，它是一种非常"节俭"的多任务操作方式。我们知道，在Linux系统下，启动一个新的进程必须分配给它独立的地址空间，建立众多的数据表来维护它的代码段、堆栈段和数据段，这是一种"昂贵"的多任务工作方式。而运行于一个进程中的多个线程，它们彼此之间使用相同的地址空间，共享大部分数据，`启动一个线程所花费的空间远远小于启动一个进程所花费的空间`，而且，`线程间彼此切换所需的时间也远远小于进程间切换所需要的时间`。据统计，总的说来，一个进程的开销大约是一个线程开销的`30倍`左右，当然，在具体的系统上，这个数据可能会有较大的区别。

2. 理由之二是线程间方便的`通信机制`。对不同进程来说，它们具有独立的数据空间，要进行数据的传递只能通过通信的方式进行，这种方式不仅费时，而且很不方便。线程则不然，由于同一进程下的线程之间共享数据空间，所以一个线程的数据可以直接为其它线程所用，这不仅快捷，而且方便。当然，数据的共享也带来其他一些问题，有的变量不能同时被两个线程所修改，有的子程序中声明为static的数据更有可能给多线程程序带来灾难性的打击，这些正是编写多线程程序时最需要注意的地方。


从函数调用上来说，进程创建使用`fork()`操作；线程创建使用`clone()`操作。Richard Stevens大师这样说过：

> fork is expensive. Memory is copied from the parent to the child, all descriptors are duplicated in the child, and so on. Current implementations use a technique called copy-on-write, which avoids a copy of the parent's data space to the child until the child needs its own copy. But, regardless of this optimization, fork is expensive.

> IPC is required to pass information between the parent and child after the fork. Passing information from the parent to the child before the fork is easy, since the child starts with a copy of the parent's data space and with a copy of all the parent's descriptors. But, returning information from the child to the parent takes more work.

> Threads help with both problems. Threads are sometimes called lightweight processes since a thread is "lighter weight" than a process. That is, thread creation can be 10–100 times faster than process creation.

> All threads within a process share the same global memory. This makes the sharing of information easy between the threads, but along with this simplicity comes the problem of synchronization.


## pthread接口

> `#include <pthread.h> `  #/usr/include/pthread.h

### pthread_create

``` C
/* Create a new thread, starting with execution of START-ROUTINE
   getting passed ARG.  Creation attributed come from ATTR.  The new
   handle is stored in *NEWTHREAD.  */
extern int pthread_create (pthread_t *__restrict __newthread,
               const pthread_attr_t *__restrict __attr,
               void *(*__start_routine) (void *),
               void *__restrict __arg) __THROWNL __nonnull ((1, 3));

```

用于创建一个线程，成功返回0，否则返回Exxx（为正数）。

### pthread_exit

``` C
/* Terminate calling thread.

   The registered cleanup handlers are called via exception handling
   so we cannot mark this function with __THROW.*/
extern void pthread_exit (void *__retval) __attribute__ ((__noreturn__));
```
用于终止线程，可以指定返回值，以便其他线程通过pthread_join函数获取该线程的返回值。

### pthread_join

``` C
/* Make calling thread wait for termination of the thread TH.  The
   exit status of the thread is stored in *THREAD_RETURN, if THREAD_RETURN
   is not NULL.

   This function is a cancellation point and therefore not marked with
   __THROW.  */
extern int pthread_join (pthread_t __th, void **__thread_return);
```
用于等待某个线程退出，成功返回0，否则返回Exxx（为正数）。

### pthread_detach

``` C
/* Indicate that the thread TH is never to be joined with PTHREAD_JOIN.
   The resources of TH will therefore be freed immediately when it
   terminates, instead of waiting for another thread to perform PTHREAD_JOIN
   on it.  */
extern int pthread_detach (pthread_t __th) __THROW;
```
用于是指定线程变为分离状态，就像进程脱离终端而变为后台进程类似。成功返回0，否则返回Exxx（为正数）。变为分离状态的线程，如果线程退出，它的所有资源将全部释放。而如果不是分离状态，线程必须保留它的线程ID，退出状态直到其它线程对它调用了pthread_join。


### 线程之间互斥

互斥锁：
>使用互斥锁（互斥）可以使线程按顺序执行。通常，互斥锁通过确保一次只有一个线程执行代码的临界段来同步多个线程。互斥锁还可以保护单线程代码。

``` C
/* Mutex handling.  */

/* Initialize a mutex.  */
extern int pthread_mutex_init (pthread_mutex_t *__mutex,
                   const pthread_mutexattr_t *__mutexattr)
     __THROW __nonnull ((1));

/* Destroy a mutex.  */
extern int pthread_mutex_destroy (pthread_mutex_t *__mutex)
     __THROW __nonnull ((1));

/* Try locking a mutex.  */
extern int pthread_mutex_trylock (pthread_mutex_t *__mutex)
     __THROWNL __nonnull ((1));

/* Lock a mutex.  */
extern int pthread_mutex_lock (pthread_mutex_t *__mutex)
     __THROWNL __nonnull ((1));

/* Unlock a mutex.  */
extern int pthread_mutex_unlock (pthread_mutex_t *__mutex)
     __THROWNL __nonnull ((1));

/* Get the priority ceiling of MUTEX.  */
extern int pthread_mutex_getprioceiling (const pthread_mutex_t *
                     __restrict __mutex,
                     int *__restrict __prioceiling)
     __THROW __nonnull ((1, 2));

/* Set the priority ceiling of MUTEX to PRIOCEILING, return old
   priority ceiling value in *OLD_CEILING.  */
extern int pthread_mutex_setprioceiling (pthread_mutex_t *__restrict __mutex,
                     int __prioceiling,
                     int *__restrict __old_ceiling)
     __THROW __nonnull ((1, 3));
```

临界资源保护：
1. 声明`pthread_mutex_t `类型的变量，并初始化`pthread_mutex_init`
2. 对临界资源加锁`pthread_mutex_lock`
3. 其他操作（Do something）
3. 对临界资源解锁`pthread_mutex_unlock`

### 线程同步

条件变量：
> 使用条件变量可以以原子方式阻塞线程，直到某个特定条件为真为止。条件变量始终与互斥锁一起使用。对条件的测试是在互斥锁（互斥）的保护下进行的。如果条件为假，线程通常会基于条件变量阻塞，并以原子方式释放等待条件变化的互斥锁。

``` C
/* Functions for handling conditional variables.  */

/* Initialize condition variable COND using attributes ATTR, or use
   the default values if later is NULL.  */
extern int pthread_cond_init (pthread_cond_t *__restrict __cond,
                  const pthread_condattr_t *__restrict __cond_attr)
     __THROW __nonnull ((1));

/* Destroy condition variable COND.  */
extern int pthread_cond_destroy (pthread_cond_t *__cond)
     __THROW __nonnull ((1));

/* Wake up one thread waiting for condition variable COND.  */
extern int pthread_cond_signal (pthread_cond_t *__cond)
     __THROWNL __nonnull ((1));

/* Wake up all threads waiting for condition variables COND.  */
extern int pthread_cond_broadcast (pthread_cond_t *__cond)
     __THROWNL __nonnull ((1));

/* Wait for condition variable COND to be signaled or broadcast.
   MUTEX is assumed to be locked before.

   This function is a cancellation point and therefore not marked with
   __THROW.  */
extern int pthread_cond_wait (pthread_cond_t *__restrict __cond,
                  pthread_mutex_t *__restrict __mutex)
     __nonnull ((1, 2));

/* Wait for condition variable COND to be signaled or broadcast until
   ABSTIME.  MUTEX is assumed to be locked before.  ABSTIME is an
   absolute time specification; zero is the beginning of the epoch
   (00:00:00 GMT, January 1, 1970).

   This function is a cancellation point and therefore not marked with
   __THROW.  */
extern int pthread_cond_timedwait (pthread_cond_t *__restrict __cond,
                   pthread_mutex_t *__restrict __mutex,
                   const struct timespec *__restrict __abstime)
     __nonnull ((1, 2, 3));
```
`pthread_cond_wait`用于等待某个特定的条件为真，`pthread_cond_signal`用于通知阻塞的线程某个特定的条件为真了。在调用者两个函数之前需要声明一个`pthread_cond_t`类型的变量，用于这两个函数的参数。

>`pthread_cond_wait`只是唤醒等待某个条件变量的一个线程。如果需要唤醒所有等待某个条件变量的线程，需要调用：
``` C
int pthread_cond_broadcast (pthread_cond_t *__cond)
```

## 参考

* [Linux多线程编程（不限Linux)](http://www.cnblogs.com/skynet/archive/2010/10/30/1865267.html)
* [pthreads 的基本用法](https://www.ibm.com/developerworks/cn/linux/l-pthred/#ibm-pcon)
