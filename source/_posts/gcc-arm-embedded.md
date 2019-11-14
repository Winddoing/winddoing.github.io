---
title: arm交叉编译工具
categories: 编译工具
tags:
  - arm
  - 交叉编译工具
abbrlink: 64642
date: 2016-09-17 23:07:24
---

## 编译工具命名规则

>交叉编译工具链的命名规则为：arch [-vendor] [-os] [-(gnu)eabi]

* arch - 体系架构，如ARM，MIPS
* vendor - 工具链提供商
* os - 目标操作系统
* eabi - 嵌入式应用二进制接口（Embedded Application Binary Interface）

根据对操作系统的支持与否，ARM GCC可分为支持和不支持操作系统，如

<!---more--->

### arm-none-eabi：

这个是没有操作系统的，自然不可能支持那些跟操作系统关系密切的函数，比如fork(2)。他使用的是newlib这个专用于嵌入式系统的C库。
arm-none-linux-eabi：用于Linux的，使用Glibc

## 示例

### arm-none-eabi-gcc

（ARM architecture，no vendor，not target an operating system，complies with the ARM EABI）
用于编译 ARM 架构的裸机系统（包括 ARM Linux 的 boot、kernel，不适用编译 Linux 应用 Application），一般适合 ARM7、Cortex-M 和 Cortex-R 内核的芯片使用，所以不支持那些跟操作系统关系密切的函数，比如fork(2)，他使用的是 newlib 这个专用于嵌入式系统的C库。

### arm-none-linux-gnueabi-gcc

(ARM architecture, no vendor, creates binaries that run on the Linux operating system, and uses the GNU EABI)
主要用于基于ARM架构的Linux系统，可用于编译 ARM 架构的 u-boot、Linux内核、linux应用等。arm-none-linux-gnueabi基于GCC，使用Glibc库，经过 Codesourcery 公司优化过推出的编译器。arm-none-linux-gnueabi-xxx 交叉编译工具的浮点运算非常优秀。一般ARM9、ARM11、Cortex-A 内核，带有 Linux 操作系统的会用到。

## 下载

### arm-none-eabi-gcc

地址：[https://launchpad.net/gcc-arm-embedded](https://launchpad.net/gcc-arm-embedded)
**注**:在a8中使用该编译工具（gcc-arm-none-eabi-5_4-2016q2），编译uboot在uboot启动时，对nand进行初始化无法成功。

### arm-none-linux-gnueabi-gcc

Mentor官方下载地址（需要注册，注册之后官方会发送一个下载地址到邮箱里面）
地址：[http://www.mentor.com/embedded-software/sourcery-tools/sourcery-codebench/evaluations](http://www.mentor.com/embedded-software/sourcery-tools/sourcery-codebench/evaluations/)
网盘下载：[http://www.veryarm.com/arm-none-linux-gnueabi-gcc](http://www.veryarm.com/arm-none-linux-gnueabi-gcc)
