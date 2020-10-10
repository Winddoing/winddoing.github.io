---
layout: post
title: SElinux与文件属性权限
date: '2020-09-22 17:20'
tags:
  - 权限
  - SElinux
categories:
  - 文件系统
abbrlink: 38ee39e7
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

传统的Linux系统中，默认权限是对文件或目录的所有者、所属组和其他人的读、写和执行权限进行控制，这种控制方式称为`自主访问控制（DAC）`方式；而在 SELinux 中，采用的是`强制访问控制（MAC）`系统，也就是控制一个进程对具体文件系统上面的文件或目录是否拥有访问权限，而判断进程是否可以访问文件或目录的依据，取决于 SELinux 中设定的很多策略规则

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


## SELinux安全上下文

``` shell
$ls -Zd tmp/
drwxr-xr-x. root root unconfined_u:object_r:unlabeled_t:s0 tmp
```
> 目录

安全上下文使用`:`分隔为5字段，只是最后一个“类别”字段是可选的

```
system_u：object_r：httpd_sys_content_t：s0：[类别]
#身份字段：角色：类型：灵敏度：[类别]
```
- `unconfined_u`: (身份字段)一个普通的标签，该标签表示不受SELinux的限制（没有约束）
- `object_r`:（角色字段）这里代表该数据目录（文件）
- `unlabeled_t`: （类型字段）无效的标签，该文件被创建是没有有效的SELinux上下文进行关联，因此在某些应用读写该文件时将无法操作。需要给其一个有效的`type`,一般与读写的应用类型一样
- `s0`:（灵敏度）

### 身份字段（user)

用于标识该数据被哪个身份所拥有，相当于权限中的用户身份。这个字段并没有特别的作用

``` shell
[root@localhost ~]# seinfo -u
Users：9
sysadm_u
system_u
xguest_u
root
guest_u
staff_u
user_u
unconfined_u
git_shell_u
```
### 角色（role）

主要用来表示此数据是进程还是文件或目录

``` shell
[root@localhost ~]# seinfo -r
Roles：12
guest_r
staff_r
user_r
git_shell_r
logadm_r
object_r
sysadm_r
system_r
webadm_r
xguest_r
nx_server_r
unconfined_r
```

- `object_r`：代表该数据是文件或目录，这里的`_r`代表 role。
- `system_r`：代表该数据是进程，这里的`_r`代表 role。

### 类型（type）

类型字段是安全上下文中最重要的字段，进程是否可以访问文件，主要就是看进程的安全上下文类型字段是否和文件的安全上下文类型字段相匹配，如果匹配则可以访问

> **注意**:类型字段在文件或目录的安全上下文中被称作类型（type），但是在进程的安全上下文中被称作域（domain）。也就是说，在主体（Subject）的安全上下文中，这个字段被称为域；在目标（Object）的安全上下文中，这个字段被称为类型。域和类型需要匹配（进程的类型要和文件的类型相匹配），才能正确访问。

``` shell
[root@localhost ~]# seinfo -t | more
Types：3488
#共有3488个类型
bluetooth_conf_t
cmirrord_exec_t
foghorn_exec_t
jacorb_port_t
sosreport_t
etc_runtime_t
...
```

### 灵敏度

灵敏度一般是用`s0`、`s1`、`s2`来命名的，数字代表灵敏度的分级。数值越大，代表灵敏度越高

### 类别

类别字段不是必须有的，所以我们使用 ls 和 ps 命令查询的时候并没有看到类别字段

## 修改SELinux上下文——type

``` shell
chcon -R -t public_content_t /var/ftp
```

``` shell
chcon -R -t bin_t tmp/
```

## 删除SELinux上下文

> `setfacl -b` will remove the ACL on a file. `setfattr -x security.selinux` will remove the SELinux file context, but you will probably have to boot with SELinux completely disabled.

``` shell
setfattr -x security.selinux tmp/test.txt
```

批量处理：
``` shell
find tmp/ -exec setfattr -h -x security.selinux {} \;
```

## 参考

- [linux初学者-SElinux篇](https://www.cnblogs.com/davidshen/p/8145946.html)
- [Linux文件权限属性后面有个点](https://www.cnblogs.com/xiaoyanger/p/7264151.html)
- [SELinux安全上下文查看方法（超详细）](http://c.biancheng.net/view/1149.html)
- [unconfined_t vs unlabeled_t in SELinux](https://stackoverflow.com/questions/58444157/unconfined-t-vs-unlabeled-t-in-selinux)
- [How do I remove any SELinux context or ACL?](https://superuser.com/questions/191903/how-do-i-remove-any-selinux-context-or-acl)
