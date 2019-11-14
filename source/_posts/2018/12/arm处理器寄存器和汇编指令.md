---
layout: post
title: ARM处理器寄存器和汇编指令
date: '2018-12-18 09:40'
tags:
  - ARM
  - 寄存器
categories:
  - ARM
  - 汇编
abbrlink: 25025
---


ARM体系结构支持`7种`处理器模式，分别是：`用户`、`FIQ `、`IRQ`、`管理`、`中止（abort）`、`未定义`和`系统`模式。除了用户模式外，其余都称之为特权模式。除了用户和系统模式外，其余都称之为异常模式

<!--more-->

## 寄存器

ARM的寄存器分为两类, `普通寄存器`和`状态寄存器`

普通寄存器总共16个，分别为R0-R15；状态寄存器共2个，分别为`CPSR`和`SPSR`

| 寄存器(Reg) | 寄存器(APCS) | 作用域           | 含义               |
|:-----------:|:------------:|:-----------------|:-------------------|
|     R0      |      a1      | 所有7种模式      | 工作寄存器         |
|     R1      |      a2      | 所有7种模式      | ..                 |
|     R2      |      a3      | 所有7种模式      | ..                 |
|     R3      |      a4      | 所有7种模式      | ..                 |
|     R4      |      v1      | 所有7种模式      | 必须保护           |
|     R5      |      v2      | 所有7种模式      | ..                 |
|     R6      |      v3      | 所有7种模式      | ..                 |
|     R7      |      v4      | 所有7种模式      | ..                 |
|     R8      |      v5      | 除FIQ模式        | ..                 |
|     R9      |      v6      | 除FIQ模式        | ..                 |
|     R10     |      sl      | 除FIQ模式        | 栈限制             |
|     R11     |      fp      | 除FIQ模式        | 帧指针             |
|     R12     |      ip      | 除FIQ模式        | 内部过程调用寄存器 |
|     R13     |      sp      | 用户和系统模式   | 栈指针             |
|     R14     |      lr      | 用户和系统模式   | 连接寄存器         |
|     R15     |      pc      | 所有7种模式      | 程序计数器         |
|    CPSR     |      -       | -                |                    |
|    SPSR     |      -       | 除用户和系统模式 | -                   |

* `R13(sp)`: 每一种异常模式都有其自己独立的r13，它通常指向异常模式所专用的堆栈，也就是说五种异常模式、非异常模式（用户模式和系统模式），都有各自独立的堆栈，用不同的堆栈指针来索引。这样当ARM进入异常模式的时候，程序就可以把一般通用寄存器压入堆栈，返回时再出栈，保证了各种模式下程序的状态的完整性。
* `R14(lr)`: 每种模式下r14都有自身版组，它有两个特殊功能。
    - 保存子程序返回地址。使用BL或BLX时，跳转指令自动把返回地址放入r14中；子程序通过把r14复制到PC来实现返回，通常用下列指令之一：
    - 当异常发生时，异常模式的r14用来保存异常返回地址，将r14如栈可以处理嵌套中断。

### PS

ARM处理器中通常将寄存器R13作为堆栈指针（SP）。ARM处理器针对不同的模式，共有**6个堆栈指针SP**, 其中用户模式和系统模式共用一个SP，每种异常模式都有各自专用的R13寄存器（SP）。它们通常指向各模式所对应的专用堆栈，也就是ARM处理器允许用户程序有六个不同的堆栈空间。这些堆栈指针分别为R13、R13_svc、R13_abt、R13_und、R13_irq、R13_fiq.

![arm_asm_reg_sp](/images/2018/12/arm_asm_reg_sp.png)

## 汇编指令

### 存储器访问指令

ARM 处理是加载/存储体系结构的典型的RISC处理器，对存储器的访问只能使用`加载`和`存储`指令实现。ARM 的加载/存储指令是可以实现字、半字、无符/有符字节操作；批量加载/存储指令可实现一条指令加载/存储多个寄存器的内容，大大提高效率；SWP指令是一条寄存器和存储器内容交换的指令，可用于信号量操作等。

#### LDR和STR

加载/存储字和无符号字节指令。使用单一数据传送指令(STR 和LDR)来装载和存储单一字节或字的数据从/到内存。
- `LDR` 指令用于从内存中读取数据放入寄存器中；
- `STR` 指令用于将寄存器中的数据保存到内存。

```
LDR{cond}{T} Rd,<地址>    ;加载指定地址上的数据(字)，放入Rd中
STR{cond}{T} Rd,<地址>    ;存储数据(字)到指定地址的存储单元，要存储的数据在Rd中
LDR{cond}B{T} Rd,<地址>   ;加载字节数据，放入Rd中，即Rd最低字节有效，高24位清零
STR{cond}B{T} Rd,<地址>   ;存储字节数据，要存储的数据在Rd，最低字节有效
```
> 其中，T 为可选后缀，若指令有T，那么即使处理器是在特权模式下，存储系统也将访问看成是处理器是在用户模式下。T在用户模式下无效，不能与前索引偏移一起使用T

* 立即数
```
LDR R1,[R0,#0x12]   ;将R0+0x12 地址处的数据读出，保存到R1中(R0 的值不变)
LDR R1,[R0,#-0x12]  ;将R0-0x12 地址处的数据读出，保存到R1中(R0 的值不变)
LDR R1,[R0]         ;将R0 地址处的数据读出，保存到R1 中(零偏移)
```
* 寄存器
```
LDR R1,[R0,R2]      ;将R0+R2 地址的数据计读出，保存到R1中(R0 的值不变)
LDR R1,[R0,-R2]     ;将R0-R2 地址处的数据计读出，保存到R1中(R0 的值不变)
```
* 寄存器及移位常数
```
LDR R1,[R0,R2,LSL #2]   ;将R0+R2*4地址处的数据读出，保存到R1中（R0，R2的值不变）
LDR R1,[R0,-R2,LSL #2]  ;将R0-R2*4地址处的数据计读出，保存到R1中(R0，R2的值不变)
```

### 数据处理指令

### 跳转指令

### 状态寄存器指令

### ARM协处理器指令

## 示例分析

### 源代码

``` C
#include <stdio.h>

int main(int argc, char* argv[])
{
    int a = 1;
    int b, c;

    b = 3;
    c = a + b;

    printf("Hello c=%d!\n", c);

    return 0;
}
```

编译:
```
arm-linux-gnueabihf-gcc hello.c -o hello --save-temp
```
### 汇编代码

``` asm
.arch armv7-a
.eabi_attribute 28, 1
.eabi_attribute 20, 1
.eabi_attribute 21, 1
.eabi_attribute 23, 3
.eabi_attribute 24, 1
.eabi_attribute 25, 1
.eabi_attribute 26, 2
.eabi_attribute 30, 6
.eabi_attribute 34, 1
.eabi_attribute 18, 4
.file	"hello.c"
.text
.section	.rodata
.align	2
.LC0:
.ascii	"Hello c=%d!\012\000"
.text
.align	1
.global	main
.syntax unified
.thumb
.thumb_func
.fpu vfpv3-d16
.type	main, %function
main:
@ args = 0, pretend = 0, frame = 24
@ frame_needed = 1, uses_anonymous_args = 0
push	{r7, lr}
sub	sp, sp, #24
add	r7, sp, #0
str	r0, [r7, #4]
str	r1, [r7]
movs	r3, #1
str	r3, [r7, #20]
movs	r3, #3
str	r3, [r7, #16]
ldr	r2, [r7, #20]
ldr	r3, [r7, #16]
add	r3, r3, r2
str	r3, [r7, #12]
ldr	r1, [r7, #12]
movw	r0, #:lower16:.LC0
movt	r0, #:upper16:.LC0
bl	printf
movs	r3, #0
mov	r0, r3
adds	r7, r7, #24
mov	sp, r7
@ sp needed
pop	{r7, pc}
.size	main, .-main
.ident	"GCC: (Linaro GCC 7.3-2018.05) 7.3.1 20180425 [linaro-7.3-2018.05 revision d29120a424ecfbc167ef90065c0eeb7f91977701]"
.section	.note.GNU-stack,"",%progbits
```
> `@`: 单行注释

## 参考

* [ARM指令集详解](https://www.cnblogs.com/uestcbutcher/p/7244799.html)
* [ARM汇编语言学习笔记（一）---ARM汇编的程序结构](https://blog.csdn.net/u013736724/article/details/53200539)
