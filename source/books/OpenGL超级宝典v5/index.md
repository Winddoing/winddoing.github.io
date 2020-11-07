---
title: OpenGL超级宝典--蓝宝石
date: 2019-09-10 8:07:24
comments: false
---

`渲染（Rendering）`：将数字和图形数据转换成3D空间图像的操作。
`变换（Transformation）`：顶点（vertex）位置的变化，变换矩阵（Transformation Matrix）
`投影（Projection）`：将3D坐标转换为二维屏幕坐标，投影矩阵（Projection Matrix）
`光栅化（Rasterization）`：实际绘制和填充每个顶点之间的像素形成线段
`着色（shading）`：通过沿着表面（在顶点之间）改变颜色值，能够轻松的创建光线照射在一个立方体上的效果
`纹理贴图（texture mapping）`：一个纹理不过是一幅贴到三角形或多边形上的图片
`混合（Blending）`：将不同的颜色混合到一起

`视口（ViewPort）`：把绘制坐标映射到窗口坐标
`图元（Primitives）`：一维或二维的实体或表面，如点、线段、三角形、多边形，在2D或3D中绘制一个物体的组成


# 第一部分：基本概念

## 缓冲区

``` C
glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
```
> 颜色缓冲区、深度缓冲区、模板缓冲区

- `颜色缓冲区`： 显示图像在内部存储的地方，如果清除会将屏幕上最后绘制的内容删除
- `帧缓冲区（FrameBuffer）`： 指所有缓冲区一起串联工作


### 混合

通常情况下OpenGL渲染时会把颜色值放到颜色缓冲区，混合发生在颜色缓冲区
- `glEnable(GL_BLEND)`: 新的颜色会与已经存在的颜色值在颜色缓冲区中进行组合
- `glDisable(GL_BLEND)`: 新的颜色值会完全覆盖原来的颜色值

颜色的组成由红、绿、蓝和可选的alpha成分，在任意情况下只要我们忽略一个alpha值，OpenGL都会将其设置为`1.0`

``` C
glBlendFunc(GLenum S, GLenum D)
```
> `S`,`D`:枚举值，分别是源和目标混合因子

### 抗锯齿

抗锯齿处理的优点是能够使多边形的边缘更为光滑，使渲染效果显得更为自然和逼真。

- 多重采样

## 着色器

> 在图形硬件上执行的单独程序，用来处理顶点和光栅化任务

着色器使用GLSL（OpenGL Shader Language）语言进行编程，
着色器传递数据的方法三种：`属性`、`uniform`、`纹理`,(为着色器程序提供所需的数据)

### 属性

> 所谓属性就是一个对每个顶点都要做改变的数据元素（只作用于`顶点着色器`）

属性值可以是`整数`、`浮点数`和`布尔类型`。属性总是以`四维向量`的形式进行内部存储的，分别是`x`、`y`、`z`、`w`，OpenGL中会将第4个`w`设置为1

### uniform值

> 对整批次的属性都取统一的单个值时，也就是它不变时，通过uniform变量设置


### 示例

```
PFNGLCREATESHADERPROC
```


## 纹理

### 纹理数据与着色器之间如何关联？


## 光栅化




## 其他

- 光线追踪器
- 离线渲染器


# 第二部分：深入探索

## 缓冲区对象

缓冲区对象实现了对像素的实际控制，在无需CPU介入的情况下，可以将GPU中的像素数据移动到合适的位置。

用途：保存顶点数据、像素数据、纹理数据、着色器处理的输入、或者不同着色器阶段的输出

```C
void glGenBuffers( 	GLsizei n,
  	GLuint * buffers);
```
- `n`：指定要生成的缓冲区对象名称的数量。
- `buffers`：指定一个数组，在其中存储生成的缓冲区对象名称。

``` C
GLuint vbo;
glGenObject(1,&vbo);
GLuint vbo[3];
glGenObject(3,vbo);
```

### 像素缓冲区对象——PBO
