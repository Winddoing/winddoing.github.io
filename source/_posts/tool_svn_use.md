---
title: SVN的基础使用
date: 2018-05-7 23:07:24
categories: 工具
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

### 添加新文件

> 将新的文件添加到代码仓库中,如果一个文件不在版本则需要使用add添加
```
svn add files
```
* `--no-ignore`: disregard default and svn:ignore and svn:global-ignores property ignores
* `--force`: 强制添加

#### 递归添加

```
svn add . --no-ignore --force
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


### 回退到某一个（r123）log

```
svn up -r r123
```

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

## 提交代码

1. 将代码更新到与目前版本库里一致（`svn up`），如果存在冲突解决冲突
2. 使用(`svn st`)查看所有文件状态，判断使用有新添加的文件，如果有新添加的文件，使用(`svn add`)将新文件添加到版本库
  - **在确定提交前，使用（`svn st`）查看是否有多余的修改，如果有将其退回（svn revert）**
3. 提交代码
```
svn commit -m "备注修改的目的"
```

## 补丁-patch

### 制作补丁

```
svn diff > patch.diff
```

### 打补丁

```
patch < to-file.patch
```

### 取消补丁

```
patch -RE  < to-file.patch
```
> `-R`: 取消打过的补丁
> `-E`: 选项说明如果发现了空文件，那么就删除它

## 示例--创建分支提交

```
svn up

svn copy http://172.16.180.100/svn/Hi3798MV200 http://172.16.180.100/svn/Hi3798MV200/Hi3798MV200_M -m "single S multi R code branch"

svn
```

## 图形界面使用

### RapidSVN
