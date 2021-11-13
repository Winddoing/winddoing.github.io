---
layout: post
title: linux系统调用——vsyscall和vDSO
date: '2021-03-16 19:37'
tags:
  - linux
  - syscall
categories:
  - 程序设计
abbrlink: f04c402b
---

`vsyscall`和`vDSO`段是用于加速Linux中某些系统调用的两种机制。

> The `"vDSO"` (virtual dynamic shared object) is a small shared library
that the kernel automatically maps into the address space of all user-space applications.  Applications usually do not need to concern themselves with these details as the vDSO is most commonly called by the C library.  This way you can code in the normal way using standard functions and the C library will take care of using any functionality that is available via the vDSO.

<!--more-->


## 参考

- [人见人爱的vDSO机制，如今也靠不住了](https://cloud.tencent.com/developer/article/1073909)
- [What are vdso and vsyscall?](https://stackoverflow.com/questions/19938324/what-are-vdso-and-vsyscall)
