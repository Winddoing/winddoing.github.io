---
layout: post
title: linux下出现死机的处理方法
date: '2019-08-29 22:37'
tags:
  - 死机
categories:
  - 工具
abbrlink: 8229
---

服务器中Linux系统出现死机后的处理：查看系统**日志**，定位死机原因

> linux系统： CentOS

<!--more-->

## 查看运行日志

### TTY文字界面

按`Ctrl+Alt+F1`,就会切换到TTY文字界面

> `Ctrl + Alt + Backspace`重启 X server
### log

- `/var/log/message`: 系统启动后的信息和错误日志
- `/var/log/secure`: 与安全相关的日志信息
- `/var/log/maillog`: 与邮件相关的日志信息
- `/var/log/cron`: 与定时任务相关的日志信息
- `/var/log/spooler`: 与UUCP和news设备相关的日志信息
- `/var/log/boot.log`: 守护进程启动和停止相关的日志消息
- `/var/log/wtmp`: 永久记录每个用户登录、注销及系统的启动、停机的事件
- `/var/run/utmp`: 记录当前正在登录系统的用户信息；
- `/var/log/btmp`: 记录失败的登录尝试信息。

### /var/log/messages

> 用于记录系统常见的系统和服务错误信息.

如果系统默认没有开启，打开方法：

将`/etc/rsyslog.d/50-default.conf`文件中的相关注释去掉

```
#
# Some "catch-all" log files.
#
#*.=debug;\
#   auth,authpriv.none;\
#   news.none;mail.none -/var/log/debug
#*.=info;*.=notice;*.=warn;\
#   auth,authpriv.none;\
#   cron,daemon.none;\
#   mail,news.none      -/var/log/messages
#
```
去掉第`4`行到第`10`行的`#`注释，并重启`rsyslog`服务：

```
sudo /etc/init.d/rsyslog restart
```
**注**：如果 /var/log/messages 被写满，导致空间被占用较多，可以查看下哪些内容被写入到文件了，然后在`/etc/rsyslog.d/50-default.conf`文件中注释掉即可.

## reisb

利用`reisub`,可以在各种情况下安全地重启计算机

在系统正常启动后需要激活内核`sysrq`功能:
```
echo "1" > /proc/sys/Kernel/sysrq

sysctl -w kernel.sysrq=1
```
或者，修改`/etc/sysctl.conf`文件，设置`kernel.sysrq = 1`

> 方法： 按住 `Alt+Print(Sys Rq)`,然后依次按下 `reisub` 这几个键,按完`b`系统就会重启。

- `r`: unRaw 将键盘控制从 X Server 那里抢回来
- `e`: tErminate 给所有进程发送 SIGTERM 信号,让他们自己解决善后
- `i`: kIll 给所有进程发送 SIGKILL 信号,强制他们马上关闭
- `s`: Sync 将所有数据同步至磁盘
- `u`: Unmount 将所有分区挂载为只读模式
- `b`: reBoot 重启


## 判断死机情况

- 在桌面卡死不动的情况下，可以通过键盘`Caps Lock/Num Lock/Scroll Lock`按键按后,判断对应LED可以正常亮灭，确定属于X server崩溃，还是内核崩溃
  - LED亮灭正常，属于X server崩溃
  - LED灯没反应，属于内核崩溃

## Kdump + crash

`kdump`是一种基于kexec的内核崩溃转储技术。kdump需要两个内核，分别是生产内核和捕获内核，生产内核是捕获内核服务的对象，且保留了内存的一部分给捕获内核启动使用。当系统崩溃时，kdump使用kexec启动捕获内核，以相应的ramdisk一起组建一个微环境，用以对生产内核下的内存进行收集和转存。

`kexec`是一个Linux内核到内核的引导加载程序，可以帮助从第一个内核的上下文引导到第二个内核。kexec会关闭第一个内核，绕过BIOS或固件阶段，并跳转到第二个内核。当第一个内核崩溃时第二个内核启动，第二个内核用于复制第一个内核的内存转储，可以使用gdb和crash等工具分析崩溃的原因。

`crash`用于调试内核崩溃的转储文件

![kdump-panic](/images/2019/09/kdump_panic.png)

>[A Kexec Based Kernel Crash Dumping Mechanism](http://lse.sourceforge.net/kdump/documentation/ols2005-kdump-presentation.pdf)

### CentOS 7

> Linux localhost.localdomain 4.14.0-115.10.1.el7a.aarch64 #1 SMP Tue Jul 30 14:50:37 UTC 2019 aarch64 aarch64 aarch64 GNU/Linux

#### 安装kexec-tools

```
# yum install kexec-tools
```
#### 配置GRUB2中的内存

- 在内核崩溃后，转存coredump文件所需的内存大小，配置参数`crashkernel=[size]`

>配置文件： /etc/default/grub

```
GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR="$(sed 's, release .*$,,g' /etc/system-release)"
GRUB_DEFAULT=saved
GRUB_DISABLE_SUBMENU=true
GRUB_TERMINAL_OUTPUT="console"
GRUB_CMDLINE_LINUX="crashkernel=auto rd.lvm.lv=centos/root rd.lvm.lv=centos/swap"
GRUB_DISABLE_RECOVERY="true"
```
**注**：在网络大多数的文章说`crashkernel=128M或512M`，但是测试直接配置`crashkernel=auto`同样可以转存coredump文件

> 在Linux4.15中使用`crashkernel=auto`，内核将通过`memblock_find_in_range`自动计算小内核的内存大小和起始位置，但是有些内核可能不支持，需要手动指定大小
> ``` C
>  if (!high)                                                             
     crash_base = memblock_find_in_range(CRASH_ALIGN,                   
                 CRASH_ADDR_LOW_MAX,                                    
                 crash_size, CRASH_ALIGN);                              
 if (!crash_base)                                                       
     crash_base = memblock_find_in_range(CRASH_ALIGN,                   
                 CRASH_ADDR_HIGH_MAX,                                   
                 crash_size, CRASH_ALIGN);                              
> ```
> file：arch/x86/kernel/setup.c

- 如果修改grub文件后，需要重新生成grub文件

```
grub2-mkconfig -o /boot/grub2/grub.cfg
```

 **注意不同的系统可能使用的grub不同**

```
ls -ls /boot/grub2
0 lrwxrwxrwx. 1 root root 25 Aug 13 04:34 grubenv -> ../efi/EFI/centos/grubenv
```

#### 配置kdump

>配置文件路径： `/etc/kdump.conf`

```
path /var/crash   #指定coredump文件放在/var/crash文件夹中
core_collector makedumpfile -l --message-level 1 -d 31
default reboot    #生成coredump后，重启系统
```

#### 开启kdump

- 检查内核启动命令

```
$ cat /proc/cmdline
BOOT_IMAGE=/vmlinuz-4.14.0-115.10.1.el7a.aarch64 root=/dev/mapper/centos-root ro crashkernel=auto rd.lvm.lv=centos/root rd.lvm.lv=centos/swap LANG=en_US.UTF-8
```

- 开启kdump服务

```
systemctl enable kdump.service  #设置开机启动
systemctl start kdump.service   #启动kdump
```

#### 测试kdump

```
# systemctl is-active kdump
active
```

- 查看捕获内核是否加载

```
# cat /sys/kernel/kexec_crash_loaded
1
```

- 查看当前的保留内存

```
cat /sys/kernel/kexec_crash_size
536870912
```
> 保留内存大小：512M
> cat /proc/iomem | grep "Crash kernel" 应该有一个分配的范围。

```
dmesg | grep crashkernel
```

- 查看kdump服务状态

```
# service kdump status
Redirecting to /bin/systemctl status kdump.service
● kdump.service - Crash recovery kernel arming
   Loaded: loaded (/usr/lib/systemd/system/kdump.service; enabled; vendor preset: enabled)
   Active: active (exited) since Wed 2019-09-04 02:04:18 EDT; 1h 8min ago
  Process: 1825 ExecStart=/usr/bin/kdumpctl start (code=exited, status=0/SUCCESS)
 Main PID: 1825 (code=exited, status=0/SUCCESS)
    Tasks: 0
   CGroup: /system.slice/kdump.service

Sep 04 02:04:16 localhost.localdomain dracut[3545]: drwxr-xr-x   2 root     root            0 Sep  4  2019 usr/share/zoneinfo/America
Sep 04 02:04:16 localhost.localdomain dracut[3545]: -rw-r--r--   1 root     root         3519 Jul 10 17:44 usr/share/zoneinfo/America/New_York
Sep 04 02:04:16 localhost.localdomain dracut[3545]: drwxr-xr-x   2 root     root            0 Sep  4  2019 var
Sep 04 02:04:16 localhost.localdomain dracut[3545]: lrwxrwxrwx   1 root     root           11 Sep  4  2019 var/lock -> ../run/lock
Sep 04 02:04:16 localhost.localdomain dracut[3545]: lrwxrwxrwx   1 root     root            6 Sep  4  2019 var/run -> ../run
Sep 04 02:04:16 localhost.localdomain dracut[3545]: ========================================================================
Sep 04 02:04:16 localhost.localdomain dracut[3545]: *** Creating initramfs image file '/boot/initramfs-4.14.0-115.10.1.el7a.aarch64kdump.img' done ***
Sep 04 02:04:18 localhost.localdomain kdumpctl[1825]: kexec: loaded kdump kernel
Sep 04 02:04:18 localhost.localdomain kdumpctl[1825]: Starting kdump: [OK]
Sep 04 02:04:18 localhost.localdomain systemd[1]: Started Crash recovery kernel arming.
```

```
# echo 1 > /proc/sys/kernel/sysrq
# echo c > /proc/sysrq-trigger
```
> - `c`: Will perform a system crash by a NULL pointer dereference.(故意使内核崩溃)

这将强制Linux内核崩溃，并且`loaclhost(ip)-YYYY-MM-DD-HH：MM：SS/vmcore`文件将被复制到配置中选择的位置, 默认`/var/crash`


#### 用crash工具分析

- 安装对应的kernel-debuginfo软件包,[地址](http://debuginfo.centos.org/7/)

> 内核版本：`uname -r` 4.14.0-115.10.1.el7a.aarch64

``` shell
wget http://debuginfo.centos.org/7/aarch64/kernel-debuginfo-$(uname -r).rpm
wget http://debuginfo.centos.org/7/aarch64/kernel-debuginfo-common-aarch64-$(uname -r).rpm
```

``` shell
# rpm -ivh kernel-debuginfo-common-aarch64-4.14.0-115.10.1.el7a.aarch64.rpm
# rpm -ivh kernel-debuginfo-4.14.0-115.10.1.el7a.aarch64.rpm
```

```
ls /usr/lib/debug/lib/modules/4.14.0-115.10.1.el7a.aarch64/vmlinux
/usr/lib/debug/lib/modules/4.14.0-115.10.1.el7a.aarch64/vmlinux
```

- 启动crash

```
crash /usr/lib/debug/lib/modules/4.14.0-115.10.1.el7a.aarch64/vmlinux /var/crash/127.0.0.1-2019-09-04-10\:02\:53/vmcore
```
在输入`bt`可以展示kernel-stack的backtrace，更多crash中的命令见`man crash`

### ubuntu18.04

#### 安装crashdump工具包

```
sudo apt-get install linux-crashdump
```
> linux-crashdump实际上安装了三个工具，分别是：crash，kexec-tools，以及makedumpfile


#### 开启kdump服务

```
service kdump start
```

#### 查看kdump配置

```
$kdump-config show
DUMP_MODE:        kdump
USE_KDUMP:        1
KDUMP_SYSCTL:     kernel.panic_on_oops=1
KDUMP_COREDIR:    /var/crash
crashkernel addr: 0x
   /var/lib/kdump/vmlinuz: symbolic link to /boot/vmlinuz-4.15.0-58-generic
kdump initrd:
   /var/lib/kdump/initrd.img: symbolic link to /var/lib/kdump/initrd.img-4.15.0-58-generic
current state:    ready to kdump

kexec command:
  /sbin/kexec -p --command-line="BOOT_IMAGE=/vmlinuz-4.15.0-58-generic root=UUID=1ff21bc1-eece-439d-a3ab-de37bc03537f ro quiet splash vt.handoff=1 nr_cpus=1 systemd.unit=kdump-tools-dump.service irqpoll nousb ata_piix.prefer_ms_hyperv=0" --initrd=/var/lib/kdump/initrd.img /var/lib/kdump/vmlinuz
```

#### Crash文件分析

crash工具需要内核调试信息`dbgsym`

- 安装dbgsym，下载[地址](http://ddebs.ubuntu.com/pool/main/l/linux/)

```
cat /proc/version
Linux version 4.15.0-58-generic (buildd@lcy01-amd64-013) (gcc version 7.4.0 (Ubuntu 7.4.0-1ubuntu1~18.04.1)) #64-Ubuntu SMP Tue Aug 6 11:12:41 UTC 2019
```

```
wget http://ddebs.ubuntu.com/pool/main/l/linux/linux-image-4.15.0-58-generic-dbgsym_4.15.0-58.64_arm64.ddeb
```

```
sudo dpkg -i linux-image-unsigned-4.15.0-58-generic-dbgsym_4.15.0-58.64_amd64.ddeb

$ ls -lsh /usr/lib/debug/boot/vmlinux-4.15.0-58-generic
566M -rw-r--r-- 1 root root 566M 8月   6 18:45 /usr/lib/debug/boot/vmlinux-4.15.0-58-generic
```

```
sudo crash /usr/lib/debug/boot/vmlinux-4.15.0-58-generic /var/crash/201909041647/dump.201909041647
```


## ubuntu apport

`apport`就是ubuntu上的"crash report"服务，就是当有程序崩溃时弹出的那个发送error report的程序窗口, 并在`/var/crash/`中将保存一个`*.crash`的文件，其中存在CoreDump转储文件和当前崩溃程序运行环境的信息，可以解压获取并通过gdb获取相关信息。

``` shell
apport-unpack systemGeneratedCrashReportPath.crash yourNewUnpackDirectoryHere
cd yourNewUnpackDirectoryHere/
gdb `cat ExecutablePath` CoreDump #(pay attention to tildes here!)
bt  #(output actual back-trace)
```
``` shell
$cat ExecutablePath
/usr/lib/x86_64-linux-gnu/piglit/bin/shader_runner
```

### 配置apport

> 默认属于开启状态

- 关闭`crash report`服务，修改`/etc/default/apport`文件中的`enabled=0`

```
# set this to 0 to disable apport, or to 1 to enable it
# you can temporarily override this with
# sudo service apport start force_start=1
enabled=1
```



## 参考

- [Kdump 实现的基本原理](https://www.ibm.com/developerworks/cn/linux/l-cn-kdump3/index.html?ca=drs-)
- [kdump 的亲密战友 crash](https://www.ibm.com/developerworks/cn/linux/l-cn-kdump4/index.html?ca=drs-)
- [CentOS7配置kdump](https://www.jianshu.com/p/8e031b28d98b)
- [centos配置kdump捕获内核崩溃](http://www.361way.com/centos-kdump/3751.html)
- [CentOS / RHEL 7 : How to configure kdump](https://www.thegeekdiary.com/centos-rhel-7-how-to-configure-kdump/)
