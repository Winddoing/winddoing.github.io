---
layout: post
title: 关于Win10中Linux Ubuntu子系统的相关问题
date: '2019-03-28 22:59'
tags:
  - window
categories:
  - 工具
  - window
abbrlink: 41029
---

记录window10中Linux子系统使用的相关问题和常见错误。

<!--more-->

## error: 0x800703fa

```
Installing, this may take a few minutes...
WslRegisterDistribution failed with error: 0x800703fa
Error: 0x800703fa ???????????????????????

Press any key to continue...
```
- 解决方法：
> 打开服务管理，重启`LxssManager`服务解决,并将其设置为`自动`
> 路径：开始（右键）->计算机管理 -> 服务和计算机程序 -> 服务(LxssManager)
