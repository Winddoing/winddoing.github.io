---
date: '2015-04-16 03:49'
layout: post
title: 【转】micro2440 移植boa服务器
thread: 166
categories: 系统应用
tags:
  - boa
  - arm
abbrlink: 62852
---

Boa是一种非常小巧的Web服务器，其可执行代码只有大约60KB左右。作为一种单任务Web服务器，Boa只能依次完成用户的请求，而不会fork出新的进程来处理并发连接请求。但Boa支持CGI，能够为CGI程序fork出一个进程来执行。Boa的设计目标是速度和安全。
　　
下面结合网上一些文档,及自己的实验给大家介绍一下Boa服务器移植的具体操作步骤。
　　
环境
	主机：redhat linux
	目标：Micro2440开发板

 <!---more--->
### 1.下载Boa源码

下载地址: http://www.boa.org/
最新发行版本： 0.94.13
下载 boa-0.94.13.tar.gz
将其拷贝到/opt/FriendlyARM/boa文件夹（自己创建的FriendlyARM/boa目录）解压：# tar xzf boa-0.94.13.tar.gz

### 2.修改文件

#### (1)修改boa-0.94.13的 src/compat.h文件
　　找到

		#define TIMEZONE_OFFSET(foo) foo##->tm_gmtoff

　　修改成

		#define TIMEZONE_OFFSET(foo) (foo)->tm_gmtoff

　　否则会出现错误：

		util.c:100:1: error: pasting "t" and "->" does not give a valid preprocessing token make: *** [util.o] 错误 1

#### (2)修改boa-0.94.13的src/log.c

　　注释掉

		if (dup2(error_log, STDERR_FILENO) == -1) {
			DIE("unable to dup2 the error log");
		}

　　为：

		/*if (dup2(error_log, STDERR_FILENO) == -1) {
		DIE("unable to dup2 the error log");
		}*/

　　否则会出现错误：

		log.c:73 unable to dup2 the error log:bad file deor

#### (3)修改boa-0.94.13的src/boa.c

　　注释掉下面两句话：

		if (passwdbuf == NULL) {
			DIE(”getpwuid”);
		}
		if (initgroups(passwdbuf->pw_name, passwdbuf->pw_gid) == -1) {
			DIE(”initgroups”);
		}

　　为

		#if 0
		if (passwdbuf == NULL) {
			DIE(”getpwuid”);
		}
		if (initgroups(passwdbuf->pw_name, passwdbuf->pw_gid) == -1) {
			DIE(”initgroups”);
		}
		#endif

　　否则会出现错误：

		boa.c:211 - getpwuid: No such file or directory

　　注释掉下面语句：

		if (setuid(0) != -1) {
			DIE(”icky Linux kernel bug!”);
		}
　　为
		#if 0
		if (setuid(0) != -1) {
			DIE(”icky Linux kernel bug!”);
		}
		#endif
　　否则会出现问题：
		boa.c:228 - icky Linux kernel bug!: No such file or directory
### 3、生成Makefile文件
　　执行：

　　#cd /opt/FriendlyARM/boa/boa-0.94.13/src
　　#./configure

### 4、修改Makefile

　　#cd /opt/FriendlyARM/boa/boa-0.94.13/src

　　vim Makefile

　　修改CC = gcc 为 CC = arm-linux-gcc
　　修改CPP = gcc -E 为 CC = arm-linux-gcc -E

### 5、编译

　　还是在/opt/FriendlyARM/boa/boa-0.94.13/src目录下

		#make

		ls -l boa
		-rwxr-xr-x 1 root root 189223 Jun 26 09:02 boa

　　然后为生成的二进制文件boa瘦身

		arm-linux-strip boa

		ls -l boa
		-rwxr-xr-x 1 root root 59120 Jun 26 09:03 boa

　　可以发现boa的大小前后差距很大这为我们节省了很大的空间

### 6、Boa的配置

　　这一步的工作也在电脑虚拟机上完成。
　　在boa-0.94.13目录下已有一个示例boa.conf，可以在其基础上进行修改。如下：

　　#vi boa.conf

#### (1)Group的修改

　　修改 Group nogroup
　　为 Group 0

#### (2)user的修改

　　修改 User nobody
　　为 User 0
    或者统一设置为
        User root
        Group root
#### (3)ScriptAlias的修改

　　修改ScriptAlias/cgi-bin/ /usr/lib/cgi-bin/
　　为 ScriptAlias/cgi-bin/ /www/cgi-bin/

#### (5)DoucmentRoot的修改
　　修改DoucmentRoot /var/www
　　为DoucmentRoot /www

#### (6)ServerName的设置
　　修改#ServerName www.your.org.here
　　为 ServerName www.your.org.here
　　否则会出现错误“gethostbyname::No such file or directory”

#### (7)AccessLog修改
　　修改AccessLog /var/log/boa/access_log
　　为#AccessLog /var/log/boa/access_log
否则会出现错误提示：“unable to dup2 the error log: Bad file deor”

### 7、以下配置和boa.conf的配置有关，都是在mini2440开发板的ARM根文件系统中创建：
　　创建目录/etc/boa并且把主机的boa可执行文件（/opt/FriendlyARM/boa/boa-0.94.13/src） 和 boa.conf（/opt/FriendlyARM/boa/boa-0.94.13）拷贝到这个目录下

　　#mkdir /etc/boa

**注**：boa.conf配置文件必须放在/etc/boa中。boa可执行文件位置可随意，否则启动boa将报错。
>Could not chdir to "/etc/boa": aborting

　　创建HTML文档的主目录/www

　　#mkdir /www

　　创建CGI脚本所在录 /www/cgi-bin

		#mkdir /www/cgi-bin

	在www下添加测试主页index.html

		<head>
		<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
		<meta http-equiv="Content-Type" content="text/html; charset=gb2312" />
		<title>Test Boa</title>
		</head>
		<body>
			Hello BOA<br>
		</body>
		</html>


	创建日志文件夹 /var/log

		#mkdir /var/log

### 8.执行boa服务器

进入/etc/boa目录，修改boa的执行权限，

		#chmod +x boa
		#./boa
开启boa

### 9.在windows xp ie输入开发板的ip（http://192.168.1.230）地址，即可访问到mini2440的默认网页。
