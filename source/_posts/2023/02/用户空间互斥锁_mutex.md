---
layout: post
title: 用户空间互斥锁-mutex
date: '2023-02-14 19:07'
tags:
  - mutex
categories:
  - 程序设计
---

在linux系统中多线程的资源同步使用互斥锁pthread_mutex_t，同时它也可以用于多进程之间的资源同步。

互斥锁的使用过程中，主要有pthread_mutex_init，pthread_mutex_destory，pthread_mutex_lock，pthread_mutex_unlock这几个函数以完成锁的初始化，锁的销毁，上锁和释放锁操作。

<!--more-->

- 头文件

```
#include <pthread.h>
```

mutex锁同步：

| Attribute           | Default value                                        | Supported values                                             |
| :------------------ | :--------------------------------------------------- | :----------------------------------------------------------- |
| pshared             | **PTHREAD_PROCESS_PRIVATE**                          | **PTHREAD_PROCESS_PRIVATE or PTHREAD_PROCESS_SHARED**        |
| kind (non portable) | **PTHREAD_MUTEX_NONRECURSIVE_NP**                    | **PTHREAD_MUTEX_NONRECURSIVE_NP** or **PTHREAD_MUTEX_RECURSIVE_NP** |
| name (non portable) | **PTHREAD_DEFAULT_MUTEX_NAME_NP** "QP0WMTX UNNAMED"  | Any name that is 15 characters or less. If not terminated by a null character, name is truncated to 15 characters. |
| type                | **PTHREAD_MUTEX_DEFAULT** (**PTHREAD_MUTEX_NORMAL**) | **PTHREAD_MUTEX_DEFAULT** or **PTHREAD_MUTEX_NORMAL** or **PTHREAD_MUTEX_RECURSIVE** or **PTHREAD_MUTEX_ERRORCHECK** or **PTHREAD_MUTEX_OWNERTERM_NP**  The **PTHREAD_MUTEX_OWNERTERM_NP** attribute value is non portable. |



## 多线程

### 创建锁

``` C
mutex_handle create_mutex()
{
  pthread_mutex_t* pmutex = (mutex_handle)Rtos_Malloc(sizeof(pthread_mutex_t));

  if(pmutex) {
    pthread_mutexattr_t mutexAttr;
    pthread_mutexattr_init(&mutexAttr);
    pthread_mutexattr_settype(&mutexAttr, PTHREAD_MUTEX_RECURSIVE);
    pthread_mutex_init(pmutex, &mutexAttr);
  }
  return (mutex_handle)pmutex;
}
```

> 静态的初始化锁:
>
> ``` C
> pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;
> ```


### 销毁锁

``` C
void delete_mutex(mutex_handle mutex)
{
  pthread_mutex_t* pmutex = (pthread_mutex_t*)mutex;

  if(pmutex) {
    pthread_mutex_destroy(pmutex);
    Rtos_Free(pmutex);
  }
}

```

### 上锁

``` C
bool get_mutex(mutex_handle mutex)
{
  pthread_mutex_t* pmutex = (pthread_mutex_t*)mutex;

  if(!pmutex)
    return false;

  if(pthread_mutex_lock(pmutex) < 0)
    return false;

  return true;
}
```

### 释放锁

``` C
bool release_mutex(mutex_handle mutex)
{
  if(!mutex)
    return false;

  if((pthread_mutex_unlock((pthread_mutex_t*)mutex)) < 0)
    return false;

  return true;
}
```

## 锁的属性

`pthread_mutexattr_init(pthread_mutexattr_t *mattr)`接口初始化锁的属性，然后可以通过其他接口可以设置锁的不同属性。

### 互斥锁的范围

- `PTHREAD_PROCESS_SHARED`: 进程间同步，但是由这个属性对象创建的互斥锁将被保存在共享内存中，可以被多个进程中的线程共享。
- `PTHREAD_PROCESS_PRIVATE`：线程间同步，只有和创建这个互斥锁的线程在同一个进程中的线程才能访问这个互斥锁。

操作接口：
``` C
pthread_mutexattr_setpshared(pthread_mutexattr_t *mattr, int pshared)
pthread_mutexattr_getshared(pthread_mutexattr_t *mattr,int *pshared)
```

### 锁的类型

``` C
enum
{
  PTHREAD_MUTEX_TIMED_NP,
  PTHREAD_MUTEX_RECURSIVE_NP,
  PTHREAD_MUTEX_ERRORCHECK_NP,
  PTHREAD_MUTEX_ADAPTIVE_NP
#if defined __USE_UNIX98 || defined __USE_XOPEN2K8
  ,
  PTHREAD_MUTEX_NORMAL = PTHREAD_MUTEX_TIMED_NP,
  PTHREAD_MUTEX_RECURSIVE = PTHREAD_MUTEX_RECURSIVE_NP,
  PTHREAD_MUTEX_ERRORCHECK = PTHREAD_MUTEX_ERRORCHECK_NP,
  PTHREAD_MUTEX_DEFAULT = PTHREAD_MUTEX_NORMAL
#endif
#ifdef __USE_GNU
  /* For compatibility.  */
  , PTHREAD_MUTEX_FAST_NP = PTHREAD_MUTEX_TIMED_NP
#endif
};
```

- `PTHREAD_MUTEX_TIMED_NP`，这是缺省值，也就是普通锁。当一个线程加锁以后，其余请求锁的线程将形成一个等待队列，并在解锁后按优先级获得锁。这种锁策略保证了资源分配的公平性。
- `PTHREAD_MUTEX_RECURSIVE_NP`，嵌套锁，允许同一个线程对同一个锁成功获得多次，并通过多次unlock解锁。如果是不同线程请求，则在加锁线程解锁时重新竞争。
- `PTHREAD_MUTEX_ERRORCHECK_NP`，检错锁，如果同一个线程请求同一个锁，则返回EDEADLK，否则与PTHREAD_MUTEX_TIMED_NP类型动作相同。这样就保证当不允许多次加锁时不会出现最简单情况下的死锁。
- `PTHREAD_MUTEX_ADAPTIVE_NP`，适应锁，动作最简单的锁类型，仅等待解锁后重新竞争。

操作接口：
``` C
pthread_mutexattr_settype(pthread_mutexattr_t *attr , int type)
pthread_mutexattr_gettype(pthread_mutexattr_t *attr , int *type)
```

## 多进程锁

在多进程中互斥锁的使用，与多线程基本一致，不过需要注意以下几点：

1. 初始化互斥锁时，需要将其属性设置为`PTHREAD_PROCESS_SHARED`
2. 初始化锁的结构`pthread_mutex_t`,必需多个进程均可以访问，否则无法达到临界区同步的目的，一般使用共享内存共享pthread_mutex_t变量。


## 参考

- [互斥锁属性PTHREAD_MUTEX_RECURSIVE](https://blog.csdn.net/kingmax26/article/details/5338065)
- [pthread.h - threads](https://pubs.opengroup.org/onlinepubs/7908799/xsh/pthread.h.html)
- [Pthread APIs](https://www.ibm.com/docs/en/i/7.2?topic=category-pthread-apis)
