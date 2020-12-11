---
layout: post
title: CPU与GPU的Benchmark测试
date: '2020-12-10 15:18'
tags:
  - cpu
  - gpu
  - benchmark
categories:
  - 软件测试
---

测试CPU与GPU性能的测试工具

<!--more-->

# CPU性能测试

## geekbench

- 支持macOS，windows，linux，android，iOS

> https://browser.geekbench.com


# GPU性能测试

## specviewperf13

- 支持linux,windows
  > https://www.spec.org/gwpg/gpc.static/vp13info.html

**Running the SPECviewperf 13 Linux Edition benchmark**

The benchmark has the following minimum system requirements:

- Ubuntu Linux 16.04 and 18.04
- `OpenGL 4.0`
- 2GB of video memory
- 8GB of installed system memory
- 80GB available disk space
- 1920x1080 screen resolution for submissions published on the SPEC website

> http://spec.cs.miami.edu/gwpg/gpc.static/vp13linuxinfo.html


### 软件依赖

> os: ubuntu20.04

``` shell
sudo apt install xterm libgconf2-dev
```


## gfxbench

- gfxbench 4.0 --- Android, iOS, OSX, Windows 7,8,10, `Linux`
- gfxbench 5.0 --- Android, iOS, OSX, Windows


## 3Dmark

- 只支持windows,android和apple
  > https://www.3dmark.com

> 基准测试具有自然寿命，若不再能针对现代硬件提供有意义的结果，其自然寿命将终止。此页面上的基准测试不再受 UL 支持，在此仅供娱乐之用。它们可能不适用于最新的操作系统，并且在线服务可能也已经停止。我们建议您使用最新版本的 3DMark 和 PCMark 测试现代硬件和设备。
>
> - [不受支持的基准测试](https://benchmarks.ul.com/zh-hans/legacy-benchmarks?redirected=true#)


## unigine benchmark

- 支持linux, windows
  > https://benchmark.unigine.com/

### Superposition 2017

```
Hardware
    GPU:
        AMD Radeon HD 7xxx and higher
        Intel HD 5xxx and higher
        NVIDIA GeForce GTX 6xx and higher
    Video memory: 2 GB
    Disk space: 5 GB
```

Unigine Superposition Benchmark只提供`DirectX 11`和`OpenGL 4.5 API`


### Valley 2013  (ok)

```
Hardware
    GPU:
        ATI Radeon HD 4xxx and higher
        Intel HD 3000 and higher
        NVIDIA GeForce 8xxx and higher
    Video memory: 512 MB
    Disk space: 1.5 GB
```

## glmark2

- 支持linux
  > `glmark2` is an OpenGL 2.0 and ES 2.0 benchmark.

glmark提供了一系列涉及图形单元性能各个方面（缓冲，建筑物，照明，纹理等）的测试，从而可以进行更全面，更有意义的测试。每次测试进行10秒钟，并分别计算帧频。最后，用户会根据之前的所有测试获得性能得分。此工具具备简单性和完美的操作。


## Cinebench

- 只支持windows和apple
  > https://www.maxon.net/en/cinebench

Cinebench is a real-world cross-platform test suite that evaluates your computer's hardware capabilities. Improvements to Cinebench Release 23 reflect the overall advancements to CPU and rendering technology in recent years, providing a more accurate measurement of Cinema 4D's ability to take advantage of multiple CPU cores and modern processor features available to the average user. Best of all: It's free


## ShaderToyMark

- 只支持windows
  > https://www.geeks3d.com/20111215/shadertoymark-0-3-0-opengl-pixel-shader-benchmark-updated/

`ShaderToyMark` is an OpenGL benchmark, developed with GeeXLab, and focused on pixel shaders only. Why ShaderToyMark? Simply because I recently played with the pixel shaders available with Shader Toy, a great WebGL tool for testing GLSL shaders. And I said to myself: that would be nice to see several of these shaders running at the same time in the same 3D window… ShaderToyMark was born.


## Geeks3D TessMark

- 只支持windows
  > https://www.geeks3d.com/20110408/download-tessmark-0-3-0-released/

TessMark is a graphics benchmark focused on the GPU tessellation, one of the killer feature of OpenGL 4 capable cards (GeForce GTX 400, GTX 500, Radeon HD 5000, HD 6000).



## V-Ray Benchmark

- 支持windows、linux和Mac OS
  > https://www.chaosgroup.com/vray/benchmark

V-Ray Benchmark是一个免费的独立应用程序（不需要安装V-Ray），可以帮助用户测试其硬件的性能。 该基准测试包括两个测试场景，一个场景用于GPU，另一个场景用于CPU，具体取决于您要衡量的性能类型。


V-Ray Benchmark是一个免费的独立应用程序，用于测试系统渲染的速度。 简单，快速，并包含三个渲染引擎测试：
- V-Ray — CPU compatible
- V-Ray GPU CUDA — GPU and CPU compatible
- V-Ray GPU RTX — RTX GPU compatible


## OctaneBench

- 支持windows、linux和Mac OS
  > https://render.otoy.com/octanebench/

OctaneBench®允许您使用OctaneRender基准测试GPU。 通过确保每个人使用相同的版本以及相同的场景和设置来提供一个公平的竞争环境。 没有这些限制，基准测试结果可能会有很大差异，无法进行比较。

- nvidia GPU (cuda)，在linux下运行测试，需要cuda库的支持



# 参考

- https://alternativeto.net/software/3dmark-vantage/?platform=linux
- https://zhuanlan.zhihu.com/p/61167045
