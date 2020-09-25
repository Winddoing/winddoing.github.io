---
layout: post
title: Android开发相关记录
date: '2018-10-09 17:21'
tags:
  - Android
categories:
  - Android
abbrlink: 2578
---

记录Android开发中遇到的一些方法和问题。

<!--more-->

## remount system分区可读可写


1. 查看挂载点
```
# cat /proc/mounts
rootfs / rootfs ro,relatime 0 0
tmpfs /dev tmpfs rw,nosuid,relatime,mode=755 0 0
devpts /dev/pts devpts rw,relatime,mode=600,ptmxmode=000 0 0
proc /proc proc rw,relatime 0 0
sysfs /sys sysfs rw,relatime 0 0
debugfs /sys/kernel/debug debugfs rw,relatime 0 0
tmpfs /mnt/asec tmpfs rw,relatime,mode=755,gid=1000 0 0
tmpfs /mnt/obb tmpfs rw,relatime,mode=755,gid=1000 0 0
tmpfs /storage/external_storage tmpfs rw,relatime,mode=775,uid=1000,gid=1023 0 0
adb /dev/usb-ffs/adb functionfs rw,relatime 0 0
/dev/block/system /system ext4 ro,noatime,nodiratime,noauto_da_alloc,data=ordered 0 0
/dev/block/data /data ext4 rw,nosuid,nodev,noatime,nodiratime,noauto_da_alloc,data=ordered 0 0
/dev/block/cache /cache ext4 rw,nosuid,nodev,noatime,nodiratime,noauto_da_alloc,data=ordered 0 0
/dev/fuse /mnt/shell/emulated fuse rw,nosuid,nodev,relatime,user_id=1023,group_id=1023,default_permissions,allow_other 0 0
/dev/block/zram0 /swap_zram0 ext2 rw,relatime,errors=continue 0 0
```

2. 重新挂载system分区
```
# mount -o remount -rw /dev/block/system
```
