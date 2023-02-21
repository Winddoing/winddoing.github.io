---
date: 2014-5-23
layout: post
title: redhat更新yum源进行软件在线安装
thread: 164
categories:
  - 软件使用
  - yum
tags:
  - yum
  - redhat
abbrlink: 44387
---

### yum安装

* YUM是Redhat Linux在线安装更新及软件的工具，但是这是RHEL5的收费功能，如果没有购买Redhat的服务时不能使用RHEL5的更新源的，会提示注册。由于CentOS是从Redhat演化而来的免费Linux版本，因此可以利用CentOS的yum更新源来实现RHEL5的YUM功能。

* 配置方法如下：检查yum是否安装，默认情况下都是安装好的，总共4各包

		[root@localhost /]# rpm -qa |grep yum
		yum-3.2.22-20.el5
		yum-security-1.1.16-13.el5
		yum-metadata-parser-1.1.2-3.el5
		yum-updatesd-0.9-2.el5
		yum-rhn-plugin-0.5.4-13.el5
<!---more--->
### 更新yum源

* 修改/etc/yum.conf文件，用下面代码全部覆盖。定义yum更新源，这里使用的是上海交大的CentOS更新源

		[main]

		cachedir=/var/cache/yum

		keepcache=1

		debuglevel=2

		logfile=/var/log/yum.log

		pkgpolicy=newest

		distroverpkg=redhat-release

		tolerant=1

		exactarch=1

		obsoletes=1

		gpgcheck=1

		plugins=1

		[base]
		name=CentOS-5-Base
		#mirrorlist=http://mirrorlist.centos.org/?release=$releasever5&arch=$basearch&repo=os
		#baseurl=http://mirror.centos.org/centos/$releasever/os/$basearch/
		baseurl=http://ftp.sjtu.edu.cn/centos/5/os/$basearch/
		gpgcheck=0
		gpgkey=http://mirror.centos.org/centos/RPM-GPG-KEY-centos5
		#released updates
		[update]
		name=CentOS-5-Updates
		#mirrorlist=http://mirrorlist.centos.org/?release=4&arch=$basearch&repo=updates
		baseurl=http://ftp.sjtu.edu.cn/centos/5/updates/$basearch/
		gpgcheck=0
		gpgkey=http://mirror.centos.org/centos/RPM-GPG-KEY-centos5
		#packages used/produced in the build but not released
		[addons]
		name=CentOS-5-Addons
		#mirrorlist=http://mirrorlist.centos.org/?release=4&arch=$basearch&repo=addons
		baseurl=http://ftp.sjtu.edu.cn/centos/5/addons/$basearch/
		gpgcheck=0
		gpgkey=http://mirror.centos.org/centos/RPM-GPG-KEY-centos5
		#additional packages that may be useful
		[extras]
		name=CentOS-5-Extras
		#mirrorlist=http://mirrorlist.centos.org/?release=4&arch=$basearch&repo=extras
		baseurl=http://ftp.sjtu.edu.cn/centos/5/extras/$basearch/
		gpgcheck=0
		gpgkey=http://mirror.centos.org/centos/RPM-GPG-KEY-centos5
		#additional packages that extend functionality of existing packages
		[centosplus]
		name=CentOS-5-Plus
		#mirrorlist=http://mirrorlist.centos.org/?release=4&arch=$basearch&repo=centosplus
		baseurl=http://ftp.sjtu.edu.cn/centos/5/centosplus/$basearch/
		gpgcheck=0
		enabled=0
		gpgkey=http://mirror.centos.org/centos/RPM-GPG-KEY-centos5
		#contrib - packages by Centos Users
		[contrib]
		name=CentOS-5-Contrib
		#mirrorlist=http://mirrorlist.centos.org/?release=4&arch=$basearch&repo=contrib
		baseurl=http://ftp.sjtu.edu.cn/centos/5/contrib/$basearch/
		gpgcheck=0
		enabled=0
		gpgkey=http://mirror.centos.org/centos/RPM-GPG-KEY-centos5
		# vi dag.repo
		[dag]
		name=Dag RPM Repository for RHEL5
		baseurl=http://ftp.riken.jp/Linux/dag/redhat/el5/en/$basearch/dag/
		enabled=1
		gpgcheck=0
		gpgkey=http://ftp.riken.jp/Linux/dag/packages/RPM-GPG-KEY.dag.txt]

* 修改yum.conf配置文件中[main]部分的参数详细说明如下：


        [main] //main开头的块用于对客户端进行配置，在main后也可以指定yum源（不推荐这样做），与/etc/yum.repo.d中指定yum源相同

		cachedir=/var/cache/yum
		#cachedir：yum更新软件时的缓存目录，默认设置为/var/cache/yum
		keepcache=[1 or 0]

		#设置 keepcache=1，yum 在成功安装软件包之后保留缓存的头文件 (headers) 和软件包。默认值为 keepcache=0 不保存

		debuglevel=2
		#debuglevel：Debug信息输出等级，范围为0-10，缺省为2
		logfile=/var/log/yum.log
		#logfile：存放系统更新软件的日志的目录。用户可以到/var/log/yum.log文件去查询自己在过去的日子里都做了哪些更新。
		pkgpolicy=newest
		#包的策略。一共有两个选项，newest和last，这个作用是如果你设置了多个repository，而同一软件在不同的repository中同时存在，yum应该安装哪一个，如果是newest，则yum会安装最新的那个版本。如果是last，则yum会将服务器id以字母表排序，并选择最后的那个服务器上的软件安装。一般都是选newest。
		distroverpkg=redhat-release
		#指定一个软件包，yum会根据这个包判断你的发行版本，默认是redhat-release，也可以是安装的任何针对自己发行版的rpm包。
		tolerant=1
		#如果值为1，则yum会忽略任何的有关包的错误。举例来说，当执行yum来安装baz时，如果baz包已经安装在系统中了，则yum会继续重复安装baz，而不会报错。默认值为1。
		exactarch=1
		#设置为1，则yum只会安装和系统架构匹配的软件包，例如，yum不会将i686的软件包安装在适合i386的系统中。默认为1
		retries=20
		#网络连接发生错误后的重试次数，如果设为0，则会无限重试。默认值为6
		obsoletes=1
		#此选项在进行发行版跨版本升级的时候会用到。
		gpgcheck=1
		#有1和0两个选择，分别代表是否是否进行gpg校验。这个选项如果设置在[main]部分，则对每个repository都有效。默认值为0.
		plugins = 1 //是否启用插件，默认1为允许，0表示不允许


* 修改完yum.conf文件，使用下列命令进行配置。

		yum clean all    清楚缓存
		yum makecache    更新生成缓存

### 使用yum安装软件

### 1. 用YUM安装删除软件

* 注：Yum（ Yellow dog Updater, Modified）是一个在Fedora和RedHat以及SUSE中的Shell前端软件包管理器。基于RPM包管理，能够从指定的服务器自动下载RPM包并且安装，可以自动处理依赖性关系，并且一次安装所有依赖的软体包，无须繁琐地一次次下载、安装。

* 在系统中添加删除软件是常事，yum同样可以胜任这一任务，只要软件是rpm安装的。安装的命令是，yum install xxx，yum会查询数据库，有无这一软件包，如果有，则检查其依赖冲突关系，如果没有依赖冲突，那么最好，下载安装;如果有，则会给出提示，询问是否要同时安装依赖，或删除冲突的包，你可以自己作出判断。删除的命令是，yum remove xxx，同安装一样，yum也会查询数据库，给出解决依赖关系的提示。

- 用YUM安装软件包命令：

		yum install xxx

- 用YUM删除软件包命令：

	yum remove xxx

### 2. 用YUM查询软件信息

* 我们常会碰到这样的情况，想要安装一个软件，只知道它和某方面有关，但又不能确切知道它的名字。这时yum的查询功能就起作用了。
你可以用 yum  search keyword这样的命令来进行搜索，比如我们要则安装一个Instant Messenger,但又不知到底有哪些，这时不妨用yum search messenger这样的指令进行搜索，yum会搜索所有可用rpm的描述，列出所有描述中和messeger有关的rpm包，于是我们可能得到gaim,kopete等等，并从中选择。有时我们还会碰到安装了一个包，但又不知道其用途，我们可以用yum info packagename这个指令来获取信息。

　　使用YUM查找软件包命令：

		yum search

　　列出所有可安装的软件包命令：

		yum list

　　列出所有可更新的软件包命令：

		yum list updates

　　列出所有已安装的软件包命令：

		yum list installed

　　列出所有已安装但不在 Yum Repository 内的软件包命令：

		yum list extras

　　列出所指定的软件包命令：

		yum list

### Ubuntu中的高级包管理方法apt-get

* apt-get的一大好处是极大地减小了所谓依赖关系恶梦的发生几率(dependency hell)，即使是陷入了dependency hell,apt-get也提供了很好的援助手段。通常 apt-get 都和网上的压缩包一起出没，从互联网上下载或是安装。

### apt方式安装：

1. 打开一个终端，su -成root用户；
2. apt-cache search soft 注：soft是您要找的软件的名称或相关信息
3. 假如2中找到了软件soft.version，则用apt-get install soft.version命令安装软件 注：只要您能够上网，只需要用apt-cache search查找软件，用apt-get install软件

* 常用的APT命令参数

		apt-cache search package 搜索包
		apt-cache show package 获取包的相关信息，如说明、大小、版本等
		sudo apt-get install package 安装包
		sudo apt-get install package - - reinstall 重新安装包
		sudo apt-get -f install 修复安装"-f = --fix-missing"
		sudo apt-get remove package 删除包
		sudo apt-get remove package - - purge 删除包，包括删除配置文件等
		sudo apt-get update 更新源sudo apt-get upgrade 更新已安装的包
		sudo apt-get dist-upgrade 升级系统
		sudo apt-get dselect-upgrade 使用 dselect 升级
		apt-cache depends package 了解使用依赖
		apt-cache rdepends package 是查看该包被哪些包依赖
		sudo apt-get build-dep package 安装相关的编译环境
		apt-get source package 下载该包的源代码
		sudo apt-get clean && sudo apt-get autoclean 清理无用的包
		sudo apt-get check 检查是否有损坏的依赖

## 其他软件安装技巧

### 1. linux下安装软件，如何知道软件安装位置

>注：一般的软件的默认安装目录在/usr/local或者/opt里，可以到那里去找找.

* 指令名称：whereis

* 功能介绍：在特定目录中查找符合条件的文件。这些文件的烈性应属于原始代码，二进制文件，或是帮助文件。

* 语法格式：whereis [-bfmsu][-B <目录>...][-M <目录>...][-S <目录>...][文件...]

* 常用参数说明：

　-b 　只查找二进制文件。
　-B <目录> 　只在设置的目录下查找二进制文件。
　-f 　不显示文件名前的路径名称。
　-m 　只查找说明文件。
　-M <目录> 　只在设置的目录下查找说明文件。
　-s 　只查找原始代码文件。
　-S <目录> 　只在设置的目录下查找原始代码文件。
　-u 　查找不包含指定类型的文件。

* 应用：#whereis  软件名   -->查看软件安装路径
* #which  软件名     -->软件软件的运行路径

### 2. 通过rpm包管理器安装的软件：

- rpm包

* 可以用命令：

		#rpm –ql 包名           如 rpm -ql gcc 来查看gcc的文件都安装到哪里去了
		#rpm -qa | grep 包名   来查看有没有安装这个包 ，
		#rpm -qa              查看全部已经安装的包名

- deb包

* 可以用命令：

		#dpkg -L 包名 查看如 dpkg -L gcc 来查看gcc的文件。
		#dpkg -l | grep 包名  来查看有没有安装某个包 ，
		# dpkg -l            是查看全部包的

## 其他更多软件安装方法技巧

>参考[http://blog.chinaunix.net/uid-28769209-id-4257451.html]:http://blog.chinaunix.net/uid-28769209-id-4257451.html
