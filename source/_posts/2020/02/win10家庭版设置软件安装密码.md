---
layout: post
title: win10家庭版设置软件安装密码——本地组策略编辑器
date: '2020-02-08 20:16'
tags:
  - win10
  - window
categories:
  - 工具
---

win10版本：`家庭版`
操作系统版本：`18363.592`

> 设置软件安装密码

<!--more-->

## 本地组策略编辑器

设置方法通过`gpedit.msc`本地组策略，但是win10家庭版中找不到gpedit.msc，需要手动添加网上找的脚本（测试有效）
```
@echo off  
pushd "%~dp0"  
dir /b C:\Windows\servicing\Packages\Microsoft-Windows-GroupPolicy-ClientExtensions-Package~3*.mum >List.txt  
dir /b C:\Windows\servicing\Packages\Microsoft-Windows-GroupPolicy-ClientTools-Package~3*.mum >>List.txt  
for /f %%i in ('findstr /i . List.txt 2^>nul') do dism /online /norestart /add-package:"C:\Windows\servicing\Packages\%%i"  
pause
```

> win10专业版默认自带本地组策略编辑器

## 设置软件安装策略

![win10_gpdeit](/images/2020/02/win10_gpdeit.png)

双击打开一个用户帐户控制：`管理审批模式下管理员的提升提示行为` 属性窗口，下拉菜单中点击【提示凭据】


## 禁止系统软件安装

> 本地组策略编辑器（gpedit.msc） -> 计算机配置 -> 管理模板 -> Window组件 -> Window Installer -> 禁止用户安装 -> （已启用）
