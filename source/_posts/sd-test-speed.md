---
title: sd卡测速
date: 2016-10-12 23:07:24
categories: MMC
tags: [MMC, SD, dd]
---

测试sd卡的读写速度

<!--- more --->

## 测试命令  dd

```
dd if=/dev/zero of=/dev/null
```

* 输入或输出

>dd if=[STDIN] of=[STDOUT]

* 强迫输入或输出的Size为多少Bytes

>bs: dd -ibs=[BYTE] -obs=[SIZE]

* 强迫一次只做多少个 Bytes

>bs=BYTES

* 跳过一段以后才输出

>seek=BLOCKS

* 跳过一段以后才输入

>skip=BLOCKS

### 写测试

```
dd if=/dev/zero of=/mnt/sd/test.txt bs=512 count=100

```
写数据量：512*100 / 1024 = 50Kb
### 读测试

```
dd if=/mnt/sd/test.txt of=/dev/null bs=512 count=100

```
读数据量：512*100 / 1024 = 50Kb

## PC测试

在pc上使用以上命令，将读写的目标改为（/dev/sdb）即可得到当前的读写速度

## 开发板测试

由于在开发板中的文件系统使用busybox编译生成，其中的dd命令无法直接得到读写速度，因此需要结合time命令

### 写测试

```
time dd if=/dev/zero of=/mnt/sd/test.txt bs=512 count=100

```
写数据量：512*100 / 1024 = 50Kb
### 读测试

```
time dd if=/mnt/sd/test.txt of=/dev/null bs=512 count=100

```
读数据量：512*100 / 1024 = 50Kb

### 注意事项

1. 在对sd进行测速时，使用以上命令进行读写操作，文件系统会将该数据块进行一定大小（128个block为一个单元，即一个request请求）的分割，并将其传入sd驱动。在mmc驱动中配置msc控制器的block count大小时，其值为VFS层传入的128blk。

也就是说一个大于128个block数据块的读写，在mmc驱动中使用若干个request请求进行读写操作完成。

2. 写测试增加conv=fsync参数

该参数可通过dd -h查看，作用将写的数据完全写入到sd完成返回，但是使用后根据写操作所得到的时间计算的写速度将降低
主要原因是，使用fsync后文件系统会将写的数据块根据bs的大小进行分割，也就是将其分割成count个bs。如果bs为512时，一次request请求的block count为512，加大了request请求次数，同时将增加sd驱动中的中断次数和读及等状态的次数，继而增大了写操作的时间，最后计算的写速度将降低。
