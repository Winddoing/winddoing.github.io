---
layout: post
title: Centos7内核编译及RPM包的制作
date: '2020-10-10 14:18'
tags:
  - centos
  - Kernel
  - rpm
categories:
  - Linux内核
---

特定内核的编译安装

<!--more-->

## 源码编译安装

``` shell
yum -y groups install "Development Tools"

wget https://mirrors.edge.kernel.org/pub/linux/kernel/v4.x/linux-4.14.105.tar.gz

tar zxvf linux-4.14.105.tar.gz

cp /boot/config-`uname -r` ./linux-4.14.105/.config

cd linux-4.14.105

make menuconfig
make oldconfig

make kernelversion
make -j32 all

make modules_install
# ls -lh /lib/modules

make install
# ls -lh /boot
```
通过以上命令可以完成内核的编译。

>Use the INSTALL_MOD_STRIP option for removing debugging symbols:
> ```shell
> make INSTALL_MOD_STRIP=1 modules_install
> ```

## 打包——RPM

在源码编译的基础上进行rpm包的制作，主要是利用在源码编译阶段生成对内核的配置`.config`文件后，不进行安装而是直接打包。

安装rpm包制作工具：`yum -y install rpmdevtools`

``` shell
make rpm -j32
```
编译完成在`~/rpmbuild/RPMS/x86_64/`目录下生成rpm安装包：
··· shell
ls -lh ~/rpmbuild/RPMS/x86_64/
-rw-r--r-- 1 root root 515M 10月 10 06:28 /root/rpmbuild/RPMS/x86_64/kernel-4.14.105-1.x86_64.rpm
-rw-r--r-- 1 root root 135M 10月 10 06:30 /root/rpmbuild/RPMS/x86_64/kernel-devel-4.14.105-1.x86_64.rpm
-rw-r--r-- 1 root root 1.2M 10月 10 06:28 /root/rpmbuild/RPMS/x86_64/kernel-headers-4.14.105-1.x86_64.rpm
···
> 为啥rpm包这么大，官方rpm包一般五六十兆大小？？？
>>主要是编译生成的`ko`文件增大所致，应该包含了debug信息和符号表
>>```shell
>>make INSTALL_MOD_STRIP=1 rpm
>>```

### 安装

``` shell
yum localinstall kernel-*.rpm
```
或
``` shell
yum install ~/rpmbuild/RPMS/x86_64/kernel-*.rpm
```

## 内核编译命令

编译内核生成`centos rpm`或`ubuntu deb`包

``` shell
make rpm          #生成带源码的RPM包
make rpm-pkg      #生成带源码的RPM包,同上
make binrpm-pkg   #生成包含内核和驱动的RMP包
make deb-pkg      #生成带源码的debian包
make bindeb-pkg   #生成包含内核和驱动的debian包
```
> `rpm-pkg`: 每次编译前会先clean,重复编译会很慢

linux内核`make help`:
```
Kernel packaging:
  rpm-pkg             - Build both source and binary RPM kernel packages
  binrpm-pkg          - Build only the binary kernel RPM package
  deb-pkg             - Build both source and binary deb kernel packages
  bindeb-pkg          - Build only the binary kernel deb package
  tar-pkg             - Build the kernel as an uncompressed tarball
  targz-pkg           - Build the kernel as a gzip compressed tarball
  tarbz2-pkg          - Build the kernel as a bzip2 compressed tarball
  tarxz-pkg           - Build the kernel as a xz compressed tarball
  perf-tar-src-pkg    - Build perf-4.14.105.tar source tarball
  perf-targz-src-pkg  - Build perf-4.14.105.tar.gz source tarball
  perf-tarbz2-src-pkg - Build perf-4.14.105.tar.bz2 source tarball
  perf-tarxz-src-pkg  - Build perf-4.14.105.tar.xz source tarball
```

``` shell
make clean            #删除编译中间文件，但是保留配置
make mrproper         #删除包括配置文件的所有构建文件
make distclean        #执行mrproper所做的一切，并删除备份文件

make menuconfig       #文本图形方式配置内核
make oldconfig        #基于当前的.config文件提示更新内核
make defconfig        #生成默认的内核配置
make allmodconfig     #所有的可选的选项构建成模块
make allyesconfig     #生成全部选择是内核配置
make noconfig         #生成全部选择否的内核配置

make all              #构建所有目标
make bzImage          #构建内核映像
make modules          #构建所有驱动
make dir/             #构建指定目录
make dir/file.[s|o|i] #构建指定文件
make dir/file.ko      #构建指定驱动

make install          #安装内核
make modules_install  #安装驱动

make xmldocs          #生成xml文档
make pdfdocs          #生成pdf文档
maek htmldocs         #生成html文档
```

## 参考

- [我需要内核的源代码](https://wiki.centos.org/zh/HowTos/I_need_the_Kernel_Source)
- [我需要创建一个自设的内核](https://wiki.centos.org/zh/HowTos/Custom_Kernel)
- [Building Source RPM as non-root under CentOS*](http://www.owlriver.com/tips/non-root/)
- [kernel 4.18.18 rpm 制作](https://www.cnblogs.com/wangjq19920210/p/10819541.html)
- [Linux kernel编译指南](https://blog.csdn.net/csujiangyu/article/details/84718750)
