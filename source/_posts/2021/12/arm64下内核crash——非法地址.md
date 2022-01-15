---
layout: post
title: arm64下内核crash——非法地址
date: '2021-12-01 09:32'
tags:
  - arm64
  - kernel
  - crash
categories:
  - Linux内核
abbrlink: 774c4289
---


下面是在实际工作中遇到的一次内核（5.4.110）访问非法内存地址（空指针）导致出错的现场，在这里记录一下简单的分析流程为以后遇到类似的问题作为参考。

<!--more-->

```
[  220.619861] Unable to handle kernel NULL pointer dereference at virtual address 0000000000000023
[  220.628815] Mem abort info:
[  220.631737]   ESR = 0x96000006
[  220.634932]   EC = 0x25: DABT (current EL), IL = 32 bits
[  220.640369]   SET = 0, FnV = 0
[  220.643542]   EA = 0, S1PTW = 0
[  220.646788] Data abort info:
[  220.649783]   ISV = 0, ISS = 0x00000006
[  220.653737]   CM = 0, WnR = 0
[  220.656855] user pgtable: 4k pages, 39-bit VAs, pgdp=000000001149c000
[  220.663422] [0000000000000023] pgd=00000000080dc003, pud=00000000080dc003, pmd=0000000000000000
[  220.672360] Internal error: Oops: 96000006 [#1] SMP
[  220.677359] Modules linked in:
[  220.680627] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 5.4.110-00126-gad9975d0488d-dirty #1
[  220.689008] Hardware name: vanxum,tequila (DT)
[  220.693614] pstate: 20000085 (nzCv daIf -PAN -UAO)
[  220.698626] pc : dwc_descriptor_complete+0x104/0x140
[  220.703775] lr : dwc_descriptor_complete+0x48/0x140
[  220.708772] sp : ffffffc010003d00
[  220.712203] x29: ffffffc010003d00 x28: 0000000000000006
[  220.717699] x27: 0000000000000100 x26: 000000000000000a
[  220.723192] x25: ffffffc010b3363b x24: ffffff80102a3080
[  220.728684] x23: 0000000000000001 x22: ffffff8010104860
[  220.734172] x21: 0000000000000000 x20: ffffff80101047f0
[  220.739664] x19: ffffffc010ed6460 x18: 0000000000000000
[  220.745152] x17: 0000000000000000 x16: 0000000000000000
[  220.750635] x15: 0000000000000000 x14: 0000000000000000
[  220.756117] x13: 0000000000000000 x12: 0000000000000000
[  220.761603] x11: 0000000000000000 x10: ffffffc010d329d8
[  220.767093] x9 : 0000000000000005 x8 : ffffffc010d329b8
[  220.772582] x7 : 0000000000000000 x6 : 0000000000000000
[  220.778067] x5 : 0000000000000000 x4 : 0000000000000000
[  220.783555] x3 : ffffffc010ed64a0 x2 : ffffffffffffffdf
[  220.789048] x1 : ffffffffffffffff x0 : ffffffc010ed6490
[  220.794528] Call trace:
[  220.797177]  dwc_descriptor_complete+0x104/0x140
[  220.801978]  dwc_scan_descriptors+0x1e4/0x32c
[  220.806510]  dw_dma_tasklet+0x37c/0x380
[  220.810551]  tasklet_action_common.constprop.0+0xb0/0x10c
[  220.816140]  tasklet_action+0x34/0x40
[  220.819966]  __do_softirq+0x1e8/0x2b8
[  220.823810]  irq_exit+0x64/0xb4
[  220.827134]  __handle_domain_irq+0x7c/0xa8
[  220.831394]  gic_handle_irq+0x84/0xc8
[  220.835213]  el1_irq+0xb8/0x140
[  220.838536]  arch_local_irq_enable+0x8/0x10
[  220.842908]  finish_task_switch+0x10c/0x194
[  220.847250]  __schedule+0x3f0/0x530
[  220.850893]  schedule_idle+0x34/0x48
[  220.854640]  do_idle+0x94/0x268
[  220.857955]  cpu_startup_entry+0x2c/0x48
[  220.862068]  rest_init+0xc8/0xd8
[  220.865489]  arch_call_rest_init+0x18/0x20
[  220.869769]  start_kernel+0x448/0x480
[  220.873658] Code: 97f276b0 a9057fff f90033ff 17ffffe2 (b9404441)
[  220.879910] ---[ end trace 6df1a29c28ae9694 ]---
[  220.884668] Kernel panic - not syncing: Fatal exception in interrupt
[  220.891172] SMP: stopping secondary CPUs
[  220.895297] Kernel Offset: disabled
[  220.898920] CPU features: 0x0002,20002004
[  220.903036] Memory Limit: none
[  220.906301] ---[ end Kernel panic - not syncing: Fatal exception in interrupt ]---
```
> 该问题初步分析是进行DMA传输时，可能将函数调用栈信息冲掉所致

## 根据dump出的函数调用定位具体出错的代码

最终出错代码
```
pc : dwc_descriptor_complete+0x104/0x140
```
gdb定位具体代码
``` C
$aarch64-none-linux-gnu-gdb vmlinux

(gdb) list *(dwc_descriptor_complete+0x104)
0xffffffc01040f7c8 is in dwc_descriptor_complete (./include/linux/dmaengine.h:1189).
1184	void dma_async_tx_descriptor_init(struct dma_async_tx_descriptor *tx,
1185					  struct dma_chan *chan);
1186
1187	static inline void async_tx_ack(struct dma_async_tx_descriptor *tx)
1188	{
1189		tx->flags |= DMA_CTRL_ACK;    //在进行flags赋值是出错，也就是tx出现空指针
1190	}
1191
1192	static inline void async_tx_clear_ack(struct dma_async_tx_descriptor *tx)
1193	{
(gdb)
```

## 定位具体出错指令

由于出错的接口函数中只是一个普通的赋值操作，因此需要进一步确认出错时，CPU执行的汇编指令是否存在异常或者特殊性

查看`dwc_descriptor_complete`接口函数的汇编实现
``` C
(gdb) disassemble dwc_descriptor_complete
Dump of assembler code for function dwc_descriptor_complete:
   0xffffffc01040f6c4 <+0>:	stp	x29, x30, [sp, #-112]!
   0xffffffc01040f6c8 <+4>:	mov	x29, sp
   0xffffffc01040f6cc <+8>:	stp	x19, x20, [sp, #16]
   0xffffffc01040f6d0 <+12>:	stp	x21, x22, [sp, #32]
   0xffffffc01040f6d4 <+16>:	str	x23, [sp, #48]
   0xffffffc01040f6d8 <+20>:	xpaclri
   0xffffffc01040f6dc <+24>:	mov	x19, x1     //第二个入参被转存到x19  <------------------ [6]
   0xffffffc01040f6e0 <+28>:	mov	x20, x0
   0xffffffc01040f6e4 <+32>:	and	w23, w2, #0xff
   0xffffffc01040f6e8 <+36>:	mov	x0, x30
   0xffffffc01040f6ec <+40>:	bl	0xffffffc01009647c <_mcount>
   0xffffffc01040f6f0 <+44>:	mrs	x0, sp_el0
   0xffffffc01040f6f4 <+48>:	add	x22, x20, #0x70
   0xffffffc01040f6f8 <+52>:	ldr	x1, [x0, #1240]
   0xffffffc01040f6fc <+56>:	str	x1, [sp, #104]
   0xffffffc01040f700 <+60>:	mov	x1, #0x0                   	// #0
   0xffffffc01040f704 <+64>:	mov	x0, x22
   0xffffffc01040f708 <+68>:	bl	0xffffffc01093b10c <_raw_spin_lock_irqsave>
   0xffffffc01040f70c <+72>:	mov	x21, x0
   0xffffffc01040f710 <+76>:	ldr	w0, [x19, #64]   // 第二个入参的第一次使用 ( dma_cookie_complete(txd);) <------- [7]
   0xffffffc01040f714 <+80>:	add	x3, x19, #0x40   //x3=x19+0x40, 0xffffffc010ed6460+0x40=0xffffffc010ed64a0
   0xffffffc01040f718 <+84>:	cmp	w0, #0x0         
   0xffffffc01040f71c <+88>:	b.gt	0xffffffc01040f724 <dwc_descriptor_complete+96>  //判断w0大于0时，进行跳转
   0xffffffc01040f720 <+92>:	brk	#0x800
   0xffffffc01040f724 <+96>:	ldr	x1, [x3, #16]
   0xffffffc01040f728 <+100>:	str	w0, [x1, #12]
   0xffffffc01040f72c <+104>:	str	wzr, [x19, #64]
   0xffffffc01040f730 <+108>:	cbz	w23, 0xffffffc01040f7bc <dwc_descriptor_complete+248> //比较w23为0，进行跳转，w23应该是传入的第三个参数
   0xffffffc01040f734 <+112>:	ldr	x0, [x3, #40]
   0xffffffc01040f738 <+116>:	str	x0, [sp, #80]
   0xffffffc01040f73c <+120>:	ldr	x0, [x3, #48]
   0xffffffc01040f740 <+124>:	str	x0, [sp, #88]
   0xffffffc01040f744 <+128>:	ldr	x0, [x3, #56]
   0xffffffc01040f748 <+132>:	str	x0, [sp, #96]
   0xffffffc01040f74c <+136>:	mov	x0, x19          //将x19赋值到x0    <---------------- [5]
   0xffffffc01040f750 <+140>:	ldr	x2, [x0, #48]!   //x2=*(x0 + 0x30),读取内存地址的值赋值x2  <-------------- [4]
   0xffffffc01040f754 <+144>:	sub	x2, x2, #0x20    //x2第一次处理，x2减0x20 （&desc->tx_list） <------------- [3]
   0xffffffc01040f758 <+148>:	add	x1, x2, #0x20    //x1是在x2基础上又加了0x20,因此变成了全F
   0xffffffc01040f75c <+152>:	cmp	x1, x0
   0xffffffc01040f760 <+156>:	b.ne	0xffffffc01040f7c8 <dwc_descriptor_complete+260>  // b.any x1不对于x0时，跳转执行 <----------- [2]
   0xffffffc01040f764 <+160>:	ldr	w0, [x3, #4]
   0xffffffc01040f768 <+164>:	mov	x1, x19

   ....
   0xffffffc01040f7ac <+232>:	subs	x1, x1, x2
   0xffffffc01040f7b0 <+236>:	mov	x2, #0x0                   	// #0
   0xffffffc01040f7b4 <+240>:	b.eq	0xffffffc01040f7f0 <dwc_descriptor_complete+300>  // b.none
   0xffffffc01040f7b8 <+244>:	bl	0xffffffc0100ad278 <__stack_chk_fail>
   0xffffffc01040f7bc <+248>:	stp	xzr, xzr, [sp, #80]
   0xffffffc01040f7c0 <+252>:	str	xzr, [sp, #96]
   0xffffffc01040f7c4 <+256>:	b	0xffffffc01040f74c <dwc_descriptor_complete+136>
   0xffffffc01040f7c8 <+260>:	ldr	w1, [x2, #68]  // 出错指令 w1=*(x2 + 0x44) <----------- [1]
   0xffffffc01040f7cc <+264>:	orr	w1, w1, #0x2
   0xffffffc01040f7d0 <+268>:	str	w1, [x2, #68]
   0xffffffc01040f7d4 <+272>:	ldr	x2, [x2, #32]
   ....
```

- [1]: 此处为具体出错指令，意思是将寄存器X2中的值加上68后作为内存地址，并将该内存地址的数据取出，存到w1寄存器中。非法内存地址也就是X2加68（0x44）得到的，根据crash dump出的寄存器值此时`X2=ffffffffffffffdf`，0xffffffffffffffdf+0x44=`0x0000000000000023`刚好是非法内存地址，也就是说出错的因为`x2`寄存器的值保存错了。
- [2]: 此处跳转到[1]处执行时出错，也就是在此之前`x2`寄存器的赋值出错了
- [3]: `x2`是由`x2`减去0x20后得到的，也就是原来的`x2`应该是0xffffffffffffffdf+0x20=0xFFFFFFFFFFFFFFFF
- [4]: `x2`（FFFFFFFFFFFFFFFF）是通过`x0`寄存器的值加48后的这个内存地址中读取出的。
- [5]: `x0`来自于`x19`(ffffffc010ed6460)
- [6]: `x19`来自于`x1`,而x1是`dwc_descriptor_complete`接口函数的第二个参数

以上流程中表明`x2`寄存器出现`FFFFFFFFFFFFFFFF`的可能性存在两种：

1. dwc_descriptor_complete接口函数传参时，第二个参数是个错误的指针。这样就会使`x0`寄存器错误导致在[4]时，通过内存地址读取数据赋值该`x2`时，出现全F的值（一个错误的指针指向了错误的内存区域所致）。
   - 由于在[7]处对第二个参数已经使用过（读写），因此可以证明传入的第二个参数指针是正确的。如果错误应该会在[7]处直接报错。
2. dwc_descriptor_complete接口函数传参时，第二个参数是正确的。但是在[4]时，通过内存地址读取数据赋值给`x2`时，原来正确的数据被别的程序覆盖掉了（踩内存）

** 通过以上流程的分析我认为是在[4]处，读取相关内存地址中的数据时，原有的正确数据被错误数据覆盖 **

C源码：
``` C
(gdb) list dwc_descriptor_complete
271	/*----------------------------------------------------------------------*/
272
273	static void
274	dwc_descriptor_complete(struct dw_dma_chan *dwc, struct dw_desc *desc,
275			bool callback_required)
276	{
277		struct dma_async_tx_descriptor	*txd = &desc->txd;
278		struct dw_desc			*child;
279		unsigned long			flags;
280		struct dmaengine_desc_callback	cb;
(gdb)
281
282		dev_vdbg(chan2dev(&dwc->chan), "descriptor %u complete\n", txd->cookie);
283
284		spin_lock_irqsave(&dwc->lock, flags);
285		dma_cookie_complete(txd);
286		if (callback_required)
287			dmaengine_desc_get_callback(txd, &cb);
288		else
289			memset(&cb, 0, sizeof(cb));
290
(gdb)
291		/* async_tx_ack */
292		list_for_each_entry(child, &desc->tx_list, desc_node)
293			async_tx_ack(&child->txd);
294		async_tx_ack(&desc->txd);
295		dwc_desc_put(dwc, desc);
296		spin_unlock_irqrestore(&dwc->lock, flags);
297
298		dmaengine_desc_callback_invoke(&cb, NULL);
299	}
300
```

通过对以上汇编代码的分析出错的原因主要是`[4]`,读取内存数据（ldr	x2, [x0, #48]!）时出错。该指令对应的C代码实现主要在`list_for_each_entry(child, &desc->tx_list, desc_node)`接口

这样结合之前分析的出错原因，可能是别的程序写内存时覆盖了tx_list链表数据（踩内存）；不过还存在一种可能就是tx_list的操作出错了，由dma驱动代码本身所造成的bug。


## MMU错误信息

``` C
[  220.619861] Unable to handle kernel NULL pointer dereference at virtual address 0000000000000023
// 解析ESR_EL1寄存器
[  220.628815] Mem abort info:
[  220.631737]   ESR = 0x96000006
[  220.634932]   EC = 0x25: DABT (current EL), IL = 32 bits
[  220.640369]   SET = 0, FnV = 0
[  220.643542]   EA = 0, S1PTW = 0
[  220.646788] Data abort info:
[  220.649783]   ISV = 0, ISS = 0x00000006
[  220.653737]   CM = 0, WnR = 0

[  220.656855] user pgtable: 4k pages, 39-bit VAs, pgdp=000000001149c000
[  220.663422] [0000000000000023] pgd=00000000080dc003, pud=00000000080dc003, pmd=0000000000000000
[  220.672360] Internal error: Oops: 96000006 [#1] SMP
```

以上信息主要是在内核出现`do_page_fault`时的一些log信息

``` shell
do_page_fault
  \->__do_kernel_fault
    \->die_kernel_fault
      \->mem_abort_decode
        \->data_abort_decode
      \->show_pte
      \->die(Oops)
```
> from: arch/arm64/mm/fault.c

`mem_abort_decode`函数主要是解析`ESR_ELx`寄存器，在内核模式下为`ESR_EL1`

![arm64_ESR_EL1](/images/2021/12/arm64_esr_el1.png)

`EC, bits [31:26]`,  EC = 0x25， DABT (current EL)，异常级别未更改的数据中止。用于数据访问产生的MMU错误、除堆栈指针未对齐引起的对齐错误和同步外部中止（包括同步奇偶校验或ECC错误）之外的对齐错误。

```
  EC == 0b100101
    Data Abort taken without a change in Exception level.
    Used for MMU faults generated by data accesses, alignment faults other than those
    caused by Stack Pointer misalignment, and synchronous External aborts, including
    synchronous parity or ECC errors. Not used for debug related exceptions.
    See ISS encoding for an exception from a Data Abort.
```


## 参考

- [DDI0487D_a_armv8_arm.pdf](https://developer.arm.com/documentation/ddi0487/gb/)
- [ARMv8 A64 Quick Reference](https://courses.cs.washington.edu/courses/cse469/20wi/arm64.pdf) —— 汇编指令
