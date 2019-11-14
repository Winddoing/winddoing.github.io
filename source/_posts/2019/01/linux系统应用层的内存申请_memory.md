---
layout: post
title: Linux系统应用层的内存申请--memory
date: '2019-01-25 09:51'
tags:
  - 内存
categories:
  - 程序设计
abbrlink: 9412
---

在linux系统编程中常见的内存申请方式和其特性，`malloc`，`calloc`, `realloc`


<!--more-->

## malloc

``` C
extern void *malloc(unsigned int num_bytes);
```
> - 功能： 分配长度为num_bytes字节的内存块
> - 返回值： 如果分配成功则返回指向被分配内存的指针(此存储区中的`初始值不确定`)，否则返回空指针NULL。

函数的工作机制

malloc函数的实质体现在，它有一个将可用的内存块连接为一个长长的列表的所谓空闲链表。调用malloc函数时，它沿连接表寻找一个大到足以满足用户请求所需要的内存块。然后，将该内存块一分为二（一块的大小与用户请求的大小相等，另一块的大小就是剩下的字节）。接下来，将分配给用户的那块内存传给用户，并将剩下的那块（如果有的话）返回到连接表上。

调用free函数时，它将用户释放的内存块连接到空闲链上。到最后，空闲链会被切成很多的小内存片段，如果这时用户申请一个大的内存片段，那么空闲链上可能没有可以满足用户要求的片段了。于是，malloc函数请求延时，并开始在空闲链上翻箱倒柜地检查各内存片段，对它们进行整理，将相邻的小空闲块合并成较大的内存块。如果无法获得符合要求的内存块，malloc函数会返回NULL指针，因此在调用malloc动态申请内存块时，一定要进行返回值的判断。

Linux Libc6采用的机制是在free的时候试图整合相邻的碎片，使其合并成为一个较大的free空间。


## calloc

``` C
void *calloc(unsigned n,unsigned size)；
```
> - 功能： 在内存的动态存储区中分配n个长度为size的内存空间，并初始化为`0`
> - 返回值： 函数返回一个指向分配起始地址的指针；如果分配不成功，返回NULL。

### malloc的区别

``` C
#include "ansidecl.h"
#include <stddef.h>
/* For systems with larger pointers than ints, this must be declared.  */
PTR malloc (size_t);
void bzero (PTR, size_t);
PTR
calloc (size_t nelem, size_t elsize)
{
  register PTR ptr;  
  if (nelem == 0 || elsize == 0)
    nelem = elsize = 1;

  ptr = malloc (nelem * elsize);
  if (ptr) bzero (ptr, nelem * elsize);

  return ptr;
}
```
> https://code.woboq.org/gcc/libiberty/calloc.c.html

只多做了初始化清零的操作`bzero`

## realloc

``` C
extern void *realloc(void *mem_address, unsigned int newsize);
```
> - 功能： 先判断当前的指针是否有足够的连续空间，如果有，扩大mem_address指向的地址，并且将mem_address返回，如果空间不够，先按照newsize指定的大小分配空间，将原有数据从头到尾拷贝到新分配的内存区域，而后释放原来mem_address所指内存区域，同时返回新分配的内存区域的首地址。即重新分配存储器块的地址。
> - 返回值： 如果重新分配成功则返回指向被分配内存的指针，否则返回空指针NULL

**注意**：这里原始内存中的数据还是保持不变的。当内存不再使用时，应使用free()函数将内存块释放。
