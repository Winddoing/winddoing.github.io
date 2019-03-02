---
layout: "post"
title: "armv8_aarch64 NEON汇编指令"
date: "2019-03-01 11:18"
---

`NEON`是一种压缩的SIMD架构，主要是给多媒体使用，结果并行计算的问题。
> NEON是ARMv7-A和ARMv7-R引入的特性，在后面的ARMv8-A和ARMv8-R中也扩展其功能.1288bit的向量运算

|                |      ARMv7-A/R      |         ARMv8-A/R          |          ARMv8-A           |
|:--------------:|:-------------------:|:--------------------------:|:--------------------------:|
|                |                     |          AArch32           |          AArch64           |
| Floating-point |       32-bit        |       16-bit*/32-bit       |       16-bit*/32-bit       |
|    Integer     | 8-bit/16-bit/32-bit | 8-bit/16-bit/32-bit/64-bit | 8-bit/16-bit/32-bit/64-bit |

<!--more-->

## NEON寄存器表示

- 32个B寄存器（B0~B31）,8bit
- 32个H寄存器（H0~H31）,半字 16bit
- 32个S寄存器（S0~S31）,单子 32bit
- 32个D寄存器（D0~D31）,双字 64bit
- 32个Q寄存器（V0~V31）,四字 128bit

## 指令

> 参考： [NEON 指令](http://infocenter.arm.com/help/basic/help.jsp?topic=/com.arm.doc.dui0204ic/CJAJIIGG.html)



## Load and Stores

### 指令格式

![arm-NEON指令格式](/images/2019/03/arm_neon指令格式.png)

- 指令助记符，它是加载VLD或存储VST
- `interleave pattern`：数字交错模式，每个结构中相应元素之间的间隙

![arm-NEON交错模式](/images/2019/03/arm_neon交错模式.png)

### 交织模式

- `VLD1`是最简单的形式。 它从内存加载一到四个数据寄存器，没有去交错。 处理非交错数据阵列时使用此选项。
- `VLD2`加载两个或四个数据寄存器，将偶数和奇数元素解交织到这些寄存器中。 用它将立体声音频数据分成左右声道。
- `VLD3`加载三个寄存器和去交错。 用于将RGB像素分割为通道。
- `VLD4`加载四个寄存器和解交织。 用它来处理ARGB图像数据。

存储支持相同的选项，但在将数据写入存储器之前将寄存器中的数据交错。



## 参考

* [Introducing NEON](http://infocenter.arm.com/help/topic/com.arm.doc.dht0002a/DHT0002A_introducing_neon.pdf)
* [NEON 指令](http://infocenter.arm.com/help/basic/help.jsp?topic=/com.arm.doc.dui0204ic/CJAJIIGG.html)
* [Coding for NEON - Part 1: Load and Stores](https://community.arm.com/processors/b/blog/posts/coding-for-neon---part-1-load-and-stores)
* [Coding for NEON - Part 2: Dealing With Leftovers](https://community.arm.com/processors/b/blog/posts/coding-for-neon---part-2-dealing-with-leftovers)
* [Coding for NEON - Part 3: Matrix Multiplication](https://community.arm.com/processors/b/blog/posts/coding-for-neon---part-3-matrix-multiplication)
* [Coding for NEON - Part 4: Shifting Left and Right](https://community.arm.com/processors/b/blog/posts/coding-for-neon---part-4-shifting-left-and-right)
* [Coding for NEON - Part 5: Rearranging Vectors](https://community.arm.com/processors/b/blog/posts/coding-for-neon---part-5-rearranging-vectors)
