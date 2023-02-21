---
title: GCC编译器的优化： fprefetch-loop-arrays
categories:
  - 编译工具
  - gcc
tags:
  - gcc
abbrlink: 14105
date: 2018-04-01 23:07:24
---

>以MIPS架构为基础进行分析
>预取指令：`pref`

指令预取，是指提前将所需要的数据取出来，在使用时可用

<!--more-->

## for loop

``` C
volatile unsigned char aa[4096];

int func()
{
	int i;

	__asm__ __volatile__("ssnop\n\t");
	__asm__ __volatile__("ssnop\n\t");

	for(i = 0; i < 4096; i++) {
		aa[i] = i;
	}

	__asm__ __volatile__("ssnop\n\t");
	__asm__ __volatile__("ssnop\n\t");
	return 0;
}
```

### 编译：
>```
>mips-linux-gnu-gcc -c for_loop.c -o for_loop.o
>```

### 反汇编：

```
mips-linux-gnu-objdump -d for_loop.o > for_loop.s
```

```
00000000 <func>:
   0:   27bdffe8    addiu   sp,sp,-24
   4:   afbe0014    sw  s8,20(sp)
   8:   03a0f025    move    s8,sp
   c:   00000040    ssnop
  10:   00000040    ssnop
  14:   afc00008    sw  zero,8(s8)
  18:   1000000b    b   48 <func+0x48>
  1c:   00000000    nop
  20:   8fc20008    lw  v0,8(s8)
  24:   304300ff    andi    v1,v0,0xff
  28:   3c020000    lui v0,0x0
  2c:   24440000    addiu   a0,v0,0
  30:   8fc20008    lw  v0,8(s8)
  34:   00821021    addu    v0,a0,v0
  38:   a0430000    sb  v1,0(v0)
  3c:   8fc20008    lw  v0,8(s8)
  40:   24420001    addiu   v0,v0,1
  44:   afc20008    sw  v0,8(s8)
  48:   8fc20008    lw  v0,8(s8)
  4c:   28421000    slti    v0,v0,4096
  50:   1440fff3    bnez    v0,20 <func+0x20>
  54:   00000000    nop
  58:   00000040    ssnop
  5c:   00000040    ssnop
  60:   00001025    move    v0,zero
  64:   03c0e825    move    sp,s8
  68:   8fbe0014    lw  s8,20(sp)
  6c:   27bd0018    addiu   sp,sp,24
  70:   03e00008    jr  ra
  74:   00000000    nop
    ...
```

## 优化

for循环的优化，对大数组的赋值

`-fprefetch-loop-arrays` 生成数组预读取指令，对于使用巨大数组的程序可以加快代码执行速度，适合数据库相关的大型软件等

gcc默认没有开预取指令的优化，需要通过`-O3`


### 编译：
>```
>mips-linux-gnu-gcc -c for_loop.c -o for_loop.o -O3 -fprefetch-loop-arrays
>```

### 反汇编：

```
00000000 <func>:
   0:   27bdff00    addiu   sp,sp,-256
   4:   afbe00fc    sw  s8,252(sp)
   ...
  24:   afb000dc    sw  s0,220(sp)
  28:   00000040    ssnop
  2c:   00000040    ssnop
  30:   3c020000    lui v0,0x0
  34:   00002025    move    a0,zero
  38:   00001825    move    v1,zero
  3c:   24460000    addiu   a2,v0,0
  40:   306200ff    andi    v0,v1,0xff
  44:   afa20008    sw  v0,8(sp)
  ...
  a0:   afbe0054    sw  s8,84(sp)
  a4:   24960019    addiu   s6,a0,25
  a8:   00d7f021    addu    s8,a2,s7
  ac:   93b70010    lbu s7,16(sp)
  b0:   24820004    addiu   v0,a0,4
  ...
  424:   a0b40000    sb  s4,0(a1)
  428:   8fa500a8    lw  a1,168(sp)
  42c:   93b40010    lbu s4,16(sp)
  430:   a0b40000    sb  s4,0(a1)
  434:   8fa500ac    lw  a1,172(sp)
  ...
  474:   a12a0000    sb  t2,0(t1)
  478:   a0e80000    sb  t0,0(a3)
  47c:   a0450000    sb  a1,0(v0)
  480:   24020fe0    li  v0,4064
  484:   1462feee    bne v1,v0,40 <func+0x40>
  488:   24051000    li  a1,4096
  48c:   304400ff    andi    a0,v0,0xff
  490:   00c21821    addu    v1,a2,v0
  494:   24420001    addiu   v0,v0,1
  498:   1445fffc    bne v0,a1,48c <func+0x48c>
  49c:   a0640000    sb  a0,0(v1)
  4a0:   00000040    ssnop
  4a4:   00000040    ssnop
  4a8:   00001025    move    v0,zero
  4ac:   8fbe00fc    lw  s8,252(sp)
  4b0:   8fb700f8    lw  s7,248(sp)
  ...
  4cc:   8fb000dc    lw  s0,220(sp)
  4d0:   03e00008    jr  ra
  4d4:   27bd0100    addiu   sp,sp,256
   ...
```

## for语句汇编


``` C
void func()
{
    int i, a;

    __asm__  __volatile__("ssnop\n\t");
    for (i = 0; i < 88; i++)
        a = i;
    __asm__  __volatile__("ssnop\n\t");

}
```

```
 00000000 <func>:
    0:   27bdffe8    addiu   sp,sp,-24
    4:   afbe0014    sw  s8,20(sp)
    8:   03a0f025    move    s8,sp
    c:   00000040    ssnop
   10:   afc00008    sw  zero,8(s8)		//1. i = 0;
   14:   10000006    b   30 <func+0x30>	//2. 跳转到0x30，判断i,如果小于88进行（4）循环
   18:   00000000    nop
   1c:   8fc20008    lw  v0,8(s8)
   20:   afc2000c    sw  v0,12(s8)
   24:   8fc20008    lw  v0,8(s8)
   28:   24420001    addiu   v0,v0,1	//3. i++
   2c:   afc20008    sw  v0,8(s8)
   30:   8fc20008    lw  v0,8(s8)
   34:   28420058    slti    v0,v0,88
   38:   1440fff8    bnez    v0,1c <func+0x1c>	//4. 如果i小于88,跳转到0x1c进行循环
   3c:   00000000    nop
   40:   00000040    ssnop
   44:   00000000    nop
   48:   03c0e825    move    sp,s8
   4c:   8fbe0014    lw  s8,20(sp)
   50:   27bd0018    addiu   sp,sp,24
   54:   03e00008    jr  ra
   58:   00000000    nop
   5c:   00000000    nop
```
