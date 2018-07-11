---
title: EDID
date: 2018-07-11 9:07:24
categories: 多媒体
tags: [edid]
---


> 环境： ubuntu 18.04

edid读取工具： get-edid

<!--more-->

## get-edid

```
sudo apt-get install read-edid
```

## 获取EDID原始数据并存储到文件

```
sudo get-edid > edid.bin
```

## 解析edid

### 在线解析

> 在[http://www.edidreader.com/](http://www.edidreader.com/)网站可以对该数据进行在线解析。把以上128字节复制到该网站的对应数据窗口

### 本地解析

```
parse-edid < edid.bin
```

## 参考

* [修改显示器EDID工具(源码)](https://github.com/bulletmark/edid-rw))
* [http://hubpages.com/technology/how-to-reflash-a-monitors-corrupted-edid //读取和修改显示器的EDID](http://hubpages.com/technology/how-to-reflash-a-monitors-corrupted-edid)
* [EDID使用说明](https://blog.csdn.net/ganshuyu/article/details/38844963)
