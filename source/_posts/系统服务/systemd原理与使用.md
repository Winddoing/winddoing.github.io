---
layout: post
title: systemd原理与使用
date: '2020-02-06 19:45'
tags:
  - systemd
  - linux
categories:
  - 系统服务
abbrlink: 14807
---

`Systemd`（系统管理守护进程）的主要目的就是减少系统引导时间和计算开销。

<!--more-->
Systemd 的核心是一个叫单元unit的概念，它是一些存有关于`服务service`（在运行在后台的程序）、`设备`、`挂载点`、和操作系统其他方面信息的配置文件。Systemd 的其中一个目标就是简化这些事物之间的相互作用，因此如果你有程序需要在某个挂载点被创建或某个设备被接入后开始运行，Systemd 可以让这一切正常运作起来变得相当容易。

![systemd_unit](/images/2020/02/systemd_unit.png)

Systemd中的所有操作都是通过`systemctl`交互控制

|                   命令                   |          功能          |
|:----------------------------------------:|:----------------------:|
|        systemctl list-unit-files         |  列出系统上的所有单元  |
| systemctl list-unit-files --type=service | 限制输出列表只包含服务 |
|       systemctl status ssh.service       |     查看服务的状态     |
|        systemctl stop ssh.service        |        停止服务        |
|       systemctl start ssh.service        |        开启服务        |
|       systemctl enable ssh.service       |      设置开机自启      |
|      systemctl disable ssh.service       |      禁止开机自启      |


`systemctl list-units --type=target`命令可以获取当前正在使用的运行目标

```
$systemctl list-units --type=target
UNIT                   LOAD   ACTIVE SUB    DESCRIPTION
basic.target           loaded active active Basic System
cryptsetup.target      loaded active active Encrypted Volumes
getty.target           loaded active active Login Prompts
graphical.target       loaded active active Graphical Interface
local-fs-pre.target    loaded active active Local File Systems (Pre)
local-fs.target        loaded active active Local File Systems
multi-user.target      loaded active active Multi-User System
network-online.target  loaded active active Network is Online
network.target         loaded active active Network
nss-user-lookup.target loaded active active User and Group Name Lookups
paths.target           loaded active active Paths
remote-fs.target       loaded active active Remote File Systems
slices.target          loaded active active Slices
sockets.target         loaded active active Sockets
sound.target           loaded active active Sound Card
swap.target            loaded active active Swap
sysinit.target         loaded active active System Initialization
time-sync.target       loaded active active System Time Synchronized
timers.target          loaded active active Timers

LOAD   = Reflects whether the unit definition was properly loaded.
ACTIVE = The high-level unit activation state, i.e. generalization of SUB.
SUB    = The low-level unit activation state, values depend on unit type.

19 loaded units listed. Pass --all to see loaded but inactive units, too.
To show all installed unit files use 'systemctl list-unit-files'.
```

## Systemd 目录

- `/etc/systemd/system`：系统或用户自定义的配置文件
- `/run/systemd/system`：软件运行时生成的配置文件
- `/usr/lib/systemd/system`：系统或第三方软件安装时添加的配置文件。
 - CentOS：Unit 文件指向该目录
 - Ubuntu：被移到了`/lib/systemd/system`

Systemd 默认从目录`/etc/systemd/system/`读取配置文件。但是，里面存放的大部分文件都是符号链接，指向目录 /usr/lib/systemd/system/，真正的配置文件存放在那个目录

## system配置文件

```
[Unit]
Description=Anbox Container Manager
After=network.target
Wants=network.target
ConditionPathExists=/home/xxx/work1/android-for-anbox/android_x86.img

[Service]
ExecStartPre=/sbin/modprobe ashmem_linux
ExecStartPre=/sbin/modprobe binder_linux
ExecStart=/usr/local/bin/anbox container-manager --daemon --privileged --data-path=/home/xxx/work1/android-for-anbox/anbox-data/ --android-image=/home/xxx/work1/android-for-anbox/android_x86.img --use-rootfs-overlay

[Install]
WantedBy=multi-user.target
```
- `Unit`和`Install`段：所有 Unit 文件通用，用于配置服务（或其它系统资源）的描述、依赖和随系统启动的方式
- `Service` 段：服务（Service）类型的 Unit 文件（后缀为 .service）特有的，用于定义服务的具体管理和操作方法

### Unit

| 属性  | 描述  |
|:-:|:-:|
| Description  | 描述这个 Unit 文件的信息  |
| Requires   | 依赖的其它 Unit 列表，列在其中的 Unit 模板会在这个服务启动时的同时被启动。并且，如果其中任意一个服务启动失败，这个服务也会被终止  |
| After  | 与 Requires 相似，但是在后面列出的所有模块全部启动完成以后，才会启动当前的服务  |
| Want   | 与 Requires 相似，但只是在被配置的这个 Unit 启动时，触发启动列出的每个 Unit 模块，而不去考虑这些模板启动是否成功  |
| ConditionPathExists   | 是指定在服务启动时检查指定文件的存在状态。如果指定的绝对路径名不存在，这个条件的结果就是失败。如果绝对路径的带有!前缀，则条件反转，即只有路径不存在时服务才启动。  |

### service

| 属性  | 描述  |
|:-:|:-:|
| ExecStartPre  | 指定在ExecStart之前用户自定义执行的脚本  |
| ExecStart  |  指定启动单元的命令或者脚本 |

### Install

这部分配置的目标模块通常是特定运行目标的 .target 文件，用来使得服务在系统启动时自动运行。

| 属性  | 描述  |
|:-:|:-:|
| WantedBy  | 和 Unit 段的 Wants 作用相似，只有后面列出的不是服务所依赖的模块，而是依赖当前服务的模块。  |



## 参考

- [systemctl命令](https://man.linuxde.net/systemctl)
- [可能是史上最全面易懂的 Systemd 服务管理教程](https://cloud.tencent.com/developer/article/1516125)[](https://winddoing.github.io/downloads/linux/systemd.pdf)
- [systemd服务内容详解](https://www.cnblogs.com/zhouhbing/p/4021635.html)
