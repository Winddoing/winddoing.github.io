---
title: VIM绘图--dot、uml
date: 2018-07-21 8:07:24
categories: 工具
tags: [vim, dot, uml]
---

在整理软件逻辑和设计思路时，通过VIM进行画图记录。

* `DOT` + graphviz: 结构图和流程图
* `plantuml`: UML图
* `DrawIt`: 简易图（ASCII）

<!--more-->

## DOT + graphviz

```
vi aaa.dot
```
>使用DOT语法，绘画

### DOT语法

`graph`（无向图）或者`digraph`（无向图）表示图，然后`{}`中的内容是对图的描述，注释风格和C类似（“`//`”用于单行注释，`/**/`用于多行注释）。如一个无向图：
```
//usr/bin/dot                                                                  
graph graph1 {                                          
    label = "this is a graph";                                                 
    aa; bb;                                                                    
    a -- b;                                     

    {p, q} -- {x, y};                                                          

    {c, d} -- o;                                                               

    o -- end [style = dotted, color = red];                                    

    subgraph subgraph1 {                                                       
        label = "This is subgraph";                                            
        bgcolor = greenyellow;                                                 
        cc; dd;                                                                
    }                                                                          

    ccc -- ddd [label = "test"]                                                
}                                                                              
```

> * [Dot脚本语言语法整理](https://blog.csdn.net/jy692405180/article/details/52077979)
> * [DOT + graphviz 轻松画图神器](https://blog.csdn.net/stormdpzh/article/details/14648827)

## Plantuml

```
vi aaa.uml
```
> * [类图](https://yq.aliyun.com/articles/25405)
> * [时序图](https://blog.csdn.net/zh_weir/article/details/72675013)
> * [流程图](https://blog.csdn.net/zhangjikuan/article/details/53484558)

## DrawIt

```
+----------------+
|                |
+-------+--------+
|       |        |
|       +--------+
|       |        |
+-------+--------+
```

* 绘图--操作                                                          
>:DIstart   -- 启动（默认虚线----）                                  
>:DIstop    -- 停止                                                  
>:DIdbl     -- 双实线(════)                                          
>:DInrml    -- 单虚线(----)                                          
>:DIsngl    -- 单实现(────)                                          

* 划线：
>方向键（直线）；Page up、Page Down（斜线）                   

* 箭头：
><、>、^、v                                                   

* 擦除：
>空格切换                                                      
