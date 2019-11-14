---
title: Cache
categories: MIPS
tags:
  - mips
  - cache
  - kernel
abbrlink: 50757
date: 2018-01-25 23:22:24
---


```
+----+  +----+   +----+  +----+
|CPU0|  |CPU1|   |CPU2|  |CPU3|
+----+  +----+   +----+  +----+
  +-+     +-+     +-+      +-+
    |     |         |      |
+---v-----v--+   +--v------v--+
|   L1 Cache |   |  L2 Cache  |
+------+-----+   +------+-----+
       |                |
+------v----------------v-----+
|         L2 Cache            |
+-----------------------------+
```

<!--more-->

## Cache 初始化

```
kernel_start
	\->setup_arch
		\->cpu_cache_init
			\->r4k_cache_init
```

``` C
#define cpu_dcache_size()           (32 * 1024)      
#define cpu_dcache_ways()           8                
#define cpu_dcache_line_size()      32               
#define cpu_icache_size()           (32 * 1024)      
#define cpu_icache_ways()           8                
#define cpu_icache_line_size()      32               
```


## cpuinfo_mips

``` C
struct cpuinfo_mips {    
	unsigned int        udelay_val;                                       
	...
	/*                                                                    
	 *Capability and feature descriptor structure for MIPS CPU           
	 */                                                                   
	unsigned int        processor_id;                                     
	unsigned int        fpu_id;                                           
	unsigned int        msa_id;                                           
	unsigned int        cputype;                                          
	...
} __attribute__((aligned(SMP_CACHE_BYTES)));   

extern struct cpuinfo_mips cpu_data[];                           
#define current_cpu_data cpu_data[smp_processor_id()]            
#define raw_current_cpu_data cpu_data[raw_smp_processor_id()]    
```
>file: arch/mips/include/asm/cpu-info.h

* 初始化：
``` C
struct cpuinfo_mips cpu_data[NR_CPUS] __read_mostly;
EXPORT_SYMBOL(cpu_data);
```
>file:  arch/mips/kernel/setup.c 

