---
layout: post
title: 图像压缩编码——JPEG
date: '2019-05-08 11:23'
tags:
  - JPEG
categories:
  - 多媒体
  - 编码
abbrlink: 59613
---

![jpeg_8x8_block](/images/2019/05/jpeg_8x8_block.png)

>在JPEG中的数据处理单元是`8x8`block

在JPEG中编码器和解码器是`互逆`的，因此在编解码过程中提供的表说明完全一致
<!--more-->

## 数据格式-YUV

标准色彩空间：一个或三个组件。 对于三个组件，YCbCr

## 编码

![jpeg_encoder](/images/2019/05/jpeg_encoder.png)

## 解码

![jpeg_decoder](/images/2019/05/jpeg_decoder.png)


## DCT变换

在计算FDCT之前，对应输入数据进行`层平移`处理，即把输入数据变成带符号的2的补码表示。对于8位输入精度，层平移通过`减128`来完成。

- FDCT：

$F(u, v) = \dfrac{1}{4}c(u)(v)\left[\sum_{i=0}^{7}\sum_{j=0}^{7}f(i, j)\cos\dfrac{(2i+1)u\pi}{16}\cos\dfrac{(2j+1)v\pi}{16}\right]$

- IDCT：

$f(i, j) = \dfrac{1}{4}c(u)c(v)\left[\sum_{u=0}^{7}\sum_{v=0}^{7}F(u, v)\cos\dfrac{(2i+1)u\pi}{16}\cos\dfrac{(2j+i)v\pi}{16}\right]$

$Cu, Cv = 1/\sqrt{2}$  为  $u, v = 0$
$Cu, Cv = 1$  除此以外

## 量化

所谓量化就是用`像素值`÷`量化表对应值`所得的结果。由于量化表左上角的值较小，右上角的值较大，这样就起到了保持低频分量，抑制高频分量的目的。

> Y分量代表了亮度信息，UV分量代表了色差信息,因此量化表通常两张。

- 编码时

$Sq_{vu}=round\left(\dfrac{S_{vu}}{Q_{vu}}\right)$

- 解码时

$R_{vu} = Sq_{vu} \times Q_{vu}$

### 量化表

``` C
//亮度分量量化表
static int quant_y[8][8] = {
    {16, 11, 10, 16, 24,  40,  51,  61},
    {12, 12, 14, 19, 26,  58,  60,  55},
    {14, 13, 16, 24, 40,  57,  69,  56},
    {14, 17, 22, 29, 51,  87,  80,  62},
    {18, 22, 37, 56, 68,  109, 103, 77},
    {24, 35, 55, 64, 81,  104, 113, 92},
    {49, 64, 78, 87, 103, 121, 120, 101},
    {72, 92, 95, 98, 112, 100, 103, 99}
};

//色度分量量化表
static int quant_uv[8][8] = {
    {17, 18, 24, 47, 99, 99, 99, 99},
    {18, 21, 26, 66, 99, 99, 99, 99},
    {24, 26, 56, 99, 99, 99, 99, 99},
    {47, 66, 99, 99, 99, 99, 99, 99},
    {99, 99, 99, 99, 99, 99, 99, 99},
    {99, 99, 99, 99, 99, 99, 99, 99},
    {99, 99, 99, 99, 99, 99, 99, 99},
    {99, 99, 99, 99, 99, 99, 99, 99}
};
```

> 所谓JPEG的有损压缩，损的是量化过程中的高频部分; 因为对于人眼而言`低频部分比高频部分要重要得多`

## 8×8块样本与DCT系数的关系

![jpeg_8x8block与DCT系数关系](/images/2019/05/jpeg_8x8block与dct系数关系.png)

## 编码分类

![zigzag](/images/2019/05/zigzag.png)

- 一类是每个8*8格子中的[0,0]位置上元素，即`DC`(直流分量)，代表8*8个子块的平均值,采用`差分编码DPCM`
  - $DIFF = DC_i - PRED$
  - 在扫描行和每个重启动间隔的开始时，将DC系数的预测值(PRED)初始化为`0`.
- 二类是每个8*8格子中的其余63个元素，即`AC`(交流分量)，采用`行程编码RLE`
  - 为了保证低频分量先出现，高频分量后出现，以增加行程中连续“0”的个数，这63个元素采用了“Z”字型(Zig-Zag)的排列方法
  - 如果“Z”序列中的剩余系数全为0，那么可直接使用块结束符（EOB）进行编码

### zigzag

![jpeg_zig_zag_table](/images/2019/05/jpeg_zig_zag_table.png)

## 熵编码

熵编码指熵保持编码，编码时，平均信息量保持不变。

### Huffman编码

- 对出现频率较高的符号，设计较短的码字，反之，用最长的码字
- Huffman编码表事先定义好

#### 编码表

- 亮度`Y`的`DC` huffman码表
- 色度`U\V`的`DC` huffman码表
- 亮度`Y`的`AC` huffman码表
- 色度`U\V`的`AC` huffman码表

> [JPEG Huffman Coding Table](http://www.cnblogs.com/dxs959229640/p/3853790.html)

编码表的生成：https://raw.githubusercontent.com/Winddoing/CodeWheel/master/jpeg/jpeg_huffman_ac_dc_table.c

主要生成`EHUFSI`和`EHUFCO`两类表

```
亮度DC系数:
===> size, EHUFSI_DC:
===> dump: {
    2     3     3     3     3     3     4     5     6     7     8     9
}
===> code, EHUFCO_DC:
===> dump: {
    0     2     3     4     5     6    14    30    62   126   254   510
}
色差DC系数:
===> size, EHUFSI_DC:
===> dump: {
    2     2     2     3     4     5     6     7     8     9    10    11
}
===> code, EHUFCO_DC:
===> dump: {
    0     1     2     6    14    30    62   126   254   510  1022  2046
}
亮度AC系数:
===> size, EHUFSI_AC:
===> dump: {
    4     2     2     3     4     5     7     8    10    16    16     0     0     0     0     0
    0     4     5     7     9    11    16    16    16    16    16     0     0     0     0     0
    0     5     8    10    12    16    16    16    16    16    16     0     0     0     0     0
    0     6     9    12    16    16    16    16    16    16    16     0     0     0     0     0
    0     6    10    16    16    16    16    16    16    16    16     0     0     0     0     0
    0     7    11    16    16    16    16    16    16    16    16     0     0     0     0     0
    0     7    12    16    16    16    16    16    16    16    16     0     0     0     0     0
    0     8    12    16    16    16    16    16    16    16    16     0     0     0     0     0
    0     9    15    16    16    16    16    16    16    16    16     0     0     0     0     0
    0     9    16    16    16    16    16    16    16    16    16     0     0     0     0     0
    0     9    16    16    16    16    16    16    16    16    16     0     0     0     0     0
    0    10    16    16    16    16    16    16    16    16    16     0     0     0     0     0
    0    10    16    16    16    16    16    16    16    16    16     0     0     0     0     0
    0    11    16    16    16    16    16    16    16    16    16     0     0     0     0     0
    0    16    16    16    16    16    16    16    16    16    16     0     0     0     0     0
   11    16    16    16    16    16    16    16    16    16    16
}
===> code, EHUFCO_AC:
===> dump: {
   10     0     1     4    11    26   120   248  1014 65410 65411     0     0     0     0     0
    0    12    27   121   502  2038 65412 65413 65414 65415 65416     0     0     0     0     0
    0    28   249  1015  4084 65417 65418 65419 65420 65421 65422     0     0     0     0     0
    0    58   503  4085 65423 65424 65425 65426 65427 65428 65429     0     0     0     0     0
    0    59  1016 65430 65431 65432 65433 65434 65435 65436 65437     0     0     0     0     0
    0   122  2039 65438 65439 65440 65441 65442 65443 65444 65445     0     0     0     0     0
    0   123  4086 65446 65447 65448 65449 65450 65451 65452 65453     0     0     0     0     0
    0   250  4087 65454 65455 65456 65457 65458 65459 65460 65461     0     0     0     0     0
    0   504 32704 65462 65463 65464 65465 65466 65467 65468 65469     0     0     0     0     0
    0   505 65470 65471 65472 65473 65474 65475 65476 65477 65478     0     0     0     0     0
    0   506 65479 65480 65481 65482 65483 65484 65485 65486 65487     0     0     0     0     0
    0  1017 65488 65489 65490 65491 65492 65493 65494 65495 65496     0     0     0     0     0
    0  1018 65497 65498 65499 65500 65501 65502 65503 65504 65505     0     0     0     0     0
    0  2040 65506 65507 65508 65509 65510 65511 65512 65513 65514     0     0     0     0     0
    0 65515 65516 65517 65518 65519 65520 65521 65522 65523 65524     0     0     0     0     0
 2041 65525 65526 65527 65528 65529 65530 65531 65532 65533 65534
}
```


#### 编码流程

编码过程是根据一组扩展表`XHUFCO`和`XHUFSI`定义的，它们包含所有可能差值的完整霍夫曼CODE和SIZE集合

##### DC系数Huffman编码

```
SIZE = XHUFSI(DIFF)
CODE = XHUFCO(DIFF)
code SIZE bits of CODE
```
> XHUFSI和XHUFCO从编码器表`EHUFSI`和`EHUFCO`产生， 使用DIFF作为两个表的索引。

代码实现：

``` C
/* Encode the DC coefficient difference per section F.1.2.1 */

temp = temp2 = block[0] - last_dc_val;

/* This is a well-known technique for obtaining the absolute value without a
 * branch.  It is derived from an assembly language technique presented in
 * "How to Optimize for the Pentium Processors", Copyright (c) 1996, 1997 by
 * Agner Fog.
 */
temp3 = temp >> (CHAR_BIT * sizeof(int) - 1);
temp ^= temp3;
temp -= temp3;

/* For a negative input, want temp2 = bitwise complement of abs(input) */
/* This code assumes we are on a two's complement machine */
temp2 += temp3;

/* Find the number of bits needed for the magnitude of the coefficient */
nbits = JPEG_NBITS(temp); //查表计算位宽

/* Emit the Huffman-coded symbol for the number of bits */
code = dctbl->ehufco[nbits];
size = dctbl->ehufsi[nbits];
EMIT_BITS(code, size)

/* Mask off any extra bits in code */
temp2 &= (((JLONG)1) << nbits) - 1;

/* Emit that number of bits of the value, if positive, */
/* or the complement of its magnitude, if negative. */
EMIT_BITS(temp2, nbits)
```
> libjpeg-turbo: [jchuff.c](https://github.com/libjpeg-turbo/libjpeg-turbo/blob/master/jchuff.c)

##### AC系数Huffman编码

ZZ中的每个非零AC系数由一个复合的8位值RS描述:

```
RS = binary ’RRRRSSSS’
```
- 后面4个低有效位（`SSSS`）为ZZ中下一个非0系数的幅值定义类别
- 前面4个高有效位（`RRRR`）给出ZZ中相对与先前非0系数位置（也就是非0系数之间的0系数行程）

由于0系数的行程可能超过15，故定义值`’RRRRSSSS‘ = ’0xf0‘`来表示行程为15的0系数组，后跟一0幅值的系数。另外，特殊值`’RRRRSSSS’ = ‘00000000’`用于对块结束符`EOB`进行编码（当块中的所有剩余系数为0时）。

![jpeg_huffman_ac_code](/images/2019/05/jpeg_huffman_ac_code.png)


![jpeg_huffman_ac_code1](/images/2019/05/jpeg_huffman_ac_code1.png)

![jpeg_huffman_ac_code2](/images/2019/05/jpeg_huffman_ac_code2.png)

## 示例：8x8block

一个8x8的量化后的亮度块，已完成zigzag排序：

```
系数： 12   5   -2   0   2   0   0   0   1    0     -1     0
下标： 0    1    2   3   4   5   6   7   8  9 ~ 30  31  32 ~ 63
```

### DC系数编码

```
DIFF = 12； //'1100b'
SSSS = 4；  //12位宽表示类别
SIZE = EHUFSI_DC(SSSS) = 3 = 11b
CODE = EHUFCO_DC(SSSS) = 5 = 101b
RESULT = `101b`
RESULT += DIFF = `1011100`
```

### AC系数编码

- ZZ(1) = 5: 它与ZZ(0)之间无0系数R=0，RRRR=0；幅值5落入第3类，SSSS=3；即’RRRRSSSS‘ = ’0/3‘。查AC Huffman[编码表](#编码表)为`100`。幅值5的编码为`101`，故ZZ(1)的编码为`100101`

```
ZZ(1) = 5; //'101b'
R = 0;     //R当前系数与前一个系数之间0的个数
SSSS = CSIZE(ZZ(1)) = 3;
RS = 16 * R + SSSS = 16*0 + 3 = 3;
SIZE = EHUFSI_AC[RS] = 3 = 11b
CODE = EHUFCO_AC[RS] = 4 = 100b
RESULT = `100b`
RESULT += ZZ(1) = `100101b`
```
- ZZ(2) = -2, 'RRRRSSSS' = '0/2', 查AC Huffman编码表是`01`，幅值-2落入第2类，ZZ(2) - 1 = -3, -3用补码表示并`取后两位`（-2除去符号位占两个位宽）为`01`， 因此ZZ(2)的编码`0101`
- ZZ(3) = 0
- ZZ(4) = 2, 编码：`1101110`

```
ZZ(4) = 2; //10b
R = 1;
SSSS = CSIZE(ZZ(4)) = 2;
RS = 16 * R + SSSS = 16*1 + 2 = 18;
SIZE = EHUFSI_AC[RS] = 5 = 101b
CODE = EHUFCO_AC[RS] = 27 = 11011b
RESULT = '11011'
RESULT += ZZ(4) = '1101110'
```
- ZZ(5) ~ ZZ(7) = 0
- ZZ(8) = 1, 编码：`1110101`
- ZZ(0) ~ ZZ(30) = 0, ZZ(31) = -1;由于RRRR=22 > 15,故先编一个F/0,huffman编码为`11111111001`。然后RRRR=22 - 16 = 6，这时RRRRSSSS=6/1， Huffman编码`1111011`；幅值-1在第1类，取（-1-1=-2）补码的最后一位`0`，最后编码`11110110`
- ZZ(32) ~ ZZ(63) = 0,直接用一个EOB(0/0)结束，编码`1010`

## JPEG文件

### 文件结构

JPEG的每个标记都是由 2个字节组成，其前一个字节是固定值`0xFF`，每个标记之前还可以添加数目不限的0xFF填充字节(fill byte)

|         标记          |    数值     |            作用            |
|:---------------------:|:-----------:|:--------------------------:|
| SOI（Start Of Image） |    0xD8     |          图像开始          |
|         APP0          |    0xEO     |       JFIF应用数据块       |
|         APPn          | 0xE1 ~ 0xEF | 其他的应用数据块(n, 1～15) |
|          DQT          |    0xDB     |           量化表           |
| SOF0(Start Of Frame)  |    0xC0     |           帧开始           |
|          DHT          |    0xC4     |     霍夫曼(Huffman)表      |
|          SOS          |    0xDA     |         扫描线开始         |
|          EOI          |    0xD9     |          图像结束          |

### jpeg文件解析示例

```
Frame 1: 345637 bytes on wire (2765096 bits), 345637 bytes captured (2765096 bits)
MIME file
JPEG File Interchange Format
    Marker: Start of Image (0xffd8)
    Marker segment: Reserved for application segments - 0 (0xFFE0)
        Marker: Reserved for application segments - 0 (0xffe0)
        Length: 16
        Identifier: JFIF
        Version: 1.1
            Major Version: 1
            Minor Version: 1
        Units: Dots per inch (1)
        Xdensity: 0
        Ydensity: 0
        Xthumbnail: 0
        Ythumbnail: 0
    Marker segment: Define quantization table(s) (0xFFDB)
        Marker: Define quantization table(s) (0xffdb)
        Length: 67
        Remaining segment data: 65 bytes
    Marker segment: Define quantization table(s) (0xFFDB)
        Marker: Define quantization table(s) (0xffdb)
        Length: 67
        Remaining segment data: 65 bytes
    Start of Frame header: Start of Frame (non-differential, Huffman coding) - Baseline DCT (0xFFC0)
        Marker: Start of Frame (non-differential, Huffman coding) - Baseline DCT (0xffc0)
        Length: 17
        Sample Precision (bits): 8
        Lines: 1080
        Samples per line: 1920
        Number of image components in frame: 3
        Component identifier: 1
        0010 .... = Horizontal sampling factor: 2
        .... 0010 = Vertical sampling factor: 2
        Quantization table destination selector: 0
        Component identifier: 2
        0001 .... = Horizontal sampling factor: 1
        .... 0001 = Vertical sampling factor: 1
        Quantization table destination selector: 1
        Component identifier: 3
        0001 .... = Horizontal sampling factor: 1
        .... 0001 = Vertical sampling factor: 1
        Quantization table destination selector: 1
    Marker segment: Define Huffman table(s) (0xFFC4)
        Marker: Define Huffman table(s) (0xffc4)
        Length: 27
        Remaining segment data: 25 bytes
    Marker segment: Define Huffman table(s) (0xFFC4)
        Marker: Define Huffman table(s) (0xffc4)
        Length: 73
        Remaining segment data: 71 bytes
    Marker segment: Define Huffman table(s) (0xFFC4)
        Marker: Define Huffman table(s) (0xffc4)
        Length: 26
        Remaining segment data: 24 bytes
    Marker segment: Define Huffman table(s) (0xFFC4)
        Marker: Define Huffman table(s) (0xffc4)
        Length: 51
        Remaining segment data: 49 bytes
    Start of Segment header: Start of Scan (0xFFDA)
        Marker: Start of Scan (0xffda)
        Length: 12
        Number of image components in scan: 3
        Scan component selector: 1
        0000 .... = DC entropy coding table destination selector: 0
        .... 0000 = AC entropy coding table destination selector: 0
        Scan component selector: 2
        0001 .... = DC entropy coding table destination selector: 1
        .... 0001 = AC entropy coding table destination selector: 1
        Scan component selector: 3
        0001 .... = DC entropy coding table destination selector: 1
        .... 0001 = AC entropy coding table destination selector: 1
        Start of spectral or predictor selection: 0
        End of spectral selection: 63
        0000 .... = Successive approximation bit position high: 0
        .... 0000 = Successive approximation bit position low or point transform: 0
    Entropy-coded segment (dissection is not yet implemented): f9354ef5d8ab0a2b96af8daa0006ad822804c0d54d18906a...
    Marker: End of Image (0xffd9)
```
> wireshark解析

## 参考

* [itu-t81.pdf](https://www.w3.org/Graphics/JPEG/itu-t81.pdf) —— 图像数字压缩和编码
* [JPEG图像编码](https://blog.csdn.net/my_happy_life/article/details/82997597)
* [JPEG File Interchange Format，JFIF](https://www.w3.org/Graphics/JPEG/jfif3.pdf)
