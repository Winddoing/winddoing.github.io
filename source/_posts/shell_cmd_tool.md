---
date: '2015-06-18 01:49'
layout: post
title: 常用的shell命令
tags:
  - shell
categories:
  - shell
abbrlink: 1644
---

常用的shell命令： `find`, `cat`

<!-- more -->

## 字符串转二进制

``` shell
echo 001122334455 | xxd -r -ps > test            // 6 个字节
```
- `xxd` :用于用二进制或十六进制显示文件的内容
- `-r`  :把xxd的十六进制输出内容转换回原文件的二进制内容
- `-ps` :以postscript的连续十六进制转储输出，这也叫做纯十六进制转储

## 查看中断与CPU的绑定关系

``` shell
cat /proc/interrupts | grep intel | cut -d: -f1 | while read i; do echo -ne irq":$i\t bind_cpu: "; cat /proc/irq/$i/smp_affinity_list; done | sort -n -t' ' -k3
```

## 内存读写速度测试

``` shell
dd if=/dev/zero of=/dev/null bs=1M count=1024
```

## 查看当前CPU运行频率

``` shell
watch -n 0.1 "cat /proc/cpuinfo | grep \"^[c]pu MHz\""
```

## 文件指定行数的字符大写转小写

``` shell
find -name "*.md" | xargs sed -i '4,9s/.*/\L&/'
```

## 删除所有文件行尾空格

``` shell
find source/_posts/ -name "*.md" | xargs sed -i 's/[ ]*$//g'
```

## 进程CPU占有率排序

``` shell
ps H -eo user,pid,ppid,tid,time,%cpu,cmd --sort=%cpu
```

## 判断进程在哪个CPU核运行的方法

### ps

``` shell
ps -o pid,psr,cmd -p <pid>
```
> `PSR`: 进程分配的CPU id

### top

`top`命令也可以显示CPU被分配给哪个进程

- 进入`top`后，按`f`键，出现Fields Management管理界面，(空格键选中)选择`P`选项(P = Last Used Cpu (SMP))
- top界面中目前使用的CPU将出现在"P"（或“PSR”）列下


``` shell
top -p <pid>
```
> 查看单独一个进程的信息

## 杀死僵尸进程

``` shell
kill -HUP <PID>
```

## iptux--局域网数据传输--飞秋

> Linux中的iptux与window中的飞秋可以相互进行文件传输

``` shell
sudo apt install iptux
```
- 调整防火墙以允许使用TCP/UDP`2425`端口
```
sudo ufw allow 2425
```

- 中文乱码
设置编码方式: `cp936`(or `gbk`)
> 工具栏设置: Tools -> Preferences -> System -> Candidate network conding: `cp936`

- 配置文件
  - 配置文件: `.iptux/config.json`
  - 日志: `.config/iptux/`


## 数据销毁和日志清理

### bleachbit

> bleachbit 是一款开源免费的系统清理工具，功能类似 Windows 平台的 CCleaner


### shred

> shred 功能简单的说就是涂鸦，把一个文件用随机的字符码篡改的一塌糊涂。其宗旨就是更安全地帮助删除一个机密文件

### wipe

> 可安全地删除磁存储器中的文件，后续无法恢复已删除文件或目录的内容。

## CPU信息

- lscpu
- lshw

``` shell
# lscpu
...
Byte Order:            Little Endian
CPU(s):                256
On-line CPU(s) list:   0-255
Thread(s) per core:    4
Core(s) per socket:    32
Socket(s):             2
NUMA node(s):          2
Model:                 1
CPU max MHz:           2500.0000
CPU min MHz:           1000.0000
BogoMIPS:              400.00
```
- `socket`: 主板上插CPU槽的数量
- `core`: CPU上的核数(物理核)
- `thread`: core上的硬件线程数(逻辑核)

## nproc

> 获取可用CPU的数量

``` shell
nproc
```

## apt build-dep

``` shell
sudo apt-get build-dep mesa
```
> build-dep causes apt-get to install/remove packages in an attempt to satisfy the build dependencies for a source package. By default the dependencies are satisfied to build the package natively. If desired a host-architecture can be specified with the `--host-architecture` option instead.

根据源码编译时所需的关系包进行搜索并下载安装.建立要编译软件的环境.

``` shell
$sudo apt build-dep mesa
Reading package lists... Done
Reading package lists... Done
Building dependency tree
Reading state information... Done
The following NEW packages will be installed:
  autopoint debhelper dh-autoreconf dh-strip-nondeterminism lib32gcc1 lib32stdc++6 libc6-i386 libclang-9-dev libclang-common-9-dev libclang1-9
  libclc-dev libfile-stripnondeterminism-perl libglvnd-core-dev libobjc-7-dev libobjc4 libpfm4 libset-scalar-perl libva-dev libva-glx2
  libvdpau-dev libvulkan-dev llvm-9 llvm-9-dev llvm-9-runtime llvm-9-tools po-debconf python-pygments python-yaml python3-pygments quilt
The following packages will be upgraded:
  cpp-7 g++-7 gcc-7 gcc-7-base gcc-8-base libasan4 libatomic1 libcc1-0 libcilkrts5 libgcc-7-dev libgcc1 libgomp1 libitm1 liblsan0 libmpx2
  libquadmath0 libstdc++-7-dev libstdc++6 libtsan0 libubsan0
20 upgraded, 30 newly installed, 0 to remove and 44 not upgraded.
Need to get 101 MB of archives.
After this operation, 477 MB of additional disk space will be used.
Do you want to continue? [Y/n]
```

## tasksel

`tasksel`命令是用来安装“任务”的，任务就是一些软件的组合，比如LAMP这个任务，就是由apache，php，MySQL等软件包组成，tasksel安装任务就是安装一系列的软件包而已。

> 通过tasksel可以直接在server版，进行ubuntu桌面的安装


### ubuntu Desktop

```
sudo apt update
sudo apt upgrade
sudo tasksel
```
> tasksel选择ubuntu Desktop进行安装，等待安装完成

```
sudo tasksel install ubuntu-desktop
```

```
$tasksel --list-tasks
u kubuntu-live	Kubuntu live CD
u lubuntu-live-gtk	Lubuntu live CD (GTK part)
u ubuntu-budgie-live	Ubuntu Budgie live CD
u ubuntu-live	Ubuntu live CD
u ubuntu-mate-live	Ubuntu MATE Live CD
u ubuntustudio-dvd-live	Ubuntu Studio live DVD
u vanilla-gnome-live	Ubuntu GNOME live CD
u xubuntu-live	Xubuntu live CD
u cloud-image	Ubuntu Cloud Image (instance)
u dns-server	DNS server
u kubuntu-desktop	Kubuntu desktop
u kubuntu-full	Kubuntu full
u lamp-server	LAMP server
u lubuntu-core	Lubuntu minimal installation
u lubuntu-desktop	Lubuntu Desktop
u lubuntu-gtk-core	Lubuntu minimal installation (GTK part)
u lubuntu-gtk-desktop	Lubuntu Desktop (GTK part)
u lubuntu-qt-core	Lubuntu minimal installation (Qt part)
u lubuntu-qt-desktop	Lubuntu Qt Desktop (Qt part)
i mail-server	Mail server
u postgresql-server	PostgreSQL database
i print-server	Print server
i samba-server	Samba file server
u ubuntu-budgie-desktop	Ubuntu Budgie desktop
i ubuntu-desktop	Ubuntu desktop
u ubuntu-mate-core	Ubuntu MATE minimal
u ubuntu-mate-desktop	Ubuntu MATE desktop
u ubuntustudio-audio	Audio recording and editing suite
u ubuntustudio-desktop	Ubuntu Studio desktop
u ubuntustudio-desktop-core	Ubuntu Studio minimal DE installation
u ubuntustudio-fonts	Large selection of font packages
u ubuntustudio-graphics	2D/3D creation and editing suite
u ubuntustudio-photography	Photograph touchup and editing suite
u ubuntustudio-publishing	Publishing applications
u ubuntustudio-video	Video creation and editing suite
u vanilla-gnome-desktop	Vanilla GNOME desktop
u xubuntu-core	Xubuntu minimal installation
u xubuntu-desktop	Xubuntu desktop
i openssh-server	OpenSSH server
u server	Basic Ubuntu server
```


## find

``` shell
[root@linfeng etc]# find . -type f -name "*" | xargs grep "root/init.sh"
```

* `-type f` : 表示只找文件
* `-name "xxx"` :  表示查找特定文件；也可以不写，表示找所有文件

### 批量修改文件名后缀

>mv ./htxynl.f90 ./htxynl.f77

```
find . -name "*.f90" | awk -F "." '{print $2}' | xargs -i -t mv .{}.f90  .{}.f77
```

## cat

>cat和重定向进行写文件操作

``` shell
=====>$cat > test.sh << EOF
> this is test
EOF
```
结束方式：
- 输入`EOF`，最好使用EOF
- 使用`Ctrl+d`

写入方式：
* `>` : 以覆盖文件内容的方式，若此文件不存在，则创建
* `>>` : 以追加的方式写入文件

## tee

``` shell
make USE_NINJA=false USE_CLANG_PLATFORM_BUILD=false 2>&1 | tee build.log
```

## ssh

### 跨服务器拷贝文件
``` shell
xbin="u-boot-with-spl-mbr-gpt.bin"
xdst="user@192.168.10.44:/home/user/x2000_ddr_test"

scp $xbin fpga@192.168.4.13:/tmp/$xbin
ssh fpga@192.168.4.13 "scp /tmp/$xbin $xdst"
```
### ssh的key值

1. 权限必须是`600`
```
chmod 600 ~/.ssh/authorized_keys
```
2. 添加key值
```
ssh-add ~/.ssh/authorized_keys
```
3. 查看生效key值
```
ssh-add -l
```
4. 测试key值
```
ssh -T git@github.com
```
5. 免密登录
```
ssh-copy-id ssh name@ip
```
6. 使用多个key值
>man ssh_config

```
cp /etc/ssh/ssh_config ~/.ssh/config
```
编辑~/.ssh/config
```
...
#   StrictHostKeyChecking ask
    IdentityFile ~/.ssh/id_rsa
    IdentityFile ~/.ssh/xxxx
#   IdentityFile ~/.ssh/id_dsa
#   IdentityFile ~/.ssh/id_ecdsa
#   IdentityFile ~/.ssh/id_ed25519
...
```

### ssh登录到远程的特定目录

``` shell
ssh -t xx@192.168.1.1 "cd /home/xx/test; bash"
```
或
``` shell
ssh -t xx@192.168.1.1 "cd /home/xx/test && bash"
```
- `-t` :标志用于强制分配伪终端


### 通过root账户ssh登录

> 在ubuntu系统中默认不能使用root账户进行ssh登录

开启root账户登录ssh，打开`/etc/ssh/sshd_config`配置

```
PermitRootLogin yes
```
> 默认配置`#PermitRootLogin prohibit-password`

重启ssh服务
``` shell
sudo systemctl restart sshd.service
```

### ssh数据的压缩传输

```
ssh -CX xxx@192.168.1.1
```
- `-C`: 压缩传输模式
- `-X`: 启用X11转发,远程打开使用图形应用

## tftp

> 开发板（busybox）


``` shell
tftp -g -r user/xxxx/system.tar 192.168.4.13
```

tftp的服务器(PC):

``` shell
# /etc/default/tftpd-hpa

TFTP_USERNAME="tftp"
TFTP_DIRECTORY="/home/"
TFTP_ADDRESS="0.0.0.0:69"
TFTP_OPTIONS="--secure"
```
> file: /etc/default/tftpd-hpa


## cpio

>解压，制作 ramdisk

* 解压
``` shell
gunzip rootfs.cpio.gz
mkdir tmp
cd tmp
cpio -i -F ../rootfs.cpio
```
>code: [unzip_ramdisk.sh](https://raw.githubusercontent.com/Winddoing/MyCode/master/android/debug/unzip_ramdisk.sh)

* 制作
``` shell
find . | cpio -o -Hnewc |gzip -9 > ../image.cpio.gz
```
>`-H`: 选项指定打包文件的具体格式，要生成init ramfs，只能用`newc`格式

## minicom

记录串口的输出日志：

``` shell
#!/bin/sh

mkdir dd
echo "while [ 1 ];do killall minicom; sleep 36000;done" > ./b.sh
chmod +x ./b.sh
./b.sh &

while [ 1 ]
do
	ff=`date +%Y%m%d%H%M`;
	echo $ff;
	minicom -w -C ./dd/$ff -o;
done
```

### ttyUSB0权限问题

每次使用串口工具时，需要sudo权限，为了普通用户方便可以通过以下命令解决：

```
sudo usermod -a -G dialout ${USER}
```
> 设置后需要重启电脑，使用minicom时不用sudo

### 串口输出增加时间戳：
```
Ctrl + a ; n
```

### 串口打印内存信息：
```
Ctrl + a; f; m
```
>`Ctrl + a; f`(send break)进行发送命令，`m`查看当前内存状态的命令
> 类似与：`echo m > /proc/sysrq-trigger `

| break signal | |
| :----------: | :----: |
| m | 查看当前内存状态的命令 |

>内核提供接口`drivers/tty/sysrq.c`,通过按键的方式获取内核的调试信息

```
static struct sysrq_key_op *sysrq_key_table[36] = {
	&sysrq_loglevel_op,		/* 0 */
	&sysrq_loglevel_op,		/* 1 */
	&sysrq_loglevel_op,		/* 2 */
	&sysrq_loglevel_op,		/* 3 */
	&sysrq_loglevel_op,		/* 4 */
	&sysrq_loglevel_op,		/* 5 */
	&sysrq_loglevel_op,		/* 6 */
	&sysrq_loglevel_op,		/* 7 */
	&sysrq_loglevel_op,		/* 8 */
	&sysrq_loglevel_op,		/* 9 */

	/*
	 * a: Don't use for system provided sysrqs, it is handled specially on
	 * sparc and will never arrive.
	 */
	NULL,				/* a */
	&sysrq_reboot_op,		/* b */
	&sysrq_crash_op,		/* c & ibm_emac driver debug */
	&sysrq_showlocks_op,		/* d */
	&sysrq_term_op,			/* e */
	&sysrq_moom_op,			/* f */
	/* g: May be registered for the kernel debugger */
	NULL,				/* g */
	NULL,				/* h - reserved for help */
	&sysrq_kill_op,			/* i */
#ifdef CONFIG_BLOCK
	&sysrq_thaw_op,			/* j */
#else
	NULL,				/* j */
#endif
	&sysrq_SAK_op,			/* k */
#ifdef CONFIG_SMP
	&sysrq_showallcpus_op,		/* l */
#else
	NULL,				/* l */
#endif
	&sysrq_showmem_op,		/* m */
	&sysrq_unrt_op,			/* n */
	/* o: This will often be registered as 'Off' at init time */
	NULL,				/* o */
	&sysrq_showregs_op,		/* p */
	&sysrq_show_timers_op,		/* q */
	&sysrq_unraw_op,		/* r */
	&sysrq_sync_op,			/* s */
	&sysrq_showstate_op,		/* t */
	&sysrq_mountro_op,		/* u */
	/* v: May be registered for frame buffer console restore */
	NULL,				/* v */
	&sysrq_showstate_blocked_op,	/* w */
	/* x: May be registered on ppc/powerpc for xmon */
	/* x: May be registered on sparc64 for global PMU dump */
	NULL,				/* x */
	/* y: May be registered on sparc64 for global register dump */
	NULL,				/* y */
	&sysrq_ftrace_dump_op,		/* z */
};
 ```

#### enable the magic SysRq key

> https://www.kernel.org/doc/html/latest/admin-guide/sysrq.html

配置内核时，您需要对'Magic Sysrq键（CONFIG_MAGIC_SYSRQ=y)。在运行使用SYSRQ的内核时，`/proc/sys/kernel/sysrq`控制通过SYSRQ键调用允许的函数。该文件中的默认值由CONFIG_MAGIC_SYSRQ_DEFAULT_ENABLE设置，该值默认为1。

`/proc/proc/sys/kernel/sysrq`中可能值的列表：
- 0 - disable sysrq completely
- 1 - enable all functions of sysrq

* 参考配置

```
CONFIG_MAGIC_SYSRQ=y
CONFIG_MAGIC_SYSRQ_DEFAULT_ENABLE=0x1
CONFIG_MAGIC_SYSRQ_SERIAL=y
```

### kermit文件传输

- 安装ckermit

```
sudo apt install ckermit
```
> 注：ubuntu20.04没有ckermit，可以手动下载ubuntu18.04的版本安装，自测可用。

- 配置kermit

在配置文件`/etc/kermit/kermrc`中追加以下配置：
```
set line          /dev/ttyUSB0
set speed         115200
set carrier-watch off
set handshake     none
set flow-control none
robust
set file type     bin
set file name     lit
set rec pack      1000
set send pack     1000
set window        5
```

- 文件发送

快捷键：`Ctrl + a + s`，选择`kermit`

## sshfs

```
sudo sshfs xxx@192.168.1.2:/home_back/xxx/work/aaa /home/user/aaa -o gid=1000,uid=1000,allow_other
```
## md5sum --- 字符串

``` shell
$echo -n '123456' | md5sum
e10adc3949ba59abbe56e057f20f883e  -
```

## 查看硬盘型号和序列号

``` shell
sudo hdparm -i /dev/sda
```

## 获取计算机硬件信息

``` shell
sudo dmidecode
```
> dmidecode遵循SMBIOS/DMI标准，其输出的信息包括BIOS、系统、主板、处理器、内存、缓存等等。

## 格式化xml

``` shell
xmllint --format run_xunit.xml
```
> 在vim中直接敲xml,进行格式化

## tldr

> Too Long Don’t Read!

查找各种命令的常用例子

``` shell
sudo apt install tldr
```

``` shell
$tldr ps
ps
Information about running processes.

 - List all running processes:
   ps aux

 - List all running processes including the full command string:
   ps auxww

 - Search for a process that matches a string:
   ps aux | grep {{string}}

 - List all processes of the current user in extra full format:
   ps --user $(id -u) -F

 - List all processes of the current user as a tree:
   ps --user $(id -u) f

 - Get the parent pid of a process:
   ps -o ppid= -p {{pid}}
```


## top

命令相关参数

| 参数  | 作用  |
|:-:|:-:|
| `1`  | 显示每个CPU的运行情况  |
| `z`  | 进入高亮模式（终端红色字体）  |
| `b`  | 高亮显示正在运行的命令  |
| `c`  | 显示command列的所有信息，包括参数  |
| `t`  | 更直观的方式展示task/cpu信息，像htop一样  |
| `m`  | 更直观的方式展示memory信息，像htop一样  |
| `M`  | 根据内存使用率进行排序，%MEM列  |
| `P`  | 根据CPU使用率进行排序，%CPU列  |

## sed

>参考：[sed命令详解](https://www.cnblogs.com/edwardlost/archive/2010/09/17/1829145.html)

### 将当前目录(包括子目录)文件中的特定字符串并进行替换

``` shell
sed -i s/jpeg_encode.h/jpeg_codec.h/g `grep jpeg_encode.h -rl --include="*.c" ./`
```
- `-i` :表示操作的是文件
- `反引号` :表示将grep命令的的结果作为操作文件

### 当前目录文件替换

``` shell
sed -i s/xxxx/yyyy/g ./*.txt
```

## pkg-config

> 用于获得某一个库/模块的所有编译相关的信息

``` shell
$pkg-config --libs --cflags gl
-I/usr/include/libdrm -lGL
```

### pkg-config默认的搜索路径

``` shell
$pkg-config --variable pc_path pkg-config
/usr/local/lib/x86_64-linux-gnu/pkgconfig:/usr/local/lib/pkgconfig:/usr/local/share/pkgconfig:/usr/lib/x86_64-linux-gnu/pkgconfig:/usr/lib/pkgconfig:/usr/share/pkgconfig
```
### PKG_CONFIG_PATH

配置pkgconfig文件路径

``` shell
echo $PKG_CONFIG_PATH
```

## 运行时库的连接

- 在环境变量`LD_LIBRARY_PATH`中指明库的搜索路径。
- 在`/etc/ld.so.conf`文件中添加库的搜索路径。

### LD_LIBRARY_PATH

配置运行时加载库的路径

``` shell
echo $LD_LIBRARY_PATH
```

## 命令行直接打开浏览器进入指定网页

```
$firefox --new-window https://winddoing.github.io
```
## 命令行直接打开文件管理（ubuntu）

```
$nautilus
```

## 参考

1. [minicom中文手册](https://www.cnblogs.com/my-blog/archive/2008/12/10/1351753.html)
