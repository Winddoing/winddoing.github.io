---
layout: post
title: Qemu虚拟机pci设备透传——网卡
date: '2020-09-24 16:58'
tags:
  - qemu
  - PCI
  - 网卡
categories:
  - 虚拟机
abbrlink: b3396e6f
---

在qemu虚拟机中为了提高网络的性能，将本地host端的多余网卡透传到虚拟机中使用。

设备的透传需要主机支持`Intel(VT-d)`或`AMD (IOMMU)`硬件虚拟化加速技术

<!--more-->

![qemu_net_passthrough](/images/2020/09/qemu_net_passthrough.png)


## 查看是否开启IOMMU

``` shell
dmesg | grep -e DMAR -e IOMMU
```

### 开启IOMMU功能

> 操作系统：Centos7,cpu: Intel(R) Xeon(R)

编辑`/boot/efi/EFI/centos/grub.cfg`文件，在系统启动内核的选项`linuxefi`中追加`intel_iommu=on`

``` diff
<       linuxefi /vmlinuz-3.10.0-1127.18.2.el7.x86_64 root=/dev/mapper/centos-root ro crashkernel=auto spectre_v2=retpoline rd.lvm.lv=centos/root rd.lvm.lv=centos/swap rhgb quiet LANG=en_US.UTF-8 intel_iommu=on
---
>       linuxefi /vmlinuz-3.10.0-1127.18.2.el7.x86_64 root=/dev/mapper/centos-root ro crashkernel=auto spectre_v2=retpoline rd.lvm.lv=centos/root rd.lvm.lv=centos/swap rhgb quiet LANG=en_US.UTF-8
```

系统重启后，查看支持IOMMU的设备：
```shell
# find /sys/kernel/iommu_groups/ -type l
/sys/kernel/iommu_groups/0/devices/0000:00:00.0
/sys/kernel/iommu_groups/1/devices/0000:00:04.0
...
```

## 查看BIOS是否开启intel-vt-x/vt-d

``` shell
cat /proc/cpuinfo | grep vmx
```

如果没有开启需要在BOIS中使能`intel-vt-x/vt-d`


## 选择绑定网卡

通过`ifconfig ethx down/up`开关相应的网络节点，获取相应的pci地址，该地址可以通过`dmesg`查看判断

``` shell
# dmesg -c
# ifconfig p1p1 down
# dmesg
[27244.804247] ixgbe 0000:3b:00.0: removed PHC on p1p1
```
> `p1p1`端口对应网卡的pci地址：0000:3b:00.0

## 加载vfio驱动

``` shell
modprobe vfio
modprobe vfio-pci
```

## 网卡透传

### Host端解绑网卡

``` shell
echo "0000:3b:00.0" > /sys/bus/pci/devices/0000\:3b\:00.0/driver/unbind
```
注意在解绑网卡是需要将该网卡下的所有端口设备全部解绑，比如

``` shell
ls /sys/bus/pci/devices/0000\:18\:00.0/iommu_group/devices/
0000:18:00.0  0000:18:00.1
```
需要将`0000:18:00.0`，`0000:18:00.1`全部进行解绑

### 生成vfio设备

``` shell
# lspci -s 0000:3b:00.0 -n
3b:00.0 0200: 8086:154d (rev 01)
# echo "8086 154d" > /sys/bus/pci/drivers/vfio-pci/new_id
```
> 在`/dev/vfio/`下面会有个以阿拉伯数字命名的文件，对应vfio设备组


### 绑定vfio总线驱动

``` shell
echo "0000:3b:00.0" > /sys/bus/pci/drivers/vfio-pci/bind
```

## 虚拟机参数

``` shell
-device vfio-pci,host=0000:3b:00.0
```
> 在qemu的启动参数中添加上面参数，该物理网卡将被透传到虚拟机中。

## 问题

在进行网卡的透传过程中，出现以下错误：
```
2020-09-23T10:16:51.707664Z qemu-system-x86_64: -device vfio-pci,host=0000:3b:00.0,id=hostdev0,bus=pci.0,addr=0xa: vfio 0000:3b:00.0: group 25 is not viable
Please ensure all devices within the iommu_group are bound to their vfio bus driver.
```
该错误的原因：在进行网卡透传时，以上提到的pci地址（0000:3b:00.0）其实为一张物理网卡的一个端口地址，一般的网卡都是两个端口，而此时只绑定了一个端口，需要将两个端口设备都进行解绑并绑定到vfio总线驱动上

``` shell
# ls /sys/bus/pci/devices/0000\:18\:00.0/iommu_group/devices/
0000:18:00.0  0000:18:00.1
```

## 脚本处理

为了以后处理方便将host端的配置进行脚本处理

``` shell
#/bin/bash
#set -x

PCI_ADDR="18:00.1"

modprobe vfio
modprobe vfio-pci
lsmod | grep vfio

lspci -s $PCI_ADDR -n  #em2

device_id=`lspci -s $PCI_ADDR -n | awk '{print $3}'`
device_id=${device_id/:/ } #去除：号
echo "PCI: $PCI_ADDR, Device ID:$device_id"

#生成vfio设备
echo "$device_id" > /sys/bus/pci/drivers/vfio-pci/new_id

#pci设备绑定vfio总线驱动（解绑--绑定）
pci_device=/sys/bus/pci/devices/0000:$PCI_ADDR/iommu_group/devices/
pci_device=`echo $pci_device | sed 's/:/\\:/g'` #添加转移符，echo打印不出来
#ls $pci_device
for dev in `ls $pci_device`
do
    echo "---dev:$dev"
    _pci_dev_unbind="/sys/bus/pci/devices/$dev/driver/unbind"
    _pci_dev_unbind=`echo $_pci_dev_unbind | sed 's/:/\\:/g'`
    #ls $_pci_dev_unbind
    echo "$dev" > $_pci_dev_unbind
    echo "$dev" > /sys/bus/pci/drivers/vfio-pci/bind
    lspci -s $dev -k
done

ls /dev/vfio/
```

## 参考

- https://www.kernel.org/doc/Documentation/vfio.txt
- https://wiki.archlinux.org/index.php/PCI_passthrough_via_OVMF
- [KVM网卡透传](https://blog.csdn.net/gerrylee93/article/details/106477055)
- [Qemu 虚拟机网卡透传（PCI Pass Through）](https://www.cnblogs.com/xia-dong/p/11542771.html)
