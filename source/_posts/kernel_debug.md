---
title: Linux内核调试方法---Debug
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
## ftrace

ftrace 是内建于 Linux 内核的跟踪工具，从 2.6.27 开始加入主流内核。使用 ftrace 可以调试或者分析内核中发生的事情。ftrace 提供了不同的跟踪器，以用于不同的场合，比如跟踪内核函数调用、对上下文切换进行跟踪、查看中断被关闭的时长、跟踪内核态中的延迟以及性能问题等

>Documentation/trace/ftrace.txt

### kernel配置

```
Symbol: FTRACE [=y]
Type  : boolean
Prompt: Tracers
  Location:
      -> Kernel hacking
	    Defined at kernel/trace/Kconfig:135
		  Depends on: TRACING_SUPPORT [=y]

--- Tracers
-*-   Kernel Function Tracer
[*]     Kernel Function Graph Tracer
[*]   Interrupts-off Latency Tracer
[*]   Preemption-off Latency Tracer
[*]   Scheduling Latency Tracer
-*-   Create a snapshot trace buffer
-*-     Allow snapshot to swap per CPU
Branch Profiling (No branch profiling)  --->
[*]   Trace max stack
[*]   Support for tracing block IO actions
[*]   enable/disable function tracing dynamically
[ ]   Kernel function profiler
[ ]   Perform a startup test on ftrace
< >   Ring buffer benchmark stress tester
[ ]   Ring buffer startup self test
```

### Use

``` shell
# mount -t debugfs none /mnt/
```

```
# cd /mnt/tracing/
# ls
README                      set_event
available_events            set_ftrace_filter
available_filter_functions  set_ftrace_notrace
available_tracers           set_ftrace_pid
buffer_size_kb              set_graph_function
buffer_total_size_kb        snapshot
current_tracer              stack_max_size
dyn_ftrace_total_info       stack_trace
enabled_functions           stack_trace_filter
events                      trace
free_buffer                 trace_clock
instances                   trace_marker
max_graph_depth             trace_options
options                     trace_pipe
per_cpu                     tracing_cpumask
printk_formats              tracing_max_latency
saved_cmdlines              tracing_on
saved_tgids                 tracing_thresh
```

### available_tracers

记录了当前编译进内核的跟踪器的列表

>available_tracers     - list of configured tracers for current_tracer

``` shell
# cat available_tracers
blk function_graph wakeup_rt wakeup preemptirqsoff preemptoff irqsoff function nop
```

### current_tracer

用于设置或显示当前使用的跟踪器；
使用`echo`将跟踪器名字写入该文件可以切换到不同的跟踪器。系统启动后，其缺省值为`nop` ，即不做任何跟踪操作。在执行完一段跟踪任务后，可以通过向该文件写入`nop`来重置跟踪器。

``` shell
# echo wakeup > current_tracer
```

### trace

文件提供了查看获取到的跟踪信息的接口。

通过 cat 等命令查看该文件以查看跟踪到的内核活动记录，也可以将其内容保存为记录文件以备后续查看。

``` shell
# cat trace

# tracer: wakeup
#
# wakeup latency trace v1.1.5 on 3.10.14-00042-ge40985e
# --------------------------------------------------------------------
# latency: 624 us, #174/174, CPU#0 | (M:preempt VP:0, KP:0, SP:0 HP:0 #P:2)
#    -----------------
#    | task: ksdioirqd/mmc1-155 (uid:0 nice:0 policy:1 rt_prio:1)
#    -----------------
#
#                  _------=> CPU#
#                 / _-----=> irqs-off
#                | / _----=> need-resched
#                || / _---=> hardirq/softirq
#                ||| / _--=> preempt-depth
#                |||| /     delay
#  cmd     pid   ||||| time  |   caller
#     \   /      |||||  \    |   /
<idle>-0       0dNh4    4us+:      0:120:R   + [000]   155: 98:R ksdioirqd/mmc1
<idle>-0       0dNh4   12us+: 0
<idle>-0       0dNh4   17us+: task_woken_rt <-ttwu_do_wakeup
<idle>-0       0dNh4   21us+: _raw_spin_unlock <-try_to_wake_up
<idle>-0       0dNh4   24us+: sub_preempt_count <-_raw_spin_unlock
<idle>-0       0dNh3   28us+: _raw_spin_unlock_irqrestore <-try_to_wake_up
....
```

### 使用

> 内核中断

``` shell
# echo 0 > tracing_on 
# echo > trace
# echo nop > current_tracer 
# echo irq > set_event 
# echo 1 > tracing_on
# cat trace_pipe 
		sh-100   [000] d.h3  1333.894909: irq_handler_entry: irq=58 name=uart1
		sh-100   [000] d.h3  1333.894931: irq_handler_exit: irq=58 ret=handled
	<idle>-0     [000] d.h2  1333.902444: irq_handler_entry: irq=34 name=jz-timerirq

# cat trace
# tracer: nop
#
# entries-in-buffer/entries-written: 5510/5510   #P:1
#
#                              _-----=> irqs-off
#                             / _----=> need-resched
#                            | / _---=> hardirq/softirq
#                            || / _--=> preempt-depth
#                            ||| /     delay
#           TASK-PID   CPU#  ||||    TIMESTAMP  FUNCTION
#              | |       |   ||||       |         |
              sh-100   [000] d.h3  1342.498892: irq_handler_exit: irq=58 ret=handled
		<idle>-0     [000] d.h2  1342.673707: irq_handler_entry: irq=34 name=jz-timerirq
		<idle>-0     [000] d.h2  1342.673717: irq_handler_exit: irq=34 ret=handled

```
