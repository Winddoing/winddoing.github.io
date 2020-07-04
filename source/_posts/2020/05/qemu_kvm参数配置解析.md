---
layout: post
title: qemu kvm参数配置解析
date: '2020-05-28 17:58'
tags:
  - qemu
  - kvm
  - 虚拟机
categories:
  - 虚拟机
abbrlink: d2c5077b
---

Qemu参数配置

<!--more-->
## 网络

### 端口转发

```
-netdev user,id=mynet,hostfwd=tcp::550-:5555
或
-netdev user,id=n0,hostfwd=::1020-:20,hostfwd=::1021-:21 #多端口映射,使用逗号分割
```
> `hostfwd=[tcp|udp]:[hostaddr]:hostport-[guestaddr]:guestport`将进入到主机端口的TCP或者UDP连接转发到客户机的某个地址和端口

这种方法可以在主机的qemu进程监听一个端口，主机可通过这个端口与客户机对应的端口通讯,相当于将客户机的端口映射到主机端.

## 外设


### 声卡

qemu支持的声卡类型
``` shell
$qemu-system-x86_64 -soundhw help
Valid sound card names (comma separated):
sb16        Creative Sound Blaster 16
es1370      ENSONIQ AudioPCI ES1370
ac97        Intel 82801AA AC97 Audio
adlib       Yamaha YM3812 (OPL2)
gus         Gravis Ultrasound GF1
cs4231a     CS4231A
hda         Intel HD Audio
pcspk       PC speaker

-soundhw all will enable all of the above
```
> `-soundhw` option is now available for all targets that have a PCI bus.

- PCI声卡:`ac97`,`hda`,`es1370`

## 参考

- [qemu-kvm 参数设置（多屏显示、图像压缩、声音压缩、USB重定向、添加agent）](https://blog.csdn.net/wangyezi19930928/article/details/53156057)
- [QEMU version 4.2.0 User Documentation](https://qemu.weilnetz.de/doc/qemu-doc.html)
