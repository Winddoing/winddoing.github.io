---
title: EDID
categories: 多媒体
tags:
  - edid
abbrlink: 47714
date: 2018-07-11 09:07:24
---

> 环境： ubuntu 18.04

EDID: [Extended Display Identification Data](https://en.wikipedia.org/wiki/Extended_Display_Identification_Data)

edid读取工具： get-edid

EDID的大小：`VGA/DVI`=128Byte; `HDMI`=256Byte

<!--more-->

## get-edid

```
sudo apt-get install read-edid edid-decode
```

## 获取EDID原始数据并存储到文件

```
sudo get-edid > edid.bin
```

## 解析edid

### 在线解析

> 在[http://www.edidreader.com/](http://www.edidreader.com/)网站可以对该数据进行在线解析。把以上128字节复制到该网站的对应数据窗口

### 本地解析

```
parse-edid < edid.bin
```

```
$parse-edid < edid.bin 
Checksum Correct

Section "Monitor"
	Identifier "PHL 237E7"
	ModelName "PHL 237E7"
	VendorName "PHL"
	# Monitor Manufactured week 24 of 2016
	# EDID version 1.3
	# Analog Display
	Option "SyncOnGreen" "true"
	DisplaySize 510 290
	Gamma 2.20
	Option "DPMS" "true"
	Horizsync 30-83
	VertRefresh 56-76
	# Maximum pixel clock is 170MHz
	#Not giving standard mode: 1920x1080, 60Hz
	#Not giving standard mode: 1440x900, 60Hz
	#Not giving standard mode: 1440x900, 75Hz
	#Not giving standard mode: 1680x1050, 60Hz
	#Not giving standard mode: 1280x720, 60Hz
	#Not giving standard mode: 1280x1024, 60Hz
	#Not giving standard mode: 1280x960, 60Hz
	Modeline 	"Mode 0" 148.50 1920 2008 2052 2200 1080 1084 1089 1125 +hsync +vsync 
EndSection
```


```
# the integer after -m is the monitor id, starting from zero and incrementing by one.
sudo get-edid -m 0 > edid.bin

# View the output of this command and verify you have the right monitor.
# You can tell via the vendor, resolutions, serial number, all that jazz.
cat edid.bin | edid-decode
```


### Window： EDID Manager

下载：[EDID Manager](https://pan.baidu.com/s/11VxNBrbvu4-4daB7R7huEw)


### Window： EDID编辑

下载：[Phoenix EDID Designer](https://pan.baidu.com/s/1EynJUGQ-FHp_ByvY5Vhpyw)

## 示例： Lenovo 1600x900

> 视频输出接口： `VGA`

```
00000000: 003f 3f3f 3f3f 3f00 303f 3f65 0101 0101  .??????.0??e....
00000010: 071a 0103 6c2c 1978 2e2c c5a4 5650 3f28  ....l,.x.,..VP?(
00000020: 0f50 543f 3f00 714f 3f3f 3f3f 3fc0 a9cf  .PT??.qO?????...
00000030: 9500 0101 0101 302a 403f 603f 6430 1850  ......0*@?`?d0.P
00000040: 1300 3f3f 1000 001e 0000 003f 0055 3041  ..??.......?.U0A
00000050: 595a 3834 300a 2020 2020 0000 003f 0032  YZ840.    ...?.2
00000060: 4b1e 5315 000a 2020 2020 2020 0000 003f  K.S...      ...?
00000070: 004c 454e 204c 5332 3033 3377 480a 0049  .LEN LS2033wH..I
00000080: 0a                                       .
```
> EDID： 128-byte EDID successfully retrieved from i2c bus 0

### 解析：Edid Manager

```


			Time: 11:22:16
			Date: 2018年9月13日
			EDID Manager Version: 1.0.0.14
	___________________________________________________________________

	Block 0 (EDID Base Block), Bytes 0 - 127,  128  BYTES OF EDID CODE:

		        0   1   2   3   4   5   6   7   8   9
		000  |  00  FF  FF  FF  FF  FF  FF  00  30  AE
		010  |  A9  65  01  01  01  01  07  1A  01  03
		020  |  6C  2C  19  78  2E  2C  C5  A4  56  50
		030  |  A1  28  0F  50  54  AF  EF  00  71  4F
		040  |  81  80  81  8A  A9  C0  A9  CF  95  00
		050  |  01  01  01  01  30  2A  40  C8  60  84
		060  |  64  30  18  50  13  00  B0  F0  10  00
		070  |  00  1E  00  00  00  FF  00  55  30  41
		080  |  59  5A  38  34  30  0A  20  20  20  20
		090  |  00  00  00  FD  00  32  4B  1E  53  15
		100  |  00  0A  20  20  20  20  20  20  00  00
		110  |  00  FC  00  4C  45  4E  20  4C  53  32
		120  |  30  33  33  77  48  0A  00  49

(8-9)    	ID Manufacture Name : LEN
(10-11)  	ID Product Code     : 65A9
(12-15)  	ID Serial Number    : N/A
(16)     	Week of Manufacture : 7
(17)     	Year of Manufacture : 2016

(18)     	EDID Version Number : 1
(19)     	EDID Revision Number: 3

(20)     	Video Input Definition: Analog
			0.700, 0.000 (0.700 V p-p)
			Separate SyncsComposite Syncs

(21)     	Maximum Horizontal Image Size: 44 cm
(22)     	Maximum Vertical Image Size  : 25 cm
(23)     	Display Gamma                : 2.20
(24)     	Power Management and Supported Feature(s):
			Active Off/Very Low Power, RGB Color, sRGB, Preferred Timing Mode

(25-34)  	Color Characteristics
			Red Chromaticity   :  Rx = 0.641  Ry = 0.338
			Green Chromaticity :  Gx = 0.315  Gy = 0.625
			Blue Chromaticity  :  Bx = 0.159  By = 0.055
			Default White Point:  Wx = 0.313  Wy = 0.329

(35)     	Established Timings I

			720 x 400 @ 70Hz (IBM, VGA)
			640 x 480 @ 60Hz (IBM, VGA)
			640 x 480 @ 72Hz (VESA)
			640 x 480 @ 75Hz (VESA)
			800 x 600 @ 56Hz (VESA)
			800 x 600 @ 60Hz (VESA)

(36)     	Established Timings II

			800 x 600 @ 72Hz (VESA)
			800 x 600 @ 75Hz (VESA)
			832 x 624 @ 75Hz (Apple, Mac II)
			1024 x 768 @ 60Hz (VESA)
			1024 x 768 @ 70Hz(VESA)
			1024 x 768 @ 75Hz (VESA)
			1280 x 1024 @ 75Hz (VESA)

(37)     	Manufacturer's Timings (Not Used)

(38-53)  	Standard Timings

			1152x864 @ 75 Hz (4:3 Aspect Ratio)
			1280x1024 @ 60 Hz (5:4 Aspect Ratio)
			1280x1024 @ 70 Hz (5:4 Aspect Ratio)
			1600x900 @ 60 Hz (16:9 Aspect Ratio)
			1600x900 @ 75 Hz (16:9 Aspect Ratio)
			1440x900 @ 60 Hz (16:10 Aspect Ratio)

(54-71)  	Detailed Descriptor #1: Preferred Detailed Timing (1600x900 @ 60Hz)

			Pixel Clock            : 108 MHz
			Horizontal Image Size  : 432 mm
			Vertical Image Size    : 240 mm
			Refresh Mode           : Non-interlaced
			Normal Display, No Stereo

			Horizontal:
				Active Time     : 1600 Pixels
				Blanking Time   : 200 Pixels
				Sync Offset     : 24 Pixels
				Sync Pulse Width: 80 Pixels
				Border          : 0 Pixels
				Frequency       : 60 kHz

			Vertical:
				Active Time     : 900 Lines
				Blanking Time   : 100 Lines
				Sync Offset     : 1 Lines
				Sync Pulse Width: 3 Lines
				Border          : 0 Lines

			Digital Separate, Horizontal Polarity (+), Vertical Polarity (+)

			Modeline: "1600x900" 108.000 1600 1624 1704 1800 900 901 904 1000 +hsync +vsync

(72-89)  	Detailed Descriptor #2: Monitor Serial Number

			Monitor Serial Number: U0AYZ840

(90-107) 	Detailed Descriptor #3: Monitor Range Limits

			Horizontal Scan Range: 30kHz-83kHz
			Vertical Scan Range  : 50Hz-75Hz
			Supported Pixel Clock: 210 MHz
			Secondary GTF        : Not Supported

(108-125)	Detailed Descriptor #4: Monitor Name

			Monitor Name: LEN LS2033wH

(126-127)	Extension Flag and Checksum

			Extension Block(s)  : 0
			Checksum Value      : 73

	___________________________________________________________________
```
- `Horizontal`: 水平方向
- `Vertical`： 垂直方向
- `Active Time`： 有效区域
- `Blanking Time`： 空白区域（包括上部和底部，或者是左边和右边的和）

### Pixel Clock

Pixel clock：像素时脉(Pixel clock)指的是用来划分进来的影像水平线里的个别画素，Pixel clock会将每一条水平线分成取样的样本，越高频率的Pixel clock，每条扫瞄线会有越多的样本画素。

```
pixclock = 1/dotclock
```
>dotclock是视频硬件在显示器上绘制像素的速率

```
dotclock = Htotal × Vtotal × framerate
```
- `Htotal`: 水平方向上的所有像素点，（Active Time + Blanking Time）
- `Vtotal`: 垂直方向上的所有像素点，（Active Time + Blanking Time）
- `framerate`: 帧数

#### 示例中的Pixel Clock

```
Pixel Clock = 60 x (1600 + 200) x (900 + 100) = 108000000Hz = 108Mhz
```
## 扩展EDID - E-EDID

> 大小`256Byte`， 追加一个128Byte的block， 在Block0中的 `Extension Block(s)  : 1`

![edid_CEA_version3](/images/2019/03/edid_cea_version3.png)

### 数据块 -- index=4

在EDID的扩展块中，第四个字节开始，后的数据块是可变长的部分。

![edid_CEA_data_block](/images/2019/03/edid_cea_data_block.png)

- 子数据块头部格式：

![EDID_CEA_data_block_head](/images/2019/03/edid_cea_data_block_head.png)

- 数据标签

![EDID_CEA_data_block_head_tag](/images/2019/03/edid_cea_data_block_head_tag.png)

#### Video Data Block

主要存储SVD（Short Video Description）

```
Video Data Block

640x480p @ 59.94/60Hz - EDTV (4:3, 1:1)
720x480p @ 59.94/60Hz - EDTV (16:9, 32:27)
1280x720p @ 59.94/60Hz - HDTV (16:9, 1:1) [Native]
```

#### Audio Data Block

进行短音频描述（short audio description）

```
Audio Data Block

Audio Format #1    : LPCM, 2-Channel, 24-Bit, 20-Bit, 16-Bit
Sampling Frequency : 48 kHz, 44.1 kHz, 32 kHz

Audio Format #2    : AC-3, 2-Channel, 640 k Max bit rate
Sampling Frequency : 96 kHz, 48 kHz, 44.1 kHz, 32 kHz
```

#### Speaker Allocation Data Block -- SADB

```
Speaker Allocation Data Block (SADB)

Front Left/Front Right Audio Channel (FL/FR)
```

#### Vendor Specific Data Block -- VSDB

![EDID_CEA_VASB](/images/2019/03/edid_cea_vasb.png)

供应商指定的特定数据块，其中可以标识出数据接口是HDMI还是DVI接口。

HDMI的源端可以检查是否为合理的HDMI VSDB，然后包含有IEEE Registration Identifier登记识别符号`0x000C03`，就可以判断为HDMI装置，而不是DVI装置。

>In order to determine if a sink is an HDMI device, an HDMI Source shall check the E-EDID for the
presence of an HDMI Vendor Specific Data Block within the first CEA Extension. Any device with
an HDMI VSDB of any valid length, containing the IEEE Registration Identifier of `0x000C03`, shall
be treated as an HDMI device.
Any device with an E-EDID that does not contain a CEA Extension or does not contain an HDMI
VSDB of any valid length shall be treated by the Source as a DVI device (see Appendix C).

```
Vendor Specific Data Block (VSDB)

IEEE Registration Identifier: 0x000C03
CEC Physical Address        : 0x0030
Maximum TMDS Clock          : 165MHz
```

## 首选最佳分辨率

> A.2.10.1 First Detailed Timing Descriptor
The VESA E-EDID Standard [10] requires that the First Detailed Timing Descriptor be used for the most
`“preferred”` video format and subsequent detailed timing descriptors are listed in order of decreasing
preference.

> All DTDs and SVDs shall be listed in order of priority; meaning that the first is the one that the display
manufacturer has identified as optimal.

> The first 18 Byte Descriptor Block shall contain the preferred timing mode. The display manufacturer
defines the “Preferred Timing Mode (PTM)” as the video timing mode that will produce the best quality
image on the display’s viewing screen.


## 解析工具

- [edid_manager](https://coding.net/u/Winddoing/p/software_tools/git/raw/master/edid_managerv1x0.zip) --- 获取即解析EDID
- [EEditZ](https://coding.net/u/Winddoing/p/software_tools/git/raw/master/setup_EEditZ-0p96.zip) --- 编辑即解析EDID

## 参考

* [EDID CEA Standard](http://read.pudn.com/downloads222/doc/1046129/CEA861D.pdf) -- 规范
* [High-Definition Multimedia Interface Specification Version 1.3](https://engineering.purdue.edu/ece477/Archive/2012/Spring/S12-Grp10/Datasheets/CEC_HDMI_Specification.pdf) -- VSDB
* [E-EDID Standard](http://read.pudn.com/downloads110/ebook/456020/E-EDID%20Standard.pdf)
* [修改显示器EDID工具(源码)](https://github.com/bulletmark/edid-rw))
* [http://hubpages.com/technology/how-to-reflash-a-monitors-corrupted-edid //读取和修改显示器的EDID](http://hubpages.com/technology/how-to-reflash-a-monitors-corrupted-edid)
* [EDID使用说明](https://blog.csdn.net/ganshuyu/article/details/38844963)
* [EDID标准简介](https://blog.csdn.net/haoxingheng/article/details/51586070)
