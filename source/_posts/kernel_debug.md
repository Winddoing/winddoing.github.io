---
title: Linux调试方法---Debug
date: 2017-12-15 23:07:24
categories: Linux内核
tags: [kernel, Debug]
---

常用的Linux调试方法：

<!--more-->


## objdump

### 用法：
``` shell
objdump -D a.out > a.dump
```
### 常用参数：

* -d:将代码段反汇编
* -D:表示对全部文件进行反汇编
* -S:将代码段反汇编的同时，将`反汇编代码和源代码交替显示`，编译时需要给出-g，即需要调试信息。
* -C:将C++符号名逆向解析。
* -l:反汇编代码中插入源代码的文件名和行号。
* -j section:仅反汇编指定的section。可以有多个-j参数来选择多个section。

> $mips-linux-gnu-objdump -d vmlinux > a.s

## addr2line

一个可以将指令的地址和可执行映像转换成文件名、函数名和源代码行数的工具

``` shell
=====>$mips-linux-gnu-addr2line -e out/target/product/xxxxx/symbols/system/lib/libdvm.so 23452
/work/android-4.3-fpga/dalvik/vm/mterp/out/InterpAsm-mips.S:1335
```
>23452 --> 异常PC

> mips-linux-gnu-addr2line -e vmlinux 0x802354c0

## 汇编定位

> 在函数中添加空指令，确认该代码段反汇编后的具体位置.

```
asm __volatile__("ssnop\n\t");
asm __volatile__("ssnop\n\t");

for (i = 0; i <= MAXJSAMPLE; i++)
	table[i] = (JSAMPLE) i;

asm __volatile__("ssnop\n\t");
asm __volatile__("ssnop\n\t");
```

## strace

### 用法：

``` shell
strace a.out
```

## gdb

core dump
### 查看core设置

``` shell
ulimit -a
```

### 开启core file

``` shell
limit -c unlimited
```

### 使用

* 异常程序(段错误)
``` C
int main(int argc, char *argv[])
{
    int *a;

    *a = 1;

    while(1)
    {

    }
    return EXIT_SUCCESS;
}

```

* 运行异常程序后,生成core文件

* 使用gdb查看异常位置

``` shell
gdb ./a.out core
```


