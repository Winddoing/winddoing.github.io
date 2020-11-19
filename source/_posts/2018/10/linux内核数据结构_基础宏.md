---
layout: post
title: linux内核数据结构--基础宏
date: '2018-10-19 15:53'
tags:
  - kernel
categories:
  - linux内核
abbrlink: 56380
---

在阅读内核源码时,存在一些基础的宏定义和函数,这里主要记录一下`offsetof`和`container_of`

<!--more-->

## offsetof
获得结构体(TYPE)的变量成员(MEMBER)在此结构体中的偏移量。

``` C
#define offsetof(TYPE, MEMBER)  ((size_t)&((TYPE *)0)->MEMBER)
```
>From file:[include/linux/stddef.h](https://elixir.bootlin.com/linux/v4.4.1/source/include/linux/stddef.h)

1. `((TYPE *)0)`:将零转型为TYPE类型指针，即TYPE类型的指针的地址是0。
2. `((TYPE *)0)->MEMBER`:访问结构中的数据成员。
3. `&(((TYPE *)0)->MEMBER)`:取出数据成员的地址。由于TYPE的地址是0，这里获取到的地址就是相对MEMBER在TYPE中的偏移。
4. `(size_t)(&(((TYPE*)0)->MEMBER))`: 结果转换类型。对于32位系统而言，size_t是unsigned int类型；对于64位系统而言，size_t是unsigned long类型。

### 示例

``` C
#include <stdio.h>
#include <stdlib.h>

// 获得结构体(TYPE)的变量成员(MEMBER)在此结构体中的偏移量。
#define offsetof(TYPE, MEMBER) ((size_t) &((TYPE *)0)->MEMBER)

struct student {
    char gender;
    int id;
    int age;
    char name[20];
};

void main()
{
    int gender_offset, id_offset, age_offset, name_offset;

    gender_offset = offsetof(struct student, gender);
    id_offset     = offsetof(struct student, id);
    age_offset    = offsetof(struct student, age);
    name_offset   = offsetof(struct student, name);

    printf("gender_offset = %d\n", gender_offset);
    printf("id_offset = %d\n", id_offset);
    printf("age_offset = %d\n", age_offset);
    printf("name_offset = %d\n", name_offset);
}
```
运行结果:
```
gender_offset = 0
id_offset = 4
age_offset = 8
name_offset = 12
```

### 图解

![list_offsetof](/images/2018/11/list_offsetof.png)

TYPE是结构体，它代表"整体"；而MEMBER是成员，它是整体中的某一部分。

将offsetof看作一个数学问题来看待，问题就相当简单了：
>已知'整体'和该整体中'某一个部分'，而计算该部分在整体中的偏移。

## container_of

根据"结构体(type)变量"中的"域成员变量(member)的指针(ptr)"来获取指向整个结构体变量的指针。
``` C
#define container_of(ptr, type, member) ({          \
        const typeof( ((type *)0)->member ) *__mptr = (ptr);    \
        (type *)( (char *)__mptr - offsetof(type,member) );})
```
>From file:[include/linux/kernel.h](https://elixir.bootlin.com/linux/v4.4.1/source/include/linux/kernel.h#L812)

1. `typeof(((type *)0)->member)`: 取出member成员的变量类型。
2. `const typeof(((type *)0)->member) *__mptr = (ptr)`: 定义变量`__mptr`指针，并将ptr赋值给`__mptr`。经过这一步, `__mptr`为member数据类型的常量指针，其指向ptr所指向的地址。
3. `(char *)__mptr`: 将`__mptr`转换为字节型指针。
4. `offsetof(type,member))`: 就是获取"member成员"在"结构体type"中的位置偏移。
5. `(char *)__mptr - offsetof(type,member))`: 就是用来获取"结构体type"的指针的起始地址（为char *型指针）。
6. `(type *)((char *)__mptr - offsetof(type,member))`: 就是将"char *类型的结构体type的指针"转换为"type *类型的结构体type的指针"。

### 示例

``` C
#include <stdio.h>
#include <stdio.h>
#include <string.h>

// 获得结构体(TYPE)的变量成员(MEMBER)在此结构体中的偏移量。
#define offsetof(TYPE, MEMBER) ((size_t) &((TYPE *)0)->MEMBER)

// 根据"结构体(type)变量"中的"域成员变量(member)的指针(ptr)"来获取指向整个结构体变量的指针
#define container_of(ptr, type, member) ({          \
        const typeof( ((type *)0)->member ) *__mptr = (ptr);    \
        (type *)( (char *)__mptr - offsetof(type,member) );})

struct student {
    char gender;
    int id;
    int age;
    char name[20];
};

void main()
{
    struct student stu;
    struct student *pstu;

    stu.gender = '1';
    stu.id = 9527;
    stu.age = 24;
    strcpy(stu.name, "zhouxingxing");

    // 根据"id地址" 获取 "结构体的地址"。
    pstu = container_of(&stu.id, struct student, id);

    // 根据获取到的结构体student的地址，访问其它成员
    printf("gender= %c\n", pstu->gender);
    printf("age= %d\n", pstu->age);
    printf("name= %s\n", pstu->name);
}
```

运行结果:
```
gender= 1
age= 24
name= zhouxingxing
```

### 图解

![list_container_of](/images/2018/11/list_container_of.png)

type是结构体，它代表"整体"；而member是成员，它是整体中的某一部分，而且member的地址是已知的。
将offsetof看作一个数学问题来看待，问题就相当简单了：
>已知'整体'和该整体中'某一个部分'，要根据该部分的地址，计算出整体的地址。


## 参考

* [Linux内核中双向链表的经典实现](https://www.cnblogs.com/skywang12345/p/3562146.html)
