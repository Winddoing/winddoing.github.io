---
layout: post
title: libvirt透传qemu参数
date: '2020-09-19 22:40'
tags:
  - qemu
  - libvirt
categories:
  - 虚拟机
  - libvirt
abbrlink: 549bb2ea
---

在使用virsh通过libvirt接口创建虚拟机时，存在一些qemu的启动参数或者系统环境变量而libvirt接口不支持，因此需要将参数直接透传到qemu的启动命令。

新创建的每一个虚拟机都有一个`xml配置文件`，用来定义该虚拟机的配置，因此可以直接在该xml文件中利用`qemu:commandline `标记添加需要透传的`参数`或`环境变量`

<!--more-->

## 编辑XML文件

```xml
<domain type='kvm'>
  <name>QEMUGuest1</name>
  <uuid>c7a5fdbd-edaf-9455-926a-d65c16db1809</uuid>
  ...
  <commandline xmlns="http://libvirt.org/schemas/domain/qemu/1.0">
    <qemu:arg value='-newarg'/>
    <qemu:arg value='parameter'/>
    <qemu:env name='ID' value='wibble'/>
    <qemu:env name='BAR'/>
  </commandline>
</domain>
```

## virt-xml

```shell
$virt-xml $DOMAIN --edit --confirm --qemu-commandline '-newarg parameter'
```

## libvirt函数接口添加

## 参考

- [QEMU command-line passthrough](https://www.libvirt.org/kbase/qemu-passthrough-security.html)
- [](http://blog.vmsplice.net/2011/04/how-to-pass-qemu-command-line-options.html)
