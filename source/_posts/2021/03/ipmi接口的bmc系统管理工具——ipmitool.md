---
layout: post
title: IPMI接口的BMC系统管理工具——ipmitool
date: '2021-03-02 17:14'
tags:
  - bmc
  - ipmitool
categories:
  - 工具
abbrlink: c41b411e
---

`ipmitool`是一种可用在 Linux/Unix 系统下的基于命令行方式的 ipmi 平台管理工具。它支持 ipmi 1.5 和ipmi 2.0 规范（最新的规范为 ipmi 2.0）。利用它可以实现获取传感器的信息、显示系统日志内容、网络远程开关机等功能。其主要功能包括读取和显示传感器数据（SDR），显示System Evernt Log（SEL）的内容，显示打印Field Replaceable Unit（FRU）信息，`读取和设置BMC模块`的LAN配置，远程控制服务器主机的电源。

<!--more-->


## 查看BMC的信息

- 本机BMC信息
``` shell
# ipmitool mc info
Device ID                 : 34
Device Revision           : 1
Firmware Revision         : 2.48
IPMI Version              : 2.0
...
```

## 查看BMC的LAN信息

- 本机LAN信息
``` shell
# ipmitool lan print 1
```

- 设定channel1从DHCP获得IP:
``` shell
# ipmitool lan set 1 ipsrc dhcp
```

- 设置channel1为静态IP
``` shell
# ipmitool lan set 1 ipsrc static
```

- 设置channel1的地址为192.168.1.11
``` shell
# ipmitool lan set 1 ipaddr 192.168.1.11
# ipmitool lan set 1 netmask 255.255.255.0
# ipmitool lan set 1 defgw ipaddr 192.168.1.1
```

## 重置BMC（包括BIOS）

``` shell
# ipmitool raw 0x32 0x66
```

![ipmitool_restore_bmc](/images/2021/03/ipmitool_restore_bmc.png)
> 来源：[IPMI Commands](http://www.staroceans.org/e-book/S2B%20IPMI%20Commands.pdf)


## 查看主机传感器信息

``` shell
# ipmitool sensor | grep "Temp "
BB Inlet Temp    | 25.000     | degrees C  | ok    | na        | 5.000     | 10.000    | 60.000    | 65.000    | na        
BB BMC Temp      | 36.000     | degrees C  | ok    | na        | 5.000     | 10.000    | 85.000    | 90.000    | na        
BB CPU1 VR Temp  | 47.000     | degrees C  | ok    | na        | 5.000     | 10.000    | 110.000   | 115.000   | na        
BB CPU2 VR Temp  | 37.000     | degrees C  | ok    | na        | 5.000     | 10.000    | 110.000   | 115.000   | na        
BB MISC VR Temp  | 49.000     | degrees C  | ok    | na        | 5.000     | 10.000    | 110.000   | 115.000   | na        
BB Outlet Temp   | 46.000     | degrees C  | ok    | na        | 5.000     | 10.000    | 110.000   | 115.000   | na        
SSB Temp         | 42.000     | degrees C  | ok    | na        | 5.000     | 10.000    | 98.000    | 103.000   | na        
LAN NIC Temp     | 56.000     | degrees C  | ok    | na        | 5.000     | 10.000    | 115.000   | 120.000   | na        
Mem 1 VRD Temp   | 39.000     | degrees C  | ok    | na        | 5.000     | 10.000    | 110.000   | 115.000   | na        
Mem 2 VRD Temp   | 25.000     | degrees C  | ok    | na        | 5.000     | 10.000    | 110.000   | 115.000   | na        
EV CPU1VR Temp   | 37.000     | degrees C  | ok    | na        | 5.000     | 10.000    | 110.000   | 115.000   | na             
```

## 配置用户名密码

``` shell
#配置channel3通过dhcp获取ip
ipmitool lan set 3 ipsrc dhcp

#查看channel3的ip
ipmitool lan print 3

#获取ip后查看channel3的用户信息
ipmitool user list 3
ID  Name	     Callin  Link Auth	IPMI Msg   Channel Priv Limit
1                    true    false      false      NO ACCESS
2                    true    false      false      NO ACCESS
3   test             true    false      false      NO ACCESS
4                    true    false      false      NO ACCESS
...

#选择用户ID 3，配置用户名密码
ipmitool user set name 3 test
ipmitool user set password 3 123456@abc#ABC
ipmitool channel setaccess 1 3 callin=on ipmi=on link=on privilege=4

#设置用户3的访问权限
ipmitool user priv 3 0x4 3
ipmitool user list 3
ID  Name	     Callin  Link Auth	IPMI Msg   Channel Priv Limit
1                    true    false      false      NO ACCESS
2                    true    false      false      NO ACCESS
3   test             true    false      false      ADMINISTRATOR
4                    true    false      false      NO ACCESS
...
```
> 注： channel的选择以接入的网口所属channel为主，配置用户名和密码是用户ID和channel id选择一致

## 常用的基本命令

| 命令                      | 描述                                                                                                        |
|:--------------------------|:------------------------------------------------------------------------------------------------------------|
| `ipmitool sel list`       | 打印日志                                                                                                    |
| `ipmitool sensor`         | 获取传感器中的各种监测值和该值的监测阈值，包括（CPU温度，电压，风扇转速，电源调制模块温度，电源电压等信息） |
| `ipmitool chassis status` | 查看底盘状态，其中包括了底盘电源信息，底盘工作状态等                                                        |
| `ipmitool user list 1`    | 查询当前BMC的用户                                                                                           |
| `ipmitool sdr`            | 查看SDR Sensor信息                                                                                          |

## 参考

- [运维管理利器系列--ipmitool](https://www.cnblogs.com/lianglab/p/14106113.html)
- [IPMITOOL工具使用详解（待验证）](https://blog.csdn.net/pansaky/article/details/102807046)
