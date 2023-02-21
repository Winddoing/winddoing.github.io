---
layout: post
title: Multiseat System
date: '2020-05-23 15:31'
tags:
  - seat
  - x11
categories:
  - 工具
abbrlink: 1458b897
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
- 给已经存在的seat,添加资源,比如其他的设备外设

### 查看seat状态

``` shell
sudo loginctl seat-status seat0
```

## udev

多设备并且固定时,可以通过udev批量添加, 在`/etc/udev/rules.d`目录下根据udev规则添加seat配置文件

### 添加udev规则

```shell
# cat 72-seat-*
SUBSYSTEM=="pci", DEVPATH=="/devices/pci0000:00/0000:00:02.2/0000:03:00.0", TAG+="seat-1", TAG+="master-of-seat", ENV{ID_AUTOSEAT}="1", ENV{ID_SEAT}="seat-1"
SUBSYSTEM=="pci", DEVPATH=="/devices/pci0000:00/0000:00:03.0/0000:04:00.0", TAG+="seat-2", TAG+="master-of-seat", ENV{ID_AUTOSEAT}="1", ENV{ID_SEAT}="seat-2"
```
> `DEVPATH`指设置地址,通过`loginctl seat-status seat0`获取

```shell
# loginctl seat-status seat0 | grep "drm:card" -A4
		  │ drm:card1
		  ├─/sys/device...0:00/0000:00:02.2/0000:03:00.0/drm/renderD128
		  │ drm:renderD128
		  ├─/sys/device...0000:00/0000:00:02.2/0000:03:00.1/sound/card0
		  │ sound:card0
--
		  │ drm:card2
		  ├─/sys/device...0:00/0000:00:03.0/0000:04:00.0/drm/renderD129
		  │ drm:renderD129
		  ├─/sys/device...0000:00/0000:00:03.0/0000:04:00.1/sound/card1
		  │ sound:card1
```

### 生成seats分组

> udevadm - udev management tool

`udevadm`是一个udev的管理工具，可以用来监视和控制udev运行时的行为，请求内核事件，管理事件队列，以及提供简单的调试机制。

``` shell
sudo udevadm trigger
```
> 从内核请求events事件,主要用于重放coldplug事件信息.(相当于模拟一次重启后的设置加载)
> `coldplug`:内核在启动时已经检测到了系统的硬件设备，并把硬件设备信息通过sysfs内核虚拟文件系统导出。udev扫描sysfs文件系统，根据硬件设备信息生成热插拔（hotplug）事件，udev再读取这些事件，生成对应的硬件设备文件。由于没有实际的硬件插拔动作，所以这一过程被称为coldplug。

``` shell
sudo loginctl list-seats
SEAT
seat-1
seat-2
seat0

3 seats listed.
```

> 有时可能无法生成seats分组,需要将本机的所有设备重新分配到seat0,重启设备后重新通过`udevadm trigger`生成分组
> **注意**: 通过`loginctl flush-devices`重置到seat0之前,需要备份我们在`/etc/udev/rules.d`目录下,编辑的udev文件,否则重置时将自动删除


## 参考

- [multiseat](https://www.freedesktop.org/wiki/Software/systemd/multiseat/)
- [Multiseat](https://www.x.org/wiki/Development/Documentation/Multiseat/)
- [Xorg multiseat](https://wiki.archlinux.org/index.php/Xorg_multiseat)
- [How to configure a Multiseat system](https://samuloop.github.io/linux/multiseat.html#create_seat)
- [Autostart all LightDM seats and show one as default](https://unix.stackexchange.com/questions/87169/autostart-all-lightdm-seats-and-show-one-as-default)
- [Debugging multiseat: How to run two X server layouts together without display manager?](https://unix.stackexchange.com/questions/167709/debugging-multiseat-how-to-run-two-x-server-layouts-together-without-display-ma)
