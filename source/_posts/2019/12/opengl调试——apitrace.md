---
layout: post
title: OpenGL调试——apitrace
date: '2019-12-05 19:22'
tags:
  - OpenGL
categories:
  - 多媒体
  - OpenGL
abbrlink: 65255
---

`apitrace`是一套用于调试OpenGL应用程序和驱动程序的工具，其中包括用于生成应用程序进行的所有OpenGL调用的跟踪的工具以及用于在程序执行期间重放这些跟踪并检查渲染和OpenGL状态的工具。

<!--more-->

## 官网

> http://apitrace.github.io

源码下载：
```
git clone https://github.com/janesma/apitrace.git
```

ubuntu安装:
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

- webgl
```
./apitrace trace --api gl /usr/bin/chromium-browser https://webglsamples.org/aquarium/aquarium.html
```

- 重现解析
```
./apitrace replay --pgpu --pcpu --ppd chromium-browser.trace > chromium-browser.retrace
```

- 输出结果
```
# call no gpu_start gpu_dura cpu_start cpu_dura vsize_start vsize_dura rss_start rss_dura pixels program name         
call 741 0 0 15358963 4741 0 0 0 0 -1 0 glViewport                                                                    
call 742 0 0 15389926 2370 0 0 0 0 -1 0 glScissor                                                                     
call 2903 0 0 125774519 8000 0 0 0 0 -1 0 glViewport                                                                  
call 2904 0 0 125802222 6223 0 0 0 0 -1 0 glScissor                                                                   
```

### 图形 —— qapitrace

```
$qapitrace
```
```
$qapitrace chromium-browser.trace
```

#### profile

选中工具栏Trace下的`Profile`功能，会执行与replay相同的动作，并将结果更直观的展示出来

![qapistrace-profile](/images/2019/12/qapistrace_profile.png)
> 将鼠标放到某个函数上会出现提示信息，双击会在主窗口中显示当前函数

界面说明：
- 第一部分
  - `Frames`: 帧号
  - `CPU`: 处理器端的执行顺序和时长（用宽度表示）
  - `GPU`: 显卡draw函数的执行顺序和时长
  - `编号n`: 第n个shader的执行情况
- 第二部分
  - `GPU`、`CPU`的执行时长（高度）
- 第三部分
  - `Program`: shader的执行情况,左边编号与第一部分相对应

## 参考

- [Apitrace OpenGL profiling view](https://www.x.org/wiki/Events/XDC2016/Program/trukhin_apitrace.pdf)
- [使用apitrace分析OpenGL程序性能](https://blog.simbot.net/index.php/2017/12/09/apitrace/)
