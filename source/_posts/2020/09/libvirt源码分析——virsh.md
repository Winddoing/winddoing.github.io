---
layout: "post"
title: "libvirt源码分析——virsh"
date: "2020-09-17 11:49"
tags:
  - virsh
  - libvirt
categories:
  - 虚拟机
  - libvirt
---

libvirt是用来管理虚拟机或虚拟化功能的软件集合，主要包括：`libvirt API`，`libvirtd进程`和`virsh`工具集三部分。最初的目的是为不同的hypervisor提供统一的管理接口

> `libvirt`是将最底层的直接在shell中输入命令来完成的操作进行了抽象封装，给应用程序开发人员提供了统一的，易用的接口。

<!--more-->

libvirt版本：`libvirt-4.9.0`

## libvirt层次体系结构

![libviry_api](/images/2020/09/libviry_api.png)

参照上图，来理一下通过virsh命令或接口创建虚拟机实例的代码执行路径：
1. virsh命令或API接口c创建虚拟机 —— 接口层
```
virsh create vm.xml 或者 virDomainPtr virDomainCreateXML (virConnectPtr conn, const char * xmlDesc, unsigned int flags)
```
> file: src/libvirt-domain.c

2. 调用libvirt提供的统一接口 —— 抽象驱动层
```
conn->driver->domainCreateXML(conn, xmlDesc, flags);  //此处的domainCreateXML即抽象的统一接口，这里并不需要关心底层的driver是kvm，还是xen
```

3. 调用底层的相应虚拟化技术的接口 —— 具体驱动层
```
domainCreateXML = qemuDomainCreateXML; //如果driver=qemu，那么此处即调用的qemu注册到抽象驱动层上的函数qemuDomainCreateXML
```

4. 拼装shell命令，并执行

### 抽象驱动层

目前，libvirt以下几种类型的抽象驱动，每一种类型的驱动代表某以功能模块的抽象封装：
- 虚拟化驱动(virDriverPtr)
- 虚拟网络驱动(virNetworkDriverPtr)
- 物理网卡驱(virInterfaceDriverPtr)
- 存储驱动(virStorageDriverPtr)
- 监控驱动(virDeviceMonitorPtr)
- 安全驱动(virSecretDriverPtr)
- 过滤驱动(virNWFilterDriverPtr)
- 状态驱动(virStateDriverPtr)

### virsh start vm-name

``` shell
virsh start vm-name
```
>启动一个虚拟机

## daemon进程（libvirtd ）
该后台进程主要实现以下功能：
1. 远程代理
      所有remote client发送来的命令，由该进程监测执行
2. 本地环境初始化
      libvirt服务的启停，用户connection的响应等
3. 根据环境注册各种Driver（qemu, xen, storage…）的实现
     不同虚拟化技术以Driver的形式实现，由于libvirt对外提供的是统一的接口，所以各个Driver就是实现这些接口， 即将Driver注册到libvirt中

## virsh API调用

> 将libvirt API封装，以Command Line Interface提供的对外接口

``` shell
$virsh define /path-vm-xml/vm_name.xml
$virst start vm-name
```

virsh命令与代码结构之间的关系：

| 文件名                 | 对应vshCmdDef变量     | 对应virsh命令        |
| ---------------------- | --------------------- | -------------------- |
| virsh-domain-monitor.c | domMonitoringCmds     | virsh XX(虚拟机监控) |
| virsh-domain.c         | domManagementCmds     | virsh XX(虚拟机操作) |
| virsh-host.c           | hostAndHypervisorCmds | virsh XX(虚拟机配置) |
| virsh-interface.c      | ifaceCmds             | virsh iface-XX       |
| virsh-network.c        | networkCmds           | virsh net-XX         |
| virsh-nodedev.c        | nodedevCmds           | virsh net-XX         |
| virsh-nwfilter.c       | nwfilterCmds          | virsh nwfilter-XX    |
| virsh-pool.c           | storagePoolCmds       | virsh pool-XX        |
| virsh-secret.c         | secretCmds            | virsh secret-XX      |
| virsh-snapshot.c       | snapshotCmds          | virsh snapshot-XX    |
| virsh-volume.c         | storageVolCmds        | virsh vol-XX         |

有了上面的表格我们就能够根据使用的**virsh命令**找到对应文件的对应**vshCmdDef变量**，在virsh中相关命令实现与具体API的调用文件相对于`tools/virsh-domain.c` <=> `src/libvirt-domain.c`

> 一个`vshCmdDef`结构对应一个`virsh`命令，其中`vshCmdOptDef`定义了命令的参数，`vshCmdInfo`定义了命令的帮助信息，`bool (*handler) (vshControl *, const vshCmd *)`定义了命令的处理函数。

### domManagementCmds

``` C
const vshCmdDef domManagementCmds[] = {             
    {.name = "attach-device",                       
     .handler = cmdAttachDevice,                    
     .opts = opts_attach_device,                    
     .info = info_attach_device,                    
     .flags = 0                                     
    },                                              
    ...
    {.name = "start",                   
     .handler = cmdStart,               
     .opts = opts_start,                
     .info = info_start,                
     .flags = 0                         
    },                                  
    ...
```
> file: tools/virsh-domain.c

启动虚拟机的主要工作：
``` shell
virst start vm-name
```
start命令的处理流程是`cmdStart`

``` C
static bool                                       
cmdStart(vshControl *ctl, const vshCmd *cmd)      
{                                                 
    ...
    if ((nfds ?                                               
         virDomainCreateWithFiles(dom, nfds, fds, flags) :    
         virDomainCreateWithFlags(dom, flags)) == 0)          
        goto started;                                         
    ...
}
```
- `virDomainCreateWithFiles`: 启动已定义的域。如果调用成功，则域将从已定义的域池移动到正在运行的域池
- `virDomainCreateWithFlags`: 启动已定义的域。如果调用成功，则域将从已定义的域池移动到正在运行的域池

```
virDomainCreateWithFiles
  \-> conn->driver->domainCreateWithFiles
```

```
virDomainCreateWithFlags
  \-> conn->driver->domainCreateWithFlags
      \-> qemuDomainCreateWithFlags
        \-> qemuProcessStart
          \->
```
> file: src/qemu/qemu_driver.c

## libvirt for qemu

由于libvirt是将最底层需要执行的shell命令进行了抽象封装，供上层应用使用。因此在其封装的借口中必须存在一个`shell运行环境`
- 底层qemu的命令何时被创建？
- 底层shell环境的搭建？
- 如何执行的该命令？

## 配置QEMU环境变量与参数

``` xml
<domain type='kvm' xmlns:qemu='http://libvirt.org/schemas/domain/qemu/1.0'>
  ...
  <devices>
    <emulator>/usr/bin/qemu-system-x86_64</emulator>
  </devices>
  <qemu:commandline>
    <qemu:arg value='-newarg'/>
    <qemu:env name='QEMU_ENV' value='VAL'/>
  </qemu:commandline>
</domain>
```
或
``` xml
<qemu:commandline xmlns:qemu='http://libvirt.org/schemas/domain/qemu/1.0'>     
  <qemu:arg value='ARGUMENT'/>                                                 
</qemu:commandline>                                                            
```

在xml配置文件中必须指定`<domain type='kvm' xmlns:qemu='http://libvirt.org/schemas/domain/qemu/1.0'>`,因为默认的`<domain type='kvm'>`不支持`qemu:commandline`的标签

- https://libvirt.org/drvqemu.html#qemucommand

## 参考

- [libvirt架构及源码分析](http://blog.chinaunix.net/uid-26133817-id-4909216.html)
- [virsh commands cheatsheet to manage KVM guest virtual machines](https://computingforgeeks.com/virsh-commands-cheatsheet/)
- [How to pass QEMU command-line options through libvirt](http://blog.vmsplice.net/2011/04/how-to-pass-qemu-command-line-options.html)
- [QEMUSwitchToLibvirt(-s)](https://wiki.libvirt.org/page/QEMUSwitchToLibvirt#-s_2)
