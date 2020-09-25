---
layout: post
title: linux下硬盘检查
date: '2020-05-23 23:01'
tags:
  - 硬盘
  - 系统
categories:
  - 工具
abbrlink: f6f2a529
---

通过`hdparm`、`smartctl`、`badblocks`等命令，获取硬盘详细信息和测试硬盘读取速度等

<!--more-->

## hdparm

> 可检测，显示与设定IDE或SCSI硬盘的参数

![tool_hdparm_cmd](/images/2020/05/tool_hdparm_cmd.png)
**hdparm的改变的配置是个临时的状态，下次启动Linux系统的时候hdparm的配置将会消失，如果需要必须加入开机启动脚本``**

```shell
$sudo hdparm  /dev/sdb

/dev/sdb:
 multcount     = 16 (on)
 IO_support    =  1 (32-bit)
 readonly      =  0 (off)
 readahead     = 256 (on)
 geometry      = 121601/255/63, sectors = 1953525168, start = 0
```

### 测试读取速度

```shell
$sudo hdparm -tT /dev/sdb

/dev/sdb:
 Timing cached reads:   9084 MB in  1.99 seconds = 4560.73 MB/sec
 Timing buffered disk reads: 418 MB in  3.01 seconds = 139.02 MB/sec
```

### 检测硬盘的电源管理模式

```shell
$sudo hdparm -C /dev/sdb

/dev/sdb:
 drive state is:  active/idle
```

### 进入省电模式

```shell
$sudo hdparm -Y /dev/sdb

/dev/sdb:
 issuing sleep command
```
### 设置硬盘省电策略

``` shell
$sudo hdparm -S 60 /dev/sdb

/dev/sdb:
 setting standby to 60 (5 minutes)
```
> 在无数据访问后，5分钟硬盘自动停转进入休眠模式

**`0`表示“超时已禁用”：设备不会自动进入待机模式。从1到240指定5秒的倍数，产生5秒到20分钟的超时。**

## smartctl

> `SMART`是一种磁盘自我分析检测技术

### 获取硬盘详细信息

``` shell
$sudo smartctl -i /dev/sdb
smartctl 7.1 2019-12-30 r5022 [x86_64-linux-5.4.0-31-generic] (local build)
Copyright (C) 2002-19, Bruce Allen, Christian Franke, www.smartmontools.org

=== START OF INFORMATION SECTION ===
Device Model:     TOSHIBA MQ04ABF100
Serial Number:    30IAP8ZKT
LU WWN Device Id: 5 000039 9e26062ca
Firmware Version: JU002U
User Capacity:    1,000,204,886,016 bytes [1.00 TB]
Sector Sizes:     512 bytes logical, 4096 bytes physical
Rotation Rate:    5400 rpm
Form Factor:      2.5 inches
Device is:        Not in smartctl database [for details use: -P showall]
ATA Version is:   ACS-3 T13/2161-D revision 5
SATA Version is:  SATA 3.3, 3.0 Gb/s (current: 3.0 Gb/s)
Local Time is:    Sat May 23 23:36:34 2020 CST
SMART support is: Available - device has SMART capability.
SMART support is: Enabled
```

## badblocks

> 检查磁盘装置中损坏的区块

### 坏道检查

``` shell
$sudo badblocks -s -v /dev/sdb
Checking blocks 0 to 976762583
Checking for bad blocks (read-only test): done
Pass completed, 0 bad blocks found. (0/0/0 errors)
```
- `-s`: 在检查时显示进度
- `-v`: 执行时显示详细的信息
