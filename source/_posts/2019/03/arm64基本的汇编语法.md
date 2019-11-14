---
layout: post
title: ARM64基本的汇编语法
date: '2019-03-13 14:27'
tags:
  - ARM
categories:
  - ARM
  - 汇编
abbrlink: 5543
---

记录常用到的arm64汇编语法，参考[libjpeg-turbo](https://github.com/libjpeg-turbo/libjpeg-turbo/blob/master/simd/arm64/jsimd_neon.S)

<!--more-->

## 常见语法

|   语法    | 说明                                                     | 备注/示例                                                                                                  |
|:---------:|:---------------------------------------------------------|:-----------------------------------------------------------------------------------------------------------|
|  `.req`   | 寄存器重命名                                             | DATA .req x0： DATA是寄存器x0的别名                                                                        |
| `.unreq`  | 取消重命名定义                                           | .unreq DATA                                                                                                |
| `.balign` | 字节对其                                                 | .balign 16 ：十六字节对其                                                                                  |
|    `b`    | 跳转到标号处执行                                         | b   40 <main+0x40>                                                                                         |
|   `cmp`   | 比较                                                     | cmp w0, #0x6e， 不会改变两个寄存器的值即两个寄存器不会变化，但是其结果会影响cpsr状态寄存器的标记值（nzcv） |
|  `b.le`   | 小于等于（less than or equal to），执行标号，否则不跳转  | b.le    24 <main+0x24>                                                                                     |
|  `b.ge`   | 大于等于（great than or equal to），执行标号，否则不跳转 |                                                                                                            |
|  `b.gt`   | 大于（greater than），执行标号，否则不跳转               |                                                                                                            |
|  `b.lt`   | 小于（less than），执行标号，否则不跳转                  |                                                                                                            |
|  `b.eq`   | 等于（equal to），执行标号，否则不跳转                   |                                                                                                            |
|  `b.hi`   | 无符号大于，执行标号，否则不跳转                         |                                                                                                            |
## 示例

## 参考

* [GNU AS汇编器官方文档](http://sourceware.org/binutils/docs/as/)
