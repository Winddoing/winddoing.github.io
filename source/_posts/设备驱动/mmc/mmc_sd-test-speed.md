---
title: sd卡测速
categories:
  - 设备驱动
  - mmc
tags:
  - mmc
  - sd
  - dd
abbrlink: 11560
date: 2016-10-12 23:07:24
---

测试sd卡的读写速度

<!--- more --->
## mmc驱动测速

结合mmc子系统提供的测试列表进行速度测试和其他相关测试。

### 添加配置

```
->DeviceDriver
    -> MMC/SD/SDIO card support (MMC [=y])
    [*]MMC host test driver
```

### 绑定

编译并启动新编译的linux内核，进入文件系统。
* 进入mmcblk解除绑定

```
cd sys/bus/mmc/drivers/mmcblk
echo mmc0:e624 > unbind
```

* 绑定测试

```
cd sys/bus/mmc/drivers/mmc_test
echo mmc0:e624 > bind
[  17.243808] mmc_test mmc0:e624: Card claimed for testing.
```

### 挂载debugfs

```
# mount -t debugfs none /mnt
```

### 测试

* 进入测试目录mmc0:e624

```
cd /mnt/mmc0/mmc0:e624
```

* 查看测试列表

```
#cat testlist
	1:      Basic write (no data verification)
	2:      Basic read (no data verification)
	3:      Basic write (with data verification)
	4:      Basic read (with data verification)
	5:      Multi-block write
	6:      Multi-block read
	7:      Power of two block writes
	8:      Power of two block reads
	9:      Weird sized block writes
	10:     Weird sized block reads
	11:     Badly aligned write
	12:     Badly aligned read
	13:     Badly aligned multi-block write
	14:     Badly aligned multi-block read
	15:     Correct xfer_size at write (start failure)
	16:     Correct xfer_size at read (start failure)
	17:     Correct xfer_size at write (midway failure)
	18:     Correct xfer_size at read (midway failure)
	19:     Highmem write
	20:     Highmem read
	21:     Multi-block highmem write
	22:     Multi-block highmem read
	23:     Best-case read performance
	24:     Best-case write performance
	25:     Best-case read performance into scattered pages
	26:     Best-case write performance from scattered pages
	27:     Single read performance by transfer size
	28:     Single write performance by transfer size
	29:     Single trim performance by transfer size
	30:     Consecutive read performance by transfer size
	31:     Consecutive write performance by transfer size
	32:     Consecutive trim performance by transfer size
	33:     Random read performance by transfer size
	34:     Random write performance by transfer size
	35:     Large sequential read into scattered pages
	36:     Large sequential write from scattered pages
	37:     Write performance with blocking req 4k to 4MB
	38:     Write performance with non-blocking req 4k to 4MB
	39:     Read performance with blocking req 4k to 4MB
	40:     Read performance with non-blocking req 4k to 4MB
	41:     Write performance blocking req 1 to 512 sg elems
	42:     Write performance non-blocking req 1 to 512 sg elems
	43:     Read performance blocking req 1 to 512 sg elems
	44:     Read performance non-blocking req 1 to 512 sg elems
	45:     eMMC hardware reset
```

* 执行测试

```
	echo 34 > test
```

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

## 总结

读写速率和以下情况有关：
1. 外部通信时钟；
2. DDR时钟，
3. 代码运行速率，和CPU时钟、L2CACHE时钟有关
4. 当前系统负荷
5. 内部的总线时钟，比如MMC控制器所在的APB总线等
6. MMC控制器的DMA工作时钟
7. 读写代码的流程
8. MSC的通信数据线的位数
9. 读写的位置是否连续。

其中瓶颈是在（1）SD的通信速率（7）代码的流程（8）SD卡通信所占用的数据线（9）读写的位置是否连续
