---
layout: post
title: scoop for window
date: '2020-07-01 22:56'
tags:
  - scoop
  - 包
  - window
categories:
  - 工具
abbrlink: 5c8794fe
---

Window下的包管理工具,便于开发环境的搭建和软件安装

<!--more-->

系统版本：`window10 2004`

## 安装

安装scoop或者choco都需要powershell的支持

```powershell
# 开启脚本权限
Set-ExecutionPolicy RemoteSigned -scope CurrentUser
# 安装
iwr -useb get.scoop.sh | iex
#or
Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
```

> 如果不使用VPNscoop的安装由于下载慢而中断导致失败，那么必须先删除`C:\Users\scoop`文件夹(默认路径可自定义)，再执行以上命令安装。

- 指定安装路径(指定SCOOP的路径到环境变量)

  ```
  [environment]::setEnvironmentVariable('SCOOP','C:\Scoop','User')
  $env:SCOOP='C:\Scoop'
  iex (new-object net.webclient).downloadstring('https://get.scoop.sh')
  ```

- 添加官网扩展支持

  ```
  scoop bucket add extras
  scoop bucket add versions
  ```

  > https://github.com/lukesampson/scoop-extras

## 帮助文档

```powershaell
Usage: scoop <command> [<args>]

Some useful commands are:

alias       管理 scoop 别名
bucket      管理 Scoop buckets
cache       显示/清理下载缓存
checkup     检查可能存在的问题
cleanup     移除旧版本清理应用
config      获取或设置配置值
create      创建一个自定义的app manifest
depends     列出一个app的依赖关系
export      导出（可导入的）已安装应用程序列表
help        显示一个命令的帮助
home        打开一个app 的主页
info        显示一个app的相关信息
install     安装 apps
list        列出已安装的 apps
prefix      返回指定应用程序的路径
reset       重置应用程序以解决冲突
search      搜索可用应用
status      显示状态并检查新的应用程序版本
uninstall   卸载 app
update      更新 apps 和更新 Scoop
virustotal  在virustotal.com上查找应用程序的哈希
which       找到一个shim/可执行文件（类似于Linux上的which）
```

## Scoop示例

### reset

```
scoop install python27 python
python --version # -> Python 3.6.2

# switch to python 2.7.x
scoop reset python27
python --version # -> Python 2.7.13

# switch back (to 3.x)
scoop reset python
python --version # -> Python 3.6.2
```

### 导出安装软件列表

```
scoop export > app_list.txt
```

### 更新所有安装软件

```
scoop update * && scoop cleanup *
```

## 参考

- [Scoop](https://scoop.sh/)
