---
layout: post
title: Ticket spinlocks
date: '2019-04-21 14:27'
tags:
  - spinlock
categories:
  - Linux内核
  - 同步
abbrlink: 50889
---

`Ticket Spinlock`思路：类似银行办业务，先取一个号排队，然后等待叫号叫到自己
<!--more-->

在x86架构中，在2.6.24内核中，自旋锁由整数值表示，其值为1表示锁是可用的。 `spin_lock()`代码通过递减值（以系统范围的原子方式），然后查看结果是否为0; 如果为0，表示锁已成功获得。 相反，如果递减的结果是负数，则`spin_lock()`知道该锁是由其他人拥有的。所以它忙着等待（“自旋”）进入一个循环，直到锁的值变为正数; 然后它回到开始并再次尝试。

代码一旦执行到关键部分，锁的所有者通过将其设置为1来释放锁。

>这种方法存在一个缺点：这是`不公平`。当自旋等待获取锁的对象增多，一旦释放锁，第一个能够减少锁定的处理器将成为新的所有者。 没有办法确保等待时间最长的处理器先获得锁定; 实际上，刚刚释放锁的CPU可以凭借拥有该缓存行而具有优势，快速重新获取锁。

## ticket spinlocks

> ARM平台为例，Linux4.4

一个自旋锁变成了`32位`数，分成两个部分：


``` C
typedef struct {
	union {
		u32 slock;
		struct __raw_tickets {
#ifdef __ARMEB__
			u16 next;
			u16 owner;
#else
			u16 owner;
			u16 next;
#endif
		} tickets;
	};
} arch_spinlock_t;
```
> file: arch/arm/include/asm/spinclok_types.h

![spinlock_struct](/images/2019/04/spinlock_struct.png)

每个半字可以被认为是一个票号。 如果你去过一家商店，客户拿纸票确保按照到货顺序送达，您可以将`next`字段视为分配器中下一张票的号码，而`owner`是在柜台上的`正在服务`显示中出现的号码。

因此，在新的方案中，锁的值被初始化（两个字段）为零。 spin_lock()开始记录锁的值，然后递增`next`字段(所有这些都在一个原子操作中)。 如果`next`（在增量之前）的值等于`owner`，则已获得锁并且可以继续工作。 否则处理器将自旋，等待`owner`增加到正确的值。 在这个方案中，释放锁是一个简单的增加`owner`的问题。

## 实现

### 汇编

| 汇编指令  | 解释  | 示例  |
|:--:|:--|:--|
| prfm  | Prefetch Memory (register)预取  |   |
| stxr | 赋值存储，并保存存储状态  | STXR <Ws>, <Wt>, [Xn{,#0}]，将Wt写入Xn中，并保存写入状态到Ws    |
| cbnz  | 不等于0  |   |
| cbz  | 等于0  |   |
| sevl  | Send Event Local是一个提示指令，它使事件在本地发出信号，而不需要将事件通知多处理器系统中的其他PE。 它可以启动一个以WFE指令开始的等待循环。 |   |
| ldaxrh   |Load-Acquire Exclusive Register Halfword, 从存储器加载半字，对其进行零扩展并将其写入寄存器, | LDAXRH <Wt>, [Xn{,#0}], 将Xn赋值给Wt   |
| staddlh  | Atomic add on halfword in memory  | STADDH <Ws>, [Xn]，Xn加Ws并保存到Xn  |
| ldadda   | Atomic add on word or doubleword in memory  |   |   |


> - PE 指的是`Process Element`， 就是逻辑核心(logic core)，一个逻辑核心上可以跑一个线程
> - Load-Acquire/Store-Release指令是ARMv8的特性，在执行load和store操作的时候顺便执行了memory barrier相关的操作, 如ldaxr，ldaxrh等指令

### spin_lock_init

``` C
#define __ARCH_SPIN_LOCK_UNLOCKED	{ 0 , 0 }

void __raw_spin_lock_init(raw_spinlock_t *lock, const char *name,
			  struct lock_class_key *key)
{
#ifdef CONFIG_DEBUG_LOCK_ALLOC
	/*
	 * Make sure we are not reinitializing a held lock:
	 */
	debug_check_no_locks_freed((void *)lock, sizeof(*lock));
	lockdep_init_map(&lock->dep_map, name, key, 0);
#endif
  //初始化，next=owner=0
	lock->raw_lock = (arch_spinlock_t)__ARCH_SPIN_LOCK_UNLOCKED;
	lock->magic = SPINLOCK_MAGIC;
	lock->owner = SPINLOCK_OWNER_INIT;
	lock->owner_cpu = -1;
}

EXPORT_SYMBOL(__raw_spin_lock_init);
```

### spin_lock

``` C
static inline int arch_spin_trylock(arch_spinlock_t *lock)
{
	unsigned int tmp;
	arch_spinlock_t lockval;

	asm volatile(ARM64_LSE_ATOMIC_INSN(
	/* LL/SC */
  //prfm: Prefetch Memory (register)预取
  //pstl1strm: 表示预取数据为一级Cache的流式存储
  //将lock结构存储到一级Cache，提高访问速度
	"	prfm	pstl1strm, %2\n"
  //赋值，将lock赋值给lockval
	"1:	ldaxr	%w0, %2\n"
  //eor:按位异或
  //ror:循环右移
  //相当于if(next == owner)
	"	eor	%w1, %w0, %w0, ror #16\n"
  //比较如果tmp不是0，跳转标号2，next与owner不相等
	"	cbnz	%w1, 2f\n"
  /* next == owner，该锁未被使用，no busy */
  //lockval中的next加1
	"	add	%w0, %w0, %3\n"
  //将lockval写入lock，并保存赋值状态到tmp
	"	stxr	%w1, %w0, %2\n"
  //如果tmp不等于0，则跳转标号1
	"	cbnz	%w1, 1b\n"
  /* next != owner, 该锁已被使用，busy */
	"2:",
	/* LSE atomics */
  //将lock赋值给lockval
	"	ldr	%w0, %2\n"
  //判断next与owner是否相等
	"	eor	%w1, %w0, %w0, ror #16\n"
  //如果tmp不等于0，跳转标号1
	"	cbnz	%w1, 1f\n"
  //lockval中的next加1
	"	add	%w1, %w0, %3\n"
  //casa:Compare and Swap
  //比较lockval与tmp，如果相等，将tmp写入lockval，否则跳转标号2(原子指令)
	"	casa	%w0, %w1, %2\n"
  //將tmp中的next減去1
	"	sub	%w1, %w1, %3\n"
  //判斷lockval与tmp是否相等
	"	eor	%w1, %w1, %w0\n"
  /* lockval与tmp，相等：退出；不相等：跳转标号1，循环 */
	"1:")
	: "=&r" (lockval), "=&r" (tmp), "+Q" (*lock)
	: "I" (1 << TICKET_SHIFT)
	: "memory");

	return !tmp;
}

static inline void arch_spin_lock(arch_spinlock_t *lock)
{
	unsigned int tmp;
	arch_spinlock_t lockval, newval;

	asm volatile(
	/* Atomically increment the next ticket. */
	ARM64_LSE_ATOMIC_INSN(
	/* LL/SC */
"	prfm	pstl1strm, %3\n"
"1:	ldaxr	%w0, %3\n"
"	add	%w1, %w0, %w5\n"
"	stxr	%w2, %w1, %3\n"
"	cbnz	%w2, 1b\n",
	/* LSE atomics */
"	mov	%w2, %w5\n"
/* next加1 */
"	ldadda	%w2, %w0, %3\n"
"	nop\n"
"	nop\n"
"	nop\n"
	)

	/* Did we get the lock? */
"	eor	%w1, %w0, %w0, ror #16\n"
"	cbz	%w1, 3f\n"
	/*
	 * No: spin on the owner. Send a local event to avoid missing an
	 * unlock before the exclusive load.
	 */
/* 使CPU进入低功耗模式， 等待自旋 */
"	sevl\n"
"2:	wfe\n"
//==> 其他cpu唤醒本cpu，获取当前owner值
"	ldaxrh	%w2, %4\n"
"	eor	%w1, %w2, %w0, lsr #16\n"
"	cbnz	%w1, 2b\n"
	/* We got the lock. Critical section starts here. */
"3:"
	: "=&r" (lockval), "=&r" (newval), "=&r" (tmp), "+Q" (*lock)
	: "Q" (lock->owner), "I" (1 << TICKET_SHIFT)
	: "memory");
}
```
> Wait For Event is a hint instruction that indicates that the PE can enter a low-power state and remain there until a wakeup event occurs. Wakeup events include the event signaled as a result of executing the `SEV` instruction on any PE in the multiprocessor system. For more information, see Wait for Event mechanism and Send event on page D1-2255.


### spin_unlock

``` C
static inline void arch_spin_unlock(arch_spinlock_t *lock)
{
	unsigned long tmp;

	asm volatile(ARM64_LSE_ATOMIC_INSN(
	/* LL/SC */
	"	ldrh	%w1, %0\n"
	"	add	%w1, %w1, #1\n"
	"	stlrh	%w1, %0",
	/* LSE atomics */
	"	mov	%w1, #1\n"
	"	nop\n"
  /* owner加1 */
	"	staddlh	%w1, %0")
	: "=Q" (lock->owner), "=&r" (tmp)
	:
	: "memory");
}
```

* 没有sev指令，如何唤醒进入低功耗模式（wfe）的CPU core？？

> ARMv8 provides Wait For Event, Send Event, and Send Event Local instructions, WFE, SEV, and SEVL, that can assist with reducing power consumption and bus contention caused by PEs repeatedly attempting to obtain a spin-lock. These instructions can be used at the application level, but a complete understanding of what they do depends on a system level understanding of exceptions. They are described in Wait for Event mechanism and Send event on page D1-2255. However, in ARMv8, when the global monitor for a PE changes from `Exclusive Access` state to Open Access state, an event is generated.

**`stlrh`和`staddlh`指令存在Exclusive操作，当PE（n）对x地址发起了exclusive操作的时候，PE（n）的global monitor从open access迁移到exclusive access状态，来自其他PE上针对x（该地址已经被mark for PE（n））的store操作会导致PE（n）的global monitor从exclusive access迁移到open access状态，这时候，PE（n）的Event register会被写入event，就好象生成一个event，将该PE唤醒，从而可以省略一个SEV的指令**

![spin_lock_pe_n](/images/2019/04/spin_lock_pe_n.png)

## 参考

* [Ticket spinlocks](https://lwn.net/Articles/267968/)
* [ARMv8®体系结构参考手册](https://dev.tencent.com/u/Winddoing/p/blog_docs/git/raw/master/DDI0487D_a_armv8_arm.pdf)
* [ARM WFI和WFE指令](http://www.wowotech.net/armv8a_arch/wfe_wfi.html)
