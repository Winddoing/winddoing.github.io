---
layout: "post"
title: "OpenGL调试——apitrace"
date: "2019-12-05 19:22"
tags:
  - OpenGL
categories:
  - OpenGL
  - 多媒体
---

`apitrace`是一套用于调试OpenGL应用程序和驱动程序的工具，其中包括用于生成应用程序进行的所有OpenGL调用的跟踪的工具以及用于在程序执行期间重放这些跟踪并检查渲染和OpenGL状态的工具。

<!--more-->

## 官网

> http://apitrace.github.io

源码下载：
```
git clone https://github.com/janesma/apitrace.git
```

- ubuntu安装
```
sudo apt install apitrace apitrace-gui
```

## 用法

### 命令行 —— apitrace
- 全部抓取
```
$apitrace trace glxgears
```
生成glxgears.trace文件

### 图形 —— qapitrace

```
$qapitrace
```

```
$qapitrace glxgears.trace
```

## 参考

- [Apitrace OpenGL profiling view](https://www.x.org/wiki/Events/XDC2016/Program/trukhin_apitrace.pdf)
