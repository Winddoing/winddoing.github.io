---
title: udev的使用
categories: 文件系统
tags:
  - linux
  - udev
abbrlink: 3820
date: 2018-05-17 23:07:24
---

udev版本：udev-167

udev 是 Linux2.6 内核里的一个功能，它替代了原来的 `devfs`，成为当前 Linux 默认的设备管理工具。udev 以`守护进程`的形式运行，通过侦听内核发出来的 uevent 来管理 /dev目录下的设备文件。不像之前的设备管理工具，udev 在`用户空间 (user space)` 运行，而不在内核空间 (kernel space) 运行。

udev下载：[http://www.kernel.org/pub/linux/utils/kernel/hotplug/](http://www.kernel.org/pub/linux/utils/kernel/hotplug/)
<!--more-->

## 好处

我们都知道，所有的设备在 Linux 里都是以设备文件的形式存在。在早期的 Linux 版本中，/dev目录包含了所有可能出现的设备的设备文件。很难想象 Linux 用户如何在这些大量的设备文件中找到匹配条件的设备文件。现在 udev 只为那些连接到 Linux 操作系统的设备产生设备文件。并且 udev 能通过定义一个 udev 规则 (rule) 来产生匹配设备属性的设备文件，这些设备属性可以是内核设备名称、总线路径、厂商名称、型号、序列号或者磁盘大小等等。

* `动态管理`：当设备添加 / 删除时，udev 的守护进程侦听来自内核的 `uevent`，以此添加或者删除 /dev下的设备文件，所以 udev 只为已经连接的设备产生设备文件，而不会在 /dev下产生大量虚无的设备文件, 同时根据udev的规则可以在添加/删除时，执行脚本。
* `自定义命名规则`：通过 Linux 默认的规则文件，udev 在 /dev/ 里为所有的设备定义了内核设备名称，比如 /dev/sda、/dev/hda、/dev/fd等等。由于 udev 是在用户空间 (user space) 运行，Linux 用户可以通过自定义的规则文件，灵活地产生标识性强的设备文件名，比如 /dev/boot_disk、/dev/root_disk、/dev/color_printer等等。
* `设定设备的权限和所有者/组`：udev 可以按一定的条件来设置设备文件的权限和设备文件所有者 / 组。在不同的 udev 版本中，实现的方法不同，在“如何配置和使用 udev”中会详解。


## 工作流程

![udev工作流程](/images/udev/udev_work_flow.jpg)

## 配置udev

udev需要内核`sysfs`和`tmpfs`的支持，sysfs为udev提供`设备入口`和`uevent通道`，tmpfs为udev设备文件提供存放空间.

## 使用

### 启动udev的守护进程

```
mkdir -p /dev/.udev
udevd --daemon
udevadm trigger
```

### 配置文件及规则

* 目录结构

```
cd /etc/udev

├── rules.d
│   ├── 22-xxx.rules
│   └── 99-fuse.rules
└── udev.conf
```

在规则文件里，除了以“#”开头的行（注释），所有的非空行都被视为一条规则，但是一条规则不能扩展到多行。规则都是由多个 键值对（key-value pairs）组成，并由逗号隔开，键值对可以分为 `条件匹配键值对`( 以下简称“匹配键 ”) 和 `赋值键值对`( 以下简称“赋值键 ”)，一条规则可以有多条匹配键和多条赋值键。匹配键是匹配一个设备属性的所有条件，当一个设备的属性匹配了该规则里所有的匹配键，就认为这条规则生效，然后按照赋值键的内容，执行该规则的赋值。下面是一个简单的规则：
```
KERNEL=="sda", NAME="my_root_disk", MODE="0660"
```
>`KERNEL`是匹配键，`NAME`和`MODE`是赋值键。这条规则的意思是：如果有一个设备的内核设备名称为 sda，则该条件生效，执行后面的赋值：在 /dev下产生一个名为 my_root_disk的设备文件，并把设备文件的权限设为 0660。

添加规则时，多从官方文档（[Writing udev rules](http://www.reactivated.net/writing_udev_rules.html)）获取信息

#### 规则操作符

* “==”：比较键、值，若等于，则该条件满足；
* “!=”： 比较键、值，若不等于，则该条件满足；
* “=”： 对一个键赋值；
* “+=”：为一个表示多个条目的键赋值。
* “:=”：对一个键赋值，并拒绝之后所有对该键的改动。目的是防止后面的规则文件对该键赋值。

#### 规则匹配键

* ACTION： 事件 (uevent) 的行为，例如：add( 添加设备 )、remove( 删除设备 )。
* KERNEL： 内核设备名称，例如：sda, cdrom。
* DEVPATH：设备的 devpath 路径。
* SUBSYSTEM： 设备的子系统名称，例如：sda 的子系统为 block。
* BUS： 设备在 devpath 里的总线名称，例如：usb。
* DRIVER： 设备在 devpath 里的设备驱动名称，例如：ide-cdrom。
* ID： 设备在 devpath 里的识别号。
* SYSFS{filename}： 设备的 devpath 路径下，设备的属性文件“filename”里的内容。

#### 规则赋值键

* NAME：在 /dev下产生的设备文件名。只有第一次对某个设备的 NAME 的赋值行为生效，之后匹配的规则再对该设备的 NAME 赋值行为将被忽略。如果没有任何规则对设备的 NAME 赋值，udev 将使用内核设备名称来产生设备文件。
* SYMLINK：为 /dev/下的设备文件产生符号链接。由于 udev 只能为某个设备产生一个设备文件，所以为了不覆盖系统默认的 udev 规则所产生的文件，推荐使用符号链接。
* OWNER, GROUP, MODE：为设备设定权限。
* ENV{key}：导入一个环境变量。

#### 值可调用的替换操作符

在键值对中的键和操作符都介绍完了，最后是值 (value)。Linux 用户可以随意地定制 udev 规则文件的值。例如：my_root_disk, my_printer。同时也可以引用下面的替换操作符：
* $kernel, %k：设备的内核设备名称，例如：sda、cdrom。
* $number, %n：设备的内核号码，例如：sda3 的内核号码是 3。
* $devpath, %p：设备的 devpath路径。
* $id, %b：设备在 devpath里的 ID 号。
* $sysfs{file}, %s{file}：设备的 sysfs里 file 的内容。其实就是设备的属性值。

### 实例

#### hidraw

```
ACTION!="add", GOTO="uibc_exit"
KERNEL=="hidraw2", SUBSYSTEM=="hidraw", RUN+="/etc/udev/xxx.sh"
LABEL="uibc_exit"
```
>file: /etc/udev/rules.d/22-xxx.rules

#### SD

```
action!="add",goto="farsight"
kernel=="mmcblk[0-9]p[0-9]",run+="/sbin/mount-sd.sh %k"
label="farsight"
```

### 注意

* 在每条规则中，赋值的字符串必须使用`双引号`括起来。
* 设备添加/删除后，触发uevent执行`RUN+`的脚本时，在该脚本中不能直接使用`echo`输出打印信息，应该导入终端的串口节点。
```
echo "print debug info ..." > /dev/ttyS000
```

## 制定 udev 规则和查询设备信息

>如何查找设备的信息 ( 属性 ) 来制定 udev 规则：

### 查询sysfs文件系统：

例如：设备 sda 的 SYSFS{size} 可以通过 cat /sys/block/sda/size得到；SYSFS{model} 信息可以通过 cat /sys/block/sda/device/model得到。

### udevadm info

```
udevadm info  --query=all --name=/dev/hidraw2
```

设备信息：
```
# udevadm info  --query=all --name=/dev/hidraw2
P: /devices/platform/soc/f9890000.ehci/usb1/1-1/1-1:1.2/0003:1C4D:0503.0003/hidraw/hidraw2
N: hidraw2
S: usb/by-devid/_/hidraw2
E: UDEV_LOG=3
E: DEVPATH=/devices/platform/soc/f9890000.ehci/usb1/1-1/1-1:1.2/0003:1C4D:0503.0003/hidraw/hidraw2
E: MAJOR=251
E: MINOR=2
E: DEVNAME=/dev/hidraw2
E: SUBSYSTEM=hidraw
E: DEVLINKS=/dev/usb/by-devid/_/hidraw2
```

## 调试

### 查看udev是否处理内核的uevent事件

```
udevadm  monitor
```

例如：U盘的插入/拔出
```
# udevadm monitor
monitor will print the received events for:
UDEV - the event which udev sends out after rule processing
KERNEL - the kernel uevent

usb 1-1: new high-speed USB device number 4 using ehci-platform
KERNEL[209.826989] add  usb-storage 1-1:1.0: USB Mass Storage device detected
    /devices/platform/soscsi host0: usb-storage 1-1:1.0
c/f9890000.ehci/usb1/1-1 (usb)
KERNEL[209.827627] add      /devices/platform/soc/f9890000.ehci/usb1/1-1/1-1:1.0 (usb)
UDEV  [209.834354] add      /devices/platform/soc/f9890000.ehci/usb1/1-1 (usb)
...
UDEV  [209.841660] add      /devices/platform/soc/f9890000.ehci/usb1/1-1/1-1:1.0/host0/scsi_host/host0 (scsi_host)
scsi 0:0:0:0: Direct-Access     General  UDisk            5.00 PQ: 0 ANSI: 2
KERNEL[210.848174] add      /devsd 0:0:0:0: [sda] 15728640 512-byte logical blocks: (8.05 GB/7.50 GiB)
ices/platform/soc/f98900sd 0:0:0:0: [sda] Write Protect is off
00.ehci/usb1/1-1/1-1:1.0sd 0:0:0:0: [sda] No Caching mode page found
/host0/target0:0sd 0:0:0:0: [sda] Assuming drive cache: write through
:0 (scsi)
KERNEL[210.848626] add      /devices/platform/soc/f9890000.ehci/usb1/ sda: sda1 sda2
1-1/1-1:1.0/host0/target0:0:0/0:0:0:0 (scsi)
KERNEL[210.848995]sd 0:0:0:0: [sda] Attached SCSI removable disk
 add      /devices/platform/soc/f9890000.ehci/usb1/1-1/1-1:1.0/host0/target0:0:0/0:0:0:0/scsi_disk/0:0:0:0 (scsi_disk)
KERNEL[210.849804] add      /devices/platform/soc/f9890000.ehci/usb1/1-1/1-1:1.0/host0/target0:0:0/0:0:0:0/scsi_device/0:0:0:0 (scsi_device)
UDEV  [210.858522] add      /devices/platform/soc/f9890000.ehci/usb1/1-1/1-1:1.0/host0/target0:0:0/0:0:0:0/scsi_device/0:0:0:0 (scsi_device)
...
dudisk1110 -> /dev/sda
udisk1110p1 -> /dev/sda1

usb usb1-port1: disabled by hub (EMI?), re-enabling...
usb 1-1: USB disconnect, device number 4
KERNEL[213.650748] remove   /devices/platform/soc/f9890000.ehci/usb1/1-1/1-1:1.0/host0/target0:0:0/0:0:0:0/bsg/0:0:0:0 (bsg)
...
UDEV  [213.652991] remove   /devices/platform/soc/f9890000.ehci/usb1/1-1/1-1:1.0/host0/target0:0:0/0:0:0:0/bsg/0:0:0:0 (bsg)
KERNEL[213.653175] remove   /devices/virtual/bdi/8:0 (bdi)
UDEV  [213.774157] remove   /devices/platform/soc/f9890000.ehci/usb1/1-1/1-1:1.0 (usb)
```

### 重启udev

```
udevadm trigger --type=devices --action=change
```

## Q&A

### udev 和 devfs 是什么关系
udev 完全在用户态 (userspace) 工作，利用设备加入或移除时内核所发送的hotplug 事件 (event) 来工作。关于设备的详细信息是由内核输出 (export) 到位于 /sys 的 sysfs 文件系统的。所有的设备命名策略、权限控制和事件处理都是在用户态下完成的。与此相反，devfs 是作为内核的一部分工作的。


## 参考

* [Writing udev rules](http://www.reactivated.net/writing_udev_rules.html)
* [使用 udev 高效、动态地管理 Linux 设备文件](https://www.ibm.com/developerworks/cn/linux/l-cn-udev/index.html?ca=drs-cn-0304)
* [udev使用方法（附实例）](http://blog.chinaunix.net/uid-26514815-id-3453208.html)
