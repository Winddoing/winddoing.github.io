---
layout: post
title: 内核宏—IRQCHIP_DECLARE
date: '2022-04-07 10:02'
tags:
  - irqchip
  - kernel
  - linux
categories:
  - Linux内核
abbrlink: c27adb68
---

``` C
IRQCHIP_DECLARE(gic_400, "arm,gic-400", gic_of_init);
```
声明irqchip与初始化函数的关联，兼容GIC-V2的GIC实现有很多，不过其初始化函数都是一个。在linux kernel编译的时候，你可以配置多个irq chip进入内核，编译系统会把所有的IRQCHIP_DECLARE宏定义的数据放入到一个特殊的section中（section name是`__irqchip_of_table`），我们称这个特殊的section叫做`irq chip table`。这个table也就保存了kernel支持的所有的中断控制器的ID信息（最重要的是驱动代码初始化函数和DT compatible string）

<!--more-->


## IRQCHIP_DECLARE宏定义

``` C
/* include/linux/irqchip.h */
#define IRQCHIP_DECLARE(name, compat, fn) OF_DECLARE_2(irqchip, name, compat, fn)
```

``` C
/* include/linux/of.h */                          
#define _OF_DECLARE(table, name, compat, fn, fn_type)           \            
    static const struct of_device_id __of_table_##name      \                
        __used __section(__##table##_of_table)          \                    
        __aligned(__alignof__(struct of_device_id))     \                    
         = { .compatible = compat,              \                            
             .data = (fn == (fn_type)NULL) ? fn : fn  }                                                                                    

typedef int (*of_init_fn_2)(struct device_node *, struct device_node *);     


#define OF_DECLARE_2(table, name, compat, fn) \                              
        _OF_DECLARE(table, name, compat, fn, of_init_fn_2)                   
```

`IRQCHIP_DECLARE`宏展开后

``` C
static const struct of_device_id __of_table_gic_400
    __used __section(__irqchip_of_table)  //编译时将定义的of_device_id结构体添加到irqchip_of_table section中
    __aligned(__alignof__(struct of_device_id))
    = {
      .compatible = "arm,gic-400",
      .data = gic_of_init
    }
```
> 将初始化的`of_device_id`结构体插入到`irqchip_of_table` section中


## irqchip_of_table段的定义

``` asm
/* arch/arm64/kernel/vmlinux.lds.S */
.init.data : {                                               
    INIT_DATA       //添加init section                                         
    INIT_SETUP(16)                                           
    INIT_CALLS                                               
    CON_INITCALL                                             
    INIT_RAM_FS                                              
    *(.init.rodata.* .init.bss) /* from the EFI stub */      
}                                                            
```

``` C
/* include/asm-generic/vmlinux.lds.h */
/* init and exit section handling */                                
#define INIT_DATA                           \                       
    ...
    IRQCHIP_OF_MATCH_TABLE()                    \                   
    ...

#define ___OF_TABLE(cfg, name)  _OF_TABLE_##cfg(name)   
#define __OF_TABLE(cfg, name)   ___OF_TABLE(cfg, name)  
#define OF_TABLE(cfg, name) __OF_TABLE(IS_ENABLED(cfg), name)
#define _OF_TABLE_0(name)                                
#define _OF_TABLE_1(name)                       \        
    . = ALIGN(8);                           \            
    __##name##_of_table = .;                    \        
    KEEP(*(__##name##_of_table))                    \    
    KEEP(*(__##name##_of_table_end))                     

#define IRQCHIP_OF_MATCH_TABLE() OF_TABLE(CONFIG_IRQCHIP, irqchip)  //CONFIG_IRQCHIP=y
```

`IRQCHIP_OF_MATCH_TABLE`宏展开
``` C
. = ALIGN(8);     //表示从该地址开始后面的存储进行8字节对齐
__irqchip_of_table = .;   //定义当前section名字为irqchip_of_table
KEEP(*(irqchip_of_table))
KEEP(*(irqchip_of_table_end))
```
- `KEEP`: 链接器关键字，防止被优化
- `ALIGN`： 表示字节对其


> `IRQCHIP_DECLARE`宏定义的的数据结构将直接插入到`.init.data`段中的`irqchip_of_table`


## 解析irqchip_of_table段

定义并初始化完后，何时如何被解析使用。

``` C
start_kernel
  \-> init_IRQ  //arch/arm64/kernel/irq.c
    \-> irqchip_init
```

``` C
/* drivers/irqchip/irqchip.c */
void __init irqchip_init(void)        
{                                     
    of_irq_init(__irqchip_of_table);  
    acpi_probe_device_table(irqchip);
}                                     
```

``` C
/* drivers/of/irq.c */

/* of_irq_init - Scan and init matching interrupt controllers in DT */
void __init of_irq_init(const struct of_device_id *matches)
{                                                          

  /* 扫描并初始化of_intc_desc结构体 */
  for_each_matching_node_and_match(np, matches, &match) {               
    ...              
    desc->irq_init_cb = match->data;                                  
    desc->dev = of_node_get(np);                                      
    desc->interrupt_parent = of_irq_find_parent(np);                  
    if (desc->interrupt_parent == np)                                 
        desc->interrupt_parent = NULL;                                
    list_add_tail(&desc->list, &intc_desc_list);                      
  }       

  /* 回调初始化接口，data成员的定义 */
  while (!list_empty(&intc_desc_list)) {                                                                                                          
    list_for_each_entry_safe(desc, temp_desc, &intc_desc_list, list) {      
        ...                 
        ret = desc->irq_init_cb(desc->dev,                                  
                    desc->interrupt_parent);                                
        ...                                  
        list_add_tail(&desc->list, &intc_parent_list);                      
    }                                                                       
  }                                                          
}
```
