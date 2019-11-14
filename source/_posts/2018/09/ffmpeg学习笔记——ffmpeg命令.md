---
layout: post
title: FFmpeg学习笔记——ffmpeg命令
date: '2018-09-05 15:49'
tags:
  - FFmpeg
categories:
  - FFmpeg
abbrlink: 41754
---

ffmpeg命令相关用法。
> - 环境： `ubuntu 18.04`
> - ffmpeg版本： `3.4.4-0ubuntu0.18.04.1`

<!--more-->

## 制作ts流

```
ffmpeg -i test.mp4 -ss 00:00:12 -to 00:00:13 -vcodec libx264 -g 1 -crf 1 test.ts
```
> ts流中包含I帧

参数解析：
- `-i`： 设定输入流（input）
- `-ss time_off`： 开始时间
- `-to time_stop`： 结束时间
- `-vcodec codec `：设定视频编解码器，未设定时则使用与输入流相同的编解码器，('copy' to copy stream)
    - libx264： ts流
- `-g <int>`：关键帧(I帧)间隔控制
- `-crf <int>`：（Constant Rate Factor） 量化比例的范围为0~51，其中0为无损模式，23为缺省值，51可能是最差的。该数字越小，图像质量越好

```
ffmpeg -i water.mp4 -codec copy -bsf:v h264_mp4toannexb water.ts
```

## 转H264

```
ffmpeg -i water.mp4 -c:v copy -bsf:v h264_mp4toannexb -an water.h264
```

## wav转mp4

```
ffmpeg -i water.wmv -c:v libx264 -strict -2 water.mp4
```

## mp4转yuv

```
ffmpeg -i food.mp4 food.yuv
```

## ffmpge帮助信息

```
ffmpeg -h full > help.txt
```
