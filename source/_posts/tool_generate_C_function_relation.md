---
title: C程序函数调用关系
categories: 工具
tags:
  - callgraph
abbrlink: 1655
date: 2018-07-11 08:07:24
---

阅读源码

<!--more-->

## 安装


```
sudo apt-get install cflow graphviz
sudo apt-get install gawk

wget -c https://github.com/tinyclub/linux-0.11-lab/raw/master/tools/tree2dotx
wget -c https://github.com/tinyclub/linux-0.11-lab/raw/master/tools/callgraph
sudo cp tree2dotx callgraph /usr/local/bin
sudo chmod +x /usr/local/bin/{tree2dotx,callgraph}
```





## 使用

```
 callgraph -f main
```



## 参考

* [源码分析：静态分析 C 程序函数调用关系图](http://tinylab.org/callgraph-draw-the-calltree-of-c-functions/)
* [看开源代码利器—用Graphviz + CodeViz生成C/C++函数调用图(call graph)](https://www.linuxidc.com/Linux/2015-01/111501.htm)
