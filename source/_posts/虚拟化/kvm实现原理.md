---
layout: post
title: KVM实现原理
date: '2021-02-18 14:09'
tags:
  - kvm
  - qemu
categories:
  - 虚拟化
abbrlink: 633d906
---

KVM是一个基于Linux内核的虚拟机，它属于完全虚拟化范畴.

X86架构下的KVM实现，分为AMD的虚拟化技术AMD-V（`svm`）,Intel的虚拟化技术Intel-VT(`vmx`)

<!--more-->

## 虚拟化技术

### 完全虚拟化：Full Virtualization，Native Virtualization

- 全虚拟化为客户机提供了完整的虚拟X86平台， 包括处理器、 内存和外设， 支持运行任何理论上可在真实物理平台上运行的操作系统， 为虚拟机的配置提供了最大程度的灵活性。
- 全虚拟化对于虚拟机是无感知的，不清楚自己运行在虚拟化环境中。
- CPU如果不支持硬件虚拟化技术：那么所有指令都是通过VMM虚拟的，通过VMM内的BT动态翻译技术把虚拟机要运行的特权指令转换为物理指令集，然后到CPU上运行。
- CPU如果支持硬件虚拟化技术：VMM运行ring -1，而GuestOS运行在ring 0。

> 虚拟机： VMWare Workstation, VirtualBox, VMWare Server, qemu(hvm), XEN(hvm),Qemu_kvm

### 半虚拟化：Para-Virutalization

- 半虚拟化需要对运行在虚拟机上的客户机操作系统进行修改（这些客户机操作系统会意识到它们运行在虚拟环境里）并提供相近的性能，但半虚拟化的性能要比完全虚拟化更优越。
- 半虚拟化对于虚拟机知道自己运行在虚拟化环境中。
- 虚拟机内核明确知道自己是运行在虚拟化之上的，对于硬件资源的使用不再需要BT而是自己向VMM申请使用，如对于内存或CPU的使用是直接向VMM申请使用，直接调用而非翻译。

> 虚拟机：xen

## Qemu+KVM

KVM主要分：CPU虚拟化、CPU调度原理、KVM内存管理、KVM存储管理、KVM设备管理

![qemu_kvm](/images/2021/03/qemu_kvm.png)

- kvm:是硬件辅助的虚拟化技术，主要负责比较繁琐的cpu虚拟化和内存虚拟化
- QEMU:负责IO设备虚拟化
- VMM:虚拟机管理器（virtual machine monitor）在底层对其上的虚拟机的管理,提供虚拟机的创建和删除

### CPU虚拟化

Intel在处理器级别提供了对虚拟化技术的支持，被称为`VMX`（virtual-machine extensions）

VMX引入了两个操作模式进行CPU虚拟化：`VMX根操作`（root operation） 与`VMX非根操作`（non-root operation）

### 内存虚拟化

内存虚拟化的目的是给虚拟客户机操作系统提供一个从0地址开始的连续物理内存空间，同时在多个客户机之间实现隔离和调度。在虚拟化环境中，内存地址的访问会主要涉及以下4个基础概念，
1. 客户机虚拟地址，GVA（Guest Virtual Address）
2. 客户机物理地址，GPA（Guest Physical Address）
3. 宿主机虚拟地址，HVA（Host Virtual Address）
4. 宿主机物理地址，HPA（Host Physical Address）

> 内存虚拟化就是要将客户机虚拟地址（GVA）转化为最终能够访问的宿主机上的物理地址（HPA）


### I/O虚拟化

在虚拟化的架构下，虚拟机监控器必须支持来自客户机的I/O请求。通常情况下有以下4种I/O虚拟化方式。

1. 设备模拟：在虚拟机监控器中模拟一个传统的I/O设备的特性，比如在QEMU中模拟一个Intel的千兆网卡或者一个IDE硬盘驱动器，在客户机中就暴露为对应的硬件设备。客户机中的I/O请求都由虚拟机监控器捕获并模拟执行后返回给客户机。
2. 前后端驱动接口：在虚拟机监控器与客户机之间定义一种全新的适合于虚拟化环境的交互接口，比如常见的virtio协议就是在客户机中暴露为virtio-net、virtio-blk等网络和磁盘设备，在QEMU中实现相应的virtio后端驱动。
3. 设备直接分配：将一个物理设备，如一个网卡或硬盘驱动器直接分配给客户机使用，这种情况下I/O请求的链路中很少需要或基本不需要虚拟机监控器的参与，所以性能很好。
4. 设备共享分配：其实是设备直接分配方式的一个扩展。在这种模式下，一个（具有特定特性的）物理设备可以支持多个虚拟机功能接口，可以将虚拟功能接口独立地分配给不同的客户机使用。如SR-IOV就是这种方式的一个标准协议。

## 参考

- [KVM实现机制](https://blog.csdn.net/yearn520/article/details/6461047)
- [KVM虚拟化技术原理简介](https://blog.csdn.net/Ghostpant/article/details/110825472)
