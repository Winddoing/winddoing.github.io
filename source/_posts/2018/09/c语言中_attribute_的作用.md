---
layout: post
title: C语言中__attribute__的作用
date: '2018-09-12 11:24'
tags:
  - gcc
categories:
  - 程序设计
---

``` C
struct __attribute__ ((__packed__)) sc3 {
    char a;
    char *b;
};
```
> `attribute`：属性，主要是用来在`函数`或`数据声明`中设置其属性,与编译器相关

GNU C的一大特色就是`__attribute__`机制。`__attribute__`可以设置`函数属性（Function Attribute）`、`变量属性（Variable Attribute）`和`类型属性（Type Attribute）`。

- 语法格式：
```
__attribute__ ((attribute-list))
```

<!--more-->

## attribute

* 数据声明：
    - `__attribute__ ((packed))`: 的作用就是告诉编译器取消结构在编译过程中的优化对齐,按照实际占用字节数进行对齐，是GCC特有的语法。
    - `__attribute__((aligned(n)))`: 内存对齐，指定内存对齐n字节
* 函数声明：
    - `__attribute__((noreturn))`: 的作用告诉编译器这个函数不会返回给调用者，以便编译器在优化时去掉不必要的函数返回代码。
    - `__attribute__((weak))`: 虚函数，弱符号


## 用法

### packed

``` C
struct sc1 {
    char a;
    char *b;
};
printf("sc1: sizeof-char*  = %ld\n", sizeof(struct sc1));

struct __attribute__ ((__packed__)) sc3 {
    char a;
    char *b;
};
printf("sc3: packed sizeof-char*  = %ld\n", sizeof(struct sc3));
```
- 运行结果：
```
sc1: sizeof-char*  = 16
sc3: packed sizeof-char*  = 9
```

该属性可以使得变量或者结构体成员使用最小的对齐方式，即对变量是一字节对齐，对域（field）是位对齐。

### aligned(n)

``` C
struct __attribute__ ((aligned(4))) sc5 {
    char a;
    char *b;
};
struct __attribute__ ((aligned(4))) sc6 {
    char a;
    char b[];
};
printf("sc5: aligned 4 sizeof-char*  = %ld\n", sizeof(struct sc5));
printf("sc6: aligned 4 sizeof-char[] = %ld\n", sizeof(struct sc6));


struct __attribute__ ((aligned(2))) sc7 {
    char a;
    char *b;
};
struct __attribute__ ((aligned(2))) sc8 {
    char a;
    char b[];
};
printf("sc7: aligned 2 sizeof-char*  = %ld\n", sizeof(struct sc7));
printf("sc8: aligned 2 sizeof-char[] = %ld\n", sizeof(struct sc8));
```

* 运行结果：
```
sc5: aligned 4 sizeof-char*  = 16
sc6: aligned 4 sizeof-char[] = 4
sc7: aligned 2 sizeof-char*  = 16
sc8: aligned 2 sizeof-char[] = 2
```

### noreturn

>This attribute tells the compiler that the function won't ever return, and this can be used to suppress errors about code paths not being reached. The C library functions abort() and exit() are both declared with this attribute:

``` C
extern void exit(int)   __attribute__((noreturn));
extern void abort(void) __attribute__((noreturn));
```
函数不会返回。

### weak

``` C
int  __attribute__((weak))  func(...)
{
    ...
    return 0;
}
```

>func转成`弱符号类型`
- 如果遇到`强符号类型`（即外部模块定义了func, `extern int func(void);`），那么我们在本模块执行的func将会是外部模块定义的func。
- 如果外部模块没有定义，那么将会调用这个弱符号，也就是在本地定义的func，直接返回了一个1（返回值视具体情况而定）相当于增加了一个`默认函数`。

**原理**：`链接器`发现同时存在`弱符号`和`强符号`，就先选择强符号，如果发现不存在强符号，只存在弱符号，则选择弱符号。如果都不存在：静态链接，恭喜，编译时报错，动态链接：对不起，系统无法启动。

> weak属性只会在静态库(.o .a )中生效，动态库(.so)中不会生效。

## 参考

* [#define PACK_STRUCT _attribute_ ((_packed_))编译器按字独立分配](https://blog.csdn.net/wangzhaotongalex/article/details/22729215)
