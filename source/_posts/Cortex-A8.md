---
title: Cortex-A8平台实验
date: 2016-09-11 23:07:24
categories: Cortex-A8
tags: [Cortex-A8, uboot, linux, bulidroot, ARM]
---

毕业的时候有把A8板子拿了过来，之前由于没有源程序（光盘丢失找不到资料）对它的开发和实验都一直没有做过，它上面的资源很多不想让它就静静的放着浪费。虽然已经很久没有接触ARM平台了，但是它与MIPS的上层基本原理相似，所以最近想倒腾它，希望可以把linux系统跑起来，也不枉失去它在我手中的价值嘿嘿嘿。在这里简单记录实验的过程和中间的少许思考吧。

<!---more--->

## 实验环境：
* 开发板：Cortex-A8
* 开发系统：Linux machine 4.2.0-27-generic #32~14.04.1-Ubuntu SMP
* ~~uboot：u-boot-2016-07~~
* uboot：u-boot-v2014.07-rc4
* linux：linux-4.0.9
* 文件系统：buildroot
>在实际的操作中可能会有所变动，不断更新

## 交叉编译工具

作为嵌入式开发交叉编译工具链是必不可少的，主要是为了在宿主机（PC）上，开发目标机（arm开发板）中可以运行的程序。

### 下载

这里选择[gcc-arm-none-eabi-5_4-2016q2-20160622-linux.tar.bz2](https://launchpadlibrarian.net/268330503/gcc-arm-none-eabi-5_4-2016q2-20160622-linux.tar.bz2)

### 配置

由于PC中从在多个交叉编译工具链，这里采用脚本envsetup.sh设置，每进入一个终端需要运行其脚本进行配置，方可使用该编译工具链。
``` shell
#!/bin/bash
MY_PWD=`pwd`

PATH=$PATH:$MY_PWD/gcc-arm-none-eabi-5_4-2016q2/bin          
CROSS_COMPILE=arm-none-eabi-

export PATH CROSS_COMPILE

echo $PATH
echo $CROSS_COMPILE
```
设置：
```
source envsetup.sh
```
## uboot移植

### 编译

1. 查找Cortex-A8相关的README，进行参考，全局搜索

``` shell
grep "Cortex-A8" . -rn
```
./doc/README.s5pc1xx中有Cortex-A8的相关说明，结合该文档进行最初的编译。

~~2. 根据README.s5pc1xx的步骤配置编译~~

将出现以下错误：
>lib/asm-offsets.c:1:0: error: bad value (armv5) for -march= switch

出现这个错误的原因是我们没有为uboot指定交叉编译工具链，它依然用自己默认的gcc进行编译，有怎么会找到armv5呢。

~~3. 指定交叉编译工具链~~
``` shell
  CROSS_COMPILE=arm-none-eabi-
  export CROSS_COMPILE
```
为了以后方便使用可将以上两句命令添加到envsetup.sh脚本中。
参考：./README --- 4963 Building the Software:

#### 改变uboot版本

>最新的uboot采用图形界面的配置方式及增加了设备树的配置，由于对这两方面都不太了解尤其设备树，根据自己比较熟悉的使用方式，选择u-boot-v2014.07-rc4。设备树等uboot可以正常启动后在深入学习添加。

#### 选择默认配置编译

1. 选择配置

根据README在boards.cfg选择smdkc100，后续在此基础上进行移植
2. 指定编译器

根据上文（3. 指定交叉编译工具链）即可
3. 编译

```
make smdkc100_config
make
```
顺利编译通过，接下来将添加spl和uboot

#### 添加自己配置

1. 添加配置文件s5pv210.h
        cp include/configs/smdkc100.h include/configs/s5pv210.h

2. 添加编译配置boards.cfg
        Active  arm         armv7          s5pc1xx     samsung   smdkc100   s5pv210      Winddoing <winddoing@sina.cn>

### 添加SPL阶段

在uboot中SPL阶段的控制是通过spl/Makefile中的CONFIG_SPL_BUILD宏控制


## 使用最新的uboot

### 环境

1. 指定编译工具链
```
export CROSS_COMPILE
```
2. 使用相关配置测试工具链
```
$make s5pc210_universal_defconfig
$make -j12
```

### 添加自定义配置

在`s5pc210_universal_defconfig`配置基础上修改。

#### 添加配置文件

1. 拷贝现有相关配置
```
$cp include/configs/s5pc210_universal.h include/configs/s5pc210_a8.h
$cp configs/s5pc210_universal_defconfig configs/s5pc210_a8_defconfig
```
2.添加板级
```
board/samsung/cortex-a8/
configs/s5pc210_a8_defconfig
include/configs/s5pc210_a8.h
```
#### 添加SPL

### 错误
