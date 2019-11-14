---
title: ext4文件系统扩容
categories: 文件系统
tags:
  - 文件系统
  - ext4
abbrlink: 38978
date: 2017-10-29 23:07:24
---

ext4文件系统在制作时，已将大小进行固定，但是在实际的使用过程中，由于后续的测试和使用导致文件系统的空间不足，而同时有不想重新进行文件系统的制作，只是单纯的进行容量的扩展

<!--more-->

## 查看现有ext4文件系统

```
mount -t ext4 roofs.ext4 tmp
```

## resize2fs

文件系统扩展容量：

```
resize2fs system.ext4 300000
```
> 文件系统大小: 300MB

## 容量扩展

### 创建空的文件系统

```
dd if=/dev/zero of=new_roofs.ext4 bs=1M count=300
mkfs.ext4 new_roofs.ext4
```
>文件系统大小：300M

### 现有文件系统的拷贝

```
mount -t ext4 roofs.ext4 tmp
mount -t ext4 new_roofs.ext4 tmp1
cp tmp/* tmp1 -arpdf
```
