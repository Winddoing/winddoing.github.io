---
layout: post
title: libvirt for qemu
date: '2020-08-24 16:37'
tags:
  - qemu
  - libvirt
categories:
  - 虚拟机
  - qemu
---

> `libvirt`是目前使用最为广泛的针对KVM虚拟机进行管理的工具和API。`libvirtd`是一个daemon进程，可以被本地和远程的virsh(命令行工具)调用，Libvirtd通过调用qemu-kvm操作管理虚拟机。libvirt 由应用程序编程接口 (API) 库、一个守护进程 (libvirtd)，和默认命令行实用工具`(virsh)`等部分组成

<!--more-->

``` shell
yum install -y qemu-kvm qemu-kvm-tools libvirt virt-install 
```

# libvirtd

``` shell
systemctl status libvirtd.service 
● libvirtd.service - Virtualization daemon
     Loaded: loaded (/lib/systemd/system/libvirtd.service; enabled; vendor preset: enabled)
     Active: active (running) since Mon 2020-08-24 09:22:15 CST; 7h ago
TriggeredBy: ● libvirtd-admin.socket
             ● libvirtd.socket
             ● libvirtd-ro.socket
       Docs: man:libvirtd(8)
             https://libvirt.org
   Main PID: 1022 (libvirtd)
      Tasks: 20 (limit: 32768)
     Memory: 65.7M
     CGroup: /system.slice/libvirtd.service
             ├─1022 /usr/sbin/libvirtd
             ├─1412 /usr/sbin/dnsmasq --conf-file=/var/lib/libvirt/dnsmasq/default.conf --leasefile-ro --dhcp-script=/usr/lib/libvirt/libvirt_leaseshelper
             └─1413 /usr/sbin/dnsmasq --conf-file=/var/lib/libvirt/dnsmasq/default.conf --leasefile-ro --dhcp-script=/usr/lib/libvirt/libvirt_leaseshelper
```
## 配置文件

libvirtd服务的配置文件: `/etc/libvirt/libvirtd.conf`

客户端主配置文件: `/etc/libvirt/libvirt.conf`

qemu的主配置文件: `/etc/libvirt/qemu.conf`

# qemu

## libvirt与qemu如何绑定

> 通过最新qemu源码编译的qemu-kvm，被libvirt进行管理

virsh编辑配置文件的`emulator`部分：

``` xml
<emulator>/usr/local/bin/qemu-system-x86_64</emulator>
```

修改后使其生效时，会出现权限错误：
``` shell
# virsh define ./qemu/win10.xml
error: Failed to define domain from ./qemu/win10.xml
error: internal error: Failed to start QEMU binary /usr/local/bin/qemu-system-x86_64 for probing: libvirt:  error : cannot execute binary /usr/local/bin/qemu-system-x86_64: Permission denied
```

解决方法：

> 在`/etc/apparmor.d/usr.sbin.libvirtd`文件中，添加一行:
> ``` shell
> /usr/local/bin/* PUx,
> ```
>
> 使能生效：`sudo systemctl reload apparmor`

原因： `libvirtd`应用的权限被`apparmor-profiles`所控制，而`/usr/local/bin`目录下的可执行文件，没有被添加到apparmor-profiles的配置中，因此使用时检测到没有权限。

- AppArmor 是一款与SeLinux类似的安全框架/工具，其主要作用是控制应用程序的各种权限，例如对某个目录/文件的读/写，对网络端口的打开/读/写等
- Ubuntu的默认选择
- 在centos中如果出现该错误，可以通过临时禁用SELinux进行测试: `setenforce 0`

`apparmor-profiles`的状态：
```
sudo apparmor_status
```

# virsh

## 查看虚拟机状态

``` shell
$virsh list --all
 Id   Name          State
 ------------------------------
  -    ubuntu20.04   shut off
  -    win10         shut off
```

## 显示虚拟机的XML配置

``` shell
$virsh dumpxml ubuntu20.04
```

## 编辑虚拟机的XML配置文件

``` shell
virsh edit ubuntu20.04
```



# 参考

- [libvirt原理](https://www.cnblogs.com/wn1m/p/11280605.html)
- [Changing libvirt emulator: Permission denied](https://unix.stackexchange.com/questions/471345/changing-libvirt-emulator-permission-denied)
