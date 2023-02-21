---
title: 进程迁移
categories:
  - 计算机系统
  - 进程
tags:
  - 进程
  - cgroup
abbrlink: 62989
date: 2018-01-17 23:07:24
---

进程迁移就是将一个进程从当前位置移动到指定的处理器上。它的基本思想是在进程执行过程中移动它，使得它在另一个计算机上继续存取它的所有资源并继续运行，而且不必知道运行进程或任何与其它相互作用的进程的知识就可以启动进程迁移操作，这意味着迁移是透明的。

> 进程迁移是支持负载平衡和高容错性的一种非常有效的手段。

<!--more-->

1. 动态负载平衡：将进程迁移到负载轻或空闲的节点上，充分利用可用资源，通过减少节点间负载的差异来全面提高性能。

2. 容错性和高可用性：某节点出现故障时，通过将进程迁移到其它节点继续恢复运行，这将极大的提高系统的可靠性和可用性。在某些关键性应用中，这一点尤为重要。

3. 并行文件IO：将进程迁移到文件服务器上进行IO，而不是通过传统的从文件服务器通过网络将数据传输给进程。对于那些需向文件服务器请求大量数据的进程，这将有效的减少了通讯量，极大的提高效率。

4. 充分利用特殊资源：进程可以通过迁移来利用某节点上独特的硬件或软件能力。

5. 内存导引（Memory Ushering）机制：当一个节点耗尽它的主存时，Memory Ushering机制将允许进程迁移到其它拥有空闲内存的节点，而不是让该节点频繁地进行分页或和外存进行交换。这种方式适合于负载较为均衡，但内存使用存在差异或内存物理配置存在差异的系统。

## Task migration(LTP)

>ltp-full-20140115/testcases/kernel/controllers/cpuctl/cpuctl_test02.c

通过cgroup将两个cgroup同两个物理核进行绑定，然后在两个cgroup中的tasks中进行两个进程ID的移动，从而进行进程的迁移

```
mount -t cgroup -o cpuset cgroup /mnt
cd /mnt
#创建子cgroup，cpu0, cpu1
mkdir cpu0 cpu1
#将CPU0绑定到子cgroup.cpu0
cd cpu0
echo 0 > cpuset.cpus
#将CPU1绑定到子cgroup.cpu1
cd cpu1
echo 1 > cpuset.cpus

#进程迁移
echo PID0 > /mnt/cpu0/tasks
或
echo PID1 > /mnt/cpu1/tasks
```
## [Cgroup](https://winddoing.github.io/2018/02/28/app_cgroup/)


## 参考

1. [Linux Cgroup系列（01）：Cgroup概述](https://segmentfault.com/a/1190000006917884)

