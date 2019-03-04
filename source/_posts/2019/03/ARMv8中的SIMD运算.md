---
layout: post
title: ARMv8中的SIMD运算
date: '2019-03-01 11:18'
tags:
  - SIMD
categories:
  - ARM
  - SIMD
---

`NEON`是一种压缩的SIMD架构，主要是给多媒体使用，结果并行计算的问题。
> NEON是ARMv7-A和ARMv7-R引入的特性，在后面的ARMv8-A和ARMv8-R中也扩展其功能.1288bit的向量运算

|                |      ARMv7-A/R      |         ARMv8-A/R          |          ARMv8-A           |
|:--------------:|:-------------------:|:--------------------------:|:--------------------------:|
|                |                     |          AArch32           |          AArch64           |
| Floating-point |       32-bit        |       16-bit*/32-bit       |       16-bit*/32-bit       |
|    Integer     | 8-bit/16-bit/32-bit | 8-bit/16-bit/32-bit/64-bit | 8-bit/16-bit/32-bit/64-bit |

<!--more-->

## ARMv8与ARMv7的区别

- 1.与`通用寄存器`相同的助记符

|  CPU  |      通用       |          SIMD           |
|:-----:|:---------------:|:-----------------------:|
| ARMv7 | mul, r0, r0, r1 |     vmul d0, d0, d1     |
| ARMv8 | mul x0, x0, x1  | mul v0.u8, v0.u8, v1.u8 |
> **注意：在ARMv7中所有的SIMD汇编的操作码如`mul`的前缀都有`v`如vml**

- 2.ARMv8的寄存器是ARMv7的两倍

  - ARMv8拥有`32`个128-bit寄存器
  - ARMv7拥有`16`个128-bit寄存器

- 3.不同的指令语法


## SIMD寄存器

![armv8SIMD寄存器](/images/2019/03/armv8simd寄存器.png)

|       寄存器        | 个数 |  位宽   |      数据类型       |
|:-------------------:|:----:|:-------:|:-------------------:|
| D寄存器（`D0-D31`） | 32个 | 64-bit  | 双字（double word） |
| Q寄存器（`Q0-Q15`） | 16个 | 128-bit |        四字         |

## 矢量寄存器V0-V31：包装

![armv8SIMD寄存器标识vx](/images/2019/03/armv8simd寄存器标识vx.png)

打包V0-V31中的数据，方便数据操作

![ARMv8SIMD寄存器打包](/images/2019/03/armv8simd寄存器打包.png)

## 矢量包装

![ARMvc8](/images/2019/03/armvc8.png)

**主要定义每一个矢量Vn的数据位宽**

| 标识 | 位宽  | 数据类型  | 示例                                   |
|:----:|:-----:|:---------:|:---------------------------------------|
| `b`  | 8bit  |   char    | v0.8b,v0.16b: 8个bit16个bit            |
| `h`  | 16bit |   short   | v0.4h，v0.8h： 4或8个半字（short类型） |
| `s`  | 32bit |    int    | v0.2s，v0.4s：2或4个字                 |
| `d`  | 64bit | long long | v0.2d：2个double word                  |

## 指令语法

![ARMv8SIMD指令op](/images/2019/03/armv8simd指令op.png)

```
ld4 {v0.4h-v3.4h}, [%0]
```
等同于：
```
ld4 {v0.4h, v1.4h, v2.4h, v3.4h}, [%0]
```

## 内联函数编程

NEON 内在函数在头文件`arm_neon.h`中定义。头文件既定义内在函数，也定义一组向量类型

> [NEON操作函数](http://infocenter.arm.com/help/topic/com.arm.doc.dui0348bc/DUI0348BC_rvct_comp_ref_guide.pdf)
> - [arm_neon.h
](https://raw.githubusercontent.com/EmDepTeam/arm-linux-gnueabihf/master/lib/gcc/arm-linux-gnueabihf/7.3.1/include/arm_neon.h)

## 内嵌汇编编程

``` asm
asm volatile(                         
    "mnemonic+operand \n\t"           
    "mnemonic+operand \n\t"           
    "mnemonic+operand \n\t"           

    : //Output operands               
    : //Output operands               
    : //Dirty registers etc           
);                                    
```

## 示例

### 4x4矩阵乘法

``` C
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <sys/time.h>

#if __aarch64__
#include <arm_neon.h>
#endif

static void dump(uint16_t **x)
{
    int i, j;
    uint16_t *xx = (uint16_t *)x;

    printf("%s:\n", __func__);

    for(i = 0; i < 4; i++) {
        for(j = 0; j < 4; j++) {
            printf("%3d ", *(xx + (i << 2) + j));
        }

        printf("\n");
    }
}

static void matrix_mul_c(uint16_t aa[][4], uint16_t bb[][4], uint16_t cc[][4])
{
    int i = 0, j = 0;

    printf("===> func: %s, line: %d\n", __func__, __LINE__);

    for(i = 0; i < 4; i++) {
        for(j = 0; j < 4; j++) {
            cc[i][j] = aa[i][j] * bb[i][j];
        }
    }

}

#if __aarch64__
static void matrix_mul_neon(uint16_t **aa, uint16_t **bb, uint16_t **cc)
{
    printf("===> func: %s, line: %d\n", __func__, __LINE__);
#if 1
    uint16_t (*a)[4] = (uint16_t (*)[4])aa;
    uint16_t (*b)[4] = (uint16_t (*)[4])bb;
    uint16_t (*c)[4] = (uint16_t (*)[4])cc;

    printf("aaaaaaaa\n");
    asm("nop");
    asm("nop");
    asm("nop");
    asm("nop");
    uint16x4_t _cc0;
    uint16x4_t _cc1;
    uint16x4_t _cc2;
    uint16x4_t _cc3;

    uint16x4_t _aa0 = vld1_u16((uint16_t*)a[0]);
    uint16x4_t _aa1 = vld1_u16((uint16_t*)a[1]);
    uint16x4_t _aa2 = vld1_u16((uint16_t*)a[2]);
    uint16x4_t _aa3 = vld1_u16((uint16_t*)a[3]);

    uint16x4_t _bb0 = vld1_u16((uint16_t*)b[0]);
    uint16x4_t _bb1 = vld1_u16((uint16_t*)b[1]);
    uint16x4_t _bb2 = vld1_u16((uint16_t*)b[2]);
    uint16x4_t _bb3 = vld1_u16((uint16_t*)b[3]);

    _cc0 = vmul_u16(_aa0, _bb0);
    _cc1 = vmul_u16(_aa1, _bb1);
    _cc2 = vmul_u16(_aa2, _bb2);
    _cc3 = vmul_u16(_aa3, _bb3);

    vst1_u16((uint16_t*)c[0], _cc0);
    vst1_u16((uint16_t*)c[1], _cc1);
    vst1_u16((uint16_t*)c[2], _cc2);
    vst1_u16((uint16_t*)c[3], _cc3);
    asm("nop");
    asm("nop");
    asm("nop");
    asm("nop");
#else
    printf("bbbbbbbb\n");
    int i = 0;
    uint16x4_t _aa[4], _bb[4], _cc[4];
    uint16_t *a = (uint16_t*)aa;
    uint16_t *b = (uint16_t*)bb;
    uint16_t *c = (uint16_t*)cc;

    for(i = 0; i < 4; i++) {
        _aa[i] = vld1_u16(a + (i << 2));
        _bb[i] = vld1_u16(b + (i << 2));
        _cc[i] = vmul_u16(_aa[i], _bb[i]);
        vst1_u16(c + (i << 2), _cc[i]);
    }

#endif
}

static void matrix_mul_asm(uint16_t **aa, uint16_t **bb, uint16_t **cc)
{
    printf("===> func: %s, line: %d\n", __func__, __LINE__);

    uint16_t *a = (uint16_t*)aa;
    uint16_t *b = (uint16_t*)bb;
    uint16_t *c = (uint16_t*)cc;

#if 0
    asm volatile(
        "ldr d3, [%0, #0]           \n\t"
        "ldr d2, [%0, #8]           \n\t"
        "ldr d1, [%0, #16]          \n\t"
        "ldr d0, [%0, #24]          \n\t"

        "ldr d7, [%1, #0]           \n\t"
        "ldr d6, [%1, #8]           \n\t"
        "ldr d5, [%1, #16]          \n\t"
        "ldr d4, [%1, #24]          \n\t"

        "mul v3.4h, v3.4h, v7.4h    \n\t"
        "mul v2.4h, v2.4h, v6.4h    \n\t"
        "mul v1.4h, v1.4h, v5.4h    \n\t"
        "mul v0.4h, v0.4h, v4.4h    \n\t"

        //"add v3.4h, v3.4h, v7.4h    \n\t"
        //"add v2.4h, v2.4h, v6.4h    \n\t"
        //"add v1.4h, v1.4h, v5.4h    \n\t"
        //"add v0.4h, v0.4h, v4.4h    \n\t"

        "str d3, [%2,#0]            \n\t"
        "str d2, [%2,#8]            \n\t"
        "str d1, [%2,#16]           \n\t"
        "str d0, [%2,#24]           \n\t"

        : "+r"(a),   //%0
          "+r"(b),   //%1
          "+r"(c)    //%2
        :
        : "cc", "memory", "d0", "d1", "d2", "d3", "d4", "d5", "d6", "d7"
    );
#else
    // test, OK
    asm("nop");
    asm("nop");
    asm("nop");
    asm("nop");
    asm("nop");
    asm volatile(
        //"ld4 {v0.4h, v1.4h, v2.4h, v3.4h}, [%0] \n\t"
        "ld4 {v0.4h-v3.4h}, [%0]                \n\t"
        "ld4 {v4.4h, v5.4h, v6.4h, v7.4h}, [%1] \n\t"

        "mul v3.4h, v3.4h, v7.4h                \n\t"
        "mul v2.4h, v2.4h, v6.4h                \n\t"
        "mul v1.4h, v1.4h, v5.4h                \n\t"
        "mul v0.4h, v0.4h, v4.4h                \n\t"

        "st4 {v0.4h, v1.4h, v2.4h, v3.4h}, [%2] \n\t"

        : "+r"(a),   //%0
          "+r"(b),   //%1
          "+r"(c)    //%2
        :
        : "cc", "memory", "v0", "v1", "v2", "v3", "v4", "v5", "v6", "v7"
    );
    asm("nop");
    asm("nop");
    asm("nop");
    asm("nop");
    asm("nop");
#endif
}
#endif

int main(int argc, const char *argv[])
{
    uint16_t aa[4][4] = {
        {1, 2, 3, 4},
        {5, 6, 7, 8},
        {3, 6, 8, 1},
        {2, 6, 7, 1}
    };

    uint16_t bb[4][4] = {
        {1, 3, 5, 7},
        {2, 4, 6, 8},
        {2, 5, 7, 9},
        {5, 2, 7, 1}
    };

    uint16_t cc[4][4] = {0};
    int i, j;
    struct timeval tv;
    long long start_us = 0, end_us = 0;

    dump((uint16_t **)aa);
    dump((uint16_t **)bb);
    dump((uint16_t **)cc);

    /* ******** C **********/
    gettimeofday(&tv, NULL);
    start_us = tv.tv_sec + tv.tv_usec;

    matrix_mul_c(aa, bb, cc);

    gettimeofday(&tv, NULL);
    end_us = tv.tv_sec + tv.tv_usec;
    printf("aa[][]*bb[][] C time %lld us\n", end_us - start_us);
    dump((uint16_t **)cc);

#if __aarch64__
    /* ******** NEON **********/
    memset(cc, 0, sizeof(uint16_t) * 4 * 4);
    gettimeofday(&tv, NULL);
    start_us = tv.tv_sec + tv.tv_usec;

    matrix_mul_neon((uint16_t **)aa, (uint16_t **)bb, (uint16_t **)cc);

    gettimeofday(&tv, NULL);
    end_us = tv.tv_sec + tv.tv_usec;
    printf("aa[][]*bb[][] neon time %lld us\n", end_us - start_us);
    dump((uint16_t **)cc);

    /* ******** asm **********/
    memset(cc, 0, sizeof(uint16_t) * 4 * 4);
    gettimeofday(&tv, NULL);
    start_us = tv.tv_sec + tv.tv_usec;

    matrix_mul_asm((uint16_t **)aa, (uint16_t **)bb, (uint16_t **)cc);

    gettimeofday(&tv, NULL);
    end_us = tv.tv_sec + tv.tv_usec;
    printf("aa[][]*bb[][] asm time %lld us\n", end_us - start_us);
    dump((uint16_t **)cc);
#endif

    return 0;
}
```

```
aarch64-linux-gcc -O3  matrix_4x4_mul.c
```

> gcc –march=armv8-a [input file] -o [output file]

### 8x8矩阵乘法

``` C
static void matrix_mul_asm(uint16_t **aa, uint16_t **bb, uint16_t **cc)
{
    printf("===> func: %s, line: %d\n", __func__, __LINE__);

    uint16_t *a = (uint16_t*)aa;
    uint16_t *b = (uint16_t*)bb;
    uint16_t *c = (uint16_t*)cc;

    asm volatile(
        "ld4 {v0.8h, v1.8h, v2.8h, v3.8h}, [%0]     \n\t"
        "ld4 {v4.8h, v5.8h, v6.8h, v7.8h}, [%0]     \n\t"
        "ld4 {v8.8h, v9.8h, v10.8h, v11.8h}, [%1]   \n\t"
        "ld4 {v12.8h, v13.8h, v14.8h, v15.8h}, [%1] \n\t"

        "mul v0.8h, v0.8h, v8.8h                    \n\t"
        "mul v1.8h, v1.8h, v9.8h                    \n\t"
        "mul v2.8h, v2.8h, v10.8h                   \n\t"
        "mul v3.8h, v3.8h, v11.8h                   \n\t"
        "mul v4.8h, v4.8h, v12.8h                   \n\t"
        "mul v5.8h, v5.8h, v13.8h                   \n\t"
        "mul v6.8h, v6.8h, v14.8h                   \n\t"
        "mul v7.8h, v7.8h, v15.8h                   \n\t"

        "st4 {v0.8h, v1.8h, v2.8h, v3.8h}, [%2]     \n\t"
        "st4 {v4.8h, v5.8h, v6.8h, v7.8h}, [%2]     \n\t"

        : "+r"(a),   //%0
          "+r"(b),   //%1
          "+r"(c)    //%2
        :
        : "cc", "memory", "v0", "v1", "v2", "v3", "v4", "v5", "v6", "v7", "v8", "v9", "v10", "v11", "v12", "v13", "v14", "v15"
    );
}
```
> 内嵌汇编实现方式`8x8`

**注意**：

- 在`LD4`数据加载时一次可以加载4行，如果8行数据分两次加载，传入的矩阵的二维数组`地址不变`

## 参考

* [ARMv8 Neon Programming](https://www.uio.no/studier/emner/matnat/ifi/INF5063/h16/pensumliste/armv8-neon-programming.pdf)
* [Introducing NEON](http://infocenter.arm.com/help/topic/com.arm.doc.dht0002a/DHT0002A_introducing_neon.pdf)
* [Coding for NEON - Part 1: Load and Stores](https://community.arm.com/processors/b/blog/posts/coding-for-neon---part-1-load-and-stores)
* [Coding for NEON - Part 2: Dealing With Leftovers](https://community.arm.com/processors/b/blog/posts/coding-for-neon---part-2-dealing-with-leftovers)
* [Coding for NEON - Part 3: Matrix Multiplication](https://community.arm.com/processors/b/blog/posts/coding-for-neon---part-3-matrix-multiplication)
* [Coding for NEON - Part 4: Shifting Left and Right](https://community.arm.com/processors/b/blog/posts/coding-for-neon---part-4-shifting-left-and-right)
* [Coding for NEON - Part 5: Rearranging Vectors](https://community.arm.com/processors/b/blog/posts/coding-for-neon---part-5-rearranging-vectors)
