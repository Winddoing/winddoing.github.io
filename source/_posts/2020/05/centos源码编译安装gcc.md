---
layout: post
title: Centos源码编译安装gcc
date: '2020-05-07 16:45'
tags:
  - gcc
  - centos
categories:
  - 编译工具
---

升级centos中默认的gcc版本

<!--more-->


## 安装依赖包

```shell
yum install -y epel-release
yum install -y gcc gcc-c++ gcc-gnat libgcc libgcc.i686 glibc-devel bison flex texinfo build-essential
```

## 下载gcc源码

>最新的gcc版本：http://ftp.gnu.org/gnu/gcc

``` shell
wget http://ftp.gnu.org/gnu/gcc/gcc-8.2.0/gcc-8.2.0.tar.xz
tar -xJvf gcc-8.2.0.tar.xz
```

## 编译安装

### 下载编译依赖库

``` shell
cd gcc-8.2.0
./contrib/download_prerequisites
```
>需要等一段时间，下载并解压完成，无需手动编译，下面编译时会自动编译安装

### 编译安装

``` shell
cd gcc-8.2.0
./configure --prefix=/usr/local/gcc-8.2.0
make -j 4 && make install
```

## 指定运行库

``` shell
vi /etc/ld.so.conf
```
```
include ld.so.conf.d/*.conf

/usr/local/gcc-8.2.0/lib
```

> 更新运行库文件的缓存：`ldconfig -v`

## scl软件集

### 安装scl源

``` shell
yum install centos-release-scl scl-utils-build
```

### 列出scl有哪些可用软件

``` shell
yum list all --enablerepo='centos-sclo-rh'
```

### 安装gcc8

``` shell
yum install devtoolset-8-gcc.x86_64
```

### 切换版本

``` shell
scl enable devtoolset-4 bash
```

## 参考

- [Centos7.5下源码编译安装gcc-8.2.0](https://www.jianshu.com/p/444169a3721a)
