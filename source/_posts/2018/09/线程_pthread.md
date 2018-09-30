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
> 以`阻塞`的方式等待thread指定的线程结束。当函数返回时，被等待线程的资源被收回。如果线程已经结束，那么该函数会立即返回。并且thread指定的线程必须是joinable的。

作用：
- 主线程等待子线程的终止
- 在子线程调用了`pthread_join()``方法后面的代码，只有等到子线程结束了才能执行。

### pthread_detach

``` C
/* Indicate that the thread TH is never to be joined with PTHREAD_JOIN.
   The resources of TH will therefore be freed immediately when it
   terminates, instead of waiting for another thread to perform PTHREAD_JOIN
   on it.  */
extern int pthread_detach (pthread_t __th) __THROW;
```
用于是指定线程变为分离状态，就像进程脱离终端而变为后台进程类似。成功返回0，否则返回Exxx（为正数）。变为分离状态的线程，如果线程退出，它的所有资源将全部释放。而如果不是分离状态，线程必须保留它的线程ID，退出状态直到其它线程对它调用了pthread_join。


### pthread_self

``` C
/* Obtain the identifier of the current thread.  */                             
extern pthread_t pthread_self (void) __THROW __attribute__ ((__const__));       
```
获取线程自身的ID，该id由线程库维护，其id空间是各个进程独立的（即不同进程中的线程可能有相同的id）。

- 比较两个线程ID
``` C
/* Compare two thread identifiers.  */                                  
extern int pthread_equal (pthread_t __thread1, pthread_t __thread2)     
  __THROW __attribute__ ((__const__));                                  
```

### 线程属性

线程属性结构体`pthread_attr_t`

``` C
typedef struct{
    int etachstate;     //线程的分离状态
    int schedpolicy;    //线程的调度策略
    struct　sched schedparam;//线程的调度参数
    int inheritsched;   //线程的继承性
    int scope;          //线程的作用域
    size_t guardsize;   //线程栈末尾的警戒缓冲区大小
    int stackaddr_set;  //线程栈的设置
    void* stackaddr;    //线程栈的启始位置
    size_t stacksize;   //线程栈大小
}pthread_attr_t;
```

- 操作接口函数：

``` C
/* Initialize thread attribute *ATTR with default attributes                          
   (detachstate is PTHREAD_JOINABLE, scheduling policy is SCHED_OTHER,                
    no user-provided stack).  */                                                      
extern int pthread_attr_init (pthread_attr_t *__attr) __THROW __nonnull ((1));        

/* Destroy thread attribute *ATTR.  */                                                
extern int pthread_attr_destroy (pthread_attr_t *__attr)                              
     __THROW __nonnull ((1));                                                         

/* Get detach state attribute.  */                                                    
extern int pthread_attr_getdetachstate (const pthread_attr_t *__attr,                 
                    int *__detachstate)                                               
     __THROW __nonnull ((1, 2));                                                      

/* Set detach state attribute.  */                                                    
extern int pthread_attr_setdetachstate (pthread_attr_t *__attr,                       
                    int __detachstate)                                                
     __THROW __nonnull ((1));                                                         
```

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

信号量：
> 使用条件变量（信号量）可以以原子方式阻塞线程，直到某个特定条件为真为止。条件变量始终与互斥锁一起使用。对条件的测试是在互斥锁（互斥）的保护下进行的。如果条件为假，线程通常会基于条件变量阻塞，并以原子方式释放等待条件变化的互斥锁。

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

### pthread_barrier_xxx

线程同步，`pthread_barrier_*`其实只做且只能做一件事，就是充当栏杆（barrier意为栏杆)。形象的说就是把先后到达的多个线程挡在同一栏杆前，直到所有线程到齐，然后撤下栏杆同时放行。

``` C
/* Initialize BARRIER with the attributes in ATTR.  The barrier is        
   opened when COUNT waiters arrived.  */                                 
extern int pthread_barrier_init (pthread_barrier_t *__restrict __barrier,
                 const pthread_barrierattr_t *__restrict                  
                 __attr, unsigned int __count)                            
     __THROW __nonnull ((1));                                             

/* Destroy a previously dynamically initialized barrier BARRIER.  */      
extern int pthread_barrier_destroy (pthread_barrier_t *__barrier)         
     __THROW __nonnull ((1));                                             

/* Wait on barrier BARRIER.  */                                           
extern int pthread_barrier_wait (pthread_barrier_t *__barrier)            
     __THROWNL __nonnull ((1));                                           
```
1. init函数负责指定要等待的线程个数
2. wait()函数由每个线程主动调用，它告诉栏杆“我到起跑线前了”。
    - wait(）执行末尾栏杆会检查是否所有人都到栏杆前了
    - 如果是，栏杆就消失所有线程继续执行下一句代码
    - 如果不是，则所有已到wait()的线程等待，剩下没执行到wait()的线程继续执行
3. destroy函数释放init申请的资源。

应用场景：
> 比如A和B两人相约在某一个地点C集合去打猎，A和B都知道地方C，但是他们到达的时间不确定，因此谁先到就需要在C点等。

### pthread_once

``` C
/* Guarantee that the initialization function INIT_ROUTINE will be called
   only once, even if pthread_once is executed several times with the     
   same ONCE_CONTROL argument. ONCE_CONTROL must point to a static or     
   extern variable initialized to PTHREAD_ONCE_INIT.                      

   The initialization functions might throw exception which is why        
   this function is not marked with __THROW.  */                          
extern int pthread_once (pthread_once_t *__once_control,                  
             void (*__init_routine) (void)) __nonnull ((1, 2));
```

pthread_once能够保证`__init_routine`只被调用一次，具体在哪个线程中执行是不定的


- 用法:
``` C
pthread_once_t once=PTHREAD_ONCE_INIT;
{
    ...
    pthread_once(&once,once_init_routine);
}
```

## 线程私有数据Thread Specific Data (TSD)

在单线程程序中，我们经常使用 “全局变量” 以实现多个函数间共享数据，在多线程环境下，由于数据空间是共享的，因此全局变量也为所有线程所共享。但有时应用程序设计中有必要提供`线程私有的全局变量`，仅在某个线程中有效，但却可以跨多个函数访问

``` C
/* Functions for handling thread-specific data.  */                             

/* Create a key value identifying a location in the thread-specific             
   data area.  Each thread maintains a distinct thread-specific data            
   area.  DESTR_FUNCTION, if non-NULL, is called with the value                 
   associated to that key when the key is destroyed.                            
   DESTR_FUNCTION is not called if the value associated is NULL when            
   the key is destroyed.  */                                                    
extern int pthread_key_create (pthread_key_t *__key,                            
                   void (*__destr_function) (void *))                           
     __THROW __nonnull ((1));                                                   

/* Destroy KEY.  */                                                             
extern int pthread_key_delete (pthread_key_t __key) __THROW;                    

/* Return current value of the thread-specific data slot identified by KEY.  */
extern void *pthread_getspecific (pthread_key_t __key) __THROW;                 

/* Store POINTER in the thread-specific data slot identified by KEY. */         
extern int pthread_setspecific (pthread_key_t __key,                            
                const void *__pointer) __THROW ;
```


## 数据结构

> /usr/include/x86_64-linux-gnu/bits/pthreadtypes.h

``` C
/* Thread identifiers.  The structure of the attribute type is not             
   exposed on purpose.  */                                                     
typedef unsigned long int pthread_t;                                           


/* Keys for thread-specific data */                                            
typedef unsigned int pthread_key_t;                                            


/* Once-only execution */                                                      
typedef int __ONCE_ALIGNMENT pthread_once_t;                                   

union pthread_attr_t                            
{                                               
  char __size[__SIZEOF_PTHREAD_ATTR_T];         
  long int __align;                             
};                                              
#ifndef __have_pthread_attr_t                   
typedef union pthread_attr_t pthread_attr_t;    
# define __have_pthread_attr_t 1                
#endif                                          


typedef union                                   
{                                               
  struct __pthread_mutex_s __data;              
  char __size[__SIZEOF_PTHREAD_MUTEX_T];        
  long int __align;                             
} pthread_mutex_t;                              


typedef union                                   
{                                               
  struct __pthread_cond_s __data;               
  char __size[__SIZEOF_PTHREAD_COND_T];         
  __extension__ long long int __align;          
} pthread_cond_t;                               
```

## 示例

- [pthread.c](https://raw.githubusercontent.com/Winddoing/CodeWheel/master/C/pthread/pthread.c)
- [threadpool](https://github.com/Winddoing/CodeWheel/tree/master/C/pthread/threadpool)

## 参考

* [Linux多线程编程（不限Linux)](http://www.cnblogs.com/skynet/archive/2010/10/30/1865267.html)
* [pthreads 的基本用法](https://www.ibm.com/developerworks/cn/linux/l-pthred/#ibm-pcon)
