---
title: Linux应用调试方法---Debug
date: 2017-12-20 23:07:24
categories: Linux内核
tags: [kernel, Debug]
---

常用的Linux应用调试方法：

<!--more-->
## strace

### 用法：

``` shell
strace ./a.out
```

## gdb

core dump
### 查看core设置

``` shell
ulimit -a
```

### 开启core file

``` shell
limit -c unlimited
```

### 使用

* 异常程序(段错误)

``` C
int main(int argc, char *argv[])
{
    int *a;

    *a = 1;

    while(1)
    {

    }
    return EXIT_SUCCESS;
}
```

* 运行异常程序后,生成core文件

* 使用gdb查看异常位置

``` shell
gdb ./a.out core
```

