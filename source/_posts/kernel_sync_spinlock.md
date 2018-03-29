---
title: Linux内核同步机制:spin lock
date: 2018-03-29 23:07:24
categories: Linux内核
tags: [linux, lock]
---
1. spinlock的使用场景，为什么使用？
2. 在spinlock控制临界区中，为什么不能睡眠？如果睡眠会产生什么结果？
3. spinlock的实现和数据结构，在x86、ARM64、MIPS中的实现方式，不同吗？存在什么差异？
4. 在发生抢锁时，spinlock和信号量处理的区别？

<!--more-->

内核版本：linux 4.4.93

## spin lock特点

* `spin lock`是一种死等的锁机制。当前的执行thread会不断的重新尝试直到获取锁进入临界区。
>当发生访问资源冲突的时候，可以有两个选择：一个是死等，一个是挂起当前进程，调度其他进程执行。

* 只允许一个thread进入。semaphore可以允许多个thread进入，spin lock不行，一次只能有一个thread获取锁并进入临界区，其他的thread都是在门口不断的尝试。

* 执行时间短。
>由于spin lock死等这种特性，因此它使用在那些代码不是非常复杂的临界区（当然也不能太简单，否则使用原子操作或者其他适用简单场景的同步机制就OK了），如果临界区执行时间太长，那么不断在临界区门口“死等”的那些thread是多么的浪费CPU啊（当然，现代CPU的设计都会考虑同步原语的实现，例如ARM提供了WFE和SEV这样的类似指令，避免CPU进入busy loop的悲惨境地）

* 可以在中断上下文执行。由于不睡眠，因此spin lock可以在中断上下文中适用。

## 场景

spin lock，其保护的资源可能来自多个CPU CORE上的`进程上下文`和`中断上下文`的中的访问
* 进程上下文包括：用户进程通过系统调用访问，内核线程直接访问，来自workqueue中work function的访问（本质上也是内核线程）。
* 中断上下文包括：HW interrupt context（中断handler）、软中断上下文（soft
irq，当然由于各种原因，该softirq被推迟到softirqd的内核线程中执行的时候就不属于这个场景了，属于进程上下文那个分类了）、timer的callback函数（本质上也是softirq）、tasklet（本质上也是softirq）。

先看最简单的单CPU上的进程上下文的访问。如果一个全局的资源被多个进程上下文访问，这时候，内核如何交错执行呢？对于那些没有打开preemptive选项的内核，所有的系统调用都是串行化执行的，因此不存在资源争抢的问题。

如果内核线程也访问这个全局资源呢？本质上内核线程也是进程，类似普通进程，只不过普通进程时而在用户态运行、时而通过系统调用陷入内核执行，而内核线程永远都是在内核态运行，但是，结果是一样的，对于non-preemptive的linux kernel，只要在内核态，就不会发生进程调度
因此，这种场景下，共享数据根本不需要保护（没有并发，谈何保护呢）。

>单核CPU中， 如果系统默认关闭抢占时，spin lock不起任何作用，因为不存在真正并发的条件，不需要进行同步。如果打开内核抢占，其同步机制主要时通过关闭抢占实现

### 进程上下文

当打开premptive选项后，事情变得复杂了，我们考虑下面的场景：

* 进程A在某个系统调用过程中访问了共享资源R
* 进程B在某个系统调用过程中也访问了共享资源R

**1.会不会造成冲突呢？**

假设在A访问共享资源R的过程中发生了中断，中断唤醒了沉睡中的，优先级更高的B，在中断返回现场的时候，发生进程切换，B启动执行，并通过系统调用访问了R，如果没有锁保护，则会出现两个thread进入临界区，导致程序执行不正确。

**2.使用spin lock：**

A在进入临界区之前获取了spin lock，同样的，在A访问共享资源R的过程中发生了中断，中断唤醒了沉睡中的，优先级更高的B，B在访问临界区之前仍然会试图获取spin lock，这时候由于A进程持有spin lock而导致B进程进入了永久的spin……怎么破？linux的kernel很简单，在A进程获取spin	lock的时候，禁止本CPU上的抢占（上面的永久spin的场合仅仅在本CPU的进程抢占本CPU的当前进程这样的场景中发生）。

如果是多核CPU，A和B运行在不同的CPU上，那么情况会简单一些：A进程虽然持有spin lock而导致B进程进入spin状态，不过由于运行在不同的CPU上，A进程会持续执行并会很快释放spin lock，解除B进程的spin状态。

### 中断上下文

* 运行在CPU0上的进程A在某个系统调用过程中访问了共享资源R
* 运行在CPU1上的进程B在某个系统调用过程中也访问了共享资源R
* 外设P的中断handler中也会访问共享资源R


在这样的场景下，使用spin lock可以保护访问共享资源R的临界区吗？我们假设CPU0上的进程A持有spin lock进入临界区，这时候，外设P发生了中断事件，并且调度到了CPU1上执行，看起来没有什么问题，执行在CPU1上的handler会稍微等待一会CPU0上的进程A，等它立刻临界区就会释放spin lock的.

但是，如果外设P的中断事件被调度到了CPU0上执行会怎么样？CPU0上的进程A在持有spin lock的状态下被中断上下文抢占，而抢占它的CPU0上的handler在进入临界区之前仍然会试图获取spin lock，悲剧发生了，CPU0上的P外设的中断handler永远的进入spin状态，这时候，CPU1上的进程B也不可避免在试图持有spin lock的时候失败而导致进入spin状态。
为了解决这样的问题，linux kernel采用了这样的办法：如果涉及到中断上下文的访问，spin lock需要和禁止本CPU上的中断联合使用。

linux kernel中提供了丰富的bottom half的机制，虽然同属中断上下文，不过还是稍有不同。我们可以把上面的场景简单修改一下：外设P不是中断handler中访问共享资源R，而是在的bottom half中访问。使用spin lock+禁止本地中断当然是可以达到保护共享资源的效果，但是使用牛刀来杀鸡似乎有点小题大做，这时候disable bottom half就OK了。

最后，我们讨论一下中断上下文之间的竞争。同一种中断handler之间在uni core和multi core上都不会并行执行，这是linux kernel的特性。如果不同中断handler需要使用spin lock保护共享资源，对于新的内核（不区分fast handler和slow handler），所有handler都是关闭中断的，因此使用spin lock不需要关闭中断的配合。
bottom half又分成softirq和tasklet，同一种softirq会在不同的CPU上并发执行，因此如果某个驱动中的sofirq的handler中会访问某个全局变量，对该全局变量是需要使用spin lock保护的，不用配合disable CPU中断或者bottom half。
tasklet更简单，因为同一种tasklet不会多个CPU上并发，具体我就不分析了，大家自行思考吧。


## 通用代码结构

### 数据结构

``` C
typedef struct spinlock {
	union {
		struct raw_spinlock rlock;
	};
} spinlock_t;

typedef struct raw_spinlock {
    arch_spinlock_t raw_lock;
} raw_spinlock_t;
```
>file: include/linux/spinlock_types.h

通过`arch_spinlock_t`结构体定义不同arch下spin lock的实现结构。

### 接口API

|		接口类型		|	 spinlock定义		|	raw_spinlock的定义	|
|	:---------------:	|	:---------------:	|	:---------------:	|
|定义spin lock并初始化	|	DEFINE_SPINLOCK		|	DEFINE_RAW_SPINLOCK	|
|动态初始化spin lock	|	spin_lock_init		|	raw_spin_lock_init	|
|获取指定的spin lock	|	spin_lock			|	raw_spin_lock		|
|获取指定的spin lock同时disable本CPU中断						|spin_lock_irq			|raw_spin_lock_irq			|
|保存本CPU当前的irq状态, disable本CPU中断并获取指定的spin lock	|spin_lock_irqsave		|raw_spin_lock_irqsave		|
|获取指定的spin lock同时disable本CPU的bottom half				|spin_lock_bh			|raw_spin_lock_bh			|
|释放指定的spin lock											|spin_unlock			|raw_spin_unlock			|
|释放指定的spin lock同时enable本CPU中断							|spin_unlock_irq		|raw_spin_unock_irq			|
|释放指定的spin lock同时恢复本CPU的中断状态						|spin_unlock_irqstore	|raw_spin_unlock_irqstore	|
|获取指定的spin lock同时enable本CPU的bottom half				|spin_unlock_bh			|raw_spin_unlock_bh			|
|尝试去获取spin lock，如果失败，不会spin，而是返回非零值		|spin_trylock			|raw_spin_trylock			|
|判断spin lock是否是locked, 如果其他的thread已经获取了该lock, 那么返回非零值，否则返回0	|spin_is_locked |	raw_spin_is_locked |

### 调用流程

spin lock:
```
spin_lock()
	\->raw_spin_lock()
		\->__raw_spin_lock
			{
				preempt_disable(); //关闭内核抢占
				spin_acquire(&lock->dep_map, 0, 0, _RET_IP_); //获取锁
				LOCK_CONTENDED(lock, do_raw_spin_trylock, do_raw_spin_lock);//上锁
			}
			-----------------------------  arch
			-> arch_spin_lock()
			-> arch_spin_trylock()
```

## MIPS架构的实现

### arch_spinlock_t

``` C
typedef union {
	/*
	 * bits  0..15 : serving_now
	 * bits 16..31 : ticket
	 */
	u32 lock;
	struct {
#ifdef __BIG_ENDIAN
		u16 ticket;
		u16 serving_now;
#else
		u16 serving_now;
		u16 ticket;
#endif
	} h;
} arch_spinlock_t;
```
>file: arch/mips/include/asm/spinlock_types.h

### 实现

#### arch_spin_lock

``` C
static inline void arch_spin_lock(arch_spinlock_t *lock)
{
    int my_ticket;
    int tmp;
    int inc = 0x10000;

     __asm__ __volatile__ (
		"   .set push       # arch_spin_lock    \n"
 		"   .set noreorder                  \n"
 		"                           \n"
 		"1: ll  %[ticket], %[ticket_ptr]        \n"
 		"   addu    %[my_ticket], %[ticket], %[inc]     \n"
 		"   sc  %[my_ticket], %[ticket_ptr]     \n"
 		"   beqz    %[my_ticket], 1b            \n"
 		"    srl    %[my_ticket], %[ticket], 16     \n"
 		"   andi    %[ticket], %[ticket], 0xffff        \n"
 		"   bne %[ticket], %[my_ticket], 4f     \n"
 		"    subu   %[ticket], %[my_ticket], %[ticket]  \n"
 		"2: .insn                       \n"
 		"   .subsection 2                   \n"
 		"4: andi    %[ticket], %[ticket], 0xffff        \n"
 		"   sll %[ticket], 5                \n"
 		"                           \n"
 		"6: bnez    %[ticket], 6b               \n"
 		"    subu   %[ticket], 1                \n"
 		"                           \n"
 		"   lhu %[ticket], %[serving_now_ptr]       \n"
 		"   beq %[ticket], %[my_ticket], 2b     \n"
 		"    subu   %[ticket], %[my_ticket], %[ticket]  \n"
 		"   b   4b                  \n"
 		"    subu   %[ticket], %[ticket], 1         \n"
 		"   .previous                   \n"
 		"   .set pop                    \n"
 		: [ticket_ptr] "+" GCC_OFF_SMALL_ASM() (lock->lock),
 		  [serving_now_ptr] "+m" (lock->h.serving_now),
 		  [ticket] "=&r" (tmp),
 		  [my_ticket] "=&r" (my_ticket)
 		: [inc] "r" (inc));

    smp_llsc_mb();
}
```
>file: arch/mips/include/asm/spinlock.h

**算法：[Ticket lock: A fair lock](/downloads/kernel/spinlock/mcs.pdf)**

#### arch_spin_trylock

``` C
static inline unsigned int arch_spin_trylock(arch_spinlock_t *lock)
{
    int tmp, tmp2, tmp3;
    int inc = 0x10000;

    __asm__ __volatile__ (
		"   .set push       # arch_spin_trylock \n"
		"   .set noreorder                  \n"
		"                           \n"
		"1: ll  %[ticket], %[ticket_ptr]        \n"
		"   srl %[my_ticket], %[ticket], 16     \n"
		"   andi    %[now_serving], %[ticket], 0xffff   \n"
		"   bne %[my_ticket], %[now_serving], 3f    \n"
		"    addu   %[ticket], %[ticket], %[inc]        \n"
		"   sc  %[ticket], %[ticket_ptr]        \n"
		"   beqz    %[ticket], 1b               \n"
		"    li %[ticket], 1                \n"
		"2: .insn                       \n"
		"   .subsection 2                   \n"
		"3: b   2b                  \n"
		"    li %[ticket], 0                \n"
		"   .previous                   \n"
		"   .set pop                    \n"
		: [ticket_ptr] "+" GCC_OFF_SMALL_ASM() (lock->lock),
		  [ticket] "=&r" (tmp),
		  [my_ticket] "=&r" (tmp2),
		  [now_serving] "=&r" (tmp3)
		: [inc] "r" (inc));

     smp_llsc_mb();

     return tmp;
 }
```
>file: arch/mips/include/asm/spinlock.h


#### 反汇编arch_spin_lock

```
<lg_local_lock>:
   ...

   3c030001    lui v1,0x1
   c0440000    ll  a0,0(v0)
   00832821    addu    a1,a0,v1
   e0450000    sc  a1,0(v0)
   10a0fffc    beqz    a1,80071228 <lg_local_lock+0x40>
   00042c02    srl a1,a0,0x10
   3084ffff    andi    a0,a0,0xffff
   14850120    bne a0,a1,800716c4 <lg_double_unlock+0x88>
   00a42023    subu    a0,a1,a0

   0000000f    sync			//smp_llsc_mb(); 
   ...
```

## 参考

1. [Linux内核同步机制之（四）：spin lock](http://www.wowotech.net/kernel_synchronization/spinlock.html)
