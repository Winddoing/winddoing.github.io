---
title: 整理文件分类
date: 2017-10-29 18:07:24
categories: 工具
tags: [shell]
---


```
ls *.md | xargs sed  -i '/categories:/{s/单片机/嵌入式/; }'
```
