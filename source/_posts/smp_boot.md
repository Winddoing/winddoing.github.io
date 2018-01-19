---
title: SMP多核启动
date: 2018-01-12 23:07:24
categories: 计算机系统
tags: [SMP]
---


smp的多核启动：

> MIPS框架下的启动流程


<!--more-->

## 数据结构

``` C
struct plat_smp_ops {
	void (*send_ipi_single)(int cpu, unsigned int action);
    void (*send_ipi_mask)(const struct cpumask *mask, unsigned int action);
    void (*init_secondary)(void);
    void (*smp_finish)(void);
    void (*cpus_done)(void);
    void (*boot_secondary)(int cpu, struct task_struct *idle);
    void (*smp_setup)(void);
    void (*prepare_cpus)(unsigned int max_cpus);
#ifdef CONFIG_HOTPLUG_CPU
    int (*cpu_disable)(void);
    void (*cpu_die)(unsigned int cpu);
#endif
};
```

### smp init


![smp_init](/images/smp/smp-init.png)

```
smp_prepare_cpus  --> (.prepare_cpus)
	|
1. 初始化mailbox并申请mailbox中断
2. 制造每个核启动时的初始化代码
3. 将初始化代码写入reset entry
4. 刷cache
```

>将CCU中的相应CPU进行reset后， 相应的CPU PC将跳入reset entry执行代码

### init_secondary

在boot_secondary中，将per CPU进行reset后，系统所有CPU依次启动

![smp_init](/images/smp/smp-init-secondary.png)

## 系统启动


系统上电后，boot CPU启动，执行`start_kernel`（init/main.c），并分别调用`boot_cpu_init`和`setup_arch`两个接口，进行possible CPU相关的初始化。

``` C
/*
 *	Activate the first processor.
 */

static void __init boot_cpu_init(void)
{
	int cpu = smp_processor_id();
	/* Mark the boot cpu "present", "online" etc for SMP and UP case */
	set_cpu_online(cpu, true);
	set_cpu_active(cpu, true);
	set_cpu_present(cpu, true);
	set_cpu_possible(cpu, true);
}
```
> set_cpu_xxx接口，可以将指定的CPU设置为（或者清除）指定的状态。

```
/*
 * The following particular system cpumasks and operations manage
 * possible, present, active and online cpus.
 *
 *     cpu_possible_mask- has bit 'cpu' set iff cpu is populatable
 *     cpu_present_mask - has bit 'cpu' set iff cpu is populated
 *     cpu_online_mask  - has bit 'cpu' set iff cpu available to scheduler
 *     cpu_active_mask  - has bit 'cpu' set iff cpu available to migration
 *
 *  If !CONFIG_HOTPLUG_CPU, present == possible, and active == online.
 *
 *  The cpu_possible_mask is fixed at boot time, as the set of CPU id's
 *  that it is possible might ever be plugged in at anytime during the
 *  life of that system boot.  The cpu_present_mask is dynamic(*),
 *  representing which CPUs are currently plugged in.  And
 *  cpu_online_mask is the dynamic subset of cpu_present_mask,
 *  indicating those CPUs available for scheduling.
 *
 *  If HOTPLUG is enabled, then cpu_possible_mask is forced to have
 *  all NR_CPUS bits set, otherwise it is just the set of CPUs that
 *  ACPI reports present at boot.
 *
 *  If HOTPLUG is enabled, then cpu_present_mask varies dynamically,
 *  depending on what ACPI reports as currently plugged in, otherwise
 *  cpu_present_mask is just a copy of cpu_possible_mask.
 *
 *  (*) Well, cpu_present_mask is dynamic in the hotplug case.  If not
 *      hotplug, it's a copy of cpu_possible_mask, hence fixed at boot.
 *
 * Subtleties:
 * 1) UP arch's (NR_CPUS == 1, CONFIG_SMP not defined) hardcode
 *    assumption that their single CPU is online.  The UP
 *    cpu_{online,possible,present}_masks are placebos.  Changing them
 *    will have no useful affect on the following num_*_cpus()
 *    and cpu_*() macros in the UP case.  This ugliness is a UP
 *    optimization - don't waste any instructions or memory references
 *    asking if you're online or how many CPUs there are if there is
 *    only one CPU.
 */
```

| 状态 | 作用 |
| :---: | :--: |
| online | 可以被调度的  |
| active | 可以被迁移的  |
| present| 内核已接管的  |
| possible | 系统存在的CPU，但没有被内核接管   |

``` C
void __init setup_arch(char **cmdline_p)
{
#ifdef CONFIG_EARLY_PRINTK
	setup_early_printk();
#endif

	cpu_probe();
	prom_init();

	cpu_report();
	check_bugs_early();

#if defined(CONFIG_VT)
#if defined(CONFIG_VGA_CONSOLE)
	conswitchp = &vga_con;
#elif defined(CONFIG_DUMMY_CONSOLE)
	conswitchp = &dummy_con;
#endif
#endif

	arch_mem_init(cmdline_p);

	resource_init();
	plat_smp_setup();

	cpu_cache_init();
}
```
>file: arch/mips/kernel/setup.c


``` C
void __init prom_init(void)
{
	prom_init_cmdline((int)fw_arg0, (char **)fw_arg1);
	mips_machtype = MACH_XBURST;
#ifdef CONFIG_SMP
	register_smp_ops(&xburst2_smp_ops);
#endif
}
```
>file: arch/mips/xburst2/core/prom.c

将`struct plat_smp_ops`结构体注册SMP框架

``` C
/* preload SMP state for boot cpu */
void smp_prepare_boot_cpu(void)
{
	set_cpu_possible(0, true);
	set_cpu_online(0, true);
	cpu_set(0, cpu_callin_map);
}
```
> file: arch/mips/kernel/smp.c





## 开关核

```
echo 0 > /sys/devices/system/cpu/cpu1/online //关
echo 1 > /sys/devices/system/cpu/cpu1/online //开
```

``` C
static ssize_t __ref store_online(struct device *dev,
				  struct device_attribute *attr,
				  const char *buf, size_t count)
{
	...
	cpu_hotplug_driver_lock();
	switch (buf[0]) {
	case '0':
		ret = cpu_down(cpuid);
		...
		break;
	case '1':
		from_nid = cpu_to_node(cpuid);
		ret = cpu_up(cpuid);
		...
		break;
	default:
		ret = -EINVAL;
	}
	cpu_hotplug_driver_unlock();
	...
}

static DEVICE_ATTR(online, 0644, show_online, store_online);
```
>file: drivers/base/cpu.c

### echo 0 > online

实现接口：

``` C
#ifdef CONFIG_HOTPLUG_CPU
static inline int __cpu_disable(void)
{
    extern struct plat_smp_ops *mp_ops; /* private */

    return mp_ops->cpu_disable();
}

static inline void __cpu_die(unsigned int cpu)
{
    extern struct plat_smp_ops *mp_ops; /* private */

    mp_ops->cpu_die(cpu);
}

extern void play_dead(void);
#endif
```
>file: arch/mips/include/asm/smp.h

调用关系：

```
cpu_down
	\->_cpu_down(cpu, 0)
		\->take_cpu_down
			\->__cpu_disable()
				\->mp_ops->cpu_disable()
        \->__cpu_die(cpu)
```
>file: /kernel/cpu.c


将被关闭的CPU的中断迁移走后，使其处理完成最后的（飞行状态）任务，进入idle模式，在idle模式判断自己是否需要关闭，如果需要将执行到`play_dead`将自己杀掉（关闭中断）。

``` C
static void cpu_idle_loop(void)
{
    while (1) {
        ...

        if (cpu_is_offline(smp_processor_id()))
            arch_cpu_idle_dead();
        ...
    }
}
```
>file: kernel/cpu/idle.c


``` C
#ifdef CONFIG_HOTPLUG_CPU
void arch_cpu_idle_dead(void)
{
	/* What the heck is this check doing ? */
	if (!cpu_isset(smp_processor_id(), cpu_callin_map))
		play_dead();
}
#endif
```
>file: arch/mips/kernel/process.c


### echo 1 > online

调用被开核的`boot_secondary`,重新走一次启动时的第二阶段。

```
cpu_up
	\->_cpu_up
		\->__cpu_up
			\->mp_ops->boot_secondary(cpu, tidle)
```
>file: /kernel/cpu.c
