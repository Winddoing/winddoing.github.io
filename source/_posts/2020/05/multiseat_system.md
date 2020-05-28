---
layout: post
title: Multiseat System
date: '2020-05-23 15:31'
tags:
  - seat
  - X11
categories:
  - 工具
---

`Multiseat system`: 可以由多个用户同时共享一个PC的大部分资源使用，比如独立的鼠标键盘、显示器

> Multiseat主要是硬件，然后才是软件配置

在每个使用`Xorg`的Linux中，即使您不想安装多座linux系统，也总是有一个席位。 该座位名为“seat0”，您无法重命名。

<!--more-->

## 软件配置

- 创建一个seat；
- 删除座位seat；
- 为seat分配资源；
- 查看分配给特定seat的资源。

> 规则，seat名称必须以`seat-`作为前缀

**无论在任何情况下都遇到麻烦，如果遇到麻烦，您总是可以通过以下简单的单个命令将所有设备重新分配给seat0**

``` shell
sudo loginctl flush-devices
```
### 列出当前seat

``` shell
sudo loginctl list-seats
```

### 创建seat并分配资源

``` shell
sudo loginctl attach seat-[name] /sys/devices/pci0000:00/0000:00:06.0/0000:02:00.0/drm/card1
```

### 查看seat状态

``` shell
sudo loginctl seat-status seat0
```

### udev

在`/etc/udev/rules.d`目录下根据udev规则添加seat配置文件

··· shell
# cat 72-seat-1.rules
SUBSYSTEM=="pci", DEVPATH=="/devices/pci0000:00/0000:00:01.0/0000:01:00.0", TAG+="seat-1", TAG+="master-of-seat", ENV{ID_AUTOSEAT}="1", ENV{ID_SEAT}="seat-1"
# cat 72-seat-3.rules
SUBSYSTEM=="pci", DEVPATH=="/devices/pci0000:00/0000:00:02.0", TAG+="seat-3", TAG+="master-of-seat", ENV{ID_AUTOSEAT}="1", ENV{ID_SEAT}="seat-3"
···

``` shell
udevadm udevadm
```

``` shell
sudo loginctl list-seats
```


## 参考

- [multiseat](https://www.freedesktop.org/wiki/Software/systemd/multiseat/)
- [How to configure a Multiseat system](https://samuloop.github.io/linux/multiseat.html#create_seat)
- [Autostart all LightDM seats and show one as default](https://unix.stackexchange.com/questions/87169/autostart-all-lightdm-seats-and-show-one-as-default)
