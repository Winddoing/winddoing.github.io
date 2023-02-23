---
layout: post
title: IPC---共享内存
date: '2021-04-10 22:07'
tags:
  - ipc
  - linux
  - 共享内存
categories:
  - 程序设计
  - C
abbrlink: a83ba476
---

进程间通信的一种方式，多个进程共享一段内存，即“`共享内存`”。与其他的ipc方式（如：pipe，fifo，messages）相比少copy一次内存

<!--more-->

## 共享内存接口函数

### shmget

创建新的，或者获取已有的共享内存

``` C
#include <sys/ipc.h>
#include <sys/shm.h>

int shmget(key_t key, size_t size, int shmflg);
```

- `key`: 类似共享内存的标签,如果key值没有对应任何共享内存,则创建一个新的共享内存；如果已存在,则直接使用创建好的共享内存
  > 由`ftok`生成的key标识，标识系统的唯一IPC资源
- 返回值: 返回共享内存的标识符，用于后续对该共享内存的操作

### shmat

将shmid所指向的共享内存空间映射到进程空间（虚拟内存空间），并返回影射后的起始地址（虚拟地址）。有了这个地址后，就可以通过这个地址对共享内存进行读写操作。

``` C
#include <sys/types.h>
#include <sys/shm.h>

void *shmat(int shmid, const void *shmaddr, int shmflg);

int shmdt(const void *shmaddr);
```

### shmctl

取消建立的映射

``` C
#include <sys/ipc.h>
#include <sys/shm.h>

int shmctl(int shmid, int cmd, struct shmid_ds *buf);
```

## 共享内存的使用步骤

- 进程调用shmget函数创建新的或获取已有共享内存
- 进程调用shmat函数，将物理内存映射到自己的进程空间，说白了就是让虚拟地址和真实物理地址建议一一对应的映射关系。
- shmdt函数，取消映射
- 调用shmctl函数释放开辟的那片物理内存空间和消息队列的msgctl的功能是一样的，只不过这个是共享内存的。

## 共享内存的删除

1. 重启OS，很麻烦，服务器也不是随随便便就让你去重启的。
2. 进程结束时，调用相应的API来删除
3. 使用ipcrm命令删除

## 查看当前系统中的共享内存

``` shell
ipcs -m
```

## 参考

- [共享内存详解（本机IPC）【linux】](https://blog.csdn.net/qq_43648751/article/details/104836005)
- [共享内存函数（shmget、shmat、shmdt、shmctl）及其范例](https://blog.csdn.net/guoping16/article/details/6584058)
