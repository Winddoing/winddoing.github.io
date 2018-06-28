---
title: Git操作
date: 2016-10-7 23:07:24
categories: 工具
tags: [Git]
---

记录平时对git的使用方法和技巧
[TOC]
<!--- more --->
### 1. 创建本地git库
     mkdir test.git
进入test.git

		 git init --bare --shared

### 2. 创建分支
     git branch branch_name
     删除本地分支：
               git branch -d branch_name

### 3. 切换分支
     git checkout  branch_name

### 4. 下载
     git clone  URL

### 5. 日志
     git commit

### 6. 提交
     git push 远程库名  分支名

### 7. 更新
     git pull 远程库名  分支名

### 8.添加代码
     git add <filename>
     git add -A    #添加所有修改

### 9.查看日志
     git log
     git log -n     #查看前n条日志
     git log --stat  #查看日志的修改情况
     git log -p       #查看日志的具体修改
     git log <filename/dirname>  #查看该文件或目录的修改日志

### 10.回退
     git reset HEAD <filename> #将该文件从缓冲区撤回

### 11.查看远程库
     git remote -v
     添加远程库：
     git remote add <name> <url>

### 12.获取远程库中的最新版本，但与git pull 不同它不会merge
     git  fetch  远程库名  分支名
作用：可以对比远程库与当前本地的差异。

### 13.查看标签
		git tag
作用：一个稳定的版本或者完成一个功能，为了发布或者保存而打的标签，主要是发布

### 14.切换标签
		git checkout <Tag>


## DoTo

1. [Git 最佳实践：分支管理](http://blog.jobbole.com/109466/)
