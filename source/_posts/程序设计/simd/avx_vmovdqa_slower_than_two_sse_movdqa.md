---
layout: post
title: AVX VMOVDQA slower than two SSE MOVDQA?
date: '2019-05-21 17:11'
tags:
  - simd
categories:
  - 程序设计
  - simd
abbrlink: 40199
---

> 转载于： https://stackoverflow.com/questions/13975546/avx-vmovdqa-slower-than-two-sse-movdqa

<!--more-->

## Problem

While I was working on my fast ADD loop (Speed up x64 assembler ADD loop), I was testing memory access with SSE and AVX instructions. To add I have to read two inputs and produce one output. So I wrote a dummy routine that reads two x64 values into registers and write one back to memory without doing any operation. This is of course useless, I only did it for benchmarking.

当我正在进行快速ADD循环（加速x64汇编ADD循环）时，我使用SSE和AVX指令测试内存访问。我必须读取两个输入并产生一个输出。 所以我编写了一个虚拟例程，它将两个x64值读入寄存器，然后将其写回存储器而不进行任何操作。 这当然没用，我只做了基准测试。

I use an unrolled loop that handles 64 bytes per loop. It is comprised of 8 blocks like this:

我使用一个展开的循环，每个循环处理64个字节。 它由8个块组成，如下所示：

```
mov rax, QWORD PTR [rdx+r11*8-64]
mov r10, QWORD PTR [r8+r11*8-64]
mov QWORD PTR [rcx+r11*8-64], rax
```

Then I upgraded it to SSE2. Now I use 4 blocks like this:

然后我将其升级到SSE2。 现在我使用4个这样的块：

```
movdqa xmm0, XMMWORD PTR [rdx+r11*8-64]
movdqa xmm1, XMMWORD PTR [r8+r11*8-64]
movdqa XMMWORD PTR [rcx+r11*8-64], xmm0
```

And later on I used AVX (256 bit per register). I have 2 blocks like this:

后来我使用了AVX（每个寄存器256位）。 我有2个这样的块：

```
vmovdqa ymm0, YMMWORD PTR [rdx+r11*8-64]
vmovdqa ymm1, YMMWORD PTR [r8+r11*8-64]
vmovdqa YMMWORD PTR [rcx+r11*8-64], ymm0
```

So far, so not-so-extremely-spectacular. What is interesting is the benchmarking result: When I run the three different approaches on 1k+1k=1k 64-bit words (i.e. two times 8 kb of input and one time 8kb of output) I get strange results. Each of the following timings is for processing two times 64 bytes input into 64 bytes of output.

到目前为止，还不那么引人注目。 有趣的是基准测试结果：当我在1k + 1k = 1k 64位字（即两次8kb输入和一次8kb输出）上运行三种不同方法时，我得到奇怪的结果。 以下每个时序用于处理两次64字节输入到64字节输出。

- The x64 register method runs at about 15 cycles/64 bytes
- x64寄存器方法以大约15个周期/ 64个字节运行
- The SSE2 method runs at about 8.5 cycles/64 bytes
- SSE2方法以大约8.5个周期/ 64个字节运行
- The AVX method runs at about 9 cycles/64 bytes
- AVX方法以大约9个周期/ 64个字节运行

My question is: how come the AVX method is slower (though not a lot) than the SSE2 method? I expected it to be at least on par. Does using the YMM registers cost so much extra time? The memory was aligned (you get GPF's otherwise).

我的问题是：为什么AVX方法比SSE2方法慢（虽然不是很多）？ 我预计它至少会与之相提并论。 使用YMM寄存器会花费多少额外的时间吗？ 内存已对齐（否则会获得GPF）。

## Answer

On Sandybridge/Ivybridge, 256b AVX loads and stores are cracked into two 128b ops [as Peter Cordes notes, these aren't quite µops, but it requires two cycles for the operation to clear the port] in the load/store execution units, so there's no reason to expect the version using those instructions to be much faster.

在Sandybridge / Ivybridge上，256b AVX加载和存储被破解为两个128b操作[正如Peter Cordes所说，这些不是很好，但在加载/存储执行单元中需要两个周期来清除端口]， 因此没有理由期望使用这些指令的版本更快

Why is it slower? Two possibilities come to mind:

它为什么慢？ 我想到了两种可能性：

- for base + index + offset addressing, the latency of a 128b load is 6 cycles, whereas the latency of a 256b load is 7 cycles (Table 2-8 in the Intel Optimization Manual). Although your benchmark should be bound by thoughput and not latency, the longer latency means that the processor takes longer to recover from any hiccups (pipeline bubbles or prediction misses or interrupt servicing or ...), which does have some impact.

- 对于基数+索引+偏移量寻址，128b负载的延迟为6个周期，而256b负载的延迟为7个周期（英特尔优化手册中的表2-8）。 尽管您的基准测试应该受到吞吐量而非延迟的限制，但延迟时间越长意味着处理器需要更长时间才能从任何暂停（流水线气泡或预测未命中或服务中断或......）中恢复，这确实会产生一些影响。

- in 11.6.2 of the same document, Intel suggests that the penalty for cache line and page crossing may be larger for 256b loads than it is for 128b loads. If your loads are not all 32-byte aligned, this may also explain the slowdown you are seeing when using the 256b load/store operations:

- 在同一文档的11.6.2中，英特尔提示对256b的加载可能比128b的加载在缓存行和页面交叉方面更不利。 如果您的加载不是全部32字节对齐，这也可以解释您在使用256b加载/存储操作时看到的速度减慢：


> Example 11-12 shows two implementations for SAXPY with unaligned addresses. Alternative 1 uses 32 byte loads and alternative 2 uses 16 byte loads. These code samples are executed with two source buffers, src1, src2, at 4 byte offset from 32- Byte alignment, and a destination buffer, DST, that is 32-Byte aligned. Using two 16- byte memory operations in lieu of 32-byte memory access performs faster.

> 例11-12显示了具有未对齐地址的SAXPY的两种实现。 备选1使用32字节加载，备选2使用16字节加载。 这些代码示例使用两个源缓冲区src1，src2执行，以32字节对齐的4字节偏移量和32字节对齐的目标缓冲区DST执行。 使用两个16字节内存操作代替32字节内存访问执行速度更快。
