---
title: QEMU的环境搭建
categories: 常用工具
tags:
  - qemu
abbrlink: 1912
date: 2018-01-21 23:07:24
---

## 编译

```
./configure --prefix=/PATH/TO/INSTALL --target-list=mipsel-softmmu,mipsel-linux-user --tscm=32
make -j4
make install
```
> --prefix=/PATH/TO/INSTALL为绝对路径

<!--more-->

## 下载

```
git clone http://git1.ingenic.cn:8082/gerrit/Manhattan/platform/development/tools/qemu
```
>MIPS架构进行x1000和x2000的模拟

## 使用

### QEMU system 模式

```shell
#!/bin/bash
QEMU_PATH=/PATH/TO/INSTALL/bin          #QEMU的安装路径
QEMU=qemu-system-mipsel
rootfs=/PATH/TO/rootfs.cpio.gz                  #要启动的文件系统
kernel=/PATH/TO/vmlinux                 #要启动的kernel

echo "
-----------------------------
- Xburst1 X1000 is booting $1 rootfs
----------------------------
"
$QEMU_PATH/${QEMU} \
	-M phoenix -cpu xburst1-x1000 \
	-kernel ${kernel} \
	-append "console=ttyS1,57600n8 rdinit=/linuxrc root=/dev/ram0 rw mem=256M@0x0 mem=768M@0x30000000" \
	-initrd ${rootfs} \
	-serial /dev/tty -serial /dev/tty \
	-nographic \
	-net nic,model=rtl8139 \
	-net user,hostfwd=tcp::2030-:22,hostfwd=tcp::2089-:80
					#定义的ssh端口号         #定义的http的端口号
```

## 参考

1. [ubuntu14.04 64位兼容32位方法](http://blog.csdn.net/lzpdz/article/details/50352299)
