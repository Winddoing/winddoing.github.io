---
layout: post
title: 汇编伪指令—.word
date: '2022-03-18 16:49'
tags:
  - 指令
  - 汇编
categories:
  - 计算机系统
abbrlink: 16d994f4
---

```
.word
Syntax: .word expressions
```
> This directive expects zero or more expressions, of any section, separatedby commas. For each expression, as emits a 16-bit number for thistarget.

<!--more-->

```
7.92 .word expressions

This directive expects zero or more expressions, of any section, separated by commas.
The size of the number emitted, and its byte order, depend on what target computer the assembly is for.
Warning: Special Treatment to support Compilers Machines with a 32-bit address space,
but that do less than 32-bit addressing, require the following special treatment.
If the machine of interest to you does 32-bit addressing (or doesn’t require it;
see Chapter 8 [Machine Dependencies], page 61), you can ignore this issue.
In order to assemble compiler output into something that works,
as occasionally does strange things to ‘.word’ directives.
Directives of the form ‘.word sym1-sym2’ are often emitted by compilers as part of jump tables.
Therefore, when as assembles a directive of the form ‘.word sym1-sym2’,
and the difference between sym1 and sym2 does not fit in 16 bits,
as creates a secondary jump table, immediately before the next label.
This secondary jump table is preceded by a short-jump to the first byte after the secondary table.
This short-jump prevents the flow of control from accidentally falling into the new table.
Inside the table is a long-jump to sym2. The original ‘.word’ contains sym1 minus the address of the long-jump to sym2.
If there were several occurrences of ‘.word sym1-sym2’ before the secondary jump table,
all of them are adjusted. If there was a ‘.word sym3-sym4’, that also did not fit in sixteen bits,
a long-jump to sym4 is included in the secondary jump table,
and the .word directives are adjusted to contain sym3 minus the address of the long-jump to sym4;
and so on, for as many entries in the original jump table as necessary.
```
> as.info文档


`.word expression`就是在当前位置放一个word型的值，这个值就是expression

```
_rWTCON:
.word 0x15300000
```
> 在当前地址，即_rWTCON处放一个值0x15300000




## 参考

- [【转载】ARM汇编伪指令.word](https://blog.csdn.net/qq_33396481/article/details/78953583)
- [The GNU Assembler](http://tigcc.ticalc.org/doc/gnuasm.html#SEC49)
- [GNU Assembler Examples](https://cs.lmu.edu/~ray/notes/gasexamples/)
- [Assembly Programming Tutorial](https://www.tutorialspoint.com/assembly_programming/assembly_tutorial.pdf)
