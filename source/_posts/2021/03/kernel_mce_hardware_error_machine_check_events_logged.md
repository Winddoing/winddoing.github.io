---
layout: post
title: 'kernel: mce: [Hardware Error]: Machine check events logged'
date: '2021-03-30 09:43'
tags:
  - kernel
  - mce
  - linux
categories:
  - 系统服务
---

```
localhost.localdomain kernel: mce: [Hardware Error]: Machine check events logged
localhost.localdomain mcelog[2226]: Hardware event. This is not a software error.
localhost.localdomain mcelog[2226]: MCE 0
localhost.localdomain mcelog[2226]: CPU 0 BANK 7 TSC b98e63765d2
localhost.localdomain mcelog[2226]: MISC 200005c280201086 ADDR 20b5cf8880
localhost.localdomain mcelog[2226]: TIME 1617035952 Tue Mar 30 00:39:12 2021
localhost.localdomain mcelog[2226]: MCG status:
localhost.localdomain mcelog[2226]: MCi status:
localhost.localdomain mcelog[2226]: Corrected error
localhost.localdomain mcelog[2226]: Error enabled
localhost.localdomain mcelog[2226]: MCi_MISC register valid
localhost.localdomain mcelog[2226]: MCi_ADDR register valid
localhost.localdomain mcelog[2226]: MCA: MEMORY CONTROLLER RD_CHANNEL0_ERR
localhost.localdomain mcelog[2226]: Transaction: Memory read error
localhost.localdomain mcelog[2226]: M2M: MscodDataRdErr
localhost.localdomain mcelog[2226]: STATUS 9c00004001010090 MCGSTATUS 0
localhost.localdomain mcelog[2226]: MCGCAP f000c14 APICID 0 SOCKETID 0
localhost.localdomain mcelog[2226]: CPUID Vendor Intel Family 6 Model 85
localhost.localdomain mcelog[2226]: warning: 8 bytes ignored in each record
localhost.localdomain mcelog[2226]: consider an update
```
内存模块出现错误

<!--more-->

## Machine Check Exceptions (MCE)

> X86 CPUs report errors detected by the CPU as machine check events (MCEs). These can be data corruption detected in the CPU caches, in main memory by an integrated memory controller, data transfer errors on the front side bus or CPU interconnect or other internal errors. Possible causes can be cosmic radiation, instable power supplies, cooling problems, broken hardware, running systems out of specification, or bad luck.

> Most errors can be corrected by the CPU by internal error correction mechanisms. Uncorrected errors cause machine check exceptions which may kill processes or panic the machine. A small number of corrected errors is usually not a cause for worry, but a large number can indicate future failure.

> When a corrected or recovered error happens the x86 kernel writes a record describing the MCE into a internal ring buffer available through the /dev/mcelog device. mcelog retrieves errors from /dev/mcelog, decodes them into a human readable format and prints them on the standard output or optionally into the system log.

用来报告主机硬件相关问题的一种日志机制

## 常见的MCE错误原因

- 内存错误或ECC(Error Correction Code)问题
- 冷却不充分/处理器过热
- 系统总线错误
- 处理器或硬件的缓存错误


## 参考

- [mcelog](http://mcelog.org/manpage.html)
