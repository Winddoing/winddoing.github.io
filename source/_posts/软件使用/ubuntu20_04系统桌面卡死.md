---
layout: post
title: ubuntu20_04系统桌面卡死
date: '2020-11-18 10:10'
tags:
  - ubuntu
  - gdm
categories:
  - 软件使用
abbrlink: '17750668'
---

ubuntu20.04在使用过程中桌面出现莫名其妙的卡死现象，但是系统正常没有死，可以通过`CTRL+ALT+Fn`切换不同的终端，并登录进行操作。这种卡死现象在之前使用的ubuntu18.04中也出现过，根据网上很多解决方法尝试后均无法解决，最后重装新系统ubuntu20.04该问题还是存在，这次就将其在这里简单记录一下。

<!--more-->

## 桌面卡死后的日志：


```
17:01:55 QTM4600-pc dnsmasq[1009]: reading /etc/resolv.conf
17:01:55 QTM4600-pc dnsmasq[1009]: using nameserver 127.0.0.53#53
17:02:34 QTM4600-pc /usr/lib/gdm3/gdm-x-session[2129]: (**) Option "fd" "25"
17:02:34 QTM4600-pc /usr/lib/gdm3/gdm-x-session[2129]: (II) event2  - Power Button: device removed
17:02:34 QTM4600-pc /usr/lib/gdm3/gdm-x-session[2129]: (**) Option "fd" "28"
17:02:34 QTM4600-pc /usr/lib/gdm3/gdm-x-session[2129]: (II) event1  - Power Button: device removed
17:02:34 QTM4600-pc /usr/lib/gdm3/gdm-x-session[2129]: (**) Option "fd" "29"
17:02:34 QTM4600-pc /usr/lib/gdm3/gdm-x-session[2129]: (II) event0  - Sleep Button: device removed
17:02:34 QTM4600-pc /usr/lib/gdm3/gdm-x-session[2129]: (**) Option "fd" "33"
17:02:34 QTM4600-pc /usr/lib/gdm3/gdm-x-session[2129]: (II) event12 - Logitech USB Optical Mouse: device removed
17:02:34 QTM4600-pc /usr/lib/gdm3/gdm-x-session[2129]: (**) Option "fd" "31"
17:02:34 QTM4600-pc /usr/lib/gdm3/gdm-x-session[2129]: (II) event4  - USB USB Keykoard: device removed
17:02:34 QTM4600-pc /usr/lib/gdm3/gdm-x-session[2129]: (**) Option "fd" "32"
17:02:34 QTM4600-pc /usr/lib/gdm3/gdm-x-session[2129]: (II) event9  - USB USB Keykoard System Control: device removed
17:02:34 QTM4600-pc /usr/lib/gdm3/gdm-x-session[2129]: (**) Option "fd" "48"
17:02:34 QTM4600-pc /usr/lib/gdm3/gdm-x-session[2129]: (**) Option "fd" "48"
17:02:34 QTM4600-pc /usr/lib/gdm3/gdm-x-session[2129]: (II) event8  - USB USB Keykoard Consumer Control: device removed
17:02:34 QTM4600-pc /usr/lib/gdm3/gdm-x-session[2129]: (II) AIGLX: Suspending AIGLX clients for VT switch
17:02:34 QTM4600-pc /usr/lib/gdm3/gdm-x-session[2129]: (II) systemd-logind: got pause for 13:73
17:02:34 QTM4600-pc /usr/lib/gdm3/gdm-x-session[2129]: (II) systemd-logind: got pause for 13:72
17:02:34 QTM4600-pc /usr/lib/gdm3/gdm-x-session[2129]: (II) systemd-logind: got pause for 13:65
17:02:34 QTM4600-pc /usr/lib/gdm3/gdm-x-session[2129]: (II) systemd-logind: got pause for 226:0
17:02:34 QTM4600-pc /usr/lib/gdm3/gdm-x-session[2129]: (II) systemd-logind: got pause for 13:66
17:02:34 QTM4600-pc /usr/lib/gdm3/gdm-x-session[2129]: (II) systemd-logind: got pause for 13:64
17:02:34 QTM4600-pc /usr/lib/gdm3/gdm-x-session[2129]: (II) systemd-logind: got pause for 13:76
17:02:34 QTM4600-pc /usr/lib/gdm3/gdm-x-session[2129]: (II) systemd-logind: got pause for 13:68
17:02:34 QTM4600-pc systemd[1]: Started Getty on tty4.
```

初步怀疑与gdm3有关，将其换为`lightdm`看是否会出现卡死现象
``` shell
sudo apt install lightdm
```

**后来又出现了一次界面卡死现象，不过每一次的卡死界面都是在firefox浏览器，后面改用chrome浏览器后情况好了点，暂时没有出现卡死现象**
