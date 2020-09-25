---
layout: post
title: linux下shell基础--软连接处理
date: '2018-12-21 17:14'
tags:
  - Shell
categories:
  - shell
abbrlink: 55887
---

软连接的截取和定位

场景: 当前所执行的脚本是连接,获取其实际的路径(位置)

<!--more-->

## 判断软连接

``` shell
#!/bin/bash

if [ -h "a.sh" ]; then
    echo "It's a soft connection"
fi
```
> `-h`: 软连接



``` shell
#!/bin/bash

PRG=$0
ls=`ls -ld "$PRG"`
link=`expr "$ls" : '.*-> \(.*\)$'`

echo "Current script PRG: $PRG"
echo "Soft connection path link: $link"

echo "Get the current path: `dirname "$PRG"`"

# 判断软连接是否在当前目录下
if expr "$link" : '/.*' > /dev/null; then
    PRG="$link"
else
    PRG="`dirname "$PRG"`/$link"
fi

echo "Soft connection path link: $link"
echo "Actual script path PRG: $PRG"
```

测试环境: 保存脚本到xx.sh

```
$mkdir -p aa/bb/cc
$mv xx.sh aa/bb/cc
$ln -s aa/bb/cc/xx.sh xx.sh
$ls -ld xx.sh
lrwxrwxrwx 1 xxx xxx 14 12月 21 16:57 xx.sh -> aa/bb/cc/xx.sh
$./xx.sh
```

执行脚本:
```
$./xx.sh
Current script PRG: ./xx.sh
Soft connection path link: aa/bb/cc/xx.sh
Get the current path: .
Soft connection path link: aa/bb/cc/xx.sh
Actual script path PRG: ./aa/bb/cc/xx.sh
```
