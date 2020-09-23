---
layout: post
title: SElinux与文件属性权限
date: '2020-09-22 17:20'
tags:
  - 权限
  - SElinux
categories:
  - 文件系统
---

文件属性与权限的相关记录：

``` shell
[root@test ~]# ls -lsh /dir-path
8.9M -rw-r--r--. 1 root root 8.9M 9月
 66M -rw-r--r--. 1 root root  66M 9月
1.8M -rw-r--r--. 1 root root 1.8M 9月
```
> 在文件的属性权限后面出现了一个小点`.`, 这是在SElinux开启的情况下创建的文件所有，表示文件带有“SELinux的安全上下文”。

<!--more-->

- 开启了SELinux功能的Linux系统就会有这个点。
- 这个点表示文件带有“SELinux的安全上下文”。
- 关闭SELinux，新创建的文件就不会再有这个点了。
- 但是，以前创建的文件本来有这个点的还会显示这个点（虽然SELinux不起作用了）。

``` shell
# ll
-rwxr-xr--  root root    #没有selinux上下文，没有ACL
-rwx--xr-x+ root root    #只有ACL，没有selinux上下文
-rw-r--r--. root root    #只有selinux上下文，没有ACL
-rwxrwxr--+ root root    #有selinux上下文，有ACL
```

## 关闭SElinux——永久

``` shell
vi /etc/sysconfig/selinux
SELINUX=disabled
```
### 在线关闭selinux——临时

``` shell
setenforce 0
```

## 查看状态

``` shell
sestatus
```

``` shell
getenforce
```
SElinux的状态分为以下三种：
- `Enforcing`    （1）   强制模式
- `Permissive`   （0）   警告模式
  - `Disabled`          关闭模式

## SELinux权限

- `ls -Z`: 可以查看文件所拥有的SELinux权限的具体信息
- `chcon`: 手动修改文件的SELinux安全上下文
- `restorecon`: 恢复为默认的SELinux权限类型
- `semanage`: 查询/修改/增加/删除文件的默认SELinux权限类型

## 参考

- [linux初学者-SElinux篇](https://www.cnblogs.com/davidshen/p/8145946.html)
- [Linux文件权限属性后面有个点](https://www.cnblogs.com/xiaoyanger/p/7264151.html)
