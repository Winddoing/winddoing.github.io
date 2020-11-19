---
layout: post
title: idr与ida
date: '2020-11-17 14:12'
tags:
  - linux
  - kernel
categories:
  - linux内核
abbrlink: e5599899
---

- `IDR`在Linux内核中指的是整数ID管理机制。实质上来讲，这就是一种将一个整数ID号和一个指针关联在一起的机制。
- `IDA`是用IDR来实现的ID分配机制,与IDR的区别是IDA仅仅`分配`与`管理`ID,并不将ID与指针相关联.

<!--more-->


## IDR

> 所谓IDR，其实就是和身份证的含义差不多，我们知道，每个人有一个身份证，身份证只是一串数字，从数字，我们就能知道这个人的信息。同样道理，idr的要完成的任务是给要管理的对象分配一个数字，可以通过这个数字找到要管理的对象。



## IDA
