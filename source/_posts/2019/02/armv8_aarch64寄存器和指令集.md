---
layout: post
title: ARMv8-aarch64寄存器和指令集
date: '2019-02-26 14:01'
tags:
  - ARM
categories:
  - ARM
---

![armv8-a](/images/2019/02/armv8_a.png)

<!--more-->

## ARMv8-A处理器属性

![armv8-a-properties](/images/2019/02/armv8_a_properties.png)

> Rockchip RK3399 SoC integrates dual-core `Cortex-A72` and quad-core `Cortex-A53` with separate NEON coprocessor, and with ARM Mali-T864 GPU.


## 异常等级

软件运行异常级别：

- `EL0`： 普通用户应用程序
- `EL1`： 操作系统内核通常被描述为特权
- `EL2`： 管理程序
- `EL3`： 低级固件，包括安全监视器


## ARMv8寄存器

AArch拥有`31`个通用寄存器，系统运行在64位状态下的时候名字叫`Xn`，运行在32位的时候就叫`Wn`.

![armv8-reg](/images/2019/02/armv8_reg.png)

> 32位W寄存器构成相应64位X寄存器的下半部分。 也就是说，W0
映射到X0的低位字，W1映射到X1的低位字。

### 特殊寄存器

![armv8特殊寄存器](/images/2019/02/armv8特殊寄存器.png)

| Name |  Size  |      Description      |
|:----:|:------:|:---------------------:|
| WZR  | 32bits |     Zero register     |
| XZR  | 64bits |     Zero register     |
| WSP  | 32bits | Current stack pointer |
|  SP  | 64bits | Current stack pointer |
|  pC  | 64bits |    Program counter    |


## ARM 64位架构的ABI

ARM体系结构的应用程序二进制接口（`ABI`， Application Binary Interface）指定了基本规则所有可执行的本机代码模块必须遵守，以便它们可以正常工作。

### 通用寄存器

通用寄存器分为4组：

![armv8-register](/images/2019/02/armv8_register.png)

- 参数寄存器`（X0-X7）`： 用作临时寄存器或可以保存的调用者保存的寄存器变量函数内的中间值，调用其他函数之间的值（8个寄存器可用于传递参数）

- 来电保存的临时寄存器`（X9-X15）`： 如果调用者要求在任何这些寄存器中保留值调用另一个函数，调用者必须将受影响的寄存器保存在自己的堆栈中帧。 它们可以通过被调用的子程序进行修改，而无需保存并在返回调用者之前恢复它们。

- 被调用者保存的寄存器`（X19-X29）`： 这些寄存器保存在被调用者帧中。 它们可以被被调用者修改子程序，只要它们在返回之前保存并恢复。

- 特殊用途寄存器`（X8，X16-X18，X29，X30）`：
  - `X8`： 是间接结果寄存器,用于保存子程序返回地址，`尽量不使用`
  - `X16`和`X17`： 程序内调用临时寄存器
  - `X18`： 平台寄存器，保留用于平台ABI，`尽量不使用`
  - `X29`： 帧指针寄存器（FP）
  - `X30`： 链接寄存器（LR）
  - `X31`： 堆栈指针寄存器SP或零寄存器ZXR

### NEON和浮点寄存器

![armv8-simd-reg](/images/2019/02/armv8_simd_reg.png)


## A64指令集

### A64特点

- 移除了批量加载寄存器指令 LDM/STM, PUSH/POP, 使用STP/LDP 一对加载寄存器指令代替；
- 没有提供访问CPSR的单一寄存器，但是提供访问PSTATE的状态域寄存器；
- A64没有协处理器的概念，没有协处理器指令MCR,MRC；
- 相比A32少了很多条件执行指令，只有条件跳转和少数数据处理这类指令才有条件执行.附件为条件指令码；

### 指令格式

```
<Opcode>{<Cond>}<S>  <Rd>, <Rn> {,<Opcode2>}
```
> - `Opcode`：操作码，也就是助记符，说明指令需要执行的操作类型
> - `Cond`：指令执行条件码，查看附件图；
> - `S`：条件码设置项,决定本次指令执行是否影响PSTATE寄存器响应状态位值
> - `Rd/Xt`：目标寄存器，A32指令可以选择R0-R14,T32指令大部分只能选择RO-R7，A64指令可以选择X0-X30；
> - `Rn/Xn`：第一个操作数的寄存器，和Rd一样，不同指令有不同要求；
> - `Opcode2`：第二个操作数，可以是立即数，寄存器Rm和寄存器移位方式（Rm，#shit）；

### 内存访问指令

- 加载指令
```
LDR Rt, <addr>
```
> - `LDRB` (8-bit, zero extended).
> - `LDRSB` (8-bit, sign extended).
> - `LDRH` (16-bit, zero extended).
> - `LDRSH` (16-bit, sign extended).
> - `LDRSW` (32-bit, sign extended).

![armv8加载指令的地址偏移](/images/2019/02/armv8加载指令的地址偏移.png)

- 存储指令
```
STR Rn, <addr>
```

## 参考

* [Programmer’s Guide for ARMv8-A](/downloads/arm/DEN0024A_v8_architecture_PG.pdf)=
