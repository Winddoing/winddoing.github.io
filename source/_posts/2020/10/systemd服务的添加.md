---
layout: post
title: systemd服务的添加
date: '2020-10-30 15:49'
tags:
  - systemd
  - linux
  - 服务
categories:
  - 系统服务
---


在linux的平时使用中，需要一些常驻后台的程序，这些为了方便操作可以将其作成一个systemd服务，通过systemd的操作命令进行管理。

<!--more-->

systemd服务的目录`/usr/lib/systemd/system`下添加`test.service`
```
[Unit]
Description=Test service

[Service]
Environment="LD_LIBRARY_PATH=/usr/local/lib/:/usr/local/lib64/"
Environment="MY_ENV=123"
ExecStart=/bin/testcmd

[Install]
WantedBy=multi-user.target
```
- 开启：`systemctl start test`
- 关闭：`systemctl stop test`

## 添加环境变量

```
[Service]
Environment="LD_LIBRARY_PATH=/usr/local/lib/:/usr/local/lib64/"
Environment="MY_ENV=123"
```
> `systemctl --help`

`EnvironmentFile`关键字是在环境变量配置较多的情况下，可以编辑到一个文件通过该变量一次性导入，编辑文件的一行为一个环境变量的定义。

## Unit模板

模板文件的主要特点是，文件名以`@`符号结尾，而启动的时候指定的Unit名称为模板名称附加一个参数字符串,比如`test@.service`, 在服务启动时可以在`@`后面放置一个用于区分服务实例的附加字符串参数,这样在参数将会传入到服务启动文件，在文件内部可以通过占位符`%i`获取服务启动是传入的参数，从而达到启动多个服务实例的目的。

- 启动：`systemctl start test@1` 这样`1`将传入服务编辑文件，可以通过`%i`传给服务启动的进程中

```
[Unit]
Description=Test service mul

[Service]
Environment="LD_LIBRARY_PATH=/usr/local/lib/:/usr/local/lib64/"
Environment="MY_ENV=123"
ExecStart=/bin/testcmd  %i #传入的参数

[Install]
WantedBy=multi-user.target
```

| 占位符  | 作用  |
|:-:|:-:|
| `%n`  | 完整的 Unit 文件名字，包括 .service 后缀名  |
| `%m`  | 实际运行的节点的 Machine ID，适合用来做Etcd路径的一部分，例如 /machines/%m/units  |
| `%b`  | 作用有点像 Machine ID，但这个值每次节点重启都会改变，称为 Boot ID  |
| `%H`  | 实际运行节点的主机名  |
| `%p`  | Unit 文件名中在 @ 符号之前的部分，不包括 @ 符号  |
| `%i`  | Unit 文件名中在 @ 符号之后的部分，不包括 @ 符号和 .service 后缀名  |



## 参考

- [可能是史上最全面易懂的 Systemd 服务管理教程！( 强烈建议收藏 )](https://cloud.tencent.com/developer/article/1516125)
- [How to set environment variable in systemd service?](https://serverfault.com/questions/413397/how-to-set-environment-variable-in-systemd-service)
