---
title: IPI通信（SMP）
categories:
  - Linux内核
tags:
  - ipi
  - smp
abbrlink: 60164
date: 2018-01-18 23:17:24
---


>IPI(Interrupt-Procecesorr Interrupt): 处理中间的中断

主要应用是一个处理器让另一个处理器做特定的事情（function和sched）

```
              +---------------------------+-+
system boot   | request_percpu_irq（）      +
              | mailbox irq handle          +
              +--+-----------------------+--+
                 |                       |
                 |                       |
              +--v--+                +---v-+
              | CPU0|                > CPU1|
              +--+--+                +----++
                 |                        |
            +----+----+             +-----+-----+
            |mailbox0 |          +-->mailbox1   |
            +---------+          |  +-----------+
                                 |
                 +---------------+        |
system run    A send IPI CPU1             |
              write mailbox1              |
                 |                        |
                 |                  +-----v-----------------+---+
          +------+----+             | 1. 读取mailbox中的action  +
          |  Task A   |             | 2. 通过action判断IPI类型  +
          |           |             | 3. 进行function和sched处理+
          +-----------+             |                           +
                                    +---------------------------+
```

在多核处理器中，每一个CPU核有一个`mailbox`(相当于邮箱)，如果需要进行IPI通信时，其主要通过IPI的中断实现。假设CPU0需要给CPU1发送一个`action`(`action`I的类型：`SMP_CALL_FUNCTION`,`SMP_RESCHEDULE_YOURSELF`等)时, 只需要CPU0向CPU1的`mailbox`中写于`action`的id（相当于信），此时CPU1将产生一个IPI中断（表明收到信），`mailbox`的中断处理程序将读取`mailbox`（相当于看信）中的`action`，判断`action`的类型进行相应的处理。

<!--more-->

MIPS架构下的IPI通信


> 1. 关闭中断后还会发送IPI

## MIPS接口

``` C
struct plat_smp_ops {
	void (*send_ipi_single)(int cpu, unsigned int action);
	void (*send_ipi_mask)(const struct cpumask *mask, unsigned int action);
	...
}
```
> IPI通信就是多个处理器之间的`交流`。
> `send_ipi_single`： 一对一聊天
> `send_ipi_mask` : 群发，mask表示群发的成员（CPU）

## action类型

``` C
#define SMP_RESCHEDULE_YOURSELF 0x1 /* XXX braindead */
#define SMP_CALL_FUNCTION   0x2
/* Octeon - Tell another core to flush its icache */
#define SMP_ICACHE_FLUSH    0x4
/* Used by kexec crashdump to save all cpu's state */
#define SMP_DUMP        0x8
#define SMP_IPI_TIMER       0xC
```
>file: arch/mips/include/asm/smp.h

1. 不同的action(活动)何时将产生？
2. 各自都有什么作用？

### SMP_RESCHEDULE_YOURSELF

> `SMP_RESCHEDULE_YOURSELF`将直接调用`scheduler_ipi`.将任务插入目标CPU的运行队列。

``` C
/*
 * this function sends a 'reschedule' IPI to another CPU.
 * it goes straight through and wastes no time serializing
 * anything. Worst case is that we lose a reschedule ...
 */
static inline void smp_send_reschedule(int cpu)
{
	extern struct plat_smp_ops *mp_ops; /* private */

	mp_ops->send_ipi_single(cpu, SMP_RESCHEDULE_YOURSELF);
}
```
>file: arch/mips/include/asm/smp.h

### SMP_CALL_FUNCTION

> `SMP_CALL_FUNCTION`:将特定的函数在目标CPU上运行

* 内核回调接口：
``` C
static inline void arch_send_call_function_single_ipi(int cpu)
{
	extern struct plat_smp_ops *mp_ops; /* private */

	mp_ops->send_ipi_mask(&cpumask_of_cpu(cpu), SMP_CALL_FUNCTION);
}

static inline void arch_send_call_function_ipi_mask(const struct cpumask *mask)
{
	extern struct plat_smp_ops *mp_ops; /* private */

	mp_ops->send_ipi_mask(mask, SMP_CALL_FUNCTION);
}
```
>file: arch/mips/include/asm/smp.h

``` C
/*
 * smp_call_function_single - Run a function on a specific CPU
 * @func: The function to run. This must be fast and non-blocking.
 * @info: An arbitrary pointer to pass to the function.
 * @wait: If true, wait until function has completed on other CPUs.
 *
 * Returns 0 on success, else a negative status code.
 */

smp_call_function_single
	\->generic_exec_single
		\->arch_send_call_function_single_ipi

/**
 * smp_call_function_many(): Run a function on a set of other CPUs.
 * @mask: The set of cpus to run on (only runs on online subset).
 * @func: The function to run. This must be fast and non-blocking.
 * @info: An arbitrary pointer to pass to the function.
 * @wait: If true, wait (atomically) until function has completed
 *        on other CPUs.
 *
 * If @wait is true, then returns once @func has returned.
 *
 * You must not call this function with disabled interrupts or from a
 * hardware interrupt handler or from a bottom half handler. Preemption
 * must be disabled when calling this function.
 */

smp_call_function_many
	\->arch_send_call_function_ipi_mask
```
>file: kernel/smp.c

## 刷新TLB

多核进行TLB的同步？
