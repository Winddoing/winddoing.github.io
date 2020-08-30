---
layout: post
title: vs与gcc编译器之间的差别
date: '2020-08-28 11:06'
tags:
  - gcc
  - vs
categories:
  - 程序设计
---

最近在做一些移植的工作时，相同的代码使用gcc编译全部正常。但是在windows下使用VS2019进行编译时，出现一些语法错误，主要有下面几种：

<!--more-->


## "void *": unknown size

``` C
void shuffle(void *arr, size_t n, size_t size)
{
    ...
    memcpy(arr+(i*size), swp,  size);
    ...  
}
```

> `void *`执行指针算术运算，因为void没有定义大小，进行偏移操作无法确定偏移的单位，因此出现错误提示

``` C
memcpy((char*)arr+(i*size), swp,  size); 
```

**注**：这种修改解决了编译报错的问题，但是与gcc的编译不兼容


## small关键字

>在编译的代码中定义了`small`变量名，但是其在VS中属于一个关键字,是`char`类型的别名

在头文件`#include <windows.h>`中包含的`<rpcndr.h>`头文件中定义了`small`

``` C
#define small char
```

解决方法：
1. 将`samll`的定义去掉：`#undef small` 
2. 修改代码`small`变量名


## 参考

- [Is “small” a keyword in c?](https://stackoverflow.com/questions/21165891/is-small-a-keyword-in-c)
- [What is RpcNdr.h](https://stackoverflow.com/questions/5874215/what-is-rpcndr-h)
