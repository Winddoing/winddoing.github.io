---
title: tftp
date: 2018-05-8 23:07:24
categories: 常用工具
tags: [tftp]
---

tftp:

<!--more-->


## 安装

### 软件包：

`tftpd（服务端）`，`tftp（客户端）`，`xinetd` 

```
sudo apt-get install tftpd tftp xinetd
```

### 建立配置文件：

```
vi /etc/xinetd.d/tftp

service tftp
{
    protocol        = udp
    port            = 69
    socket_type     = dgram
    wait            = yes
    user            = nobody
    server          = /usr/sbin/in.tftpd
    server_args     = /home/xxx/tftprootfs
    disable         = no
}
```

### 重启服务

```
sudo /etc/init.d/xinetd restart
```

## 本地测试

```
$tftp localhost
tftp> get aaa
Received 8 bytes in 0.0 seconds
```

## 开发板使用

下载：

```
tftp –gr 源文件名  服务器地址  
```

上传：

```
tftp –pr 目标文件名 服务器地址
```

