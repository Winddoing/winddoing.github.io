---
title: cpu_cache_init与rixi
date: 2018-01-14 23:07:24
categories: Linux内核
tags: [kernel, cache]
---

`cpu_cache_init`接口：

* 初始化cache（r4k_cache_init）
* 设置cache的保护权限（setup_protection_map）

```
kernel_start
	\->setup_arch
		\->cpu_cache_init()
```
> file: arch/mips/mm/cache.c

<!--more-->

## r4k_cache_init

## setup_protection_map

``` C
static inline void setup_protection_map(void)                                   
{                                                                               
    if (cpu_has_rixi) {                                                         
        protection_map[0]  = __pgprot(_page_cachable_default | _PAGE_PRESENT | _PAGE_NO_EXEC | _PAGE_NO_READ);
        protection_map[1]  = __pgprot(_page_cachable_default | _PAGE_PRESENT | _PAGE_NO_EXEC);
        protection_map[2]  = __pgprot(_page_cachable_default | _PAGE_PRESENT | _PAGE_NO_EXEC | _PAGE_NO_READ);
        protection_map[3]  = __pgprot(_page_cachable_default | _PAGE_PRESENT | _PAGE_NO_EXEC);                                 
        protection_map[4]  = __pgprot(_page_cachable_default | _PAGE_PRESENT | _PAGE_NO_READ);
        protection_map[5]  = __pgprot(_page_cachable_default | _PAGE_PRESENT);  
        protection_map[6]  = __pgprot(_page_cachable_default | _PAGE_PRESENT | _PAGE_NO_READ);
        protection_map[7]  = __pgprot(_page_cachable_default | _PAGE_PRESENT);  

        protection_map[8]  = __pgprot(_page_cachable_default | _PAGE_PRESENT | _PAGE_NO_EXEC | _PAGE_NO_READ);
        protection_map[9]  = __pgprot(_page_cachable_default | _PAGE_PRESENT | _PAGE_NO_EXEC);
        protection_map[10] = __pgprot(_page_cachable_default | _PAGE_PRESENT | _PAGE_NO_EXEC | _PAGE_WRITE | _PAGE_NO_READ);
        protection_map[11] = __pgprot(_page_cachable_default | _PAGE_PRESENT | _PAGE_NO_EXEC | _PAGE_WRITE);
        protection_map[12] = __pgprot(_page_cachable_default | _PAGE_PRESENT | _PAGE_NO_READ);
        protection_map[13] = __pgprot(_page_cachable_default | _PAGE_PRESENT);  
        protection_map[14] = __pgprot(_page_cachable_default | _PAGE_PRESENT | _PAGE_WRITE  | _PAGE_NO_READ);
        protection_map[15] = __pgprot(_page_cachable_default | _PAGE_PRESENT | _PAGE_WRITE);

    } else {                                                                    
        protection_map[0] = PAGE_NONE;                                          
        protection_map[1] = PAGE_READONLY;                                      
        protection_map[2] = PAGE_COPY;                                          
        protection_map[3] = PAGE_COPY;                                          
        protection_map[4] = PAGE_READONLY;                                      
        protection_map[5] = PAGE_READONLY;                                      
        protection_map[6] = PAGE_COPY;                                          
        protection_map[7] = PAGE_COPY;                                          
        protection_map[8] = PAGE_NONE;                                          
        protection_map[9] = PAGE_READONLY;                                      
        protection_map[10] = PAGE_SHARED;                                       
        protection_map[11] = PAGE_SHARED;                                       
        protection_map[12] = PAGE_READONLY;                                     
        protection_map[13] = PAGE_READONLY;                                     
        protection_map[14] = PAGE_SHARED;                                       
        protection_map[15] = PAGE_SHARED;                                       
    }                                                                           
}                                                                               
```
`setup_protection_map`函数主要是对`protection_map`结构体数组的初始化
cpu_has_rixi: 需要CPU中rixi的硬件支持


``` C
/* description of effects of mapping type and prot in current implementation.   
 * this is due to the limited x86 page protection hardware.  The expected       
 * behavior is in parens:                                                       
 *                                                                              
 * map_type prot                                                                
 *      PROT_NONE   PROT_READ   PROT_WRITE  PROT_EXEC                           
 * MAP_SHARED   r: (no) no  r: (yes) yes    r: (no) yes r: (no) yes             
 *      w: (no) no  w: (no) no  w: (yes) yes    w: (no) no                      
 *      x: (no) no  x: (no) yes x: (no) yes x: (yes) yes                        
 *                                                                              
 * MAP_PRIVATE  r: (no) no  r: (yes) yes    r: (no) yes r: (no) yes             
 *      w: (no) no  w: (no) no  w: (copy) copy  w: (no) no                      
 *      x: (no) no  x: (no) yes x: (no) yes x: (yes) yes                        
 *                                                                              
 */                                                                             
pgprot_t protection_map[16] = {                                                                  
    __P000, __P001, __P010, __P011, __P100, __P101, __P110, __P111,             
    __S000, __S001, __S010, __S011, __S100, __S101, __S110, __S111              
};                                                                              
```
>file: mm/mmap.c

`protection_map`定义16种内存访问权限，其中映射类型`MAP_PRIVATE`和`MAP_SHARED`

>`__P000` 的意思是 P ( private)，0 ( No Exec)，0 ( No Write)，0 ( No Read)；

>`__P001` 的意思是 P ( private)，0 ( No Exec)，0 ( No Write)，0 ( Read)；

>`__S111` 的意思是 S ( Shared)，1 (Exec)，1 ( Write)，1 ( Read)；

## rixi

``` C
#define cpu_has_rixi                    1
```
>arch/mips/xburst2/soc-x2000/include/cpu-feature-overrides.h

使能该功能

``` C
__pgprot(_page_cachable_default | _PAGE_PRESENT | _PAGE_NO_EXEC | _PAGE_NO_READ);
```
相应宏定义：
``` C
#if defined(CONFIG_JZRISC_PEP) && defined(CONFIG_CPU_MIPS32)                    
#define _PAGE_PRESENT_SHIFT 0                                                   
#define _PAGE_PRESENT       (1 << _PAGE_PRESENT_SHIFT)                          
#define _PAGE_READ_SHIFT    1                                                   
#define _PAGE_READ      (1 << _PAGE_READ_SHIFT)                                 
#define _PAGE_WRITE_SHIFT   2                                                   
#define _PAGE_WRITE     (1 << _PAGE_WRITE_SHIFT)                                
#define _PAGE_ACCESSED_SHIFT    3                                               
#define _PAGE_ACCESSED      (1 << _PAGE_ACCESSED_SHIFT)                         
#define _PAGE_MODIFIED_SHIFT    4                                               
#define _PAGE_MODIFIED      (1 << _PAGE_MODIFIED_SHIFT)                         
#define _PAGE_FILE      (1 << 4)                                                
#define _PAGE_NO_EXEC       (1 << 5)                                            
#define _PAGE_GLOBAL        (1 << 6)                                            
#define _PAGE_VALID_SHIFT   7                                                   
#define _PAGE_VALID     (1 << _PAGE_VALID_SHIFT)                                
#define _PAGE_SILENT_READ   (1 << 7)                                            
#define _PAGE_DIRTY_SHIFT   8                                                   
#define _PAGE_DIRTY     (1 << _PAGE_DIRTY_SHIFT)                                
#define _PAGE_SILENT_WRITE  (1 << 8)                                            
#define _CACHE_SHIFT        (9)                                                 
#define _CACHE_MASK     (7 << _CACHE_SHIFT)                                     
#define _PFN_SHIFT      (PAGE_SHIFT - 12 + _CACHE_SHIFT + 3)                    
```
> file: arch/mips/include/asm/pgtable-bits.h

### _page_cachable_default

>定义MMU的类型

``` C
static void __cpuinit coherency_setup(void)                          
{                                                                    
    if (mips_cca < 0 || mips_cca > 7)                                
        mips_cca = read_c0_config() & CONF_CM_CMASK;                 
    _page_cachable_default = mips_cca << _CACHE_SHIFT;               
	...
}
```
>file: arch/mips/mm/c-r4k.c

c0_config: Config寄存器主要描述CPU资源信息和配置，`CONF_CM_CMASK`(#define CONF_CM_CMASK 7)Config[7:9]为MT，表示MMU的类型

>Config[7:9]: MT MMU类型

> 0: None； 1: MIPS32/64标准的TLB； 2：BAT类型； 3： MIPS32标准的FMT固定映射

### cpu_has_rixi = 1 和 cpu_has_rixi = 0 区别

* cpu_has_rixi = 1
``` C
protection_map[0]  = __pgprot(_page_cachable_default | _PAGE_PRESENT | _PAGE_NO_EXEC | _PAGE_NO_READ);
```

* cpu_has_rixi = 0
``` C
#define _CACHE_CACHABLE_NONCOHERENT (3<<_CACHE_SHIFT)  /* R4[0246]00      */
#define PAGE_NONE   __pgprot(_PAGE_PRESENT | _CACHE_CACHABLE_NONCOHERENT)

protection_map[0] = PAGE_NONE;
```

通过对`protection_map[0]`定义的对比，在使能rixi后，其属性增加了 `_PAGE_NO_EXEC`和`_PAGE_NO_READ`
也就是rixi在内存的访问权限上增加了`_PAGE_WRITE`, `_PAGE_READ`,`_PAGE_NO_READ`, `_PAGE_NO_EXEC`的属性控制

## 参考

1. [内核初始化](http://www.360doc.com/content/15/0310/16/18252487_454073748.shtml)
