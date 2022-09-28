---
layout: post
title: OpenGL进行RGBA转NV12
date: '2022-09-23 11:28'
mathjax: true
tags:
  - opengl
  - rgba
  - yuv
categories:
  - 多媒体
  - OpenGL
abbrlink: ab7c39de
---

通过OpenGL使用GPU进行色彩空间的转换可以加速转换时间，提高效率。

<!--more-->

## RGBA

RGB图像具有三个通道 R、G、B，分别对应红、绿、蓝三个分量，由三个分量的值决定颜色；通常，会给RGB图像加一个通道alpha，即透明度，于是共有四个分量共同控制颜色。

### 像素存储格式

一个`6x4`的图像，示例：
```
RGBA RGBA RGBA RGBA RGBA RGBA
RGBA RGBA RGBA RGBA RGBA RGBA
RGBA RGBA RGBA RGBA RGBA RGBA
RGBA RGBA RGBA RGBA RGBA RGBA
          - RGBA -  
```
内存空间大小：6x4x(8x4)=768bit


## NV12

### 像素存储格式

一个`6x4`的图像，示例：
```
Y Y Y Y Y Y
Y Y Y Y Y Y
Y Y Y Y Y Y
Y Y Y Y Y Y
U V U V U V
U V U V U V
 - NV12 -  
```
内存空间大小：6x(4+4/2)x8=288bit

## RGBA转NV12-计算公式

{% raw %}
$$
\begin{bmatrix}
   Y \\
   U \\
   V \\
\end{bmatrix} =
\begin{bmatrix}
   0.299  & 0.587  & 0.114 \\
   -0.169 & -0.331 & 0.5   \\
   0.5    & 0.419  & -0.081 \\
\end{bmatrix}
\begin{bmatrix}
   R \\
   G \\
   B \\
\end{bmatrix} +
\begin{bmatrix}
   0 \\
   128 \\
   128 \\
\end{bmatrix} \tag{RGB to YUV}
$$

$$
\begin{bmatrix}
   R \\
   G \\
   B
\end{bmatrix} =
\begin{bmatrix}
   1 & -0.00093 & 1.401687 \\
   1 & -0.3437  & -0.71417 \\
   1 & 1.77216  & 0.00099
\end{bmatrix}
\begin{bmatrix}
   Y \\
   U - 128 \\
   V -128
\end{bmatrix} \tag{ YUV to RGB}
$$
{% endraw %}

根据上面公式单个像素点的RGB转YUV计算方式：
```
Y =  0.299R + 0.587G + 0.114B
U = -0.169R - 0.331G + 0.500B
V =  0.500R - 0.419G - 0.081B
```

## shader转换

需求：在实际业务中渲染后的最终结果将输出一张RGBA格式的纹理，但是编码器的输入格式为NV12,因此需要将一个RGBA的纹理转换为一个NV12格式的纹理，并且可以一次性读取NV12格式的数据（glReadPixels）.


shader实现RGB转YUV原理图：




### 片段着色器处理

参考实现代码：https://github.com/githubhaohao/NDK_OpenGLES_3_0/app/src/main/cpp/sample/RGB2NV21Sample.cpp

RGBA转成YUYV
![opengl rgba to yuv](/images/2022/09/opengl_rgba_to_yuv.png)

```
#version 300 es
precision mediump float;
in vec2 v_texCoord;
layout(location = 0) out vec4 outColor;
uniform sampler2D s_TextureMap;//RGBA纹理, 输入纹理参数
uniform float u_Offset;//采样偏移

//RGB to YUV
//Y =  0.299R + 0.587G + 0.114B
//U = -0.147R - 0.289G + 0.436B
//V =  0.615R - 0.515G - 0.100B

const vec3 COEF_Y = vec3( 0.299,  0.587,  0.114);
const vec3 COEF_U = vec3(-0.147, -0.289,  0.436);
const vec3 COEF_V = vec3( 0.615, -0.515, -0.100);

void main()
{
    vec2 texelOffset = vec2(u_Offset, 0.0);
    vec4 color0 = texture(s_TextureMap, v_texCoord);
    //偏移 offset 采样
    vec4 color1 = texture(s_TextureMap, v_texCoord + texelOffset);

    float y0 = dot(color0.rgb, COEF_Y);
    float u0 = dot(color0.rgb, COEF_U) + 0.5;
    float v0 = dot(color0.rgb, COEF_V) + 0.5;
    float y1 = dot(color1.rgb, COEF_Y);

    outColor = vec4(y0, u0, y1, v0);
}
```

#### 为什么UV分量要加`0.5`

因为`归一化`

YUV格式图像`UV分量`的默认值分别是`127`，`Y分量`默认值是`0` ，8个bit位的取值范围是`0 ~ 255`，由于在shader中纹理采样值需要进行归一化，所以`UV分量`的采样值需要分别加`0.5`，确保RGB到YUV正确转换

> `归一化`的目的就是使得预处理的数据被限定在一定的范围内（比如[0,1]或者[-1,1]），从而消除奇异样本数据导致的不良影响

> 纹理格式:
>
>OpenGL默认以无符号`归一化`格式存储纹理；当数据以无符号归一化格式存储时，**纹素的值在内存中以整数存储，整数在读进着色器时转化为浮点数，并且用整数对应的最大值来除，最后生成[0.0, 1.0]的数据传给着色器**。如果提供的是_SNORM修改符（例如GL_RGBA8_SNORM），数据是有符号的归一化；此时在内存中的数据是有符号整数，并且在它返回给着色器前，转换为浮点数，并被对应的最大有符号整数除，生成范围在[-1.0, 1.0]的浮点数值并传给着色器


YUV默认值`[0, 127, 127]`的情况下，着色器读取数据时进行归一化(每个分量除以最大值255)，将变为`[0, 0.5, 0.5]`；而RGB默认值`[0, 0, 0]`, 进行归一化，后依然为`[0, 0, 0]`，因此在shader中进行转换时需要考虑归一化后的参数，RGB转YUV时，UV分量需要加`0.5`，而YUV转RGB时，UV分量需要减`0.5`。


### 计算着色器处理

```
#extension GL_NV_image_formats : enable
layout (rgba8, binding = 0) readonly uniform lowp image2D rgbaImage;  //输入纹理ID
layout (r8, binding = 1) writeonly uniform lowp image2D yImage;       //输出纹理ID
layout (local_size_x = 16, local_size_y = 16) in;   //以16x16像素块为处理单元
layout(location = 2) uniform int height;            //输入参数纹理高度
void main()
{
    ivec2 storePos = ivec2(gl_GlobalInvocationID.xy);
    ivec2 nvPos;
    ivec2 ypos;
    vec4 vr;  //right
    vec4 vl;  //left
    vec4 vld;
    vec4 vrd;
    vec4 sumUV;
    vec4 yvec;
    float y0,u0,v0,y1,u1,v1,y2,u2,v2,y3,u3,v3;
    if(storePos.y >= height)
    {
        return;
    }
    if(storePos.x % 2 == 0 && storePos.y % 2 == 0)
    {
        nvPos = storePos;
        ypos = storePos;
        vl = imageLoad(rgbaImage, storePos);
        storePos.x+=1;
        vr = imageLoad(rgbaImage, storePos);
        storePos.y+=1;
        vrd = imageLoad(rgbaImage, storePos);
        storePos.x-=1;
        vld = imageLoad(rgbaImage, storePos);

        y0 = 0.299*vl.r + 0.587 *vl.g + 0.114*vl.b;
        u0 = (-0.169*vl.r - 0.331*vl.g + 0.500*vl.b) + 0.5;
        v0 = ( 0.500*vl.r - 0.419*vl.g - 0.081*vl.b) + 0.5;

        y1 = 0.299*vr.r + 0.587 *vr.g + 0.114*vr.b;
        u1 = (-0.169*vr.r - 0.331*vr.g + 0.500*vr.b) + 0.5;
        v1 = ( 0.500*vr.r - 0.419*vr.g - 0.081*vr.b) + 0.5;

        y2 = 0.299*vrd.r + 0.587 *vrd.g + 0.114*vrd.b;
        u2 = (-0.169*vrd.r - 0.331*vrd.g + 0.500*vrd.b) + 0.5;
        v2 = ( 0.500*vrd.r - 0.419*vrd.g - 0.081*vrd.b) + 0.5;

        y3 = 0.299*vld.r + 0.587 *vld.g + 0.114*vld.b;
        u3 = (-0.169*vld.r - 0.331*vld.g + 0.500*vld.b) + 0.5;
        v3 = ( 0.500*vld.r - 0.419*vld.g - 0.081*vld.b) + 0.5;

        sumUV.x = (u0+u1+u2+u3)/4.0;
        sumUV.y = (v0+v1+v2+v3)/4.0;

        // calculate position of NV components
        nvPos.x = nvPos.x;
        nvPos.y = nvPos.y/2;

        // update start position of NV buffer
        nvPos.y += height;

        imageStore(yImage, nvPos, sumUV);
        sumUV.x = sumUV.y;
        nvPos.x += 1;
        imageStore(yImage, nvPos, sumUV);

        yvec.x = y0;
        imageStore(yImage, ypos, yvec);
        ypos.x = ypos.x+1;
        yvec.x = y1;
        imageStore(yImage, ypos, yvec);
        ypos.y = ypos.y+1;
        yvec.x = y2;
        imageStore(yImage, ypos, yvec);
        ypos.x = ypos.x-1;
        yvec.x = y3;
        imageStore(yImage, ypos, yvec);

    }
}
```

输入输出纹理传入shader需要`glGetTextureImage`进行绑定。

片段着色器和计算着色器在同一个OpenGL上下文中无法使用，会导致渲染后的生成的像素点变为白色。

因此实际操作中需要以渲染上下文为基础，创建一个共享上下文进行转换（转换上下文），这样也可以实现渲染与转换的异步操作，提供部分性能。


## 另一种处理方式—输出y和uv两个纹理

参考：https://stackoom.com/cn_en/question/3kAdu

着色器代码：
```
#version 450 core
layout(local_size_x = 32, local_size_y = 32) in;
layout(binding = 0) uniform sampler2D src;
layout(binding = 0) uniform writeonly image2D dst_y;
layout(binding = 1) uniform writeonly image2D dst_uv;
void main() {
    ivec2 id = ivec2(gl_GlobalInvocationID.xy);
    vec3 yuv = rgb_to_yuv(texelFetch(src, id).rgb);
    imageStore(dst_y, id, vec4(yuv.x,0,0,0));
    imageStore(dst_uv, id, vec4(yuv.yz,0,0));
}
```
有很多不同的YUV约定，我不知道您的编码器应该使用哪种约定(上面的转换公式)。因此，将上面的rgb_to_yuv替换为YUV-> RGB转换的倒数。

```
GLuint in_rgb = ...; // rgb(a) input texture
int width = ..., height = ...; // the size of in_rgb

GLuint tex[2]; // output textures (Y plane, UV plane)

glCreateTextures(GL_TEXTURE_2D, tex, 2);
glTextureStorage2D(tex[0], 1, GL_R8, width, height); // Y plane

// UV plane -- TWO mipmap levels
glTextureStorage2D(tex[1], 2, GL_RG8, width, height);

// use this instead if you need signed UV planes:
//glTextureStorage2D(tex[1], 2, GL_RG8_SNORM, width, height);

glBindTextures(0, 1, &in_rgb);
glBindImageTextures(0, 2, tex);
glUseProgram(compute); // the above compute shader

int wgs[3];
glGetProgramiv(compute, GL_COMPUTE_WORK_GROUP_SIZE, wgs);
glDispatchCompute(width/wgs[0], height/wgs[1], 1);

glUseProgram(0);
glGenerateTextureMipmap(tex[1]); // downsamples tex[1]

// copy data to the CPU memory:
uint8_t *data = (uint8_t*)malloc(width*height*3/2);
glGetTextureImage(tex[0], 0, GL_RED, GL_UNSIGNED_BYTE, width*height, data);
glGetTextureImage(tex[1], 1, GL_RG, GL_UNSIGNED_BYTE, width*height/2,
    data + width*height);
```
- 此代码未经测试。
- 假定宽度和高度可以被32整除。
- 它可能在某处缺少内存障碍。
- 这不是从GPU中读取数据的最有效方法-您可能需要至少在读取下一帧的同时计算下一帧。


## 代码实现——参考（未测试）

参考代码来自：https://github.com/cohenrotem/Rgb2NV12/

```
//https://software.intel.com/en-us/node/503873
//YCbCr Color Model:
//    The YCbCr color space is used for component digital video and was developed as part of the ITU-R BT.601 Recommendation. YCbCr is a scaled and offset version of the YUV color space.
//    The Intel IPP functions use the following basic equations [Jack01] to convert between R'G'B' in the range 0-255 and Y'Cb'Cr' (this notation means that all components are derived from gamma-corrected R'G'B'):
//    Y' = 0.257*R' + 0.504*G' + 0.098*B' + 16
//    Cb' = -0.148*R' - 0.291*G' + 0.439*B' + 128
//    Cr' = 0.439*R' - 0.368*G' - 0.071*B' + 128


//Y' = 0.257*R' + 0.504*G' + 0.098*B' + 16
static float Rgb2Y(float r0, float g0, float b0)
{
    float y0 = 0.257f*r0 + 0.504f*g0 + 0.098f*b0 + 16.0f;
    return y0;
}

//U equals Cb'
//Cb' = -0.148*R' - 0.291*G' + 0.439*B' + 128
static float Rgb2U(float r0, float g0, float b0)
{
    float u0 = -0.148f*r0 - 0.291f*g0 + 0.439f*b0 + 128.0f;
    return u0;
}

//V equals Cr'
//Cr' = 0.439*R' - 0.368*G' - 0.071*B' + 128
static float Rgb2V(float r0, float g0, float b0)
{
    float v0 = 0.439f*r0 - 0.368f*g0 - 0.071f*b0 + 128.0f;
    return v0;
}

//Convert two rows from RGB to two Y rows, and one row of interleaved U,V.
//I0 and I1 points two sequential source rows.
//I0 -> rgbrgbrgbrgbrgbrgb...
//I1 -> rgbrgbrgbrgbrgbrgb...
//Y0 and Y1 points two sequential destination rows of Y plane.
//Y0 -> yyyyyy
//Y1 -> yyyyyy
//UV0 points destination rows of interleaved UV plane.
//UV0 -> uvuvuv
static void Rgb2NV12TwoRows(const unsigned char I0[],
                            const unsigned char I1[],
                            int step,
                            const int image_width,
                            unsigned char Y0[],
                            unsigned char Y1[],
                            unsigned char UV0[])
{
    int x;  //Column index

    //Process 4 source pixels per iteration (2 pixels of row I0 and 2 pixels of row I1).
    for (x = 0; x < image_width; x += 2)
    {
        //Load R,G,B elements from first row (and convert to float).
        float r00 = (float)I0[x*step + 0];
        float g00 = (float)I0[x*step + 1];
        float b00 = (float)I0[x*step + 2];

        //Load next R,G,B elements from first row (and convert to float).
        float r01 = (float)I0[x*step + step+0];
        float g01 = (float)I0[x*step + step+1];
        float b01 = (float)I0[x*step + step+2];

        //Load R,G,B elements from second row (and convert to float).
        float r10 = (float)I1[x*step + 0];
        float g10 = (float)I1[x*step + 1];
        float b10 = (float)I1[x*step + 2];

        //Load next R,G,B elements from second row (and convert to float).
        float r11 = (float)I1[x*step + step+0];
        float g11 = (float)I1[x*step + step+1];
        float b11 = (float)I1[x*step + step+2];

        //Calculate 4 Y elements.
        float y00 = Rgb2Y(r00, g00, b00);
        float y01 = Rgb2Y(r01, g01, b01);
        float y10 = Rgb2Y(r10, g10, b10);
        float y11 = Rgb2Y(r11, g11, b11);

        //Calculate 4 U elements.
        float u00 = Rgb2U(r00, g00, b00);
        float u01 = Rgb2U(r01, g01, b01);
        float u10 = Rgb2U(r10, g10, b10);
        float u11 = Rgb2U(r11, g11, b11);

        //Calculate 4 V elements.
        float v00 = Rgb2V(r00, g00, b00);
        float v01 = Rgb2V(r01, g01, b01);
        float v10 = Rgb2V(r10, g10, b10);
        float v11 = Rgb2V(r11, g11, b11);

        //Calculate destination U element: average of 2x2 "original" U elements.
        float u0 = (u00 + u01 + u10 + u11)*0.25f;

        //Calculate destination V element: average of 2x2 "original" V elements.
        float v0 = (v00 + v01 + v10 + v11)*0.25f;

        //Store 4 Y elements (two in first row and two in second row).
        Y0[x + 0]    = (unsigned char)(y00 + 0.5f);
        Y0[x + 1]    = (unsigned char)(y01 + 0.5f);
        Y1[x + 0]    = (unsigned char)(y10 + 0.5f);
        Y1[x + 1]    = (unsigned char)(y11 + 0.5f);

        //Store destination U element.
        UV0[x + 0]    = (unsigned char)(u0 + 0.5f);

        //Store destination V element (next to stored U element).
        UV0[x + 1]    = (unsigned char)(v0 + 0.5f);
    }
}


//Convert image I from pixel ordered RGB to NV12 format.
//I - Input image in pixel ordered RGB format
//image_width - Number of columns of I
//image_height - Number of rows of I
//J - Destination "image" in NV12 format.

//I is pixel ordered RGB color format (size in bytes is image_width*image_height*3):
//RGBRGBRGBRGBRGBRGB
//RGBRGBRGBRGBRGBRGB
//RGBRGBRGBRGBRGBRGB
//RGBRGBRGBRGBRGBRGB
//
//J is in NV12 format (size in bytes is image_width*image_height*3/2):
//YYYYYY
//YYYYYY
//UVUVUV
//Each element of destination U is average of 2x2 "original" U elements
//Each element of destination V is average of 2x2 "original" V elements
//
//Limitations:
//1. image_width must be a multiple of 2.
//2. image_height must be a multiple of 2.
//3. I and J must be two separate arrays (in place computation is not supported).
void Rgb2NV12(const unsigned char I[], int step,
              const int image_width,
              const int image_height,
              unsigned char J[])
{
    //In NV12 format, UV plane starts below Y plane.
    unsigned char *UV = &J[image_width*image_height];

    //I0 and I1 points two sequential source rows.
    const unsigned char *I0;  //I0 -> rgbrgbrgbrgbrgbrgb...
    const unsigned char *I1;  //I1 -> rgbrgbrgbrgbrgbrgb...

    //Y0 and Y1 points two sequential destination rows of Y plane.
    unsigned char *Y0;    //Y0 -> yyyyyy
    unsigned char *Y1;    //Y1 -> yyyyyy

    //UV0 points destination rows of interleaved UV plane.
    unsigned char *UV0; //UV0 -> uvuvuv

    int y;  //Row index

    //In each iteration: process two rows of Y plane, and one row of interleaved UV plane.
    for (y = 0; y < image_height; y += 2)
    {
        I0 = &I[y*image_width*step];        //Input row width is image_width*3 bytes (each pixel is R,G,B).
        I1 = &I[(y+1)*image_width*step];

        Y0 = &J[y*image_width];            //Output Y row width is image_width bytes (one Y element per pixel).
        Y1 = &J[(y+1)*image_width];

        UV0 = &UV[(y/2)*image_width];    //Output UV row - width is same as Y row width.

        //Process two source rows into: Two Y destination row, and one destination interleaved U,V row.
        Rgb2NV12TwoRows(I0,
                        I1,
                        step,
                        image_width,
                        Y0,
                        Y1,
                        UV0);
    }
}
```

## 参考

- [RGB YUV420sp 互相转换 nv21](https://www.jianshu.com/p/da2a682ae964)
- [OpenGL ES 将 RGB 图像转换为 YUV 格式。](https://juejin.cn/post/6966608082042355725)
- [如何使用OpenGL将RGBA转换为NV12？](https://stackoom.com/cn_en/question/3kAdu)
- [【OpenGL】用OpenGL shader实现将YUV(YUV420,YV12)转RGB-(直接调用GPU实现，纯硬件方式，效率高) ](https://www.cnblogs.com/mazhenyu/p/7240407.html) —— 多个纹理处理
- [OpenGL ES：rgb转换yuv](https://www.jianshu.com/p/197319b0b007)
