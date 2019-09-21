---
layout: post
title: 升级Centos7系统内核版本（for arm64）
date: '2019-09-21 09:54'
tags:
  - centos
categories:
  - 系统服务
---

升级CentOS7中的内核版本：

<!--more-->


## Q&A

### 认证错误

```
target `certs/centos.pem', needed by `certs/x509_certificate_list'.  Stop
```
- 注释掉`.config`中的相关配置
  ```
  CONFIG_SYSTEM_TRUSTED_KEYS="certs/centos.pem"
  ```
- [Attempting to compile any kernel yields a certification error](https://unix.stackexchange.com/questions/293642/attempting-to-compile-any-kernel-yields-a-certification-error/294116)
- [Kernel module signing facility](https://www.kernel.org/doc/html/v5.3-rc8/admin-guide/module-signing.html)

## 参考

- [Bug#823107: marked as done (linux: make deb-pkg fails: No rule to make target 'debian/certs/benh@debian.org.cert.pem')](https://lists.debian.org/debian-kernel/2016/04/msg00579.html)
- [https://blog.ziki.cn/post/compile-kernel/](https://blog.ziki.cn/post/compile-kernel/)
