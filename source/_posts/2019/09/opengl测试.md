---
layout: post
title: OpenGL测试
date: '2019-09-12 18:33'
tags:
  - OpenGL
categories:
  - 多媒体
---

OpenGL API相关测试：

<!--more-->


## piglit


## WebGL Test

- https://www.khronos.org/registry/webgl/conformance-suites/1.0.3/webgl-conformance-tests.html
- https://www.khronos.org/registry/webgl/conformance-suites/2.0.0/webgl-conformance-tests.html


### 查看浏览器是否支持webgl的方法

- https://get.webgl.org/

![webgl_supports](/images/2019/09/webgl_supports.png)


### 浏览器对WebGL版本的支持

- http://caniuse.com

![webgl_version](/images/2019/09/webgl_version.png)
> 在页面搜索`WebGL`,查找`WebGL - 3D Canvas graphics`

- 图中，绿色部分为完全实现 webgl 标准功能的版本，但有些厂商的实现并不一定如其所述那样完整，而有些并没那么稳定
- 当某一浏览器无法运行 webgl 应用时，应考虑，是否需要手动开启 webgl 功能，如 safari;
- 当某一浏览器无法打开本地的 webgl 应用时，应考虑，浏览器对本地资源出于安全考虑，对本地资源的访问是需要设置是否允许的，针对不浏览器设置方法不同，而像 firefox 默认是开启的；


### 检测浏览器支持的WebGL Report

- https://webglreport.com/?v=2
