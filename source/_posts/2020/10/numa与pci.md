---
layout: post
title: NUMA与PCI
date: '2020-10-12 16:11'
tags:
  - numa
  - pci
categories:
  - Linux内核
---

![NUMA PCI mapping](/images/2020/10/numa_pci_mapping.png)
NUMA与PCI之间的关系：
<!--more-->

多物理CPU之间通过`QPI`总线进行通信


```shell
# lspci -s 02:0.0 -vv
02:00.0 VGA compatible controller: xxx [VGA controller])
	Physical Slot: 2
  ...
	Latency: 0
	Interrupt: pin A routed to IRQ 240
	NUMA node: 0         #不同的pci卡槽对应的node节点可能不同，与其绑定的CPU相关
```

在不同的NUMA node下的pci设备进行内存读写时速度与响应时间存在差异，相同的NUMA node节点下的设备与内存的读写效果会更好。

例如，如果客户机被固定在NUMA节点0-1上，但是其PCI设备中的一个隶属于节点2，那么节点之间的数据传输将花费一段时间。

`lstopo`命令可以查看系统的硬件拓扑结构

## 安装lstopo命令

- ubuntu
``` shell
sudo apt install hwloc
```
- centos
``` shell
sudo yum install hwloc-gui
```

## 示例

![lstopo my pc](/images/2020/10/lstopo_test1.png)

![lstopo test](/images/2020/10/lstopo_test2.png)


## 虚拟机中资源的最佳分布

> 虚拟机所使用的到的所有硬件资源尽可能的分布在同一个node节点之上，这样将提高设备的利用率和虚拟机性能

![VM Resources Mapping](/images/2020/10/vm_resources_mapping.png)

## CPU与内存吞吐量测试

> Intel处理器测试工具:[Processor Counter Monitor](https://github.com/opcm/pcm)

- 内存的读写速度
- 多物理CPU之间的QPI速度

```shell
pcm-202009]# ls ./pcm-*.x
./pcm-core.x  ./pcm-latency.x  ./pcm-memory.x  ./pcm-msr.x   ./pcm-pcicfg.x  ./pcm-power.x  ./pcm-sensor-server.x  ./pcm-tsx.x
./pcm-iio.x   ./pcm-lspci.x    ./pcm-mmio.x    ./pcm-numa.x  ./pcm-pcie.x    ./pcm-raw.x    ./pcm-sensor.x
```

```
# ./pcm.x 20

 Processor Counter Monitor  (2020-10-01 16:31:57 +0200 ID=f510546)


IBRS and IBPB supported  : yes
STIBP supported          : yes
Spec arch caps supported : yes
Number of physical cores: 32
Number of logical cores: 64
Number of online logical cores: 64
Threads (logical cores) per physical core: 2
Num sockets: 2
Physical cores per socket: 16
Core PMU (perfmon) version: 4
Number of core PMU generic (programmable) counters: 4
Width of generic (programmable) counters: 48 bits
Number of core PMU fixed counters: 3
Width of fixed counters: 48 bits
Nominal core frequency: 2300000000 Hz
IBRS enabled in the kernel   : no
STIBP enabled in the kernel  : no
The processor is not susceptible to Rogue Data Cache Load: yes
The processor supports enhanced IBRS                     : yes
Package thermal spec power: 125 Watt; Package minimum power: 68 Watt; Package maximum power: 307 Watt;
Socket 0: 2 memory controllers detected with total number of 6 channels. 3 QPI ports detected. 2 M2M (mesh to memory) blocks detected. 0 Home Agents detected. 3 M3UPI blocks detected.
Socket 1: 2 memory controllers detected with total number of 6 channels. 3 QPI ports detected. 2 M2M (mesh to memory) blocks detected. 0 Home Agents detected. 3 M3UPI blocks detected.
Delay: 20
Disabling NMI watchdog since it consumes one hw-PMU counter.
Trying to use Linux perf events...
Successfully programmed on-core PMU using Linux perf
Link 3 is disabled
Link 3 is disabled
Socket 0
Max QPI link 0 speed: 23.3 GBytes/second (10.4 GT/second)
Max QPI link 1 speed: 23.3 GBytes/second (10.4 GT/second)
Socket 1
Max QPI link 0 speed: 23.3 GBytes/second (10.4 GT/second)
Max QPI link 1 speed: 23.3 GBytes/second (10.4 GT/second)

Detected Intel(R) Xeon(R) Gold 5218 CPU @ 2.30GHz "Intel(r) microarchitecture codename Cascade Lake-SP" stepping 7 microcode level 0x5002f01

 EXEC  : instructions per nominal CPU cycle
 IPC   : instructions per CPU cycle
 FREQ  : relation to nominal CPU frequency='unhalted clock ticks'/'invariant timer ticks' (includes Intel Turbo Boost)
 AFREQ : relation to nominal CPU frequency while in active state (not in power-saving C state)='unhalted clock ticks'/'invariant timer ticks while in C0-state'  (includes Intel Turbo Boost)
 L3MISS: L3 (read) cache misses
 L2MISS: L2 (read) cache misses (including other core's L2 cache *hits*)
 L3HIT : L3 (read) cache hit ratio (0.00-1.00)
 L2HIT : L2 cache hit ratio (0.00-1.00)
 L3MPI : number of L3 (read) cache misses per instruction
 L2MPI : number of L2 (read) cache misses per instruction
 READ  : bytes read from main memory controller (in GBytes)
 WRITE : bytes written to main memory controller (in GBytes)
 LOCAL : ratio of local memory requests to memory controller in %
LLCRDMISSLAT: average latency of last level cache miss for reads and prefetches (in ns)
 PMM RD : bytes read from PMM memory (in GBytes)
 PMM WR : bytes written to PMM memory (in GBytes)
 L3OCC : L3 occupancy (in KBytes)
 TEMP  : Temperature reading in 1 degree Celsius relative to the TjMax temperature (thermal headroom): 0 corresponds to the max temperature
 energy: Energy in Joules


 Core (SKT) | EXEC | IPC  | FREQ  | AFREQ | L3MISS | L2MISS | L3HIT | L2HIT | L3MPI | L2MPI |   L3OCC | TEMP

   0    0     0.02   0.50   0.03    1.26     926 K   9825 K    0.89    0.42    0.00    0.01      128     43
   1    1     0.03   0.67   0.05    0.84    4930 K   6272 K    0.14    0.63    0.00    0.00      320     55
   2    0     0.22   0.81   0.28    1.05    5539 K     12 M    0.53    0.79    0.00    0.00     1472     54
   3    1     0.00   0.29   0.00    1.33      23 K     44 K    0.38    0.86    0.00    0.00        0     47
   4    0     0.14   0.84   0.17    0.96    3001 K   7083 K    0.53    0.79    0.00    0.00      640     49
   5    1     0.01   0.53   0.03    0.99     129 K   2453 K    0.93    0.61    0.00    0.00      256     61
   6    0     0.21   0.85   0.25    1.04    5115 K     11 M    0.50    0.80    0.00    0.00      384     54
   7    1     0.03   0.55   0.05    1.10     273 K   4573 K    0.93    0.60    0.00    0.00     1344     57
   8    0     0.21   0.80   0.26    1.06    5361 K     11 M    0.49    0.80    0.00    0.00     1216     54
   9    1     0.09   0.57   0.16    1.32     769 K     14 M    0.94    0.65    0.00    0.00     2048     57
  10    0     0.21   0.74   0.29    1.26    7000 K     14 M    0.48    0.79    0.00    0.00      256     52
  11    1     0.02   0.44   0.04    1.30    1072 K   2780 K    0.36    0.62    0.00    0.00        0     54
  12    0     0.20   0.84   0.23    1.08    4916 K     11 M    0.50    0.78    0.00    0.00      640     53
  13    1     0.01   0.55   0.03    1.06     158 K   2583 K    0.92    0.61    0.00    0.00      192     57
  14    0     0.14   0.70   0.20    1.26    2654 K   7546 K    0.58    0.81    0.00    0.00     1664     52
  15    1     0.00   0.52   0.01    0.78      54 K    897 K    0.78    0.57    0.00    0.00        0     54
  16    0     0.11   0.74   0.14    0.96    2978 K   7413 K    0.54    0.78    0.00    0.00     3328     53
  17    1     0.00   0.50   0.01    0.80      38 K    610 K    0.79    0.57    0.00    0.00        0     59
  18    0     0.15   0.69   0.22    1.00    5981 K     12 M    0.45    0.78    0.00    0.00     2368     53
  19    1     0.13   2.30   0.06    1.07     186 K    952 K    0.79    0.53    0.00    0.00      128     58
  20    0     0.11   0.74   0.14    0.87    5408 K     10 M    0.43    0.74    0.00    0.00     4928     52
  21    1     0.01   0.44   0.03    1.05    1742 K   2476 K    0.22    0.74    0.00    0.00      448     55
  22    0     0.20   0.84   0.23    0.98    4198 K   9626 K    0.51    0.81    0.00    0.00      576     55
  23    1     0.00   0.87   0.00    0.52     191 K    316 K    0.37    0.59    0.00    0.00      192     60
  24    0     0.15   0.86   0.17    1.05    2357 K   6482 K    0.58    0.80    0.00    0.00      384     52
  25    1     0.01   1.18   0.00    0.50     123 K    275 K    0.49    0.82    0.00    0.00        0     59
  26    0     0.12   0.76   0.16    1.02    4988 K     10 M    0.43    0.77    0.00    0.00      704     52
  27    1     0.01   1.06   0.01    0.69     125 K   1009 K    0.87    0.63    0.00    0.00        0     55
  28    0     0.15   0.83   0.18    0.99    4284 K   9017 K    0.46    0.79    0.00    0.00     1792     53
```

## 参考

- [NUMA Node to PCI Slot Mapping in Red Hat Enterpise Linux](https://fatmin.com/2016/06/10/numa-node-to-pci-slot-mapping-in-red-hat-enterpise-linux/)
- [虚拟化调试和优化指南](https://access.redhat.com/documentation/zh-cn/red_hat_enterprise_linux/7/html-single/virtualization_tuning_and_optimization_guide/index#sect-Virtualization_Tuning_Optimization_Guide-NUMA-Auto_NUMA_Balancing)
- [Notes and tools for measuring CPU-to-memory throughput in Linux](https://github.com/LucaCanali/Miscellaneous/blob/master/Spark_Notes/Tools_Linux_Memory_Perf_Measure.md)
- [Machine Learning Workload and GPGPU NUMA Node Locality](https://frankdenneman.nl/2020/01/30/machine-learning-workload-and-gpgpu-numa-node-locality/)
