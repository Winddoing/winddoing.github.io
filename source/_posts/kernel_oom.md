---
title: OOM
date: 2018-03-08 23:07:24
categories: Linux内核
tags: [kernel, OOM]
---

内核出现OOM的log分析：

<!--more-->


```
[  128.496873] min_free_kbytes invoked oom-killer: gfp_mask=0x200da, order=0, oom_score_adj=0
[  128.505497] min_free_kbytes cpuset=/ mems_allowed=0
[  128.510968] CPU: 0 PID: 118 Comm: min_free_kbytes Not tainted 3.10.14-00062-g277665d-dirty #322
[  128.523967] Stack : 00000000 00000000 00000000 00000000 80624582 00000053 805b0000 805ad500
		8c3933a0 805ad407 8053d15c 00000076 80623d20 805ad500 00000000 00000000
		805ad500 8046cffc 805c0000 8003b3bc 80b3324c 00000000 8053eecc 890019ac
		00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
		00000000 00000000 00000000 00000000 00000000 00000000 00000000 89001938
		...
[  128.607831] Call Trace:
[  128.612474] [<800209e0>] show_stack+0x48/0x70
[  128.621191] [<8046daf0>] dump_header.isra.4+0x88/0x260
[  128.628626] [<800bd78c>] oom_kill_process+0xd0/0x478
[  128.635875] [<800be070>] out_of_memory+0x318/0x390
[  128.642951] [<800c1ef4>] __alloc_pages_nodemask+0x8b8/0x900
[  128.650833] [<800d9104>] handle_pte_fault+0xae4/0xc5c
[  128.660245] [<800d9358>] handle_mm_fault+0xdc/0x11c
[  128.667406] [<800298d8>] do_page_fault+0x158/0x480
[  128.674477] [<8001a784>] resume_userspace_check+0x0/0x10
[  128.684178] 
[  128.687833] Mem-Info:
[  128.692287] Normal per-cpu:
[  128.699351] CPU    0: hi:   90, btch:  15 usd:  32
[  128.706406] HighMem per-cpu:
[  128.711486] CPU    0: hi:   90, btch:  15 usd:  15
[  128.718564] active_anon:120239 inactive_anon:11 isolated_anon:0
[  128.718564]  active_file:5 inactive_file:2 isolated_file:0
[  128.718564]  unevictable:0 dirty:0 writeback:0 unstable:0
[  128.718564]  free:4617 slab_reclaimable:150 slab_unreclaimable:600
[  128.718564]  mapped:1 shmem:15 pagetables:150 bounce:0
[  128.718564]  free_cma:0
[  128.754330] Normal free:18244kB min:10084kB low:12604kB high:15124kB active_anon:219220kB inactive_anon:0kB active_file
:20kB inactive_file:8kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:262144kB managed:241940kB mlocked:0k
B dirty:0kB writeback:0kB mapped:4kB shmem:0kB slab_reclaimable:600kB slab_unreclaimable:2400kB kernel_stack:320kB pagetab
les:600kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:426 all_unreclaimable? yes
[  128.798925] lowmem_reserve[]: 0 2048 2048
[  128.807365] HighMem free:224kB min:256kB low:2984kB high:5716kB active_anon:261736kB inactive_anon:44kB active_file:0kB
inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:262144kB managed:262144kB mlocked:0kB dir
ty:0kB writeback:0kB mapped:0kB shmem:60kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB uns
table:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:31 all_unreclaimable? yes
[  128.850710] lowmem_reserve[]: 0 0 0
[  128.858541] Normal: 1*4kB (R) 0*8kB 0*16kB 0*32kB 1*64kB (R) 0*128kB 1*256kB (R) 1*512kB (R) 1*1024kB (R) 0*2048kB 0*40
96kB 2*8192kB (R) 0*16384kB 0*32768kB 0*65536kB = 18244kB
[  128.896190] HighMem: 0*4kB 0*8kB 0*16kB 1*32kB (R) 1*64kB (R) 1*128kB (R) 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB 0*
8192kB 0*16384kB 0*32768kB 0*65536kB = 224kB
[  128.928406] 22 total pagecache pages
[  128.988524] 262144 pages RAM
[  128.993703] 131072 pages HighMem
[  129.001226] 136074 pages reserved
[  129.006754] 30 pages shared
[  129.011751] 121318 pages non-shared
[  129.017458] [ pid ]   uid  tgid total_vm      rss nr_ptes swapents oom_score_adj name
[  129.027697] [   61]     0    61      883       18       3        0             0 syslogd
[  129.040259] [   64]     0    64      883       18       3        0             0 klogd
[  129.050561] [   86]  1000    86      753       38       4        0             0 dbus-daemon
[  129.061408] [   96]     0    96     1327       70       4        0         -1000 sshd
[  129.071623] [  103]     0   103      899       23       5        0             0 sh
[  129.081664] [  104]     0   104      883       17       3        0             0 telnetd
[  129.094214] [  108]     0   108      753       36       4        0             0 min_free_kbytes
[  129.105410] [  118]     0   118   120817   120018     121        0             0 min_free_kbytes
[  129.116617] Out of memory: Kill process 118 (min_free_kbytes) score 922 or sacrifice child
[  129.129353] Killed process 118 (min_free_kbytes) total-vm:483268kB, anon-rss:480072kB, file-rss:0kB
```

## 相关变量说明

### file-rss

```
[  129.129353] Killed process 118 (min_free_kbytes) total-vm:483268kB, anon-rss:480072kB, file-rss:0kB
```
>`rss`:"Resident Set Size", 实际驻留"在内存中"的内存数. 不包括已经交换出去的代码. 举一个例子: 如果你有一个程序使用了100K内存, 操作系统交换出40K内存, 那么RSS为60K. RSS还包括了与其它进程共享的内存区域. 这些区域通常用于libc库等.


## 处理流程





## 参考

1. [Linux中进程内存RSS与cgroup内存的RSS统计 - 差异](http://blog.163.com/digoal@126/blog/static/1638770402016514102751241/)
2. [进程实际内存占用: 私有驻留内存数(Private RSS)介绍](http://blog.chinaunix.net/uid-29043620-id-5754325.html)
3. [Out of Memory(OOM)处理流程](https://e-mailky.github.io/2017-01-14-oom)
4. [Taming the OOM killer](https://lwn.net/Articles/317814/)
