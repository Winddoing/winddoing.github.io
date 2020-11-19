---
layout: post
title: ARM--GCC内嵌汇编
date: '2018-12-14 10:02'
tags:
  - arm
  - 汇编
categories:
  - arm
  - 汇编
abbrlink: 4526
---

记录ARM平台中相关的汇编操作和总结

<!--more-->

## 空指令--nop

NOP指令`不产生任何意义的操作`,只占用一个机器周期,可以用于简单的延时操作

``` C
asm("nop");
```
> 在C代码中可以通过前后使用`nop`定位反汇编后代码所在的位置.

实际编程的用途:

1. 需要短暂延时
2. 需要精确控制延时,如控制驱动器步进电机的延时
3. 通过在写NOP指令处填写相应代码实现分支跳转或分支调用???
4. 解密时用???
5. 在控制系统中插入NOP指令防止系统飞程???









## 参考

* [NOP 指令作用](https://blog.csdn.net/erazy0/article/details/6071281)
