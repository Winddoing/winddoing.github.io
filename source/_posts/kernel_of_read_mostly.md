---
title: Linux内核中的read_mostly
date: 2017-10-24 23:07:24
categories: Linux内核
tags: [编译]
---

## read_mostly
__read_mostly原语将定义的变量为存放在.data.read_mostly段中，原型在include/asm/cache.h 中定义：
```
#define __read_mostly __attribute__((__section__(".data.read_mostly")))
```
<!--more-->

## 作用

因为__read_mostl修饰的变量均放在.data.read_mostly段中，因此，我们可以将经常需要被读取的数据定义为__read_mostly类型， 这样Linux内核被加载时,该数据将自动被存放到Cache中,以提高整个系统的执行效率。


如果所在平台没有Cache，或者虽然有Cache，但是并不提供存放数据的接口，(也就是并不允许人工放置数据在Cache中), 那么定义为__read_mostly类型的数据将不能存放在Linux内核中，甚至也不能够被加载到系统内存去执行。

如果数据不能存放在linux内核，甚至也不能够被加载到系统内存去执行，后果非常严重，将造成Linux 内核启动失败。
 