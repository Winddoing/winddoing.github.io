---
layout: "post"
title: "ARMv8异常处理"
date: "2021-11-22 10:04"
tags:
  - arm64
  - 异常处理
categories:
  - arm
---

![arm64_spec_regs](/images/2021/11/arm64_spec_regs.png)

在ARM64中`SP`（栈指针），由于存在`EL0～EL3`四种异常级别，因此存在四个`SP`；但是`PC`指针只有一个（单核）

<!--more-->

- `XZR/WZR`(Zero register):零寄存器用作源寄存器时读为零，用作目标寄存器时丢弃结果。你可以在大多数（但不是所有）指令中使用零寄存器。
- `PC`（Program Counter）：程序计数器
- `SP`（Stack pointer）： 堆栈指针（SP）是一个指向堆栈顶部的寄存器。 选择使用的堆栈指针在某种程度上与“异常”级别是分开的。 默认情况下，发生异常时会为目标异常级别选择堆栈指针（SP_ELn）
- `SPSR`（Program Status Register）： 发生异常时，处理器状态存储在相关的保存程序状态寄存器 (SPSR) 中，类似于ARMv7中的CPSR。 SPSR在发生异常之前保存PSTATE的值，用于在执行异常返回时恢复PSTATE的值
- `ELR`(Exception Link Register): 异常链接寄存器,保存导致异常的指令的地址

```
EL0为普通用户程序
EL1是操作系统内核相关
EL2是Hypervisor, 可以理解为上面跑多个虚拟OS
EL3是Secure Monitor(ARM Trusted Firmware)
```

![arm64_exception_handling](/images/2021/11/arm64_exception_handling.png)

异常类型：

- 中断（Interrupts）
- 中止（Aborts）
- 重置（Reset）
- 异常指令（Exception generating instructions）

## 异常处理寄存器

如果发生异常，PSTATE 信息将保存在`Saved Program Status Register`(SPSR_ELn) 中，该寄存器以`SPSR_EL3`、`SPSR_EL2`和`SPSR_EL1`的形式存在。

![arm64异常处理寄存器](/images/2021/11/arm64异常处理寄存器.png)
> `SPRSR.M`字段（第4位）用于记录执行状态（`0`表示AArch64，`1`表示AArch32）。

| PSTATE fields |              描述               |
|:-------------:|:-------------------------------:|
|     NZCV      |            条件标志             |
|       Q       |           累积饱和位            |
|     DAIF      |           异常掩码位            |
|     SPSel     | SP选择（EL0或ELn），不适用于EL0 |
|       E       |   数据字节序（仅限 AArch32）    |
|      IL       |            非法标志             |
|      SS       |      软件步进位(单步调试)       |

异常掩码位(DAIF)允许屏蔽异常事件，设置该位时不发生异常。
- `D`：Debug exceptions mask.
- `A`：SError interrupt Process state mask, for example, asynchronous External Abort.
- `I`：IRQ interrupt Process state mask
- `F`：FIQ interrupt Process state mask.


当导致异常的事件发生时，处理器硬件会自动执行某些操作。 更新`SPSR_EL`（其中n是发生异常的异常级别），以存储在异常结束时正确返回所需的`PSTATE`信息。 `PSTATE`被更新以反映新的处理器状态（这可能意味着异常级别被提升，或者它可能保持不变）。 异常结束时使用的返回地址存储在`ELR_ELn`中。

![arm64异常事件处理流程](/images/2021/11/arm64异常事件处理流程.png)

请记住，寄存器名称上的`_ELn`后缀表示这些寄存器的多个副本存在于不同的异常级别。 例如，`SPSR_EL1`与`SPSR_EL2`是不同的物理寄存器。 此外，在同步或SError异常的情况下，ESR_ELn也会更新为指示异常原因的值。

必须通过软件告知处理器何时从异常中返回。 这是通过执行`ERET`指令来完成的。 这会从`SPSR_ELn`恢复异常前的`PSTATE`，并通过从`ELR_ELn`恢复`PC`将程序执行返回到原始位置。

我们已经看到SPSR如何记录异常返回所需的状态信息。 我们现在将查看用于存储程序地址信息的链接寄存器。 该架构为函数调用和异常返回提供了单独的链接寄存器。

在A64指令集，寄存器`X30`用于与`RET`指令结合）从子程序返回。 每当我们执行带有链接指令（BL或BLR）的分支时，它的值都会使用要返回的指令的地址进行更新。

`ELR_ELn`寄存器用于存储异常的返回地址。该寄存器中的值（实际上是几个寄存器，正如我们所见）在进入异常时自动写入，并作为执行用于从异常返回的`ERET`指令的效果之一写入`PC`。

**注**：从异常返回时，如果`SPSR`中的值与系统寄存器中的设置冲突，您将看到错误。


## 同步和异步异常

在AArch64中，异常可能是同步的，也可能是异步的。 如果异常是作为指令流的执行或尝试执行的结果而生成的，并且返回地址提供了使用它的指令的详细信息，则该异常被描述为同步异常。 执行指令不会生成异步异常，而返回地址可能并不总是提供导致异常的原因的详细信息。

`异步异常`的来源是IRQ（正常优先级中断）、FIQ（快速中断）或SError（系统错误）。 系统错误有多种可能的原因，最常见的是异步数据中止（例如，由脏数据从缓存行写回外部存储器触发的中止）。

`同步异常`有多种来源：
- 来自MMU的指令中止。 例如，通过从标记为从不执行的内存位置读取指令。
- 来自MMU的数据中止。 例如，权限失败或对齐检查。
- SP和PC对齐检查。
- 同步外部中止。 例如，读取翻译表时中止。
- 未分配的指令。
- 调试异常。

## AArch64异常表

当异常发生时，处理器必须执行与异常对应的处理程序代码。 存储处理程序的内存位置称为异常向量。 在ARM架构中，异常向量存储在一个表中，称为`异常向量表`。 每个异常级别都有自己的向量表，即EL3、EL2和EL1各有一个向量表。 该表包含要执行的指令，而不是一组地址。 个别异常的向量位于距表开头的固定偏移量处。每个表基址的虚拟地址由向量基址寄存器（Vector Based Address Registers）`VBAR_EL3`、`VBAR_EL2`和`VBAR_EL1`设置。


## 中断处理

ARM通常使用中断来表示中断信号。 在ARM A-profile和R-profile处理器上，这意味着外部IRQ或FIQ中断信号。 该架构没有指定如何使用这些信号。 FIQ通常保留用于安全中断源。 在早期的体系结构版本中，FIQ和IRQ用于表示高标准中断优先级，但在ARMv8-A中并非如此。

当处理器对AArch64执行状态发生异常时，所有`PSTATE`中断掩码都会自动设置，这意味着禁用更多异常。 如果软件要支持嵌套异常，例如，允许较高优先级的中断中断较低优先级源的处理，则软件需要明确地重新启用中断。


## 中断控制器


ARM提供了一个标准的中断控制器，可用于ARMv8-A系统，该中断控制器的编程接口在GIC架构中定义。GIC架构规范有多个版本，本文档侧重于版本2(GICv2)。 ARMv8-A处理器通常连接到GIC，例如GIC-400或GIC-500。通用中断控制器 (GIC) 支持在多核系统中的内核之间路由软件生成的、私有的和共享的外设中断。

GIC架构提供的寄存器可用于管理中断源和行为以及（在多核系统中）用于将中断路由到各个内核。它使软件能够屏蔽、启用和禁用来自各个源的中断，对（在硬件中）各个源进行优先级排序并生成软件中断。 GIC接受在系统级别断言的中断，并可以将它们发送给它所连接的每个内核，这可能会导致发生IRQ或FIQ异常。

从软件的角度来看，GIC 有两个主要功能块：

- `Distributor`（分发器）
  - 系统中所有中断源都连接到它。 Distributor具有寄存器来控制各个中断的属性，例如优先级、状态、安全性、路由信息和启用状态。 分配器通过附加的CPU接口确定将哪个中断转发到内核。

- `CPU Interface`（中央处理器接口）
  - 内核通过它接收中断。 CPU接口托管寄存器以屏蔽、识别和控制转发到该内核的中断的状态。 系统中的每个内核都有一个单独的CPU接口。

中断在软件中由一个数字标识，称为`中断ID`。 一个中断ID唯一对应一个中断源，软件可以使用中断ID来识别中断源并调用相应的处理程序来服务中断，提供给软件的确切中断ID由系统设计决定。

### 中断可以有多种不同的类型：

- Software Generated Interrupt (SGI) —— 软件产生中断
  - 这是由软件通过写入专用分配器寄存器（软件生成中断寄存器 (GICD_SGIR)）显式生成的，它最常用于内核间通信。SGI可以是全部目标，也可以是系统中选定的一组核心。`中断ID0-15`是为此保留的，用于给定中断的中断ID由生成它的软件设置。

- Private Peripheral Interrupt (PPI) —— 私有外设中断
  - 这是一个`全局外设中断`，分发器可以将其路由到指定的一个或多个内核。 `中断ID16-31`是为此保留的，它们标识`内核私有的中断源`，并且独立于另一个内核上的相同源，例如每内核定时器。

- Shared Peripheral Interrupt (SPI) —— 共享外设中断
  - 这是由GIC可以路由到多个内核的`外设`生成的。 `中断ID32-1020`用于此目的， SPI用于从整个系统中可访问的各种`外设发出中断信号`。

- Locality-specific Peripheral Interrupt (LPI) —— 特定于本地的外设中断
  - 这些是路由到特定内核的基于消息的中断。 GICv2或GICv1不支持LPI。


### 中断状态

中断可以是边沿触发的（当 GIC 检测到相关输入的上升沿时被认为是有效的，并保持有效直到被清除）或电平敏感（仅当 GIC 的相关输入为高时才被认为是有效的 ）。

中断可以处于多种不同的状态：

- `Inactive` —— 意味着当前没有中断
- `Pending` —— 意味着中断源已被中断，但正在等待内核处理。待处理的中断是被转发到CPU接口，然后再转发到内核的候选者
- `Active` —— 意味着已被内核确认并且当前正在服务的中断
- `Active and pending` —— 这描述了内核正在为中断提供服务并且GIC也有来自同一源的挂起中断的情况

中断状态变化的经典顺序：

- Inactive -> Pending： 当外设发出中断时
- Pending -> Active： 当处理程序确认中断时
- Active -> Inactive： 当句柄处理完中断时


```
# cat /proc/interrupts
           CPU0       CPU1

  7:        272          0     GIC-0  66 Level     ttyS0
  9:         71          0     GIC-0  45 Level     mmc0
 10:       1130          0     GIC-0  46 Level     mmc1

IPI0:      3834      12053       Rescheduling interrupts
IPI1:         4          4       Function call interrupts
IPI2:         0          0       CPU stop interrupts
IPI3:         0          0       CPU stop (for crash dump) interrupts
IPI4:         0          0       Timer broadcast interrupts
IPI5:         0          0       IRQ work interrupts
IPI6:         0          0       CPU wake-up interrupts
Err:          0
#
```

## GIC设备树

> [Documentation/devicetree/bindings/interrupt-controller/arm,gic.yaml](https://elixir.bootlin.com/linux/v5.4.110/source/Documentation/devicetree/bindings/interrupt-controller/arm,gic.yaml)

```
"#interrupt-cells":
  const: 3
  description: |
    The 1st cell is the interrupt type; 0 for SPI interrupts, 1 for PPI
    interrupts.

    The 2nd cell contains the interrupt number for the interrupt type.
    SPI interrupts are in the range [0-987].  PPI interrupts are in the
    range [0-15].

    The 3rd cell is the flags, encoded as follows:
      bits[3:0] trigger type and level flags.
        1 = low-to-high edge triggered
        2 = high-to-low edge triggered (invalid for SPIs)
        4 = active high level-sensitive
        8 = active low level-sensitive (invalid for SPIs).
      bits[15:8] PPI interrupt cpu mask.  Each bit corresponds to each of
      the 8 possible cpus attached to the GIC.  A bit set to '1' indicated
      the interrupt is wired to that CPU.  Only valid for PPI interrupts.
      Also note that the configurability of PPI interrupts is IMPLEMENTATION
      DEFINED and as such not guaranteed to be present (most SoC available
      in 2014 seem to ignore the setting of this flag and use the hardware
      default value).
```

第二个单元格包含中断号,在配置SPI中断号时，由于硬件中断号的前32个中断号被PPI中断使用，因此在设备树中配置时应该是硬件中断号减去32。

## 参考

- DEN0024A_v8_architecture_PG.pdf
