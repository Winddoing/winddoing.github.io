---
layout: post
title: Linux内核工具--Sparse
date: '2018-12-05 16:22'
tags:
  - linux
categories:
  - Linux内核
  - 工具
abbrlink: 22743
---

Sparse诞生于2004年，是由Linux之父开发的，目的就是提供一个静态检查代码的工具，从而减少Linux内核的隐患。起始，在Sparse之前已经有了一个不错的代码静态检查工具（SWAT），只不过这个工具不是免费软件，使用上有一些限制。所以Linus自己开发了一个静态检查工具。

>版本: linux4.4.166
>
>参考文档:[Documentation/sparse.txt](https://elixir.bootlin.com/linux/v4.4.166/source/Documentation/sparse.txt)

<!--more-->

Sparse通过gcc的扩展属性`__attribute__`以及自己定义的`__context__`来对代码进行静态检查。

> `__xxx`双下划线开头的宏,表示编译器相关的一些属性设置

``` C
#ifdef __CHECKER__
# define __user     __attribute__((noderef, address_space(1)))
# define __kernel   __attribute__((address_space(0)))
# define __safe     __attribute__((safe))
# define __force    __attribute__((force))
# define __nocast   __attribute__((nocast))
# define __iomem    __attribute__((noderef, address_space(2)))
# define __must_hold(x) __attribute__((context(x,1,1)))
# define __acquires(x)  __attribute__((context(x,0,1)))
# define __releases(x)  __attribute__((context(x,1,0)))
# define __acquire(x)   __context__(x,1)
# define __release(x)   __context__(x,-1)
# define __cond_lock(x,c)   ((c) ? ({ __acquire(x); 1; }) : 0)
# define __percpu   __attribute__((noderef, address_space(3)))
# define __pmem     __attribute__((noderef, address_space(5)))
#ifdef CONFIG_SPARSE_RCU_POINTER
# define __rcu      __attribute__((noderef, address_space(4)))
#else
# define __rcu
#endif
extern void __chk_user_ptr(const volatile void __user *);
extern void __chk_io_ptr(const volatile void __iomem *);
#else
```
> file: include/linux/compiler.h

``` C
#ifdef __CHECKER__
#define __bitwise__ __attribute__((bitwise))
#else
#define __bitwise__
#endif
#ifdef __CHECK_ENDIAN__
#define __bitwise __bitwise__
#else
#define __bitwise
#endif
```
>file: tools/include/linux/types.h


|      宏名称      |                     定义                     |                            说明                            |
|:----------------:|:--------------------------------------------:|:----------------------------------------------------------:|
|    __bitwise     |          `__attribute__((bitwise))`          | 确保变量是相同的位方式(比如 bit-endian, little-endiandeng) |
|      __user      | `__attribute__((noderef, address_space(1)))` |                 指针地址必须在用户地址空间                 |
|     __kernel     | `__attribute__((noderef, address_space(0)))` |                 指针地址必须在内核地址空间                 |
|     __iomem      | `__attribute__((noderef, address_space(2)))` |                 指针地址必须在设备地址空间                 |
|      __safe      |           `__attribute__((safe))`            |                        变量可以为空                        |
|     __force      |           `__attribute__((force))`           |                    变量可以进行强制转换                    |
|     __nocast     |          `__attribute__((nocast))`           |               参数类型与实际参数类型必须一致               |
|  __acquires(x)   |     `__attribute__((context(x, 0, 1)))`      |    参数x 在执行前引用计数必须是0,执行后,引用计数必须为1    |
|  __releases(x)   |     `__attribute__((context(x, 1, 0)))`      |                    与__acquires(x)相反                     |
|   __acquire(x)   |             `__context__(x, 1)`              |                     参数x的引用计数+1                      |
|   __release(x)   |             `__context__(x, 1)`              |                     与__acquire(x)相反                     |
| __cond_lock(x,c) |     `((c) ? ({ __acquire(x); 1; }) : 0)`     |            参数c 不为0时,引用计数 + 1, 并返回1             |


>其中`__acquires(x)`和`__releases(x)`，`__acquire(x)`和`__release(x)`必须配对使用,都和`锁`有关，否则Sparse会发出警告


## Sparse 在编译内核中的使用

```
make C=1 检查所有重新编译的代码
make C=2 检查所有代码, 不管是不是被重新编译
```
> 如果进行`-Wbitwise`的检查,需要定义`#define __CHECK_ENDIAN__`,可以通过`CF`进行传参
> ```
>  make C=2 CF="-D__CHECK_ENDIAN__"
> ```

## 示例

``` C
static int
fb_open(struct inode *inode, struct file *file)
__acquires(&info->lock)
__releases(&info->lock)
{
    ...
    return 0;
}
```
在编译阶段检查锁,防止死锁.


## 参考

* [内核工具 – Sparse 简介](https://www.cnblogs.com/wang_yb/p/3575039.html)
* [what-does-static-int-function-acquires-releases-mean](https://stackoverflow.com/questions/21018778/what-does-static-int-function-acquires-releases-mean)
