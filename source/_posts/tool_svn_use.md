---
title: SVN的基础使用
date: 2018-05-7 23:07:24
categories: SVN
tags: [svn]
---

svn的基础使用命令：

<!--more-->

## 安装

```
sudo apt-get install subversion
```

## 命令行使用

### 下载代码

```
svn checkout svn_path local_path
```

### 添加文件

```
svn add files
```

### 更新

```
svn update
```

### 修改提交

```
svn commit -m path-to-commit，其中path-to-commit可以为空
```

### 查看log

```
svn log
```
> -v : 显示修改目录

### 创建分支

```
svn copy -m "create branch" http://svn_server/xxx_repository http://svn_server/xxx_repository/br_feature001
```
>分支名： br_feature001

### 切换分支

```
svn switch http://svn_server/xxx_repository/br_feature001
```

### 删除分支

```
svn rm http://svn_server/xxx_repository/br_feature001
```

### 恢复本地修改

```
revert PATH...
```

## 示例--创建分支提交

```
svn up

svn copy http://172.16.180.100/svn/Hi3798MV200 http://172.16.180.100/svn/Hi3798MV200/Hi3798MV200_M -m "single S multi R code branch"

svn
```

## 图形界面使用

### RapidSVN
