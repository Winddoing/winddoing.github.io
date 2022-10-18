---
title: Linux内存的VM参数
categories:
  - Linux内核
tags:
  - kernel
  - vm
abbrlink: 18938
date: 2018-02-27 23:07:24
---

```
[root@buildroot ~]# sysctl -a | grep "vm"
sysctl: error reading key 'net.ipv4.route.flush': Permission denied
vm.admin_reserve_kbytes = 8192
vm.block_dump = 0
vm.dirty_background_bytes = 0
vm.dirty_background_ratio = 10
vm.dirty_bytes = 0
vm.dirty_expire_centisecs = 3000
vm.dirty_ratio = 20
vm.dirty_writeback_centisecs = 500
vm.drop_caches = 0
vm.extra_free_kbytes = 0
vm.highmem_is_dirtyable = 0
vm.laptop_mode = 0
vm.legacy_va_layout = 0
vm.lowmem_reserve_ratio = 32      32
vm.max_map_count = 65530
vm.min_free_kbytes = 1970
vm.min_free_order_shift = 1
vm.mmap_min_addr = 4096
vm.nr_pdflush_threads = 0
vm.oom_dump_tasks = 1
vm.oom_kill_allocating_task = 0
vm.overcommit_memory = 0
vm.overcommit_ratio = 50
vm.page-cluster = 3
vm.panic_on_oom = 0
vm.percpu_pagelist_fraction = 0
vm.scan_unevictable_pages = 0
vm.stat_interval = 1
vm.swappiness = 60
vm.user_reserve_kbytes = 15712
vm.vfs_cache_pressure = 100
```
>proc文件系统：` ls /proc/sys/vm/`

<!--more-->

## overcommit_memory

>内核分配内存的策略，有0，1，2三种

| overcommit_memory |	说明	|
| :---------------: | :-------: |
|          0        | 表示内核将检查是否有足够的可用内存供应用进程使用；如果有足够的可用内存，内存申请允许；否则，内存申请失败，并把错误返回给应用进程。|
|          1        | 表示内核允许分配所有的物理内存，而不管当前的内存状态如何|
|          2        | 表示内核允许分配超过所有物理内存和交换空间总和的内存|





