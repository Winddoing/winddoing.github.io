---
title: 博客文件整理——分类/标签
categories:
  - 工具
tags:
  - shell
abbrlink: 39420
date: 2017-10-29 18:07:24
---

## 批量修改分类名

``` shell
ls *.md | xargs sed  -i '/categories:
  -/{s/单片机/嵌入式/; }'
```

## 文件指定行数的字符大写转小写

所有tag改为小写

``` shell
find -name "*.md" | xargs sed -i '4,9s/.*/\L&/'
```

## 删除所有文件行尾空格

``` shell
find source/_posts/ -name "*.md" | xargs sed -i 's/[ ]*$//g'
```

## 标签一行变两行

```
categories:
  - 工具
转
categories:
  -
  - 工具
```

``` shell
grep "categories: " _posts/ -rn | awk -F: '{print $1}' | xargs sed -i "s/categories:/categories:\\n  -/g"
```

## 统计当前所有的标签

``` shell
grep "tags" ../_posts/ -rn -A 6 | grep " - " | awk '{print $3}' | sort -u
```
