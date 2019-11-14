---
layout: post
title: FFmpeg学习笔记——颜色编码
date: '2018-08-30 11:53'
categories:
  - FFmpeg
tags:
  - FFmpeg
abbrlink: 49519
---

颜色编码：`YUV`、`RGB`

![BT601_UV_YUV ](/images/2018/09/bt601_uv_yuv.png)
> - BT601 UV 的坐标图（量化后）： （横坐标为u，纵坐标为v，左下角为原点）
> - `U越大, 蓝色越蓝`; `V越大，红色越红`

<!--more-->

## YUV

YUV，分为三个分量，`“Y”`表示明亮度（Luminance或Luma），也就是灰度值（gray）；而`“U”`和`“V”` 表示的则是色度（Chrominance或Chroma），作用是描述影像色彩及饱和度，用于指定像素的颜色。

**作用：** 主要用于电视系统以及模拟视频领域，它将亮度信息（Y）与色彩信息（UV）分离，没有UV信息一样可以显示完整的图像，只不过是黑白的，这样的设计很好地解决了彩色电视机与黑白电视的兼容问题。并且，YUV不像RGB那样要求三个独立的视频信号同时传输，所以`用YUV方式传送占用极少的频宽`。

### 格式

YUV Formats分成两个格式：

* `紧缩格式（packed formats）`：将Y、U、V值储存成Macro Pixels阵列，和RGB的存放方式类似, 将YUV分量存放在同一个数组中，通常是几个相邻的像素组成一个`宏像素`（macro-pixel）。
* `平面格式（planar formats）`：将Y、U、V的三个分量分别存放在不同的矩阵中, 使用三个数组分开存放YUV三个分量，就像是一个三维平面一样。

### 采样方式

主流的采样方式有三种，`YUV4:4:4`，`YUV4:2:2`，`YUV4:2:0`

* `YUV4:4:4`:表示完全取样。
* `YUV4:2:2`:表示2:1的水平取样，垂直完全采样。
* `YUV4:2:0`:表示2:1的水平取样，垂直2：1采样。

![yuv_sample_way](/images/2018/08/yuv_sample_way.png)
> - `黑点`:表示采样该像素点的Y分量;
> - `空心圆圈`:表示采用该像素点的UV分量。

1. `YUV 4:4:4`采样，每一个Y对应一组UV分量， 每个像素32bit。
2. `YUV 4:2:2`采样，每两个Y共用一组UV分量， 每个像素16bit。
3. `YUV 4:2:0`采样，每四个Y共用一组UV分量， 每个像素16bit。

### 存储方式

下面我用图的形式给出常见的YUV码流的存储方式，并在存储方式后面附有取样每个像素点的YUV数据的方法，其中，Cb、Cr的含义等同于U、V。

#### YUYV格式 （属于YUV422）

>YUV 4:2:2

```
start + 0:    Y'00    Cb00    Y'01    Cr00    Y'02    Cb01    Y'03    Cr01
start + 8:    Y'10    Cb10    Y'11    Cr10    Y'12    Cb11    Y'13    Cr11
start +16:    Y'20    Cb20    Y'21    Cr20    Y'22    Cb21    Y'23    Cr21
start +24:    Y'30    Cb30    Y'31    Cr30    Y'32    Cb31    Y'33    Cr31
```

YUYV为YUV422采样的存储格式中的一种，相邻的两个Y共用其相邻的两个Cb、Cr，分析，对于像素点Y'00、Y'01 而言，其Cb、Cr的值均为 Cb00、Cr00，其他的像素点的YUV取值依次类推。

#### UYVY格式（属于YUV422）

```
start + 0:    Cb00    Y'00    Cr00    Y'01    Cb01    Y'02    Cr01    Y'03
start + 8:    Cb10    Y'10    Cr10    Y'11    Cb11    Y'12    Cr11    Y'13
start +16:    Cb20    Y'20    Cr20    Y'21    Cb21    Y'22    Cr21    Y'23
start +24:    Cb30    Y'30    Cr30    Y'31    Cb31    Y'32    Cr31    Y'33
```

每四字节代表两个像素，包含两个Y'，一个Cb和Cr。两个Y是两个像素的数据，而Cb和Cr对于两个像素来说都是一样的。如你所见，Cr和Cb部分只有相对于Y部分的一半竖向分辨率。

#### YV12，YU12格式（属于YUV420）

> YUV4:2:0

```
start + 0:    Y'00    Y'01    Y'02    Y'03
start + 4:    Y'10    Y'11    Y'12    Y'13
start + 8:    Y'20    Y'21    Y'22    Y'23
start +12:    Y'30    Y'31    Y'32    Y'33
start +16:    Cr00    Cr01          
start +18:    Cr10    Cr11          
start +20:    Cb00    Cb01          
start +22:    Cb10    Cb11
```

YU12和YV12属于YUV420格式，也是一种Plane模式，将Y、U、V分量分别打包，依次存储。其每一个像素点的YUV数据提取遵循YUV420格式的提取方式，即4个Y分量共用一组UV。注意，上图中，Y'00、Y'01、Y'10、Y'11共用Cr00、Cb00，其他依次类推。

#### NV12、NV21格式（属于YUV420）

> YUV4:2:0

```
start + 0:    Y'00    Y'01    Y'02    Y'03
start + 4:    Y'10    Y'11    Y'12    Y'13
start + 8:    Y'20    Y'21    Y'22    Y'23
start +12:    Y'30    Y'31    Y'32    Y'33
start +16:    Cb00    Cr00    Cb01    Cr01
start +20:    Cb10    Cr10    Cb11    Cr11
```
NV12和NV21属于YUV420格式，是一种two-plane模式，即Y和UV分为两个Plane，但是UV（CbCr）为交错存储，而不是分为三个plane。其提取方式与上一种类似，即Y'00、Y'01、Y'10、Y'11共用Cr00、Cb00

### 存储空间

假设，图片大小：`w`，`h`

> 这里的`w`和`h`，代表的是`y`在整个编码中的个数

#### YUV420

> - Y = w * h
> - UV = (w * h)/2
> - 所占内存：YUV = Y + UV = (w * h * 3) / 2

#### YUV422

> - 所占内存：YUV = (w * h) * 2


## RGB

`RGB：` 三原色光模式（RGB color model），又称RGB颜色模型或红绿蓝颜色模型，是一种`加色模型`，将`红（Red）`、`绿（Green）`、`蓝（Blue）`三原色的色光以不同的比例相加，以产生多种多样的色光。(且三原色的红绿蓝不可能用其他单色光合成)

![rgb](/images/2018/08/rgb.png)
> 三原色光的相加：`红光加绿光为黄光`，`黄光加蓝光为白光`


### RGB颜色查询对照表

* [RGB颜色查询对照表](http://www.114la.com/other/rgb.htm)

### 格式

* `RGB565`: 每个像素用16位表示，RGB分量分别使用5位、6位、5位
* `RGB555`: 每个像素用16位表示，RGB分量都使用5位（剩下1位不用）
* `RGB24`: 每个像素用24位表示，RGB分量各使用8位
* `RGB32`: 每个像素用32位表示，RGB分量各使用8位（剩下8位不用）
* `ARGB32`: 每个像素用32位表示，RGB分量各使用8位（剩下的8位用于表示Alpha通道值）

### 存储方式

#### RGB565

```
high                         low
7 6 5 4 3 2 1 0  7 6 5 4 3 2 1 0
R R R R R G G G  G G G B B B B B
```

``` C
#define RGB565_MASK_RED    0xF800
#define RGB565_MASK_GREEN  0x07E0
#define RGB565_MASK_BLUE   0x001F

R = (wPixel & RGB565_MASK_RED) >> 11;   // 取值范围0-31
G = (wPixel & RGB565_MASK_GREEN) >> 5;  // 取值范围0-63
B =  wPixel & RGB565_MASK_BLUE;         // 取值范围0-31

#define RGB(r,g,b) (unsigned int)( (r|0x08 << 10) | (g|0x08 << 5) | b|0x08 )
```

#### RGB555

```
X R R R R R G G  G G G B B B B B
```

### RGB24

``` C
typedef struct rgb24 {
    unsigned char rgbtBlue;
    unsigned char rgbtGreen;
    unsigned char rgbtRed;
} RGB;
```
### RGB32

``` C
typedef struct rgb32 {
    unsigned char rgbBlue;
    unsigned char rgbGreen;
    unsigned char rgbRed;
    unsigned char rgbReserved;
} RGB；
```

## YUV模型和RGB模型的关系

YUV色彩模型来源于RGB模型，该模型的特点是将`亮度`和`色度`分离开，从而适合于图像处理领域。

1. 应用——模拟领域
```
Y'= 0.299*R' + 0.587*G' + 0.114*B'
U'= -0.147*R' - 0.289*G' + 0.436*B' = 0.492*(B'- Y')
V'= 0.615*R' - 0.515*G' - 0.100*B' = 0.877*(R'- Y')
R' = Y' + 1.140*V'
G' = Y' - 0.394*U' - 0.581*V'
B' = Y' + 2.032*U'
```

2. 应用——数字领域
```
Y’ = 0.257*R' + 0.504*G' + 0.098*B' + 16
Cb' = -0.148*R' - 0.291*G' + 0.439*B' + 128
Cr' = 0.439*R' - 0.368*G' - 0.071*B' + 128
R' = 1.164*(Y’-16) + 1.596*(Cr'-128)
G' = 1.164*(Y’-16) - 0.813*(Cr'-128) - 0.392*(Cb'-128)
B' = 1.164*(Y’-16) + 2.017*(Cb'-128)
```
YCbCr模型来源于YUV模型。YCbCr是 YUV 颜色空间的偏移版本.
>上面各个符号都带了一撇，表示该符号在原值基础上进行了`伽马校正`,伽马校正有助于弥补在抗锯齿的过程中，线性分配伽马值所带来的细节损失，使图像细节更加丰富。在没有采用伽马校正的情况下，暗部细节不容易显现出来，而采用了这一图像增强技术以后，图像的层次更加明晰了。所以说`H264`里面的YUV应属于`YCbCr`.


## 参考

* [V4L2文档翻译（十）](https://blog.csdn.net/airk000/article/details/25032901)
* [YUV与RGB互转各种公式](https://www.cnblogs.com/luoyinjie/p/7219319.html)
* [运用NEON指令集加速RGB与YUV相互转换](https://www.jianshu.com/p/e498326a55b1)
