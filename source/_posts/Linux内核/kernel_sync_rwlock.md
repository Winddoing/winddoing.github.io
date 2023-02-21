---
title: Linux内核同步机制【rwlock】
categories:
  - Linux内核
tags:
  - linux
  - rwlock
abbrlink: 42371
date: 2018-04-03 12:07:24
---

>读写锁实际是一种`特殊的自旋锁`，它把对共享资源的访问者划分成读者和写者，读者只对共享资源进行读访问，写者则需要对共享资源进行写操作。这种锁相对于自旋锁而言，能提高并发性，因为在多处理器系统中，它允许同时有多个读者来访问共享资源，最大可能的读者数为实际的逻辑CPU数。写者是排他性的，一个读写锁同时只能有一个写者或多个读者（与CPU数相关），但不能同时既有读者又有写者。

<!--more-->


## 数据结构

### rwlock_t

``` C
typedef struct {
	arch_rwlock_t raw_lock;
#ifdef CONFIG_GENERIC_LOCKBREAK
	unsigned int break_lock;
#endif
#ifdef CONFIG_DEBUG_SPINLOCK
	unsigned int magic, owner_cpu;
	void *owner;
#endif
#ifdef CONFIG_DEBUG_LOCK_ALLOC
	struct lockdep_map dep_map;
#endif
} rwlock_t;
```
>file: include/linux/rwlock_types.h

### arch_rwlock_t

#### MIPS

``` C
typedef struct {
    volatile unsigned int lock;
} arch_rwlock_t;
```
>file: arch/mips/include/asm/spinlock_types.h

## 通用接口API

* rwlock_init

``` C
#define __ARCH_RW_LOCK_UNLOCKED     { 0 }

#define __RW_LOCK_UNLOCKED(lockname) \
    (rwlock_t)  {   .raw_lock = __ARCH_RW_LOCK_UNLOCKED,    \
	RW_DEP_MAP_INIT(lockname) }


# define rwlock_init(lock)                  \
    do { *(lock) = __RW_LOCK_UNLOCKED(lock); } while (0)
```

初始化`rwlock_t->raw_lock->lock=0`

* R/W lock

```
#define write_lock(lock)    _raw_write_lock(lock)
#define read_lock(lock)     _raw_read_lock(lock)
```
>file: include/linux/rwlock.h

## 实现

读写锁包括读取锁和写入锁，多个读线程可以同时访问共享数据；写线程必须等待所有读线程都释放锁以后，才能取得锁；同样的，读线程必须等待写线程释放锁后，才能取得锁；

也就是说读写锁要确保的是如下互斥关系：可以同时读，但是读-写，写-写都是互斥的；

* 读锁

```
read_lock
  |->_raw_read_lock
	|->__raw_read_lock
	  |->preempt_disable();
	  |->rwlock_acquire_read(&lock->dep_map, 0, 0, _RET_IP_);
	  |->LOCK_CONTENDED(lock, do_raw_read_trylock, do_raw_read_lock);
```
在读锁上锁时与spinlock的流程基本相同，都会关闭内核抢占，因此读写锁中也不能睡眠

``` C
# define do_raw_read_trylock(rwlock)    arch_read_trylock(&(rwlock)->raw_lock)
# define do_raw_read_lock(rwlock)   do {__acquire(lock); arch_read_lock(&(rwlock)->raw_lock); } while (0)
```
>file: include/linux/rwlock.h

### MIPS

不同架构的实现：

### arch_read_lock

``` C
static inline void arch_read_lock(arch_rwlock_t *rw)
{
    unsigned int tmp;

    do {
        __asm__ __volatile__(
        "1: ll  %1, %2  # arch_read_lock    \n"
        "   bltz    %1, 1b              \n"
        "    addu   %1, 1               \n"
        "2: sc  %1, %0              \n"
        : "=m" (rw->lock), "=&r" (tmp)
        : "m" (rw->lock)
        : "memory");
    } while (unlikely(!tmp));

    smp_llsc_mb();
}
```
> bltz $s,offset <==> if($s< 0) jump(offset « 2); 小于0，跳转

内嵌汇编源码：
```
c2020000    ll  v0,0(s0)
0440fffe    bltz    v0,8021c8f8 <do_raw_read_lock+0x38>
00000000    nop
24420001    addiu   v0,v0,1
e2020000    sc  v0,0(s0)
1040fffa    beqz    v0,8021c8f8 <do_raw_read_lock+0x38>
```
上读锁是通过原子操作对`rwlock_t->raw_lock->lock += 1`

### arch_read_unlock

``` C
static inline void arch_read_unlock(arch_rwlock_t *rw)
{
    unsigned int tmp;

    smp_mb__before_llsc();

    do {
        __asm__ __volatile__(
        "1: ll  %1, %2  # arch_read_unlock  \n"
        "   sub %1, 1               \n"
        "   sc  %1, %0              \n"
        : "=m" (rw->lock), "=&r" (tmp)
        : "m" (rw->lock)
        : "memory");
    } while (unlikely(!tmp));
}
```
解读锁是通过原子操作对`rwlock_t->raw_lock->lock -= 1`


### arch_write_lock

``` C
static inline void arch_write_lock(arch_rwlock_t *rw)
{
    unsigned int tmp;

    do {
        __asm__ __volatile__(
        "1: ll  %1, %2  # arch_write_lock   \n"
        "   bnez    %1, 1b              \n"
        "    lui    %1, 0x8000          \n"
        "2: sc  %1, %0              \n"
        : "=m" (rw->lock), "=&r" (tmp)
        : "m" (rw->lock)
        : "memory");
    } while (unlikely(!tmp));

    smp_llsc_mb();
}
```
>
>lui $t,imm <==> $t=(imm « 16)
>将立即数左移16位，低16位补零

内嵌汇编反汇编源码：
```
c2020000    ll  v0,0(s0)
1440fffe    bnez    v0,8021ca08 <do_raw_write_lock+0x70>
00000000    nop
3c028000    lui v0,0x8000
e2020000    sc  v0,0(s0)
1040fffa    beqz    v0,8021ca08 <do_raw_write_lock+0x70>
```


### arch_write_unlock

``` C
static inline void arch_write_unlock(arch_rwlock_t *rw)
{
    smp_mb();

    __asm__ __volatile__(
    "               # arch_write_unlock \n"
    "   sw  $0, %0                  \n"
    : "=m" (rw->lock)
    : "m" (rw->lock)
    : "memory");
}
```

## Q&A

1. 读锁怎么实现可以存在多个读者进行处理？？


2. 读写锁与SMP多核之间的线程处理关系？？


## 参考

1. [Linux下写者优先的读写锁的设计](https://www.ibm.com/developerworks/cn/linux/l-rwlock_writing/)
2. [读/写自旋锁](http://guojing.me/linux-kernel-architecture/posts/read-and-write-spin-lock/)
