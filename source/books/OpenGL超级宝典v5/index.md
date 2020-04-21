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
`图元（Primitives）`：一维或二维的实体或表面，如点、线段、多边形，在2D或3D中绘制一个物体的组成

## 着色器

> 在图形硬件上执行的单独程序，用来处理顶点和光栅化任务

着色器使用GLSL（OpenGL Shader Language）语言进行编程，
着色器传递数据的方法三种：`属性`、`uniform`、`纹理`

### 属性

属性值可以是`整数`、`浮点数`和`布尔类型`。属性总是以`四维向量`的形式进行内部存储的，分别是`x`、`y`、`z`、`w`，OpenGL中会将第4个`w`设置为1

### uniform

## 纹理


## 光栅化




## 其他

- 光线追踪器
- 离线渲染器
