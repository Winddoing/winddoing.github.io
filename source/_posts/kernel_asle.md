---
title: ASLR
categories: 计算机系统
tags:
  - 进程
  - ASLR
abbrlink: 4177
date: 2018-01-17 23:22:24
---

>`ASLR`（Address space layout randomization）是一种针对缓冲区溢出的安全保护技术，通过对堆、栈、共享库映射等线性区布局的随机化，通过增加攻击者预测目的地址的难度，防止攻击者直接定位攻击代码位置，达到阻止溢出攻击的目的。

<!--more-->

## 控制接口

``` C
/proc/sys/kernel/randomize_va_space
```

`randomize_va_space`的属性：

| randomize_va_space |   作用   |
| :-----------------:| :------: |
| 0 | 关闭 |
| 1 | `mmap base`、`stack`、`vdso page`将随机化。这意味着.so文件将被加载到随机地址。链接时指定了`-pie`选项的可执行程序，其代码段加载地址将被随机化。randomize_va_space缺省为1。此时heap没有随机化|
| 2 | 在1的基础上增加了`heap`随机化。配置内核时如果禁用`CONFIG_COMPAT_BRK`，randomize_va_space缺省为2。|

## 操作

### 查看

```
cat  /proc/sys/kernel/randomize_va_space
```

```
sysctl -n kernel.randomize_va_space
```
### 设置（关闭）

```
echo 0 > /proc/sys/kernel/randomize_va_space
```

```
sysctl -w kernel.randomize_va_space=0
```

## 参考

*[地址空间布局随机化(ASLR)增强研究综述](https://www.inforsec.org/wp/?p=1009)
*[Remix: On-demand Live Randomization](http://ww2.cs.fsu.edu/~ychen/paper/Remix_slides.pdf)
