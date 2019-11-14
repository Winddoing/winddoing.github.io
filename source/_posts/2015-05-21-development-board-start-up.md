---
date: '2015-05-21 01:49'
layout: post
title: Micro2440开发板启动Linux
thread: 166
categories: 嵌入式
tags: ARM
abbrlink: 32798
---

### 1.Micro2440移植Linux2.6的流程
>>移植uboot->移植内核->移植文件系统

这里只记录在开发板启动时，移植的基本步骤：
### 2.烧写Linux内核镜像
#### a.修改uboot环境变量
    setenv bootargs 'root=/dev/mtdblock2 noinitrd console=ttySAC0,115200'

    setenv bootcmd 'nand read 0x30008000 0x200000 0x400000;bootm'
**注**：
root=/dev/mtdblock2指定根文件系统路径，/dev/mtdblock2表示在nandflash的第三块分区中（第一块分区用0表示）。
bootm指使用uImage引导
修改完uboot引导命令后，就制作uImage
<!---more--->
#### b.制作内核镜像
根据自己项目的需求的开发板的设计，剪裁linux内核进行编译。linux内核编译完有两种不同格式的内核镜像（uImage和zImage）。
uImage和zImage的区别：
>这两个都是内核，zImage是真正的内核，在内存中的地址0x30008000；而uImage是包含64字节头的内核，在头中存放着bootargs环境变量，在内存中的地址0x30007fc0
![uImage和zImage区别]（/images/uImage-zImage.PNG）

到这时你就要选择到底使用哪个镜像了，这里根据你uboot的环境变量bootcmd判断。
#### c.选择镜像
##### 烧写zImage
到这里想那就烧写正真的内核吧zImage，我们uboot中也是在0x30008000内存地址中启动的，将zImage烧写到nandflash启动开发板，内核启动错。

    Starting kernel ...                                                          

    test:machid:805306624                                                        
    test: bi_boot_params:0x31f5bfb8                                              
    test:starting 1                                                              
    data abort                                                                   
    pc : [<30008008>]          lr : [<31f98ba4>]                                 
    sp : 31f5ba94  ip : 30008000     fp : 31f5bca4                               
    r10: 00000000  r9 : 00000001     r8 : 31f5bfdc                               
    r7 : 00000000  r6 : 31fcbd1c     r5 : 31f5c83d  r4 : 00000000                
    r3 : 31f5bfb8  r2 : 30000100     r1 : 000000c1  r0 : 00000000                
    Flags: nZCv  IRQs off  FIQs off  Mode SVC_32                                 
    Resetting CPU ...                                

内核不断重启就是进不去，是因为缺失内核的一个头部信息，需要添加64字节的内核头，zImage也需要添加。
怎么添加头呢，需要什么工具？
编译完成uboot已经提供的这个工具**mkimage**
工具使用参数解析：

    -A指定cpu体系结构
    -O指定是什么操作系统   
    -T指定映像类型，如standalone、kernel、ramdisk、multi、firmware、script、filesystem等
    -C指定映像压缩方式，如none(不压缩)、gzip、bzip2。这里不对uImage进行压缩
    -a指定映象在内存中的加载地址，映象下载到内存中时，要按照用MKIMAGE制作映象时，这个参数所指定的地址值来下载  
    -e 指定映象运行的入口点地址，这个地址就是-a参数指定的值加上0x40（因为前面有个MKIMAGE添加的0x40个字节的头）
    -n 指定映象名  
    -d 指定制作映象的源文件

添加所需头信息：

    16:23 [root@linfeng boot]#mkimage -n 'linux-2.6' -A arm -O linux -T kernel -C none -a 0x30008000 -e 0x30008040 -d zImage zImage.img
正真内核烧写这么麻烦那就以后使用uImage
##### 烧写uImage
将uImage镜像直接烧写到nandflash，启动开发板，无法启动。
不着急刚才uboot环境变量还没有修改过来呢，重新进入uboot修改环境变量

    setenv bootcmd 'nand read 0x30007fc0 0x200000 0x400000;bootm'
=====
**经过第二次的内核烧写测试，使用该方法也不可行，同样会报出内核恐慌错误**
现在可以正常启动，成功进入内核后有出现：

    yaffs: dev is 32505858 name is "mtdblock2"                                    
    yaffs: passed flags ""                                                        
    yaffs: Attempting MTD mount on 31.2, "mtdblock2"                              
    yaffs: auto selecting yaffs2                                                                                             
    yaffs_read_super: isCheckpointed 0                                            
    VFS: Mounted root (yaffs filesystem) on device 31:2.
    Freeing init memory: 156K                                                     
    Warning: unable to open an initial console.                                   
    Kernel panic - not syncing: No init found.  Try passing init= option to kerne.
    Backtrace:                                                                    
    [<c00341cc>] (dump_backtrace+0x0/0x10c) from [<c0329f3c>] (dump_stack+0x18/0x)
    r7:00000000one_wire_status: 4                                                
     r6:00000000 r5:c001f308 r4:c0481c50                                          
    [<c0329f24>] (dump_stack+0x0/0x1c) from [<c0329f8c>] (panic+0x4c/0x114)       
    [<c0329f40>] (panic+0x0/0x114) from [<c002f598>] (init_post+0xa8/0x10c)       
    r3:00000000 r2:c393a100one_wire_status: 4                                    
     r1:c393a200 r0:c03db74c                                                      
    [<c002f4f0>] (init_post+0x0/0x10c) from [<c00084b4>] (kernel_init+0xe4/0x114)
    r5:c001f308 r4:c04813e0                                                      
    [<c00083d0>] (kernel_init+0x0/0x114) from [<c004bbbc>] (do_exit+0x0/0x620)    
     r5:00000000 r4:00000000    
这是没有找到yaffs文件系统，因为你还没有移植呢
### 移植yaffs文件系统
将你自己做好的文件系统使用[mkyaffs2image](/src/toolchains/mkyaffs2image.tgz)工具制作出文件系统镜像。可是这时使用nand write 0x30008000 0x600000 0x2100000进行烧写后，开发板启动后同样进不到文件系统。
正确的烧写命令：

    nand write.yaffs 0x30008000 0x600000 0x2100000
* * *
**写入yaffs文件系统时，下载的文件系统有多大。就烧写多大，但是大小必须是2k倍**

### 烧写的方式
通过tftp将uboot、kernel、文件系统下载到0x30008000这块可读可写的内存中，然后使用nand相关命令进行操作。
**nandflash操作命令：**
>nand - NAND sub-system                                                        

  Usage:                                                                        
  nand info - show available NAND devices                                       
  nand device [dev] - show or set current device                                
  nand read - addr off|partition size                                           
  nand write - addr off|partition size                                          
      read/write 'size' bytes starting at offset 'off'                          
      to/from memory address 'addr', skipping bad blocks.                       
  nand erase [clean] [off size] - erase 'size' bytes from                       
      offset 'off' (entire device if not specified)                             
  nand read[.yaffs[1]] is not provide temporarily!                              
  nand write[.yaffs[1]]    addr off size - write the `size' byte yaffs image stg
     at offset `off' from memory address `addr' (.yaffs1 for 512+16 NAND)     
  nand bad - show bad blocks                                                    
  nand dump[.oob] off - dump page                                               
  nand scrub - really clean NAND erasing bad blocks (UNSAFE)                    
  nand markbad off [...] - mark bad block(s) at offset (UNSAFE)                 
  nand biterr off - make a bit error at offset (UNSAFE)  

### 附：NSF文件系统启动时，uboot环境变量的设置

    setenv bootargs 'noinitrd console=ttySAC0,115200 init=/linuxrc root=/dev/nfs nfsroot=192.168.11.11:/work/embedded/rootfs ip=192.168.11.22:192.168.11.11:192.168.11.11:255.255.255.0:micro2440.arm9.net:eth0'


    setenv bootcmd 'tftp 0x30007fc0 uImage ; bootm'
