---
title: Cortex-A8平台实验
categories:
  - Cortex-A8
tags:
  - cortex-a8
  - uboot
  - linux
  - bulidroot
  - arm
  - s5pv210
abbrlink: 36419
date: 2016-09-11 23:07:24
---

毕业的时候有把A8板子拿了过来，之前由于没有源程序（光盘丢失找不到资料）对它的开发和实验都一直没有做过，它上面的资源很多不想让它就静静的放着浪费。虽然已经很久没有接触ARM平台了，但是它与MIPS的上层基本原理相似，所以最近想倒腾它，希望可以把linux系统跑起来，也不枉失去它在我手中的价值嘿嘿嘿。在这里简单记录实验的过程和中间的少许思考吧。

<!---more--->

# 开篇——flag

## 实验环境：
* 开发板：Cortex-A8
* 开发系统：Linux machine 4.2.0-27-generic #32~14.04.1-Ubuntu SMP
* ~~uboot：u-boot-2016-07~~
* uboot：u-boot-v2014.07-rc4
* linux：linux-4.0.9
* 文件系统：buildroot
>在实际的操作中可能会有所变动，不断更新 [DebugCode](https://github.com/EmDepTeam)

## 交叉编译工具

作为嵌入式开发交叉编译工具链是必不可少的，主要是为了在宿主机（PC）上，开发目标机（arm开发板）中可以运行的程序。

### 下载

这里选择[gcc-arm-none-eabi-5_4-2016q2-20160622-linux.tar.bz2](https://launchpadlibrarian.net/268330503/gcc-arm-none-eabi-5_4-2016q2-20160622-linux.tar.bz2)

### 配置

由于PC中从在多个交叉编译工具链，这里采用脚本envsetup.sh设置，每进入一个终端需要运行其脚本进行配置，方可使用该编译工具链。
``` shell
#!/bin/bash
MY_PWD=`pwd`

PATH=$PATH:$MY_PWD/gcc-arm-none-eabi-5_4-2016q2/bin
CROSS_COMPILE=arm-none-eabi-

export PATH CROSS_COMPILE

echo $PATH
echo $CROSS_COMPILE
```
设置：
```
source envsetup.sh
```
## uboot移植

### 编译

1. 查找Cortex-A8相关的README，进行参考，全局搜索

``` shell
grep "Cortex-A8" . -rn
```
./doc/README.s5pc1xx中有Cortex-A8的相关说明，结合该文档进行最初的编译。

~~2. 根据README.s5pc1xx的步骤配置编译~~

将出现以下错误：
>lib/asm-offsets.c:1:0: error: bad value (armv5) for -march= switch

出现这个错误的原因是我们没有为uboot指定交叉编译工具链，它依然用自己默认的gcc进行编译，有怎么会找到armv5呢。

~~3. 指定交叉编译工具链~~
``` shell
  CROSS_COMPILE=arm-none-eabi-
  export CROSS_COMPILE
```
为了以后方便使用可将以上两句命令添加到envsetup.sh脚本中。
参考：./README --- 4963 Building the Software:

#### 改变uboot版本

>最新的uboot采用图形界面的配置方式及增加了设备树的配置，由于对这两方面都不太了解尤其设备树，根据自己比较熟悉的使用方式，选择u-boot-v2014.07-rc4。设备树等uboot可以正常启动后在深入学习添加。

#### 选择默认配置编译

1. 选择配置

根据README在boards.cfg选择smdkc100，后续在此基础上进行移植
2. 指定编译器

根据上文（3. 指定交叉编译工具链）即可
3. 编译

```
make smdkc100_config
make
```
顺利编译通过，接下来将添加spl和uboot

#### 添加自己配置

1. 添加配置文件s5pv210.h
        cp include/configs/smdkc100.h include/configs/s5pv210.h

2. 添加编译配置boards.cfg
        Active  arm         armv7          s5pc1xx     samsung   smdkc100   s5pv210      Winddoing <winddoing@sina.cn>

### 添加SPL阶段

在uboot中SPL阶段的控制是通过spl/Makefile中的CONFIG_SPL_BUILD宏控制


## 使用最新的uboot

### 环境

1. 指定编译工具链
```
export CROSS_COMPILE
```
2. 使用相关配置测试工具链
```
$make s5pc210_universal_defconfig
$make -j12
```

### 添加自定义配置

在`s5pc210_universal_defconfig`配置基础上修改。

#### 添加配置文件

1. 拷贝现有相关配置
```
$cp include/configs/s5pc210_universal.h include/configs/s5pc210_a8.h
$cp configs/s5pc210_universal_defconfig configs/s5pc210_a8_defconfig
```
2.添加板级
```
board/samsung/cortex-a8/
configs/s5pc210_a8_defconfig
include/configs/s5pc210_a8.h
```
#### 添加SPL

### 错误

```
./tools/mkexynosspl  spl/u-boot-spl.bin spl/qt210-spl.bin
make[1]: ./tools/mkexynosspl: Command not found
scripts/Makefile.spl:283: recipe for target 'spl/qt210-spl.bin' failed
make[1]: *** [spl/qt210-spl.bin] Error 127
Makefile:1508: recipe for target 'spl/u-boot-spl' failed
make: *** [spl/u-boot-spl] Error 2
```

这是个可执行文件是在make时自动增加头信息用的

### 参考

* [【u-boot-2016到s5pv210】1.1 自定义板卡ok210](https://blog.csdn.net/gjianw217/article/details/79939889)
* [u-boot-2016.09移植(3)-u-boot-spl.bin](https://blog.csdn.net/keyue123/article/details/53072164)
* [u-boot-2016.11移植uboot-spl.bin](https://blog.csdn.net/Config_init/article/details/53373423)
* [u-boot v2018.01 启动流程分析](https://blog.csdn.net/weixin_39655765/article/details/80058644)


## 参考

* [S5PV210开发版配置](https://blog.csdn.net/JerryGou/article/details/79027479)


# 再续前缘——2022.1.21

今天已经是在家隔离的第28天了，接着上次在家办公时把uboot基本移植成功后，这两天也把kerel和文件系统都给安排上了，算是完成了这个久违的flag。以上这部分，记录了刚毕业那会对手里拿着的cortex-a8开发版所立的一个flag，想着既然有一个就将最新的uboot和kernel全部跑起来，也是一个锻炼过程，同时如果需要调试内核新的功能也方便，出于这个目的就进行了uboot的移植（记录在上），记得当时spl都没有弄完就不了了之了。这次乘着疫情在家时间比较充足就将其重新进行移植。

在移植之前给这个工程与开发板起了一个新的名字`wdg`，其实就是winddoing的简写，主要是为了容易辩识。

当前状态：

- uboot移植
  - 实现uart，时钟，DDR初始化等，最基本功能
  - 移植LAN9220网卡
  - 实现tftp加载kernel，及挂载NFS文件系统
- kernel移植
  - 实现正常启动并进入文件系统
  - 移植LAN9220网卡驱动
- buildroot
  - 构建完成可用的最小文件系统

这里主要记录整个调试流程和需要注意的地方，其实也就是我出现错误和比较容易忽略的地方。

## wdg工程环境

- 硬件环境：
  - s5pv210开发板（Cortex-A8）
- 软件环境：
  - 开发机：`Ubuntu 20.04.3 LTS`
  - 交叉编译工具：`arm-none-eabi-gcc`, sudo apt install gcc-arm-none-eabi
  - uboot：`v2021.10-rc5`
  - kernel：`5.16.0`
  - buildroot: `2021.11`
  > uboot、kernel、buildroot均为当时下载`master`分支代码进行移植操作，目的是为了后续方便更新代码

## 基础环境

### 编译工具

``` shell
sudo apt install gcc-arm-none-eabi
```
> 编译应用：arm-none-eabi-gcc --specs=nosys.specs $(OTHER_LINK_OPTIONS)
>
> 如：arm-none-eabi-gcc --specs=nosys.specs  a.c

### 硬件电路——调试

#### 串口

默认使用最边上的串口，为COM1，j7

![s5pv210_wdg_uart_debug](/images/2022/01/s5pv210_wdg_uart_debug.png)

#### LED

在开发板上有四个led灯，为了方便调试uboot与spl的启动，将其作为指示灯用

![s5pv210_wdg_led_debug](/images/2022/01/s5pv210_wdg_led_debug.png)

uboot中接口函数`wdg_led_status()`,可以直接设置状态值`1~15`

## 裸板测试

裸板测试主要调试uart和led，为spl启动流程调试做准备。

![s5pv210_boot_diagram](/images/2022/01/s5pv210_boot_diagram.png)

`BL1`区域最大大小为16KByte，因此启动阶段BL1代码大小不能超过16KByte，也就是裸板测试程序不能超过16KByte，（uboot spl阶段大小也不能超过16KByte）

BL1区域数据格式：`Header`+`Data`
```
      ----+------------------------+----------->+------------------------------+
       ^  |                        |            |BL1 size unit:byte(User Write)|
       |  |   BL1 Header(16byte)   |            +------------------------------+
       |  |                        |            |Reserved(should be 0)         |
       |  +------------------------+-----+      +------------------------------+
       |  |                        | ^   |      |CheckSum(User write)          |
       |  |                        | |   |      +------------------------------+
       |  |                        | |   |      |Reserved(should be 0)         |
       |  |                        | |   +----->+------------------------------+
       |  |                        | |
       |  |                        | |
       |  |      BL1 binary        | |
   BL1 size                        | |
       |  |                        | |
       |  |                        |CheckSum
       |  |                        | |
       |  |                        | |
       |  |                        | |
       |  |                        | |
       |  |                        | |
       |  |                        | |
       |  |                        | |
       |  |                        | |
       |  |                        | |
       v  |                        | v
      ----+------------------------+----
```

裸板测试程序编译生成后，需要根据以上格式进行处理生成新的bin文件，这个bin文件写入SD卡启动时才会被识别运行，否则会触发蜂鸣器报警。

BL1阶段bin格式处理流程：
1. 添加`16Byte`的头部信息
2. 计算BL1阶段程序bin文件的实际大小，并填入头部第一个word
3. 计算BL1阶段程序bin文件的校验和，它通过对所有字节求和来计算，并填入头部第三个word
4. 生成新的BL1阶段执行程序BIN

将最终生成的BIN写入SD卡的第1个扇区，启动测试。

``` shell
sudo dd if=BIN of=/dev/sdb bs=512 seek=1
```

## uboot移植

### 添加wdg板级

为了后续添加各种配置并不影响后续代码的更新，需要添加一份自定义板级，这里主要参考uboot源码中的`goni`，以其为模板进行拷贝。

- 添加设备树
```
cp arch/arm/dts/s5pc1xx-goni.dts arch/arm/dts/s5pc1xx-wdg.dts
```
- 添加配置文件
```
cp configs/s5p_goni_defconfig  configs/s5p_wdg_defconfig
```
```
cp include/configs/s5p_goni.h  include/configs/s5p_wdg.h
```

- 添加板级目录
```
cp board/samsung/goni board/samsung/wdg
```
> 拷贝完板级目录后，修改相应的文件名及makefile文件，并且将设备树和配置文件中的可能无用的模块进行`删减`，后续如果需要可以不断添加

注：根据自定义板级名，修改相应的Makefile及Kconfig文件中的相关配置

### 添加SPL阶段

在s5pv210的启动流程中由于BL1阶段可利用的SRAM空间有限（最大只有16KB），这样就无法直接使用uboot进行启动，这样uboot将分为两部分启动，一部分SPL，主要为初始化DDR（以小的SRAM空间，换大的内存空间）；第二部分uboot，一般意义上的uboot，初始化各种外设，并加载引导kernel启动。

> SPL阶段，其实就是BL1阶段，主要的目的就是初始化DDR，将uboot拷贝到DDR中并进入下一阶段。

使能SPL，使uboot编译后生成两部分。

```
diff --git a/arch/arm/mach-s5pc1xx/Kconfig b/arch/arm/mach-s5pc1xx/Kconfig
index b9e620e885..2b973d0633 100644
--- a/arch/arm/mach-s5pc1xx/Kconfig
+++ b/arch/arm/mach-s5pc1xx/Kconfig
@@ -15,6 +15,7 @@ config TARGET_S5P_WDG
        select OF_CONTROL
        select BLK
        select DM_MMC
+       select SUPPORT_SPL
```

在配置完成后，直接编译测试，正常情况下可以生成u-boot-spl.bin,但是该bin文件无法直接启动测试，跟裸板程序一样需要进一步处理，也就是加头部信息。

这部分处理工作在uboot存在有成的工具，但是无法直接使用，需要针对s5pv210进行调整
```
diff --git a/tools/Makefile b/tools/Makefile
index 4a86321f64..b2f1a75138 100644
--- a/tools/Makefile
+++ b/tools/Makefile
@@ -193,6 +193,7 @@ HOSTLDLIBS_fit_check_sign := $(HOSTLDLIBS_mkimage)

 hostprogs-$(CONFIG_EXYNOS5250) += mkexynosspl
 hostprogs-$(CONFIG_EXYNOS5420) += mkexynosspl
+hostprogs-$(CONFIG_S5PC110) += mkexynosspl
 HOSTCFLAGS_mkexynosspl.o := -pedantic

 ifdtool-objs := $(LIBFDT_OBJS) ifdtool.o
diff --git a/tools/mkexynosspl.c b/tools/mkexynosspl.c
index 53122b8614..a9be388e19 100644
--- a/tools/mkexynosspl.c
+++ b/tools/mkexynosspl.c
@@ -11,6 +11,7 @@
 #include <string.h>
 #include <sys/stat.h>
 #include <compiler.h>
+#include <generated/autoconf.h>

 #define CHECKSUM_OFFSET                (14*1024-4)
 #define FILE_PERM              (S_IRUSR | S_IWUSR | S_IRGRP \
@@ -28,11 +29,21 @@
  * blob [i.e size - sizeof(struct var_size_header) bytes], calculates the
  * checksum and compares it with value read from the header.
  */
+#ifdef CONFIG_ARCH_S5PC1XX
+//BL1 Header (16byte) for s5pv210
+struct var_size_header {
+       uint32_t spl_size;
+       uint32_t reserved;
+       uint32_t spl_checksum;
+       uint32_t reserved1;
+};
+#else
 struct var_size_header {
        uint32_t spl_size;
        uint32_t spl_checksum;
        uint32_t reserved[2];
 };
+#endif
```
这样处理后将生成wdg-spl.bin，这个是可以烧录到SD卡进行测试的，这样虽然可以启动，并且蜂鸣器也没有报警，但是不幸的是串口也不会有任何输入打印（可能有些板级完全相同的，这样处理后在`spl阶段`输出少量打印的吧）。因为时钟与串口可能都没有正常初始化，无法通过输出打印确定spl运行的流程以及卡死的位置。

在进入这一步后，就需要引入新的调试手段，这里有两种，一种串口输出，直接通过汇编指令往串口的TX地址写数据，使其串口输出；另一种是点亮LED指示灯，同样使用汇编指令点亮LED灯。

这两种方式在裸板测试阶段，均以测试完成。这里我选择使用点亮LED灯，更直观方便。在uboot中将点亮LED灯，封装成一个接口函数`wdg_led_status`，入参为`1~15`数值，LED灯会根据相应的值被一次点亮。

下一步就是追踪`Crotex-a8`在SPL中的启动流程，在可能卡住或不确定的地方添加`wdg_led_status`，判断实际流程是否执行到此处，进行相关代码的调试。

这里简单记录一下，调试流程，细节东西可以直接看代码。

### uart与ddr初始化

在spl阶段uart和ddr的初始化是最关键的，这部分调试消耗的时间最长，主要是ddr老初始化不成功。最后直接将uplooking提供的uboot中ddr初始化部分全部移植过来，才完成ddr初始化。当时在这个阶段感觉又进行不下去了，主要是DDR这块不熟悉也没有相关的文档。

### 移植LAN9220网卡驱动

网卡移植比较简单在设备中添加，lan9220网卡设备并配置相关参数，由于该网卡是内部集成PHY，因此相对更简单不需要考虑相关PHY的操作。

注意点：`总线位宽`、`时钟`
- 总线位宽：lan9220是16bit地址宽度，因此需要配置成16bit，默认好像是32bit。
- 时钟：lan9220接在SROM bank3上，因此需要配置相关时钟，这部分也是从旧uboot中移植。

### 命令行参数

命令行参数这部分主要是针对kernel而已，目前为了使用方便主要配置tftp boot与NFS文件系统

```
#define CONFIG_BOOTCOMMAND  "run tftpboot"

#define CONFIG_RAMDISK_BOOT "root=/dev/ram0 rw ${console}"

#define CONFIG_COMMON_BOOT  "${console}"

#define CONFIG_MISC_COMMON

#define CONFIG_EXTRA_ENV_SETTINGS                   \
    "tftpboot=" \
        "setenv bootargs root=/dev/nfs rw " \
        "nfsroot=192.168.2.2:/home/wqshao/nfs/rootfs,tcp,nfsvers=3,nolock " \
        "ip=192.168.2.3:192.168.2.2:192.168.2.1:255.255.255.0 ::eth0:off " \
        CONFIG_COMMON_BOOT \
        ";tftp 40000000 s5pv210-wdg.dtb; tftpboot 20008000 zImage; "\
        "fdt addr 40000000; bootz 20008000 - 40000000\0" \
    "ramboot=" \
        "set bootargs " CONFIG_RAMDISK_BOOT \
        "initrd=0x33000000,8M ramdisk=8192 " \
        ";tftp 40000000 s5pv210-wdg.dtb; tftpboot 20008000 zImage; "\
        "fdt addr 40000000; bootz 20008000 - 40000000\0" \
    "mmcboot=" \
        "set bootargs root=/dev/mmcblk${mmcdev}p${mmcrootpart} " \
        "rootfstype=${rootfstype} ${opts} ${lcdinfo} " \
        CONFIG_COMMON_BOOT "; run bootk\0" \
    "boottrace=setenv opts initcall_debug; run bootcmd\0" \
    "bootchart=set opts init=/sbin/bootchartd; run bootcmd\0" \
    "verify=n\0" \
    "rootfstype=ext4\0" \
    "console=console=ttySAC0,115200n8 earlyprintk\0" \
    "loaduimage=ext4load mmc ${mmcdev}:${mmcbootpart} 0x30007FC0 uImage\0" \
    "mmcdev=0\0" \
    "mmcbootpart=2\0" \
    "mmcrootpart=5\0" \
    "partitions=" PARTS_DEFAULT \
    "opts=always_resume=1\0" \
    "dfu_alt_info=" CONFIG_DFU_ALT "\0"
```

**注意点**:
- 串口打印输出，在进入内核后打印内核调试信息，必须在`console`项添加`earlyprintk`，否则严重影响内核调试，在内核卡死的时候不输出任何信息无法定位
- tftpboot需要适应zimage和dtb，在bootz参数后需要添加kernel和dtb加载到内存中的地址
- nfs文件系统，在挂载nfs文件系统时，出现卡住无法挂载的情况，根本原因是uboot中默认支持的nfs协议版本为`2`,但是开发机中搭建的NFS server支持的nfs协议版本为`3`和`4`。由于协议版本不匹配导致无法正常挂载文件系统，因此需要在`nfsroot`参数后添加`nfsvers=3`


### uboot与kernel的机器码匹配

在kernel启动中出现以下错误：
```
Error: invalid dtb and unrecognized/unsupported machine ID
  r1=0x00000b2e, r2=0x20000100
  r2[]=05 00 00 00 01 00 41 54 00 00 00 00 00 00 00 00
Available machine support:

ID (hex)        NAME
ffffffff        Generic DT based system
ffffffff        Samsung S5PC110/S5PV210-based board

Please check your kernel config and/or bootloader.
```
> 该错误就是uboot传入的与内核中的machine ID不一致无法启动的。

uboot中传递的ID是`r1=0x00000b2e`，由`bi_arch_number`字段配置，但是内核不支持，而内核支持的ID是`ffffffff`, 因此解决方法有两种，一种是修改内核ID为uboot传递的，另一种是修改uboot传递的ID为全f

这里选择后者，在uboot板级文件中修改`bi_arch_number = 0xffffffff`

bi_arch_number配置值在uboot中可以通过`bdinfo`获取
```
wdg # bdinfo
bd address  = 0x3fe93fa0
boot_params = 0x20000100
   ...
arch_number = 0x00000b2e    <ID>
TLB addr    = 0x3fff0000
irq_sp      = 0x3fe930f0
sp start    = 0x3fe930e0
Early malloc usage: 100 / 400
```
## kernel移植

### 添加wdg配置文件

```
cp arch/arm/configs/s5pv210_defconfig arch/arm/configs/s5pv210_wdg_defconfig
```

### 添加wdg设备树

内核中同样选择`smdkv210`的设备树配置文件为模板进行配置。

```
cp arch/arm/boot/dts/s5pv210-smdkv210.dts  arch/arm/boot/dts/s5pv210-wdg.dts
```
将`s5pv210-wdg.dts`中可能多余的配置项删减，并修改相应的Makefile和Kconfig。

### 内核配置——默认调试输出串口

```
Kernel hacking  --->
    arm Debugging  --->
        [*] Kernel low-level debugging functions (read help!)
              Kernel low-level debugging port (Use Samsung S3C UART 0 for low-level debug)  --->
        [*] Early printk
```


### 调整时钟

经过以上步骤编译完成的zImage，在启动时会卡死出错，如下
```
[    0.000000] S5PV210 clocks: mout_apll = 0, mout_mpll = 0
[    0.000000]  mout_epll = 0, mout_vpll = 0
[    0.000000] Division by zero in kernel.
[    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted 5.16.0-11061-g6c325cf02a71 #15
[    0.000000] Hardware name: Samsung S5PC110/S5PV210-based board
[    0.000000]  unwind_backtrace from show_stack+0x10/0x14
[    0.000000]  show_stack from Ldiv0+0x8/0x10
[    0.000000]  Ldiv0 from clockevents_config.part.0+0x18/0x74
[    0.000000]  clockevents_config.part.0 from clockevents_config_and_register+0x20/0x2c
[    0.000000]  clockevents_config_and_register from _samsung_pwm_clocksource_init+0x150/0x2a0
[    0.000000]  _samsung_pwm_clocksource_init from samsung_pwm_alloc+0x144/0x190
[    0.000000]  samsung_pwm_alloc from timer_probe+0x74/0xec
[    0.000000]  timer_probe from start_kernel+0x4b4/0x620
[    0.000000]  start_kernel from 0x0
[    0.000000] ------------[ cut here ]------------
[    0.000000] WARNING: CPU: 0 PID: 0 at kernel/time/clockevents.c:38 cev_delta2ns+0x148/0x170
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted 5.16.0-11061-g6c325cf02a71 #15
[    0.000000] Hardware name: Samsung S5PC110/S5PV210-based board
[    0.000000]  unwind_backtrace from show_stack+0x10/0x14
[    0.000000]  show_stack from __warn+0xd4/0xec
[    0.000000]  __warn from warn_slowpath_fmt+0x64/0xc8
[    0.000000]  warn_slowpath_fmt from cev_delta2ns+0x148/0x170
[    0.000000]  cev_delta2ns from clockevents_config.part.0+0x54/0x74
[    0.000000]  clockevents_config.part.0 from clockevents_config_and_register+0x20/0x2c
[    0.000000]  clockevents_config_and_register from _samsung_pwm_clocksource_init+0x150/0x2a0
[    0.000000]  _samsung_pwm_clocksource_init from samsung_pwm_alloc+0x144/0x190
[    0.000000]  samsung_pwm_alloc from timer_probe+0x74/0xec
[    0.000000]  timer_probe from start_kernel+0x4b4/0x620
[    0.000000]  start_kernel from 0x0
```

这个错误主要是`xxti`时钟没有配置，因此需要在设备树中添加`xxti`的时钟配置
```
+++ b/arch/arm/boot/dts/s5pv210-wdg.dts
@@ -58,6 +58,10 @@ backlight {
        };
 };

+&xxti {
+       clock-frequency = <24000000>;
+};
+
 &xusbxti {
        clock-frequency = <24000000>;
 };
```

### 使用Ramdisk文件系统

到这一步内核基本完成需要挂载文件系统，这里使用最方便的文件系统ramdisk，文件系统格式`cpio`

内核配置ramdisk文件系统路径：
```
General setup  --->
    [*] Initial RAM filesystem and RAM disk (initramfs/initrd) support
    (/home/xxx/rootfs.cpio) Initramfs source file(s)
```

这样在uboot中选择`ramboot`进行启动，系统就可以正常启动进入文件系统

`ramboot`启动操作方式：重启系统回车进入uboot命令行中，执行`run ramboot`

### 调试LAN9220网卡驱动

由于ramdisk文件系统的使用没有NFS文件系统方便，因此添加网卡驱动为后续挂载NFS文件系统做准备。

在设备树中添加lan9220设备，参考`Documentation/devicetree/bindings/net/smsc,lan9115.yaml`

```
ethernet@a8000000 {
    compatible = "smsc,lan9115";
    reg = <0xA8000000 0x10000>;
    phy-mode = "mii";
    interrupt-parent = <&gph1>;
    interrupts = <1 IRQ_TYPE_LEVEL_LOW>;
    clocks = <&clocks CLK_SROMC>;
    local-mac-address = [00 00 de ad be ef];
    reg-io-width = <2>;
    smsc,force-internal-phy;
    smsc,irq-push-pull;
};
```

注意点与uboot中一样，`总线位宽`与`时钟`,在内核中时钟可以直接通过添加`clocks = <&clocks CLK_SROMC>;`开启，如果不添加时钟，网卡驱动进行loop测试时会失败。

### 添加NFS文件系统

NFS文件系统，在内核中需要开启NFS client，启动参考uboot命令行中的tftpboot

```
File systems  --->
    [*] Network File Systems  --->
        <*>   NFS client support
        <*>     NFS client support for NFS version 2
        <*>     NFS client support for NFS version 3
        [ ]       NFS client support for the NFSv3 ACL protocol extension
        < >     NFS client support for NFS version 4
        [ ]     Provide swap over NFS support
        [*]   Root file system on NFS
        [*]   NFS: Disable NFS UDP protocol support
```

## 文件系统构建

通过buildroot构建最小的文件系统，后续根据实际需求逐步添加。

### 添加wdg配置

在`configs`目录下搜索存在`cortex_a8`的配置文件，随便选择一个./mx51evk_defconfig为例，拷贝一份添加自己的配置

```
cp configs/mx51evk_defconfig configs/s5pv210_wdg_defconfig
```

### 调整配置——只编译文件系统

1. 关闭uboot和kernel的编译配置
2. 指定包的下载目录为`BR2_DL_DIR="$(TOPDIR)/../downloads"`，方便使用单独的库进行保存
3. 删除多余无用配置项
4. 配置串口设备名`BR2_TARGET_GENERIC_GETTY_PORT="ttySAC0"`
5. 配置ramdisk文件系统格式`ROOTFS_CPIO`
6. ~~配置shell为bash~~，后续根据实际需求确定是否修改，改为bash，文件系统比之前大1.2M将近一倍


## 参考

- [S5PV210_iROM_ApplicationNote_Preliminary_20091126.pdf](https://winddoing.coding.net/p/s5pv210/d/docs/git/raw/master/datasheet/S5PV210_iROM_ApplicationNote_Preliminary_20091126.pdf)
- [linux-3.4.2 smsc911x 网卡移植](https://blog.csdn.net/liujia2100/article/details/8688657)
- [s5pv210 uboot-2012-10移植(五) 之支持LAN9220网卡](https://blog.csdn.net/xiaojiaohuazi/article/details/8285054?spm=1001.2014.3001.5502)
- [S5PV210 Linux内核移植 - 天嵌E8](https://blog.csdn.net/hanxiaohuaa/article/details/105420669)
