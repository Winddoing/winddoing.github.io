
# NPTL

NPTL，或称为 Native POSIX Thread Library，是 Linux 线程的一个新实现，它克服了 LinuxThreads 的缺点，同时也符合 POSIX 的需求。与 LinuxThreads 相比，它在性能和稳定性方面都提供了重大的改进。与 LinuxThreads 一样，NPTL 也实现了一对一的模型。

Ulrich Drepper 和 Ingo Molnar 是 Red Hat 参与 NPTL 设计的两名员工。他们的总体设计目标如下：

这个新线程库应该兼容 POSIX 标准。
这个线程实现应该在具有很多处理器的系统上也能很好地工作。
为一小段任务创建新线程应该具有很低的启动成本。
NPTL 线程库应该与 LinuxThreads 是二进制兼容的。注意，为此我们可以使用 LD_ASSUME_KERNEL，这会在本文稍后进行讨论。
这个新线程库应该可以利用 NUMA 支持的优点。
原文地址：http://www.ibm.com/developerworks/cn/linux/l-threading.html
