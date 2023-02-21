---
title: Android ART编译预优化
categories:
  - Android
  - android
tags:
  - android
abbrlink: 40126
date: 2018-02-02 23:07:24
---

```
# Enable dex-preoptimization to speed up the first boot sequence
# of an SDK AVD. Note that this operation only works on Linux for now
ifeq ($(HOST_OS),linux)
	ifeq ($(WITH_DEXPREOPT),)
		WITH_DEXPREOPT := true
	endif
endif
```
>device/xxx/xxx/BoardConfig.mk

| WITH_DEXPREOPT |      |
| :------------: | :--: |
| true	| system image 就会被预先优化. 由于在启动时不再需要进行app的dex文件进行优化(dex2oat操作)从而提升其启动速度.|
| false | 禁止预编译优化，在系统启动时编译|

<!--more-->


## ART

ART兼容Dalvik.也就是说ART 能运行”dex”(Dalvik执行文件).因此对Androidapp的开发者来说,他们没有什么区别.两者最大的区别是:ART把JIT(Just-in-Time)变成了AOT(Ahead-of-Time).JIT需要在每次运行app时都需要执行一遍,而AOT 只需要执行一次,而后续再运行此app是不需要再执行,其明显提高了性能.当然ART 这样做,也是有代价的,那就是以空间换时间.ART能对应用的所有code做优化,其把bitcode 编译为ELF文件.而ELF文件也往往比odex文件大很多.而JIT
只能对local/method做优化.ART的另一个缺点是其第一次执行优化时需要更长的时间.这也是导致第一次开机时间过长的原因

## dex2oat

`dex2oat`顾名思义dex file to oat file，就是在新旧两种运行时文件的转换。

> `dex`文件字节码，（多个class每个文件都有的共有信息合成一体）
> `oat`文件格式:ELF

## 好处

1. 优化开机速度，减少启动时间(不是第一次)



## 参考

1. [Android 开机速度优化-----ART 预先优化](http://blog.csdn.net/u010164190/article/details/51463492)
