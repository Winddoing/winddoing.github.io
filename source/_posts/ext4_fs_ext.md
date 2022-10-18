---
title: ext4文件系统扩容
categories:
  - 文件系统
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

```
resize2fs -h
resize2fs 1.44.1 (24-Mar-2018)
Usage: resize2fs [-d debug_flags] [-f] [-F] [-M] [-P] [-p] device [-b|-s|new_size] [-S RAID-stride] [-z undo_file]
```
> $man resize2fs

| 参数 |                   描述                   |
|:----:|:----------------------------------------:|
| `-d` |               打开调试特性               |
| `-f` | 强制执行，覆盖一些通常强制执行的安全检查 |
| `-F` |      执行之前，刷新文件系统的缓冲区      |
| `-M` |          将文件系统缩小到最小值          |
| `-p` |         显示已经完成任务的百分比         |
| `-P` |           显示文件系统的最小值           |

### 显示文件系统最小值

``` shell
resize2fs -P  rootfs.ext4
resize2fs 1.44.1 (24-Mar-2018)
Estimated minimum size of the filesystem: 5161
```

### 文件系统扩展容量：

``` shell
resize2fs system.ext4 300000
resize2fs system.ext4 300M
```
> 文件系统大小: 300MB，单位可以使用`k`、`M`、`G`

## 容量扩展

### 创建空的文件系统

``` shell
dd if=/dev/zero of=new_roofs.ext4 bs=1M count=300
mkfs.ext4 new_roofs.ext4
```
>文件系统大小：300M

### 现有文件系统的拷贝

``` shell
mount -t ext4 roofs.ext4 tmp
mount -t ext4 new_roofs.ext4 tmp1
cp tmp/* tmp1 -arpdf
```
