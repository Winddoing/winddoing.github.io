---
title: MIPS架构下的中断处理
date: 2018-03-22 23:22:24
categories: Linux内核
tags: [中断]
---

<!--more-->

内核版本: 3.10.14

linux内核出入文件:arch/mips/kernel/traps.c

## 函数调用关系

```
set_except_vector(0, using_rollback_handler() ? rollback_handle_int: handle_int)
	-> handle_int 
		-> plat_irq_dispatch
```

## 代码跳转(反汇编)
 
``` asm
80014780 <handle_int>:
80014780:   401a6000    mfc0    k0,c0_status
80014784:   335a0001    andi    k0,k0,0x1
80014788:   17400002    bnez    k0,80014794 <handle_int+0x14>
8001478c:   00000000    nop
	.
	.
80014898:   27ff43e0    addiu   ra,ra,17376
8001489c:   3c028001    lui v0,0x8001
800148a0:   24421404    addiu   v0,v0,5124
800148a4:   00400008    jr  v0       #jr -> 0x80011404
800148a8:   00000000    nop


80011404 <plat_irq_dispatch>:                                 
80011404:   40076000    mfc0    a3,c0_status
80011408:   40066800    mfc0    a2,c0_cause
8001140c:   00e61024    and v0,a3,a2
80011410:   00021202    srl v0,v0,0x8

```

### jr v0

handle_int中jr跳转的函数地址v0的计算:

``` asm
lui v0 0x8001
addiu v0,v0,5124 #0x80011404
```

### lui & addiu

具体的指令码,可参考MIPS手册.
这两个指令码的低十六位为立即数的十六进制数.

## handle_int函数的组合

