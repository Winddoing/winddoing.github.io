---
title: 等待队列
categories: Linux内核
tags:
  - process
  - queue
abbrlink: 36894
date: 2016-10-20 23:07:24
---

### 等待队列

由循环链表实现，其元素包括指向进程描述符的指针。每个等待队列都有一个等待队列头(wait queue head),等待队列头是一个类型为wait_queue_head_t的数据结构

### 用途


