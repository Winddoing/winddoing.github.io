---
layout: post
title: Android Systrace
date: '2021-01-23 14:27'
tags:
  - android
  - systrace
categories:
  - Android
abbrlink: 7f0df936
---

Android性能分析工具

<!--more-->

## 下载android-sdk-platform-tools

> https://developer.android.google.cn/studio/releases/platform-tools?hl=zh-cn

解压后直接使用

## 获取systrace日志并转换为html

``` shell
#!/bin/bash
ip="127.0.0.1"
port="5555"

TRACE_BUFFER_SZ_KB=16384 #16MB
TRACE_FILE="/data/local/tmp/trace_$port.log"

adb disconnect
adb connect $ip:$port
adb root

sleep 1

# adb shell atrace --list_categories
tracedump=$(echo `adb shell atrace --list_categories | awk '{print $1}'` | sed 's/\n//g')

adb shell "atrace -b $TRACE_BUFFER_SZ_KB -t 30 -z $tracedump > $TRACE_FILE"
adb pull $TRACE_FILE

python platform-tools/systrace/systrace.py  -b $TRACE_BUFFER_SZ_KB --from-file trace_$port.log -o trace_$port.html
```

## 查看trace文件的快捷键

| 快捷键 | 描述 |
|:------:|:----:|
|   w    | 放大 |
|   s    | 缩小 |
|   a    | 左移 |
|   e    | 右移 |

## 使用Systrace 检测卡顿丢帧问题

- Systrace报告列出了每个进程呈现UI frame，并显示沿着时间线的每个渲染帧。 在`绿色框`架圆圈中，是指在16.6ms内呈现每秒稳定60帧， 花费16.6ms以上渲染的帧用`黄色或红色圆`圈表示。

## 错误

### ImportError: No module named six

``` shell
sudo apt install python-six
```

### 权限问题

```
error opening /sys/kernel/debug/tracing/options/overwrite: Permission denied (13)
error opening /sys/kernel/debug/tracing/buffer_size_kb: Permission denied (13)
error opening /sys/kernel/debug/tracing/trace_clock: Permission denied (13)
error opening /sys/kernel/debug/tracing/tracing_on: Permission denied (13)
error opening /sys/kernel/debug/tracing/tracing_on: Permission denied (13)
unable to start tracing
error opening /sys/kernel/debug/tracing/options/overwrite: Permission denied (13)
error opening /sys/kernel/debug/tracing/buffer_size_kb: Permission denied (13)
```

通过`adb root`获取权限


## 参考

- [Android Systrace 使用详解](https://www.jianshu.com/p/75aa88d1b575)
