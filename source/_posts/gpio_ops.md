---
title: 用户空间的GPIO操作
categories:
  - 系统应用
tags:
  - gpio
abbrlink: 50599
date: 2017-11-03 23:07:24
---

用户空间的GPIO的操作

<!--more-->

``` shell
# cd sys/class/gpio/
# ls
export      gpiochip0   gpiochip32  gpiochip64  gpiochip96  unexport
# echo 33 > export
# ls
export      gpiochip0   gpiochip64  unexport
gpio33      gpiochip32  gpiochip96
# cd gpio33/
# ls
active_low  edge        subsystem   value
direction   power       uevent
```

## 输入输出

> support "in" and "out"

``` shell
echo "in" > direction
```

## GPIO中断

> support "both" or "none", "rising", "falling" edge trigger"

上升沿中断

``` shell
echo "rising" > edge
```

下降沿中断

``` shell
echo "falling" > edge
```


