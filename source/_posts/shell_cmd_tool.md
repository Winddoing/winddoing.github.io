---
date: '2015-06-18 01:49'
layout: post
title: 常用的shell命令
tags:
  - Shell
categories:
  - shell
abbrlink: 1644
---

常用的shell命令： `find`, `cat`

<!-- more -->

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

* 串口输出增加时间戳：
```
Ctrl + a ; n
```

* 串口打印内存信息：
```
Ctrl + a; f; m
```
>`Ctrl + a; f`(send break)进行发送命令，`m`查看当前内存状态的命令

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

```
$pkg-config --libs --cflags gl
-I/usr/include/libdrm -lGL
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
