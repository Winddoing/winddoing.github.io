---
layout: post
title: Linux中systemd的日志管理——journalctl
date: '2019-09-06 13:54'
tags:
  - log
categories:
  - 系统服务
---

`Systemd`统一管理所有linux的启动日志。带来的好处就是，可以只用`journalctl`一个命令，查看所有日志（内核日志和应用日志）。日志的配置文件`/etc/systemd/journald.conf`

<!--more-->

## 配置

>配置文件：`/etc/systemd/journald.conf`

```
[Journal]
#Storage=auto
#Compress=yes
#Seal=yes
#SplitMode=uid
#SyncIntervalSec=5m
#RateLimitIntervalSec=30s
#RateLimitBurst=1000
//指定journal所能使用的最高持久存储容量。
#SystemMaxUse=
//指定journal在添加新条目时需要保留的剩余空间。
#SystemKeepFree=
//控制单一journal文件大小，符合要求方可被转为持久存储。
#SystemMaxFileSize=
#SystemMaxFiles=100
//指定易失性存储中的最大可用磁盘容量（/run文件系统之内）
#RuntimeMaxUse=
//指定向易失性存储内写入数据时为其它应用保留的空间量（/run文件系统之内）
#RuntimeKeepFree=
//指定单一journal文件可占用的最大易失性存储容量（/run文件系统之内）
#RuntimeMaxFileSize=
#RuntimeMaxFiles=100
#MaxRetentionSec=
#MaxFileSec=1month
#ForwardToSyslog=yes
#ForwardToKMsg=no
#ForwardToConsole=no
#ForwardToWall=yes
#TTYPath=/dev/console
#MaxLevelStore=debug
#MaxLevelSyslog=debug
#MaxLevelKMsg=notice
#MaxLevelConsole=info
#MaxLevelWall=emerg
#LineMax=48K
```
- [Journal service configuration files](https://www.freedesktop.org/software/systemd/man/journald.conf.html)

### 把日志保存到文件中

- 方法1： 创建目录`/var/log/journal`，然后重启日志服务`systemd-journald.service`
  ``` shell
  sudo mkdir -p /var/log/journal
  ```
- 方法2： 修改配置文件`/etc/systemd/journald.conf`，把`Storage=auto`改为`Storage=persistent`，并取消注释，然后重启日志服务`systemd-journald.service`

  ``` shell
  sudo systemctl restart systemd-journald
  ```

## 参数

``` shell
$journalctl -h
```
或
``` shell
$man journalctl
```

## 常见用法

### 查看所有日志（默认情况下 ，只保存本次启动的日志）

``` shell
$journalctl
```

### 查看当前最后一次启动后日志

``` shell
$journalctl -xb
```
> `-x`: 使用消息目录中的说明文本扩充日志行
> `-b`: 参数为空时，将显示当前引导的日志

### 查看内核日志（不显示应用日志）

``` shell
$journalctl -k
```

### 查看系统本次启动的日志

``` shell
$journalctl -b
```

### 查看某次启动后的日志

默认情况下`systemd-journald`服务只保存本次启动后的日志(重新启动后丢掉以前的日志)。此时`-b`选项是没啥用的。当我们把`systemd-journald`服务收集到的日志保存到文件中之后，就可以通过下面的命令查看系统的重启记录：

``` shell
$journalctl --list-boots
-82 672e675b37f74b72b2900c13743675e9 Mon 2019-03-18 11:11:20 CST—Fri 2019-03-22 09:17:58 CST
-81 f857b21a80db4be3acfdf7d04247e4bd Fri 2019-03-22 09:18:44 CST—Fri 2019-03-22 18:13:10 CST
-80 ee3d23ea84434be2b7d6a6353733e37c Sat 2019-03-23 11:23:40 CST—Sat 2019-03-23 13:28:06 CST
```
通过`-b`选项来选择查看某次运行过程中的日志:
``` shell
$journalctl -b -82
或
$journalctl -b 672e675b37f74b72b2900c13743675e9
```

### 查看指定时间段的日志

利用`--since`与`--until`选项设定时间段，二者分别负责指定给定时间之前与之后的日志记录。时间值可以使用多种格式，比如下面的格式：

```
YYYY-MM-DD HH:MM:SS
```

如果我们要查询2018年3月26日下午8:20之后的日志：

``` shell
$journalctl --since "2018-03-26 20:20:00"
```

### 通过日志级别进行过滤

除了通过`PRIORITY=`的方式，还可以通过`-p`选项来过滤日志的级别。 可以指定的优先级如下：

| 优先级 |  名称   |      严重性      |
|:------:|:-------:|:----------------:|
|   0    |  emerg  |    系统不可用    |
|   1    |  alert  | 必须立即采取措施 |
|   2    |  crit   |     严重状况     |
|   3    |   err   |  非严重错误状况  |
|   4    | warning |     警告状况     |
|   5    | notice  | 正常但重要的事件 |
|   6    |  info   |    信息性事件    |
|   7    |  debug  |   调试级别消息   |

``` shell
$journalctl -p err
```

### 实时更新日志

``` shell
$journalctl -f
```

### 按可执行文件的路径过滤

``` shell
$journalctl /bin/bash
```

### 查看指定应用日志

``` shell
$journalctl -t sshd
```

## 维护

### 查看当前日志占用磁盘的空间的总大小

``` shell
$journalctl --disk-usage
Archived and active journals take up 3.9G in the file system.
```

### 指定日志文件最大空间

``` shell
$journalctl --vacuum-size=1G
```

### 指定日志文件保存多久

``` shell
$journalctl --vacuum-time=1years
```

### 检查journal是否运行正常以及日志文件是否完整无损坏

``` shell
$journalctl --verify
```

## 参考

- [journalctl 中文手册](http://www.jinbuguo.com/systemd/journalctl.html)
