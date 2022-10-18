---
layout: post
title: Linux内核调试——dynamic_debug
date: '2022-10-17 16:32'
tags:
  - linux
  - debug
categories:
  - Linux内核
abbrlink: cb918227
---

`dynamic debug` (dyndbg)是内核提供的一个调试功能，允许动态的开关内核打印输出，包含的API：`pr_debug()`、`dev_dbg()`、`print_hex_dump_debug()`、`print_hex_dump_bytes()`等。
dynamic debug通过设置/dynamic_debug/control文件来控制内核输出，有多种匹配的条件：文件名，函数名，行号，模块名和输出字符的格式；

<!--more-->


## 开启配置

```
CONFIG_DEBUG_FS=y
CONFIG_DYNAMIC_DEBUG=y
```

sys文件系统：
```
# ls /sys/kernel/debug/dynamic_debug/
control
```

查询所有开启了`dynamic debug`选项的文件；
```
# cat /sys/kernel/debug/dynamic_debug/control
# filename:lineno [module]function flags format
init/main.c:857 [main]initcall_blacklisted =p "initcall %s blacklisted\012"
init/main.c:818 [main]initcall_blacklist =p "blacklisting initcall %s\012"
init/initramfs.c:477 [initramfs]unpack_to_rootfs =_ "Detected %s compressed data\012"
arch/arm64/kernel/setup.c:122 [setup]smp_build_mpidr_hash =_ "mask of set bits %#llx\012"
arch/arm64/kernel/setup.c:156 [setup]smp_build_mpidr_hash =_ "MPIDR hash: aff0[%u] aff1[%u] aff2[%u] aff3[%u] mask[%#llx] bits[%u]\012"
arch/arm64/kernel/traps.c:90 [traps]dump_backtrace =_ "%s(regs = %p tsk = %p)\012"
arch/arm64/kernel/smp.c:667 [smp]of_parse_and_init_cpus =_ "cpu logical map 0x%llx\012"
arch/arm64/kernel/topology.c:56 [topology]store_cpu_topology =_ "CPU%u: cluster %d core %d thread %d mpidr %#016llx\012"
arch/arm64/kernel/armv8_deprecated.c:401 [armv8_deprecated]swp_handler =_ "addr in r%d->0x%08x, dest is r%d, source in r%d->0x%08x)\012"
arch/arm64/kernel/armv8_deprecated.c:408 [armv8_deprecated]swp_handler =_ "SWP{B} emulation: access to 0x%08x not allowed!\012"
arch/arm64/kernel/armv8_deprecated.c:326 [armv8_deprecated]emulate_swpX =_ "SWP instruction on unaligned pointer!\012"
arch/arm64/kernel/armv8_deprecated.c:432 [armv8_deprecated]swp_handler =_ "SWP{B} emulation: access caused memory abort!\012"
kernel/params.c:177 [params]parse_args =_ "doing %s, parsing ARGS: '%s'\012"
kernel/params.c:139 [params]parse_one =_ "handling %s with %p\012"
kernel/params.c:152 [params]parse_one =_ "doing %s: %s='%s'\012"
kernel/params.c:156 [params]parse_one =_ "Unknown argument '%s'\012"
...
```

## control文件的语法格式

```
command ::= match-spec* flags-spec
```

匹配的关键字：
```
match-spec ::= 'func' string |
               'file' string |
               'module' string |
               'format' string |
               'class' string |
               'line' line-range

line-range ::= lineno |
               '-'lineno |
               lineno'-' |
               lineno'-'lineno

lineno ::= unsigned-int
```

`flags-spec`包括一个更改操作，后跟一个或多个标志字符。更改操作是以下字符之一：
```
-    remove the given flags
+    add the given flags
=    set the flags to the given flags
```

flags包括：
```
p    enables the pr_debug() callsite.
_    enables no flags.

Decorator flags add to the message-prefix, in order:
t    Include thread ID, or <intr>
m    Include module name
f    Include the function name
l    Include line number
```

组合参数就有：

- `+mp`: 输出打打印包含模块名
- `+mfp`： 输出打印包含模块名、函数名
- `+mflp`： 输出打印包含模块名、函数名、行号
- `+mflp`： 输出打印包含模块名、函数名、行号、线程号

## 使用方法

内核实现：`lib/dynamic_debug.c`

```
Parse words[] as a ddebug query specification, which is a series
of (keyword, value) pairs chosen from these possibilities:

func <function-name>
file <full-pathname>
file <base-filename>
module <module-name>
format <escaped-string-to-find-in-format>
line <lineno>
line <first-lineno>-<last-lineno> // where either may be empty
```

> **开启某个文件中的pr_debug或dev_dbg**


### 输出打印

开启后内核日志将输出到`dmesg`,串口不会输出。也可以在`/var/log/messages`中查看。

- 指定调试文件
  ```
  echo "file mm/cma.c +p" > /sys/kernel/debug/dynamic_debug/control
  ```

  ```
  echo "file mm/cma.c +mfplt" > /sys/kernel/debug/dynamic_debug/control
  ```


- 指定调试模块
  ```
  echo "module cma +p" > /sys/kernel/debug/dynamic_debug/control
  ```

### 关闭打印


```
echo "file mm/cma.c -p" > /sys/kernel/debug/dynamic_debug/control
```

```
echo "module cma -p" > /sys/kernel/debug/dynamic_debug/control
```

## 参考

- [内核文档——Dynamic debug](https://www.kernel.org/doc/html/latest/admin-guide/dynamic-debug-howto.html)
