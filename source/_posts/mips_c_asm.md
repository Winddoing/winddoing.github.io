---
title: GCC内嵌汇编(mips)
date: 2018-04-03 23:12:24
categories: 随笔
tags: [mips, 汇编]
---

>以MIPS架构的汇编为主进行说明

```
__asm__ __volatile__(
	"1: ll  %1, %2  # arch_read_lock    \n"
	"   bltz    %1, 1b              \n"
	"    addu   %1, 1               \n"
	"2: sc  %1, %0              \n"
	: "=m" (rw->lock), "=&r" (tmp)
	: "m" (rw->lock)
	: "memory");
```
* 基本形式： `__asm__ __volatile__("ssnop\n\t");`
>`ssnop`: 空指令

汇编扩展以`__asm__`开头表示后面部分为汇编,`__volatile__`严禁将此处的汇编语句和其他语句进行重组优化，就是希望gcc不要修改我们这个部分。
<!--more-->

## 构成

主要由四部分构成,之间以`:`分隔：

1. `instruction指令`:每条指令之后最好使用`"\n\t"`结尾,这样在gcc产生汇编格式比较好.
2. `output operand输出`:每个输出部分使用,分隔."="作为修饰符,"m"表示`存放位置/约束符`,()里面表示对应C程序值.
3. `input operand输入`:这个部分和输出是一样的.
4. `clobber(装备)`:这个部分是告诉gcc在这条指令里面我们会修改什么值.

### 约束符

束符影响的内容包括:
>whether an operand may be in a register
>which kinds of register
>whether the operand can be a memory reference
>which kinds of address
>whether the operand may be an immediate constant
>which possible values it may have

约束符包括:

* p 内存地址
* m 内存变量
* o 内存变量,但是寻址方式必须是偏移量的,就是基址寻址或者是基址变址寻址.
* V 内存变量,但是寻址方式是非偏移量的.
* r general寄存器操作数
* i 立即操作数,内容在编译器可以确定.
* n 立即操作数.有些系统不支持字(双字节)以外的立即操作数,这些操作数以n非i来表示.
* E/F 浮点常数
* g 内存操作数,整数常数,非genernal寄存器操作数
* X 任何操作数
* 0,1,2…9 和编号指定操作数匹配的操作数束符影响的内容包括

### 修饰符

修饰符包括:

* = 操作数是write only的
* + 操作数是可读可写的
* & 常用于输出限定符,表示某个寄存器不会被输入所使用.

```
__asm__ __volatile__(
"   .set    mips3               \n"
"   ll  %0, %1      # atomic_sub    \n"
"   subu    %0, %2              \n"
"   sc  %0, %1              \n"
"   .set    mips0               \n"
: "=&r" (temp), "+m" (v->counter)
: "Ir" (i));
```

## 实例

### 读取CP0 25号硬件计数寄存器的值

```
int get_counter()
{
	int rst;

	__asm__ __volatile__(		/* mfc0 为取cp0 寄存器值的指令 */
	"mfc0	%0, $25\n\t"		/* %0 表示列表开始的第一个寄存器 */
	: "=r" (rst)				/* 告诉gcc 让rst对应一个通用寄存器 */
	);

	return rst;
}
```
>"=r" 中，'=' 为修饰符，表示该操作对象只写，一般用于修饰输出参数列表中。'r' 表示任意一个通用寄存器

### 设置CP0 24号硬件计数寄存器的值

```
unsigned int op = 0x80f;

__asm__ __volatile__(
"mtc0 %0, $24\n\t"
:				/* 没有输出，列表为空 */
:"r"(op)		/* 输入参数，告诉gcc 让op对应一个通用寄存器 */
);
```

### 重设后，读取CP0 24号寄存器的值

```
unsigned int rst;
unsigned int op = 0x80f;

__asm__ __volatile__(
"mtc0	%1, $24\n\t"	/* %1 表示 op 对应的寄存器 */
"mfc0	%0, $25\n\t"	/* %0 表示 rst 对应的寄存器 */
: "=r" (rst)
: "r" (op)
);
```
>输入输出参数列表，按先后顺序，从0开始编号, %0, %1。

### 解读开头汇编代码

读写锁中读锁上锁的汇编实现：

```
__asm__ __volatile__(
	"1: ll  %1, %2  # arch_read_lock    \n"
	"   bltz    %1, 1b              \n"
	"    addu   %1, 1               \n"
	"2: sc  %1, %0              \n"
	: "=m" (rw->lock), "=&r" (tmp)
	: "m" (rw->lock)
	: "memory");
```
> `"=m" (rw->lock)`: 只写内存操作
> `"=&r" (tmp)` : 只写的输出变量，使用一个通用寄存器
> `"memory"`: 告诉gcc编译，该指令会修改内存中的值

1. 通过原子操作`ll`,将`rw->lock`读到`tmp`
2. 加一：`tmp = tmp + 1`
3. 通过原子操作`sc`,将`tmp`写入`rw->lock`

## barrier

内存屏障：保证前后指令的执行顺序

``` C
#define barrier() __asm__ __volatile__("": : :"memory")
```
>file: include/linux/compiler-gcc.h

>"memory"作为clobber部分另外一个作用是可以让在这条指令之后的指令,告诉gcc应该刷新 内存状态.内存的状态可能发生修改,如果需要操作的话,需要重新把内存内容载入寄存器

## 参考

1. [MIPS GCC 嵌入式汇编](https://blog.csdn.net/comcat/article/details/1557963)
2. [GCC内嵌汇编](https://dirtysalt.github.io/html/gcc-asm.html)
