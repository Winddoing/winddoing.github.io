---
layout: post
title: X Sever —— Xorg
date: '2020-03-20 16:15'
tags:
  - Xorg，X11
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
# Xorg -configure :2
```
> `:2`显示窗口，在Xorg启动的情况下，无法获取当前的Xorg配置文件


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


## 参数


## 参考

- [X,X11,Xorg,XServer,XClient,Xlib](https://blog.csdn.net/a379039233/article/details/80782351)
- [Linux学习-X Server 配置文件解析与设定](https://www.cnblogs.com/uetucci/p/7794335.html)
- [xorg的配置文件](https://blog.csdn.net/seaship/article/details/95481154)
