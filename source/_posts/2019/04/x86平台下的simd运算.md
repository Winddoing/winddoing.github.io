---
layout: post
title: X86平台下的SIMD运算
date: '2019-04-30 17:52'
tags:
  - SIMD
categories:
  - 程序设计
  - 性能
---

> `SSE`的全称是 Sreaming SIMD Extensions， 它是一组Intel CPU指令，用于像信号处理、科学计算或者3D图形计算一样的应用。

```
#include <mmintrin.h>    //MMX  64bits
#include <xmmintrin.h>   //SSE  128bits
#include <emmintrin.h>   //SSE2
#include <immintrin.h>   //AVX  256bits
```
- `immintrin.h`: (Intel(R) AVX compiler intrinsics  256bit)
- `emmintrin.h`: Principal header file for Intel(R) Pentium(R) 4 processor SSE2 intrinsics

<!--more-->

## XMM、SSE、AVX关系？？

- `MMX`是由英特尔开发的一种SIMD多媒体指令集，共有57条指令。
- `SSE`(Sreaming SIMD Extensions)是继MMX的扩充指令集。SSE 指令集提供了 70 条新指令。
- `AVX`(Advanced Vector Extensions) 是Intel的SSE延伸架构，如IA16至IA32般的把暂存器XMM 128bit提升至YMM 256bit，以增加一倍的运算效率。

## 数据类型

| 关键字  | 说明  | 备注  |
|:-:|:-:|:-:|
| `__m64`  | 64位紧缩整数（MMX）  | 一个MMX寄存器,表示封装了8个8bit,4个16bit,2个32bit,1个64bit的整数  |
| `__m128`  | 128位紧缩单精度（SSE）  | 封装4个32bit的单精度浮点数  |
| `__m128d`  | 128位紧缩双精度（SSE2）  | 封装2个64bit的双精度浮点数  |
| `__m128i`  | 128位紧缩整数（SSE2）  |   |
| `__m256`  | 256位紧缩单精度（AVX）  |   |
| `__m256d`  | 256位紧缩双精度（AVX）  |   |
| `__m256i`  | 256位紧缩整数（AVX）  |   |

> **注**： 紧缩整数包括了8位、16位、32位、64位的带符号和无符号整数。

## 指令函数

>[Intel intrinsic](https://software.intel.com/sites/landingpage/IntrinsicsGuide/#)



## 参考

* [SSE2 Intrinsics各函数介绍](https://blog.csdn.net/fengbingchun/article/details/18460199)
* [GCC中SIMD指令的应用方法](https://www.ibm.com/developerworks/cn/linux/l-gccsimd)
* [mmintrin.h与MMX指令集 Intrinsics函数](https://blog.csdn.net/u014713819/article/details/38433879)
* [SIMD指令初学](https://blog.csdn.net/tercel_zhang/article/details/80694573)
* [SSE指令集学习：Compiler Intrinsic](https://www.cnblogs.com/wangguchangqing/p/5466301.html)
* [深入浅出指令编码之四：指令核心](https://www.pediy.com/kssd/pediy10/78121.html)
* [An evaluation of the automatic generation of parallel X86 SIMD](https://www.cri.ensmp.fr/classement/doc/E-272.pdf)
