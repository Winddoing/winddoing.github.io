---
layout: post
title: X Sever —— Xorg
date: '2020-03-20 16:15'
tags:
  - xorg
  - x11
categories:
  - 系统服务
  - Xorg
abbrlink: 39845
---

Xorg：基于`X11`协议的服务端。管理硬件设备（驱动），键盘鼠标显示器等

<!--more-->


## Xorg配置文件

生成配置文件
``` shell
# Xorg -configure :0
```
> `:0`显示窗口，在Xorg启动的情况下，无法获取当前的Xorg配置文件，可以随意指定数字


### xorg.conf

> 具体参数说明：`man xorg.conf`

```
Section "ServerLayout"
	Identifier     "X.org Configured"
	Screen      0  "Screen0" 0 0
	Screen      1  "Screen1" RightOf "Screen0"
	InputDevice    "Mouse0" "CorePointer"
	InputDevice    "Keyboard0" "CoreKeyboard"
EndSection

Section "Files"
	ModulePath   "/usr/lib/xorg/modules"
	FontPath     "/usr/share/fonts/X11/misc"
	FontPath     "/usr/share/fonts/X11/cyrillic"
	FontPath     "/usr/share/fonts/X11/100dpi/:unscaled"
	FontPath     "/usr/share/fonts/X11/75dpi/:unscaled"
	FontPath     "/usr/share/fonts/X11/Type1"
	FontPath     "/usr/share/fonts/X11/100dpi"
	FontPath     "/usr/share/fonts/X11/75dpi"
	FontPath     "built-ins"
EndSection

Section "Module"
	Load  "glx"
EndSection

Section "InputDevice"
	Identifier  "Keyboard0"
	Driver      "kbd"
EndSection

Section "InputDevice"
	Identifier  "Mouse0"
	Driver      "mouse"
	Option	    "Protocol" "auto"
	Option	    "Device" "/dev/input/mice"
	Option	    "ZAxisMapping" "4 5 6 7"
EndSection

Section "Monitor"
	Identifier   "Monitor0"
	VendorName   "Monitor Vendor"
	ModelName    "Monitor Model"
EndSection

Section "Monitor"
	Identifier   "Monitor1"
	VendorName   "Monitor Vendor"
	ModelName    "Monitor Model"
EndSection

Section "Device"
        ### Available Driver options are:-
        ### Values: <i>: integer, <f>: float, <bool>: "True"/"False",
        ### <string>: "String", <freq>: "<f> Hz/kHz/MHz",
        ### <percent>: "<f>%"
        ### [arg]: arg optional
        #Option     "Accel"              	# [<bool>]
        #Option     "SWcursor"           	# [<bool>]
        #Option     "EnablePageFlip"     	# [<bool>]
        #Option     "SubPixelOrder"      	# [<str>]
        #Option     "ZaphodHeads"        	# <str>
        #Option     "AccelMethod"        	# <str>
        #Option     "DRI3"               	# [<bool>]
        #Option     "DRI"                	# <i>
        #Option     "ShadowPrimary"      	# [<bool>]
        #Option     "TearFree"           	# [<bool>]
        #Option     "DeleteUnusedDP12Displays" 	# [<bool>]
	Identifier  "Card0"
	Driver      "amdgpu"
	BusID       "PCI:1:0:0"
EndSection

Section "Device"
        ### Available Driver options are:-
        ### Values: <i>: integer, <f>: float, <bool>: "True"/"False",
        ### <string>: "String", <freq>: "<f> Hz/kHz/MHz",
        ### <percent>: "<f>%"
        ### [arg]: arg optional
        #Option     "Accel"              	# [<bool>]
        #Option     "SWcursor"           	# [<bool>]
        #Option     "EnablePageFlip"     	# [<bool>]
        #Option     "SubPixelOrder"      	# [<str>]
        #Option     "ZaphodHeads"        	# <str>
        #Option     "AccelMethod"        	# <str>
        #Option     "DRI3"               	# [<bool>]
        #Option     "DRI"                	# <i>
        #Option     "ShadowPrimary"      	# [<bool>]
        #Option     "TearFree"           	# [<bool>]
        #Option     "DeleteUnusedDP12Displays" 	# [<bool>]
	Identifier  "Card1"
	Driver      "amdgpu"
	BusID       "PCI:1:0:1"
EndSection

Section "Screen"
	Identifier "Screen0"
	Device     "Card0"
	Monitor    "Monitor0"
	SubSection "Display"
		Viewport   0 0
		Depth     1
	EndSubSection
	SubSection "Display"
		Viewport   0 0
		Depth     4
	EndSubSection
	SubSection "Display"
		Viewport   0 0
		Depth     8
	EndSubSection
	SubSection "Display"
		Viewport   0 0
		Depth     15
	EndSubSection
	SubSection "Display"
		Viewport   0 0
		Depth     16
	EndSubSection
	SubSection "Display"
		Viewport   0 0
		Depth     24
	EndSubSection
EndSection

Section "Screen"
	Identifier "Screen1"
	Device     "Card1"
	Monitor    "Monitor1"
	SubSection "Display"
		Viewport   0 0
		Depth     1
	EndSubSection
	SubSection "Display"
		Viewport   0 0
		Depth     4
	EndSubSection
	SubSection "Display"
		Viewport   0 0
		Depth     8
	EndSubSection
	SubSection "Display"
		Viewport   0 0
		Depth     15
	EndSubSection
	SubSection "Display"
		Viewport   0 0
		Depth     16
	EndSubSection
	SubSection "Display"
		Viewport   0 0
		Depth     24
	EndSubSection
EndSection
```
> **注意**：在`xorg.conf`中配置显卡总线地址`BusID`时，必须以`十进制`表示，比如`lspci`总线地址（以十六进制显示）为`91:00.0`，将其转换为十进制`145:00:0`（16x9+1）配置在xorg.conf中。
> 细节有两点:
>   1. 总线地址的进制转换(十六进制转十进制)
>   2. 总线地址的分隔符,在xorg.conf中,地址均为`:`分隔

- `Driver`的选择必须根据使用的显卡和系统的支持情况配置,在系统不支持的情况下可以使用`modesetting`代替测试，不一定配置成功
  - centos系统支持的驱动在`/lib64/xorg/modules/drivers/`
    ``` shell
    # ls /lib64/xorg/modules/drivers/
    ati_drv.so  dummy_drv.so  fbdev_drv.so  modesetting_drv.so  nouveau_drv.so  qxl_drv.so  radeon_drv.so  v4l_drv.so
    ```
  - ubuntu系统支持的驱动在`/usr/lib/xorg/modules/drivers/`
    ``` shell
    ls /usr/lib/xorg/modules/drivers/
    amdgpu_drv.so  ati_drv.so  fbdev_drv.so  intel_drv.so  modesetting_drv.so  nouveau_drv.so  qxl_drv.so  radeon_drv.so  vesa_drv.so  vmware_drv.so
    ```

## 参数

```
$man Xorg
$man xorg.conf
$man Xserver
$man modesetting
$man fbdevhw
$man Xwrapper.config

$man Xephyr
$man exa
$man cvt
$man gtf
```

- `Xephyr`: X服务器输出到预先存在的X显示器上的窗口


## 应用示例


```
# nvidia-settings: X configuration file generated by nvidia-settings
# nvidia-settings:  version 440.82

Section "ServerLayout"
    Identifier     "Layout0"
    Screen      0  "Screen0" 0 0
    InputDevice    "Keyboard0" "CoreKeyboard"
    InputDevice    "Mouse0" "CorePointer"
    Option         "Xinerama" "0"
EndSection

Section "Files"
EndSection

Section "InputDevice"
    # generated from default
    Identifier     "Mouse0"
    Driver         "mouse"
    Option         "Protocol" "auto"
    Option         "Device" "/dev/input/mice"
    Option         "Emulate3Buttons" "no"
    Option         "ZAxisMapping" "4 5"
EndSection

Section "InputDevice"
    # generated from default
    Identifier     "Keyboard0"
    Driver         "kbd"
EndSection

Section "Monitor"
    # HorizSync source: edid, VertRefresh source: edid
    Identifier     "Monitor0"
    VendorName     "Unknown"
    ModelName      "Philips PHL 237E7"
    HorizSync       30.0 - 83.0
    VertRefresh     56.0 - 76.0
    Option         "DPMS"
EndSection

Section "Device"
    Identifier     "Device0"
    Driver         "nvidia"
    VendorName     "NVIDIA Corporation"
    BoardName      "Quadro P6000"
EndSection

Section "Screen"
    Identifier     "Screen0"
    Device         "Device0"
    Monitor        "Monitor0"
    DefaultDepth    24
    Option         "Stereo" "0"
    Option         "nvidiaXineramaInfoOrder" "DFP-8"
    Option         "metamodes" "DP-5: nvidia-auto-select +1920+0, DP-7: nvidia-auto-select +0+0"
    Option         "SLI" "Off"
    Option         "MultiGPU" "Off"
    Option         "BaseMosaic" "off"
    SubSection     "Display"
      Depth       24
    EndSection
```

## 启动

``` shell
startx -- -layout seat0 -seat seat0 -novtswitch -sharevts
```
> 参数详解： `man Xorg`

- `-novtswitch `: 如果操作系统支持，请禁用自动启动服务器时将X服务器重置和关机自动切换到激活的VT的功能
- `-sharevts`: 如果操作系统支持，则与另一个X服务器共享虚拟终端。

## xinitrc

> `$HOME/.xinitrc`指定启动的桌面环境,比如xterm

`~/.xinitrc`由xinit执行，通常通过startx调用。 登录后将执行该程序：首先登录文本控制台，然后使用startx启动GUI。`.xinitrc`的作用是启动会话的GUI部分，通常是通过设置一些与GUI相关的设置，例如键绑定（使用xmodmap或xkbcomp），X资源（使用xrdb）等，以及启动会话管理器或窗口管理器（可能是桌面环境的一部分）。

``` shell
# xinit /etc/X11/xinitrc -- /usr/bin/X :1 -config /etc/X11/xorg.conf.new -novtswitch -sharevts vt2 -keeptty -listen tcp
# X :1 -config /etc/X11/xorg.conf.new -novtswitch -sharevts vt2 -keeptty -listen tcp
```

### 窗口管理器

- fvwm:虚拟窗口管理器,占用资源少
- twm:(Tab Window Manager for the X Window System)

## 驱动模块——Driver

``` shell
$ls /usr/lib/xorg/modules/drivers/
amdgpu_drv.so  ati_drv.so  fbdev_drv.so  intel_drv.so  modesetting_drv.so  nouveau_drv.so  qxl_drv.so  radeon_drv.so  vesa_drv.so  vmware_drv.so
```

每一个驱动模块的详细信息，可以通过`man`手册进行查看，比如`man modesetting`、`man intel`、`man amdgpu`等

### modesetting

> `modesetting` is an Xorg driver for KMS devices.

The modesetting driver supports all hardware where a KMS driver is available. modesetting uses the Linux DRM KMS ioctls and dumb object create/map.

modesetting是KMS设备的Xorg驱动程序。 该驱动程序支持在帧缓冲区深度为15、16、24和30的TrueColor视觉效果。multi-head配置支持RandR 1.2。 对于至少支持OpenGL ES 2.0或OpenGL 2.1的设备，可以通过glamor进行加速。 如果未启用魅力，则根据KMS驱动程序的偏好配置阴影帧缓冲区（除非帧缓冲区为每像素24位，在这种情况下始终使用阴影帧缓冲区）。


### vesa

`vesa`是用于通用VESA视频卡的Xorg驱动程序。 它可以驱动大多数与VESA兼容的视频卡，但仅使用这些卡通用的基本标准VESA内核。驱动程序支持深度8、15、16和24。

### Driver配置的缺失

如果在xorg.conf的配置中将Driver字段的配置缺失，系统会默认选择加载`modeseting`、`fbdev`、`vesa`驱动。

``` conf
Section "Device"
  Identifier "devname"
  #Driver "modesetting" #将该字段注释掉，Xorg将自动进行加载
  BusID  "pci:bus:dev:func"
  ...
EndSection
```

```
...
(II) xfree86: Adding drm device (/dev/dri/card2)
(II) Platform probe for /sys/devices/pci0000:ae/0000:ae:00.0/0000:af:00.0/0000:b0:10.0/0000:bb:00.0/0000:bc:01.0/0000:bd:00.0/drm/card2
(II) "glx" will be loaded. This was enabled by default and also specified in the config file.
(II) LoadModule: "glx"
(II) Loading /usr/lib64/xorg/modules/extensions/libglx.so
(II) Module glx: vendor="X.Org Foundation"
   compiled for 1.20.4, module version = 1.0.0
   ABI class: X.Org Server Extension, version 10.0

(==) Matched modesetting as autoconfigured driver 0
(==) Matched fbdev as autoconfigured driver 1
(==) Matched vesa as autoconfigured driver 2
(==) Assigned the driver to the xf86ConfigLayout

(II) LoadModule: "modesetting"
(II) Loading /usr/lib64/xorg/modules/drivers/modesetting_drv.so
(II) Module modesetting: vendor="X.Org Foundation"
   compiled for 1.20.4, module version = 1.20.4
   Module class: X.Org Video Driver
   ABI class: X.Org Video Driver, version 24.0
(II) LoadModule: "fbdev"
(II) Loading /usr/lib64/xorg/modules/drivers/fbdev_drv.so
(II) Module fbdev: vendor="X.Org Foundation"
   compiled for 1.20.1, module version = 0.5.0
   Module class: X.Org Video Driver
   ABI class: X.Org Video Driver, version 24.0
(II) LoadModule: "vesa"
(II) Loading /usr/lib64/xorg/modules/drivers/vesa_drv.so
(II) Module vesa: vendor="X.Org Foundation"
   compiled for 1.20.1, module version = 2.4.0
   Module class: X.Org Video Driver
   ABI class: X.Org Video Driver, version 24.0
(II) modesetting: Driver for Modesetting Kernel Drivers: kms
(II) FBDEV: driver for framebuffer: fbdev
(II) VESA: driver for VESA chipsets: vesa
(II) modeset(0): using drv /dev/dri/card2
```


## 参考

- [X,X11,Xorg,XServer,XClient,Xlib](https://blog.csdn.net/a379039233/article/details/80782351)
- [Linux学习-X Server 配置文件解析与设定](https://www.cnblogs.com/uetucci/p/7794335.html)
- [xorg的配置文件](https://blog.csdn.net/seaship/article/details/95481154)
- [xorg.conf 配置详解](https://blog.csdn.net/ohappytime/article/details/7384001)
- [nvidia gpu fan speed control](https://www.cnblogs.com/rickerliang/p/5673015.html)
- [Appendix D. X Config Options](http://http.download.nvidia.com/XFree86/Linux-x86/1.0-8774/README/appendix-d.html)
- [xorg.conf](https://www.x.org/releases/current/doc/man/man5/xorg.conf.5.xhtml)
- [Difference between .xinitrc, .xsession and .xsessionrc](https://unix.stackexchange.com/questions/281858/difference-between-xinitrc-xsession-and-xsessionrc)
- [Chapter 13. Configuring Multiple Display Devices on One X Screen](https://download.nvidia.com/XFree86/Linux-x86_64/304.137/README/configtwinview.html)
