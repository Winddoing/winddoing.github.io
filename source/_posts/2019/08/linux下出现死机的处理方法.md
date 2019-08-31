---
layout: post
title: linux下出现死机的处理方法
date: '2019-08-29 22:37'
tags:
  - 死机
categories:
  - 工具
---

服务器中Linux系统出现死机后的处理：

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
