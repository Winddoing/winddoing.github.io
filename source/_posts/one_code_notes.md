---
title: 一行代码的作用
categories: 随笔
tags:
  - code
abbrlink: c6279e60
date: 2016-08-18 08:07:24
---

## 网页自由编辑

```
document.body.contentEditable=`true`
```

> 1. 在任意需要编辑的网页中点击`F12`
> 2. 在调试面板选中`Console`，然后输入上面的这行代码，回车。
> 3. 现在当前整个网页可以随便编辑了


## CSDN复制代码

- 添加一个书签，名称随意设置，比如CSDN复制
- 设置URL为:
	```
	javascript:document.body.contentEditable='true';document.designMode='on'; void 0
	```
- 在CSDN中遇到无法复制的代码，点击该书签后进行再复制即可
