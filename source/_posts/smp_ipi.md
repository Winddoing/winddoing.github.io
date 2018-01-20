---
title: IPI通信（SMP）
date: 2018-01-18 23:17:24
categories: Linux内核
tags: [IPI, SMP]
---


>IPI(Interrupt-Procecesorr Interrupt)

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
