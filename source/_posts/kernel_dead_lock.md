---
title: 死锁
date: 2018-01-18 23:07:24
categories: Linux内核
tags: [lock]
---


```
[15299.717341] BUG: spinlock lockup suspected on CPU#1, rixitest/4186
[15299.723758]  lock: 0x8c77d644, .magic: dead4ead, .owner: rixitest/4161, .owner_cpu: 0
[15299.731858] CPU: 1 PID: 4186 Comm: rixitest Not tainted 3.10.14-00058-g5afe79c #3
```
<!--more-->

## 死锁检测

以`spin_lock`进行死锁机制的检测流程说明：

### raw_lock

``` C
typedef struct raw_spinlock {
    arch_spinlock_t raw_lock;
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
} raw_spinlock_t;
```

死锁的检测内核需要配置`CONFIG_DEBUG_SPINLOCK`,它主要使用的数据有`magic`, `owner_cpu`,`*owner`:

|	type	|	作用	|
| :-------: | :-------: |
| magic		| 幻数,表示锁以及初始化	|
| owner_cpu | raw_smp_processor_id(),`锁`所在的当前CPU号	|
| *ower		| current,`锁`所在的当前进程|

### Init

``` C
#define SPINLOCK_MAGIC		0xdead4ead

#define SPINLOCK_OWNER_INIT	((void *)-1L)

#ifdef CONFIG_DEBUG_SPINLOCK
# define SPIN_DEBUG_INIT(lockname)		\
	.magic = SPINLOCK_MAGIC,		\
	.owner_cpu = -1,			\
	.owner = SPINLOCK_OWNER_INIT,
#else
# define SPIN_DEBUG_INIT(lockname)
#endif
```
初始化时`owner_cpu=-1`表示该锁不属于任何CPU，并且不属于任何进程(`owner=(void *)-1L`)

### Use

>在什么时候指明该锁属于哪一个CPU，哪一个进程。

1. 上锁时指定：`spin_lock`
2. 解锁时恢复：`spin_unlock`


```
spin_lock
	|
_raw_spin_lock
	|
__raw_spin_lock --> {
						preempt_disable();
						spin_acquire(&lock->dep_map, 0, 0, _RET_IP_);
						LOCK_CONTENDED(lock, do_raw_spin_trylock, do_raw_spin_lock);
					}
```


#### do_raw_spin_trylock

定义：CONFIG_LOCK_STAT

``` C
static inline void
debug_spin_lock_before(raw_spinlock_t *lock)
{
	SPIN_BUG_ON(lock->magic != SPINLOCK_MAGIC, lock, "bad magic");
	//进程重入
	SPIN_BUG_ON(lock->owner == current, lock, "recursion"); 
	//CPU重入
	SPIN_BUG_ON(lock->owner_cpu == raw_smp_processor_id(),
							lock, "cpu recursion");
}

static inline void debug_spin_lock_after(raw_spinlock_t *lock)
{
	lock->owner_cpu = raw_smp_processor_id();
	lock->owner = current;
}
```

``` C
定义：CONFIG_LOCK_STAT

#define LOCK_CONTENDED(_lock, try, lock)			\
do {								\
	if (!try(_lock)) {					\
		lock_contended(&(_lock)->dep_map, _RET_IP_);	\
		lock(_lock);					\
	}							\
	lock_acquired(&(_lock)->dep_map, _RET_IP_);			\
} while (0)

int do_raw_spin_trylock(raw_spinlock_t *lock)
{
	int ret = arch_spin_trylock(&lock->raw_lock);

	if (ret)
		debug_spin_lock_after(lock);  //上锁成功后进行重新赋值
#ifndef CONFIG_SMP
	/*
	 * Must not happen on UP:
	 */
	SPIN_BUG_ON(!ret, lock, "trylock failure on UP");
#endif
	return ret;
}
```
>file: lib/spinlock_debug.c


#### do_raw_spin_lock

``` C
#define LOCK_CONTENDED(_lock, try, lock) \
	lock(_lock)


void do_raw_spin_lock(raw_spinlock_t *lock)
{
	debug_spin_lock_before(lock);
	if (unlikely(!arch_spin_trylock(&lock->raw_lock)))
		__spin_lock_debug(lock);
	debug_spin_lock_after(lock);
}
```
>file: lib/spinlock_debug.c

`arch_spin_trylock`主要实现不同架构的实际`加锁`的功能函数。如果上锁失败将进入`_spin_lock_debug`函数，打印上锁失败的原因。在`do_raw_spin_lock`函数中除路上锁的关键函数，其他函数均为debug函数，这里主要说明debug函数的原理和死锁出现后的debug info的具体含义。



## Debug Info

如果上锁失败，将不断尝试上锁直到超时，内核认为出现死锁，主要的引起原因有：`该锁没有被释放`（排除CPU硬件错误）

``` C
static void __spin_lock_debug(raw_spinlock_t *lock)
{
	u64 i;
	u64 loops = loops_per_jiffy * HZ;

	for (i = 0; i < loops; i++) {
		if (arch_spin_trylock(&lock->raw_lock))
			return;
		__delay(1);
	}
	/* lockup suspected: */
	spin_dump(lock, "lockup suspected");
	...
}
```

``` C
unsigned long loops_per_jiffy = (1<<12);
```
>file: /init/main.c

`loops_per_jiffy`:定义超时时间, (4096)_delay(1)为4096s



```
[15299.717341] BUG: spinlock lockup suspected on CPU#1, rixitest/4186
[15299.723758]  lock: 0x8c77d644, .magic: dead4ead, .owner: rixitest/4161, .owner_cpu: 0
[15299.731858] CPU: 1 PID: 4186 Comm: rixitest Not tainted 3.10.14-00058-g5afe79c #3
```

``` C
static void spin_dump(raw_spinlock_t *lock, const char *msg)
{
	...
	printk(KERN_EMERG "BUG: spinlock %s on CPU#%d, %s/%d\n",
		msg, raw_smp_processor_id(),
		current->comm, task_pid_nr(current));
	printk(KERN_EMERG " lock: %pS, .magic: %08x, .owner: %s/%d, "
			".owner_cpu: %d\n",
		lock, lock->magic,
		owner ? owner->comm : "<none>",
		owner ? task_pid_nr(owner) : -1,
		lock->owner_cpu);
	dump_stack();
}
```

>`lockup suspected on CPU#1`: 说明当前检测到死锁的CPU为核1
>`.owner_cpu: 0`:说明之前上锁的CPU为核0

>以上log说明有一把锁，在核0上锁后，没有释放之前核1有一次去上锁，从而导致死锁
