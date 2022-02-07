---
layout: post
title: TestDisk
date: '2022-02-07 10:06'
tags:
  - TestDisk
  - 分区
  - 磁盘恢复
categories:
  - 工具
---

`TestDisk`是一款强大的免费数据恢复软件! 早期主要是设计用来在使用有缺陷的软件，病毒或人为误操作（如不小心删除分区表）导致的分区丢失后，帮助用户恢复丢失分区，或修复不能启动的磁盘。 用Testdisk来恢复分区表非常简单。

> https://www.cgsecurity.org/wiki/TestDisk_CN

<!--more-->

TestDisk支持以下功能:

- 修复分区表, 恢复已删除分区
- 用FAT32备份表恢复启动扇区
- 重建FAT12/FAT16/FAT32启动扇区
- 修复FAT表
- 重建NTFS启动扇区
- 用备份表恢复NTFS启动扇区
- 用MFT镜像表(MFT Mirror)修复MFT表
- 查找ext2/ext3/ext4备份的SuperBlock
- 从FAT,NTFS及ext2文件系统恢复删除文件
- 从已删除的FAT,NTFS及ext2/ext3/ext4分区复制文件.

## 应用

通过dd误将磁盘分区表删除后，使用TestDisk进行了恢复，数据均正常。注意我的数据恢复是在知道误删除后，直接进行恢复，如果是重启了就会使系统无法启动，这个工具可能就无法用了。

## 参考

- [TestDisk 数据恢复 重建分区表恢复文件-恢复diskpart clean ](https://www.cnblogs.com/findumars/p/7192291.html)
