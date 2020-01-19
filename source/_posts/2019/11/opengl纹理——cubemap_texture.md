---
layout: post
title: OpenGL纹理——Cubemap Texture
date: '2019-11-29 16:04'
tags:
  - OpenGL
categories:
  - 多媒体
  - OpenGL
abbrlink: 43690
---

>A Cubemap Texture is a texture, where each mipmap level consists of six 2D images which must be square. The 6 images represent the faces of a cube. The texture coordinate used to access a cubemap is a 3D direction vector which represents a direction from the center of the cube to the value to be accessed.
>https://www.khronos.org/opengl/wiki/Cubemap_Texture

<!--more-->

## error

```
Mesa: User error: GL_INVALID_ENUM in glSamplerParameteri(pname=GL_TEXTURE_CUBE_MAP_SEAMLESS)
```
- 错误打印
``` C
case INVALID_PNAME:                                                 
_mesa_error(ctx, GL_INVALID_ENUM, "glSamplerParameteri(pname=%s)\n",
        _mesa_enum_to_string(pname));                               
```
>mesa:src/mesa/main/samplerobj.c

- 错误函数
``` C
glSamplerParameteri(state->ids[i], GL_TEXTURE_CUBE_MAP_SEAMLESS, templ->seamless_cube_map);
```


## GL_TEXTURE_CUBE_MAP_SEAMLESS

``` C                                   
glEnable(GL_TEXTURE_CUBE_MAP_SEAMLESS);
```                                     


立方体贴图的边界利用相邻面线性差值,消除立方体边缘的缝隙

## 参考

- [立方体贴图(Cubemap)](https://learnopengl-cn.readthedocs.io/zh/latest/04%20Advanced%20OpenGL/06%20Cubemaps/)
