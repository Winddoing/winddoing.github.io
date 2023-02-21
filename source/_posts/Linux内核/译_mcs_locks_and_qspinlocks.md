---
layout: post
title: '[译]MCS locks and qspinlocks'
date: '2019-04-20 13:49'
tags:
  - sync
  - spinlock
categories:
  - Linux内核
abbrlink: 12400
---

原文： https://lwn.net/Articles/590243/


从概念上讲，自旋锁是一种简单的机制。 锁可以小到一位; 如果该位清零，则锁定可用。 想要获取锁的线程将尝试使用`原子比较交换指令`(atomic compare-and-swap instruction)设置该位，如果当时锁不可用则反复“旋转”。 多年来，自旋锁变得更加复杂; 排队自旋锁（[Ticket spinlocks](https://lwn.net/Articles/267968/)）在2008年增加了对该机制的公平性，并且2013年增加了更好的半虚拟化支持。

<!--more-->

尽管每次尝试获取锁定都需要将包含该锁定的高速缓存行移动到本地CPU，但自旋锁仍然存在一个根本问题，除了简单的旋转锁定是痛苦的。 对于竞争锁，此`缓存弹跳`(cache-line bouncing)可能会显着损害性能。 因此，开发人员一直在努力减少自旋锁的缓存争用并不奇怪; 例如，尝试在2013年初为自旋锁添加自动退避([an attempt to add automatic backoff](https://lwn.net/Articles/531254/))是为了实现这一目标，但这项工作从未合并过。


## MCS locks

最近，Tim Chen根据一个名为“MCS锁”的原语组合了一种不同的方法。 通过将自旋锁扩展为每个CPU结构，MCS锁可以消除更简单锁所经历的大部分缓存弹跳，尤其是在竞争情况下。

MCS锁定由此结构的实例定义：
```
struct mcs_spinlock {
  struct mcs_spinlock *next;
	int locked; /* 1 if lock acquired */
};
```
![msc_lock_struct](/images/2019/04/msc_lock_struct.png)

当CPU出现获取此锁的愿望时，它将提供自己的`mcs_spinlock`结构。 使用无条件原子交换操作，它将自己的结构的地址存储在锁的`next`字段中，并将`locked`置为1，标记为以拿到，产生如下情况：
![msc_lock_taken](/images/2019/04/msc_lock_taken.png)

原子交换将返回`next`指针的前面值。 由于该指针为空，因此获取CPU知道它已成功获取锁。 一旦完成，锁将是忙，但没有争用。 如果第二个CPU出现并尝试获取锁，它将以相同的方式启动，在主锁的`next`指针中存储指向其`mcs_spinlock`结构的指针：
![msc_lock_2](/images/2019/04/msc_lock_2.png)

当第二个CPU在主锁上执行此原子交换时，它也将返回`next`字段的先前值(指向第一个CPU的mcs_spinlock结构的指针)。非NULL值则告诉第二个CPU锁是不可用，而特定指针的值表示谁在锁的前面。 第二个CPU将通过在CPU1的结构的`next`字段中存储指向其mcs_spinlock结构的指针来响应这种情况：
![msc_lock_3](/images/2019/04/msc_lock_3.png)

请注意，在主锁上使用原子交换操作意味着只有CPU2可以具有指向CPU1的mcs_spinlock结构的指针。因此，在对该结构进行更改时不需要原子操作，但仍需要进行一些仔细的编程，以确保在正确的时间CPU1可以看到更改。

完成此分配后，CPU2将在其自己的mcs_spinlock结构中旋转锁定值，而不是主锁中的值。因此，它的旋转完全是CPU本地的，根本不会触及主锁。 随着对锁的争用增加，这个过程可以无限期地继续进行，每个CPU将自己置于已经存在的那些后面，并且每个CPU在其自己的锁副本上旋转。 因此，“主”锁中的指针始终指示等待CPU队列的尾部。

当CPU 1最终完成锁定时，它将对主锁执行比较和交换操作，尝试将下一个指针设置为NULL，假设此指针仍指向其自己的结构。 如果该操作成功，则永远不会争用锁定并完成作业。但是，如果某个其他CPU已经更改了该指针，如上所示，则compare-and-swap将失败。 在这种情况下，CPU1根本不会改变主锁; 相反，它将更改CPU2结构中的锁定值并从以下情况中移除自身：
![msc_lock_4](/images/2019/04/msc_lock_4.png)

一旦锁的副本被更改，CPU2将脱离其旋转并成为锁的新所有者。

因此，MCS锁比常规自旋锁稍微复杂一些。但是，增加的复杂性消除了许多缓存行从竞争情况中反弹; 它也完全公平，按照CPU到达的顺序将锁传递给每个CPU。


## Qspinlocks

MCS锁用于实现互斥锁，但它们不会替换现有的排队自旋锁（ticket spinlocks）实现。 其中一个原因是占用内存大小：排队自旋锁适合单个32位字，而MCS锁不适合。 事实证明这很重要：自旋锁被嵌入到许多内核结构中，其中一些（特别是结构页面）不能容忍大小的增加。 如果要在整个内核中使用MCS锁定技术，则需要一些其他方法。

可能合并的那种方法的版本可以在Peter Zijlstra的[“qspinlock”补丁](https://lwn.net/Articles/590189/)系列中看到，而后者则基于Waiman Long的[实施](https://lwn.net/Articles/588426/)。 在此补丁集中，每个CPU在众所周知的位置获取四个`mcs_spinlock`结构的数组。 需要四种结构，因为CPU可能一次尝试获取多个自旋锁：想象如果在线程在锁上旋转时硬件中断进入会发生什么，并且中断处理程序试图锁定它自己的锁 ， 例如。 结构数组允许来自正常，软件中断，硬件中断和不可屏蔽中断上下文的锁定获取尝试保持分开。

32位`qspinlock`字段：
- 函数的整数计数器，如上所述的`locked`字段
- 一个两位`index`字段，表示每个CPU`mcs_spinlock`数组中的哪个条目由列表尾部被使用
- 一个`pending`位
- 一个整数字段，用于保存指示队列尾部的CPU编号

一个与每个CPU用于自转的值有关。 当下一个CPU获得锁时，它将自动上锁，而不是在每个CPU结构上自旋。 这样，当释放锁时，不需要操作每CPU结构的高速缓存行，从~~等式~~中移除一个高速缓存行未命中。 任何后续的CPU都会在它们自己的结构上自旋，直到它们到达队列的头部。

`pending`位将该策略进一步扩展。如果CPU发现锁正忙但没有其他CPU正在等待，它将简单地设置挂起位而不打扰其自己的mcs_spinlock结构。第二个出现的CPU将看到挂起的位，开始构建队列的过程，并像往常一样旋转其锁定字段的本地副本。 服务员之间的缓存行反弹仍然被消除，但第一个服务员也能够避免与访问其自己的mcs_spinlock数组相关的缓存未命中代价。

## Other

* [spin lock(Ticket lock: A fair lock)](/downloads/kernel/spinlock/mcs.pdf)
