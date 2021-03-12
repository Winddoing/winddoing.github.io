---
layout: post
title: KVM实现原理
date: '2021-02-18 14:09'
tags:
  - kvm
  - qemu
categories:
  - 虚拟化
---

KVM是一个基于Linux内核的虚拟机，它属于完全虚拟化范畴.

X86架构下的KVM实现，分为AMD的虚拟化技术AMD-V（`svm`）,Intel的虚拟化技术Intel-VT(`vmx`)

<!--more-->

KVM主要分：CPU虚拟化、CPU调度原理、KVM内存管理、KVM存储管理、KVM设备管理



## CPU虚拟化




## 参考

- [KVM实现机制](https://blog.csdn.net/yearn520/article/details/6461047)
