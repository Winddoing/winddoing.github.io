---
title: QEMU的环境搭建
date: 2018-01-21 23:07:24
categories: 常用工具
tags: [qemu]
---

## 编译

```
./configure --prefix=./install --target-list=mipsel-softmmu,mipsel-linux-user
```

<!--more-->

## 下载

```
git clone http://git1.ingenic.cn:8082/gerrit/Manhattan/platform/development/tools/qemu
```
>MIPS架构进行x1000和x2000的模拟 

## 使用

## 参考

1. [ubuntu14.04 64位兼容32位方法](http://blog.csdn.net/lzpdz/article/details/50352299)
