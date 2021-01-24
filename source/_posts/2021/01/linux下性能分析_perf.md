---
layout: post
title: linux下性能分析---perf
date: '2021-01-24 21:12'
tags:
  - perf
  - 性能
categories:
  - 工具
---

`perf`是Linux kernel自带的系统性能优化工具

<!--more-->


## perf

``` shell
$perf

 usage: perf [--version] [--help] [OPTIONS] COMMAND [ARGS]

 The most commonly used perf commands are:
   annotate        Read perf.data (created by perf record) and display annotated code
   archive         Create archive with object files with build-ids found in perf.data file
   bench           General framework for benchmark suites
   buildid-cache   Manage build-id cache.
   buildid-list    List the buildids in a perf.data file
   c2c             Shared Data C2C/HITM Analyzer.
   config          Get and set variables in a configuration file.
   data            Data file related processing
   diff            Read perf.data files and display the differential profile
   evlist          List the event names in a perf.data file
   ftrace          simple wrapper for kernel's ftrace functionality
   inject          Filter to augment the events stream with additional information
   kallsyms        Searches running kernel for symbols
   kmem            Tool to trace/measure kernel memory properties
   kvm             Tool to trace/measure kvm guest os
   list            List all symbolic event types
   lock            Analyze lock events
   mem             Profile memory accesses
   record          Run a command and record its profile into perf.data
   report          Read perf.data (created by perf record) and display the profile
   sched           Tool to trace/measure scheduler properties (latencies)
   script          Read perf.data (created by perf record) and display trace output
   stat            Run a command and gather performance counter statistics
   test            Runs sanity tests.
   timechart       Tool to visualize total system behavior during a workload
   top             System profiling tool.
   version         display the version of perf binary
   probe           Define new dynamic tracepoints
   trace           strace inspired tool

 See 'perf help COMMAND' for more information on a specific command.
```


## 常用参数

| 参数  | 描述  |
|:-:|:-:|
| top | 动态时实追踪显示占用CPU较高的进程  |
| record | 由于top只能实时查看不能保存，不便于事后分析，用此参数保存追踪的内容，文件名为perf.data  |
| report | 重放perf.data的内容  |


## 示例

``` shell
#记录
$sudo perf record -g -p <pid>
#回放
$sudo perf report
```
