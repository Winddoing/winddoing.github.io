---
layout: post
title: window下的包管理工具
date: '2020-07-04 22:19'
tags:
  - choco
  - scoop
  - window
  - 包
categories:
  - 工具
  - window
abbrlink: f9f0e3bd
---

在window10中微软开发了`winget`包管理工具,但是由于时间问题可以安装的软件包比较少,以后可能会好些.

除了`winget`,还有一些第三方包管理工具,比较好的有`choco`和`scoop`,但是由于scoop的仓库依赖github,可能有时由于网络的原因导致无法安装使用,如果网络正常可以参考[scoop](https://winddoing.github.io/post/5c8794fe.html)使用起来有点像ubuntu下的apt-get,还挺好用.如果网络不能用,使用`choco`虽然慢点但是还能下载安装,同样简化了软件的安装.

<!--more-->

## winget

暂时没有使用过,以后可能也不会使用了呵呵呵

## choco

- 官网: https://chocolatey.org

通过`CMD`进行安装,需要`管理员`权限
```
@powershell -NoProfile -ExecutionPolicy unrestricted -Command "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
```

```
choco --help
```
> 可以安装的软件包:https://chocolatey.org/packages

### 本地已安装软件

```
choco list -lo
```

## scoop

> [scoop for window](https://winddoing.github.io/post/5c8794fe.html)
