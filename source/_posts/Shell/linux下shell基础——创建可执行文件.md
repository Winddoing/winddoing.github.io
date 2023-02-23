---
layout: post
title: ' linux下shell基础——创建可执行文件'
date: '2020-12-26 15:00'
tags:
  - shell
categories:
  - Shell
abbrlink: 5b5dea38
---

在平时通过shell脚本部署一个服务和应用时，除了自身的脚本外可能还依赖一些二进制文件，如何将二者一起打包发布，使其变为一个可执行文件，方便后期维护和使用

为实现以上目标可以使用`sed`实现，具体流程如下：
- 前期使用`cat`将两个文件合并为一个文件
- 后期运行是通过`sed`将两个文件分开，后在具体操作

<!--more-->

## 测试脚本

``` shell
#!/bin/bash

echo "This is test shell"
```

## 打包测试脚本（如同二进制文件）

``` shell
tar zcvf test.tar.gz test.sh
```
> 在实际应用中可以根据实际需要使用其他二进制文件


## 运行测试脚本(run.sh)

``` shell
#!/bin/bash

set -x

echo "Test shell+bin"
mkdir tmp

sed -n '1,/^exit 0$/!p' $0 > ./tmp/test.tar.gz

cd tmp
tar zxvf test.tar.gz
bash ./test.sh
cd -

exit 0
```

> `sed -n '1,/^exit 0$/!p' $0 > ./tmp/test.tar.gz`命令用于将后面`cat`合并两个文件重新分开，并执行
> - 当前文件中除了`第一行`和`exit 0`所在行中间的部分，也就是`exit 0`后面的内容，输出到`./tmp/test.tar.gz`。`$0`是当前脚本的名，也就是`run.sh`
> - `exit 0`在这里可以看作一个分割标志，可以使用其他字符串代替

## 合并可执行文件

``` shell
cat run.sh test.tar.gz > run-tst.sh
```

重新生成的运行脚本：
``` shell
#!/bin/bash

set -x

echo "Test shell+bin"
mkdir tmp

sed -n '1,/^exit 0$/!p' $0 > ./tmp/test.tar.gz

cd tmp
tar zxvf test.tar.gz
bash ./test.sh
cd -

exit 0
^_?^H^@^@^@^@^@^@^C??AK?0^T^G?^?O?\?[??^M?&?GO?^B?^ZL???d?^S(;{???N?ɛ^H~?֯a?^^??@^YC??^H<??=x?8e???`??????r?????DȀ???I?d"^Cƅ^_^H??u?/^K???(X^[????????????T?Ynu^T?Z^Tә)^U???*^L3r?????^K???ϖ?*??T^W>=iT?
TAS??3^RL?????n?^Ri?~??~?m???^S??[?p֮n?????^O?*;o̕3u^Uf^?Y:Rs]?`??%^????jU?????^B^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@??;??z^]^@(^@^@
```

## shell加密——shc

将shell脚本转换为一个可执行的二进制文件，可以保护shell脚本中的一些敏感信息和具体的执行步骤。

``` shell
sudo apt install shc
```

``` shell
shc -v -f run-tst.sh
```
