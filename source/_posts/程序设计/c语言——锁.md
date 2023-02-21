---
layout: post
title: C语言——锁
date: '2018-09-19 15:49'
tags:
  - c
  - sync
categories:
  - 程序设计
abbrlink: 37537
---

`锁`：原子锁, 线程安全

``` C
static int _a = 0;

++_a;
/*
	++_a 大致可以拆分为下面三步(MIPS 指令)

	1' 把 _a 的值放入`寄存器$1`中   【lw】
	2' 把`寄存器$1`中值加1    【add】
	3' 返回`寄存器$1`中值并且设置给a   【sw】
 */
```
> `自加1`和`自减1`：在GCC中提供了相应的原子指令操作，排除多线程对一个变量的操作的不可预期性。

``` C
type __sync_fetch_and_add (type *ptr, type value, ...)
type __sync_fetch_and_sub (type *ptr, type value, ...)
type __sync_fetch_and_or (type *ptr, type value, ...)
type __sync_fetch_and_and (type *ptr, type value, ...)
type __sync_fetch_and_xor (type *ptr, type value, ...)
type __sync_fetch_and_nand (type *ptr, type value, ...)
```

<!--more-->

## 原子锁与自旋锁

> 原子锁和自旋锁的本质相同，通过对一个变量的`自加`和`自减`操作（这里的`自加`、`自减`都是通过一条原子指令完成），判断临界区的可操作性。

## memory barrier

memory barrier有几种类型：
- `acquire barrier` : 不允许将barrier之后的内存读取指令移到barrier之前（linux kernel中的wmb()）。
- `release barrier` : 不允许将barrier之前的内存读取指令移到barrier之后 (linux kernel中的rmb())。
- `full barrier`    : 以上两种barrier的合集(linux kernel中的mb())。

``` C
__sync_synchronize (...)
```
> GCC: This builtin issues a `full memory barrier`.

## 应用层：原子锁

``` C
#ifndef _H_SIMPLEC_SCATOM
#define _H_SIMPLEC_SCATOM

#if defined(__GNUC__)

// v += a ; return v;
#define ATOM_ADD(v, a)		__sync_add_and_fetch(&(v), (a))
// type tmp = v ; v = a; return tmp;
#define ATOM_SET(v, a)		__sync_lock_test_and_set(&(v), (a))
// v &= a; return v;
#define ATOM_AND(v, a)		__sync_and_and_fetch(&(v), (a))
// return ++v;
#define ATOM_INC(v) 		__sync_add_and_fetch(&(v), 1)
// return --v;
#define ATOM_DEC(v) 		__sync_sub_and_fetch(&(v), 1)
// bool b = v == c; b ? v=a : ; return b;
#define ATOM_CAS(v, c, a)	__sync_bool_compare_and_swap(&(v), (c), (a))

 // 保证代码不乱序
#define ATOM_SYNC() 		__sync_synchronize()

// 对ATOM_LOCK 解锁, 当然 直接调用相当于 v = 0;
#define ATOM_UNLOCK(v)		__sync_lock_release(&(v))

#endif // __GNUC__

/*
 * 试图加锁, 用法举例

	 if(ATOM_TRYLOCK(v)) {
		 // 已经有人加锁了, 处理返回事件
		...
	 }

	 // 得到锁资源, 开始处理
	 ...

	 ATOM_UNLOCK(v);

 * 返回1表示已经有人加锁了, 竞争锁失败.
 * 返回0表示得到锁资源, 竞争锁成功
 */
#define ATOM_TRYLOCK(v)		ATOM_SET(v, 1)

//
// 使用方式:
//  int lock = 0;
//  ATOM_LOCK(lock);
//  ...
//  ATOM_UNLOCK(lock);
//
#define ATOM_LOCK(v)		while(ATOM_SET(v, 1))

#endif // !_H_SIMPLEC_SCATOM
```
> scatom.h

### 示例

``` C
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <sys/time.h>

#include "include/atom.h"

int g_iFlagAtom = 0;
#define WORK_SIZE 5000000
#define WORKER_COUNT 10
pthread_t g_tWorkerID[WORKER_COUNT];
int g_iSum = 0;
int lock = 0;

void * thr_worker(void *arg)
{
	printf("WORKER THREAD %08X STARTUP\n", (unsigned int)pthread_self());
	int i=0;
	for (i=0; i<WORK_SIZE; ++i) {
		if (g_iFlagAtom) {
			ATOM_INC(g_iSum);
		} else {
			//ATOM_LOCK(lock);
			g_iSum ++;
			//ATOM_UNLOCK(lock);
		}
	}
	return NULL;
}

void * thr_management(void *arg)
{
	printf("MANAGEMENT THREAD %08X STARTUP\n", (unsigned int)pthread_self());
	int i;
	for (i=0;i<WORKER_COUNT;++i) {
		pthread_join(g_tWorkerID[i], NULL);
	}
	printf("ALL WORKER THREADS FINISHED.\n");
	return NULL;
}

int main(int argc, const char* argv[])
{
	pthread_t tManagementID;
	int i=0;
	struct timeval start, end;

	gettimeofday(&start, NULL);
	pthread_create (&tManagementID, NULL, thr_management, NULL);

	for (i=0;i<WORKER_COUNT;++i) {
		pthread_create(&g_tWorkerID[i], NULL, thr_worker, NULL);
	}

	printf("CREATED %d WORKER THREADS\n", i);
	pthread_join(tManagementID, NULL);

	gettimeofday(&end, NULL);
	printf("THE SUM: %d\n", g_iSum);

	printf("Run time: %ldms\n", 1000 * (end.tv_sec - start.tv_sec) + (end.tv_usec - start.tv_usec) / 1000);
	return 0;
}
```
* 结果
    - g_iSum++
    ```
    THE SUM: 14617872
    Run time: 201ms
    ```
    - ATOM_INC
    ```
    THE SUM: 50000000
    Run time: 1612ms
    ```
    - ATOM_LOCK
    ```
    THE SUM: 50000000
    Run time: 11821ms
    ```

## 读写锁

``` C
#ifndef _H_SIMPLEC_SCRWLOCK
#define _H_SIMPLEC_SCRWLOCK

#include "scatom.h"

/*
 * create simple write and read lock
 * struct rwlock need zero.
 * is scatom ext
 */

// init need all is 0
struct rwlock {
	int rlock;
	int wlock;
};

// add read lock
extern void rwlock_rlock(struct rwlock * lock);
// add write lock
extern void rwlock_wlock(struct rwlock * lock);

// add write lock
extern void rwlock_unrlock(struct rwlock * lock);
// unlock write
extern void rwlock_unwlock(struct rwlock * lock);

#endif // !_H_SIMPLEC_SCRWLOCK
```

``` C
// add read lock
void
rwlock_rlock(struct rwlock * lock) {
	for (;;) {
		// 看是否有人在试图读, 得到并防止代码位置优化
		while (lock->wlock)
			ATOM_SYNC();

		ATOM_INC(lock->rlock);
		// 没有写占用, 开始读了
		if (!lock->wlock)
			break;

		// 还是有写, 删掉添加的读
		ATOM_DEC(lock->rlock);
	}
}

// unlock read lock
inline void
rwlock_unrlock(struct rwlock * lock) {
	ATOM_DEC(lock->rlock);
}

/ add write lock
void
rwlock_wlock(struct rwlock * lock) {
	ATOM_LOCK(lock->wlock);
	// 等待读占用锁
	while (lock->rlock)
		ATOM_SYNC();
}

// unlock write lock
inline void
rwlock_unwlock(struct rwlock * lock) {
	ATOM_UNLOCK(lock->wlock);
}
```
## 参考

* [Built-in functions for atomic memory access](https://gcc.gnu.org/onlinedocs/gcc-4.1.2/gcc/Atomic-Builtins.html)
* [原子锁线程协程](https://github.com/wangzhione/cdesignbook/blob/master/%E7%AC%AC3%E7%AB%A0-%E6%B0%94%E5%8A%9F-%E5%8E%9F%E5%AD%90%E9%94%81%E7%BA%BF%E7%A8%8B%E5%8D%8F%E7%A8%8B/README.md)
