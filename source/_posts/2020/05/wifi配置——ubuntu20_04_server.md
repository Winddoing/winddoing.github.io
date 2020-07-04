---
layout: post
title: WiFi配置——ubuntu20.04 server
date: '2020-05-31 17:52'
tags:
  - WiFi
  - server
categories:
  - 工具
abbrlink: 9cb9cc51
---

前段时间发现之前给老家买的mini主机很久没用了，拿来加了个无线网卡和硬盘通过nextcloud搭建一个私人网盘备份一些文件，在家里也方便手机共享。在wifi的配置时踩过一些坑，在这里简单记录下。

<!--more-->

在ubuntu18.04中就发现使用`netplan`进行网络配置，WiFi同样可以通过netplan的简单配置实现上网，不需要我们在配置wpa_supplicant

netplan配置文件：
```
cat /etc/netplan/00-installer-config.yaml
# This is the network config written by 'subiquity'
network:
  version: 2
  ethernets:
    enp2s0:
      dhcp4: true
      dhcp6: true
  wifis:
    wlp3s0:
      dhcp4: false
      dhcp6: true
      optional: true
      addresses: [192.168.1.38/24]
      gateway4: 192.168.1.1
      nameservers:
          addresses: [8.8.8.8]
      access-points:
          "ChinaNet-xxx":
              password: "xxxxx"
```
常用的命令：
``` shell
netplan generate
netplan apply
```
> - `generate`: 从`/etc/netplan/*.yaml`生成特定于后端的配置文件
> - `apply`: 应用配置(以便生效),在每一次修改完配置文件后需要执行，使配置生效

配置完成执行以上两个命令后，系统可以正常上网，但是在系统重启后存在两个问题。
1. 系统重启时间过长，两分钟多
2. 重启后，无线网卡可以正常配置IPv4地址，但是IPv6地址没有配置成功（nextcloud通过docker安装，局域网访问需要IPv6地址配置成功）


## 优化开机时间

``` shell
$systemd-analyze
Startup finished in 2.582s (firmware) + 4.843s (loader) + 5.075s (kernel) + 2min 15.951s (userspace) = 2min 28.453s
graphical.target reached after 2min 14.410s in userspace
```

``` shell
$systemd-analyze blame   
2min 213ms systemd-networkd-wait-online.service
    7.145s docker.service
```
耗时最多的是`systemd-networkd-wait-online.service`服务其超时后才退出，主要用于检查网络配置是否成功，便于后面其他依赖于网络的服务启动，直接禁掉最省事，网络连接也不会受影响。但是`netdata`的服务启动会受影响导致失败，因此不能直接mark掉。

通过对系统log的分析这里主要原因是，检查网络连接失败最后导致的超时，网络链接失败是由于该主机有两张网卡（有线网卡，无线网卡），但是我没有使用，导致检查超时。由于后期可能会用到有线网卡，不打算有线网卡的检查过滤掉，同时为了方便只能牺牲一些开机时间，将该服务的超时时间重新配置为30s

```
[Service]
TimeoutStartSec=30
```
> file: /lib/systemd/system/systemd-networkd-wait-online.service


## 配置IPv6网络

通过系统启动日志，发现网络配置存在异常，可能是导致IPv6网络配置失败的原因

```
May 24 22:36:39 ubuntu NetworkManager[874]: <warn>  [1590330999.7653] device (wlp3s0): re-acquiring supplicant interface (#1).                    
May 24 22:36:39 ubuntu systemd-networkd[816]: wlp3s0: Lost carrier                                                                                
May 24 22:36:39 ubuntu systemd-networkd[816]: wlp3s0: Gained carrier                                                                              
May 24 22:36:39 ubuntu systemd[1]: NetworkManager-dispatcher.service: Succeeded.                                                                  
May 24 22:36:39 ubuntu wpa_supplicant[897]: ctrl_iface exists and seems to be in use - cannot override it                                         
May 24 22:36:39 ubuntu wpa_supplicant[897]: Delete '/run/wpa_supplicant/wlp3s0' manually if it is not used anymore                                
May 24 22:36:39 ubuntu wpa_supplicant[897]: Failed to initialize control interface '/run/wpa_supplicant'.                                         
                                            You may have another wpa_supplicant process already running or the file was                           
                                            left by an unclean termination of wpa_supplicant in which case you will need                          
                                            to manually remove this file before starting wpa_supplicant again.                                    
May 24 22:36:39 ubuntu systemd-networkd[816]: wlp3s0: Lost carrier                                                                                
May 24 22:36:39 ubuntu systemd-networkd[816]: wlp3s0: Gained carrier                                                                              
May 24 22:36:39 ubuntu wpa_supplicant[897]: nl80211: deinit ifname=wlp3s0 disabled_11b_rates=0                                                    
May 24 22:36:39 ubuntu NetworkManager[874]: <error> [1590330999.9224] sup-iface[0x558f502f31f0,wlp3s0]: error adding interface: wpa_supplicant    
couldn't grab this interface.                                                                                                                     
May 24 22:36:39 ubuntu NetworkManager[874]: <info>  [1590330999.9225] device (wlp3s0): supplicant interface state: starting -> down               
May 24 22:36:42 ubuntu snapd[891]: stateengine.go:150: state ensure error: decode new commands catalog: net/http: request canceled (Client.       
Timeout exceeded while reading body)                                                                                                              
May 24 22:36:49 ubuntu NetworkManager[874]: <warn>  [1590331009.7629] device (wlp3s0): re-acquiring supplicant interface (#2).                    
May 24 22:36:49 ubuntu systemd-networkd[816]: wlp3s0: Lost carrier                                                                                
May 24 22:36:49 ubuntu systemd-networkd[816]: wlp3s0: Gained carrier                                                                              
May 24 22:36:49 ubuntu wpa_supplicant[897]: ctrl_iface exists and seems to be in use - cannot override it                                         
May 24 22:36:49 ubuntu wpa_supplicant[897]: Delete '/run/wpa_supplicant/wlp3s0' manually if it is not used anymore                                
May 24 22:36:49 ubuntu wpa_supplicant[897]: Failed to initialize control interface '/run/wpa_supplicant'.                                         
                                            You may have another wpa_supplicant process already running or the file was                           
                                            left by an unclean termination of wpa_supplicant in which case you will need                          
                                            to manually remove this file before starting wpa_supplicant again.                                    
May 24 22:36:49 ubuntu systemd-networkd[816]: wlp3s0: Lost carrier                                                                                
May 24 22:36:49 ubuntu systemd-networkd[816]: wlp3s0: Gained carrier                                                                              
```

在系统的启动日志里，WiFi的配置被进行了两次，在第一次配置中日志显示ipv6地址获取成功，可能是第二次失败导致ipv6地址无法获取。

```
May 26 23:00:43 ubuntu wpa_supplicant[663]: Successfully initialized wpa_supplicant
```

```
May 26 23:00:48 ubuntu wpa_supplicant[1002]: Successfully initialized wpa_supplicant
```

在这里无线网络被配置两次是由于系统启动时两个网络配置的服务（`NetworkManager.service`，`network-manager.service`）都被启动了，我们禁掉`NetworkManager.service`服务重启后网络配置正常。

```shell
sudo systemctl disable NetworkManager.service
```

## netplan的配置

> `NetworkManager`主要用于在桌面系统上管理网络设备。如果您使用`NetworkManager`作为网络设备管理的系统守护程序，将会使用 NetworkManager 的图形程序来管理网络接口。
> - [网络配置](https://winddoing.github.io/post/18692.html)


在netplan的配置文件中有一个`renderer`字段将其指定为`networkd`，或许也可以解决上面的问题，没有进行验证，不过netplan手册说其是默认值。

```
renderer (scalar)                                                                                                                              
       Use  the  given  networking backend for this definition.  Currently supported are networkd and NetworkManager.  This property can be    
       specified globally in networks:, for a device type (in e.  g.  ethernets:) or for a particular device definition.  Default  is  net‐    
       workd.                                                                                                                                  

       The renderer property has one additional acceptable value for vlan objects (i.  e.  defined in vlans:): sriov.  If a vlan is defined    
       with the sriov renderer for an SR-IOV Virtual Function interface, this causes netplan to set up  a  hardware  VLAN  filter  for  it.    
       There can be only one defined per VF.                                                                                                   
```

## 参考

- [systemd-networkd-wait-online拖慢Ubuntu 18.04云主机开机的排查手记](https://xzclip.cn/tech-records/systemd-networkd-wait-online-stuck-boot-ubuntu-1804/)
- [ubuntu命令行配置wifi，不使用NetworkManager和netplan](https://blog.csdn.net/doushi/article/details/104062482)
