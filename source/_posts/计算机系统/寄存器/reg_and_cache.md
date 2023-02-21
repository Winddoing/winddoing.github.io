---
title: 寄存器和Cache
categories:
  - 计算机系统
  - 寄存器
tags:
  - 寄存器
  - cache
abbrlink: 12702
date: 2017-12-03 23:07:24
---


在平时的工作中经常进行`寄存器`和`Cache`的相关操作，这里主要说明其二者的具体操作和实现的不同


``` C
 *(volatile unsigned int*)(0xb3450000 + 0x20) = 0x5a5a5a5a;
```

>1. 写寄存器时经过Cache吗？，为什么？怎么实现的？
>2. 如果经常Cache，是CPU进行同步，还是软件进行同步？

<!--more-->

![cpu_memory_struct](/images/cpu_memory_struct.png)

## 寄存器

>寄存器是中央处理器内的组成部份。寄存器是有限存贮容量的`高速存贮部件`，它们可用来暂存指令、数据和位址。在中央处理器的控制部件中，包含的寄存器有指令寄存器(IR)和程序计数器(PC)。在中央处理器的算术及逻辑部件中，包含的寄存器有累加器(ACC)。




## Cache

>即高速缓冲存储器，是位于CPU与主内存间的一种容量较小但速度很高的存储器。由于CPU的速度远高于主内存，CPU直接从内存中存取数据要等待一定时间周期，Cache中保存着CPU刚用过或循环使用的一部分数据，当CPU再次使用该部分数据时可从Cache中直接调用,这样就减少了CPU的等待时间,提高了系统的效率。Cache又分为一级Cache(L1 Cache)和二级Cache(L2 Cache)，L1 Cache集成在CPU内部，L2 Cache早期一般是焊在主板上,现在也都集成在CPU内部，常见的容量有256KB或512KB L2 Cache。

## 二者联系？
