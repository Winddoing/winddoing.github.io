---
layout: post
title: Linux下Anaconda环境搭建
date: '2018-11-17 15:13'
tags:
  - python
categories:
  - python
  - 环境
abbrlink: 65273
---

`Anaconda`是Python的包管理器和环境管理器

优点:
* Anaconda附带了一大批常用数据科学包，它附带了conda、Python和 150 多个科学包及其依赖项
* 管理包. Anaconda 是在 conda（一个包管理器和环境管理器）上发展出来的, 包括安装、卸载和更新包
* 管理环境. 方便创建和使用不同python版本的虚拟环境

<!--more-->

## 安装
### 下载

官网:[https://www.anaconda.com/download/#linux](https://www.anaconda.com/download/#linux)

### 安装

``` shell
bash Anaconda3-5.3.0-Linux-x86_64.sh
```
在安装的过程中，会问你安装路径(home目录下)，直接回车选择默认。有个地方问你是否将anaconda安装路径加入到环境变量（.bashrc)中，输入yes，默认的是no

如果选择了默认需要手动将anaconda的路径添加到环境变量
- 打开vi ~/.bashrc
- 添加anaconda的路径下的bin路径到`PATH`
```
export PATH=$PATH:$HOME/.tools/x86:$HOME/anaconda3/bin/
```

**安装完成后,需要重启终端或者`source ~/.bashrc`**

### 检查安装是否成功

which conda或conda –version
```
$conda --version
conda 4.5.11
```

## 使用命令--conda

### 帮助

```
$conda -h
usage: conda [-h] [-V] command ...

conda is a tool for managing and deploying applications, environments and packages.

Options:

positional arguments:
  command
    clean        Remove unused packages and caches.
    config       Modify configuration values in .condarc. This is modeled
                 after the git config command. Writes to the user .condarc
                 file (/home/xxx/.condarc) by default.
    create       Create a new conda environment from a list of specified
                 packages.
    help         Displays a list of available conda commands and their help
                 strings.
    info         Display information about current conda install.
    install      Installs a list of packages into a specified conda
                 environment.
    list         List linked packages in a conda environment.
    package      Low-level conda package utility. (EXPERIMENTAL)
    remove       Remove a list of packages from a specified conda environment.
    uninstall    Alias for conda remove. See conda remove --help.
    search       Search for packages and display associated information. The
                 input is a MatchSpec, a query language for conda packages.
                 See examples below.
    update       Updates conda packages to the latest compatible version. This
                 command accepts a list of package names and updates them to
                 the latest versions that are compatible with all other
                 packages in the environment. Conda attempts to install the
                 newest versions of the requested packages. To accomplish
                 this, it may update some packages that are already installed,
                 or install additional packages. To prevent existing packages
                 from updating, use the --no-update-deps option. This may
                 force conda to install older versions of the requested
                 packages, and it does not prevent additional dependency
                 packages from being installed. If you wish to skip dependency
                 checking altogether, use the '--force' option. This may
                 result in an environment with incompatible packages, so this
                 option must be used with great caution.
    upgrade      Alias for conda update. See conda update --help.

optional arguments:
  -h, --help     Show this help message and exit.
  -V, --version  Show the conda version number and exit.

conda commands available from other packages:
  build
  convert
  develop
  env
  index
  inspect
  metapackage
  render
  server
  skeleton
```

### 查看已安装的库

```
$conda list
```

### 安装库

```
$conda install numpy
```

### 更新库

```
$conda update numpy
```

### 验证是否安装成功

进入python环境使用`import numpy`进行验证,不报任何错误表示安装成功

```
$python3.7
Python 3.7.0 (default, Jun 28 2018, 13:15:42)
[GCC 7.2.0] :: Anaconda, Inc. on linux
Type "help", "copyright", "credits" or "license" for more information.
>>>
>>> import numpy
>>>
```

## Conda的环境管理

### 虚拟环境

Conda的环境管理功能允许我们同时安装若干不同版本的Python，并能自由切换。
若需要安装Python3.6，此时，我们需要做的操作如下：

1. 创建Python虚拟环境test，指定Python版本是3.6（不用管是3.6.x，conda会为我们自动寻找3.6.x中的最新版本）
```
conda create -n test python=3.6
```
2. 激活虚拟环境
```
source activate test
```
3. 关闭虚拟环境
```
source deactivate zeronet
```
4. 删除虚拟环境
```
conda remove -n test --all
```
5. 虚拟环境中安装额外的包
```
conda install -n test [package]
```

## 参考

* [conda环境管理](http://www.cnblogs.com/liaohuiqiang/p/9380417.html)
* [conda命令：管理包、管理环境](https://blog.csdn.net/z583636762/article/details/79166373)
