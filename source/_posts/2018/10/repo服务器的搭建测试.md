---
layout: post
title: repo服务器的搭建测试
date: '2018-10-11 19:41'
tags:
  - repo
categories:
  - 工具
abbrlink: 44256
---

`repo`的作用就是进行多个git仓库的统一管理，其实repo就是一个python的脚本，这里测试repo服务的搭建和使用

<!--more-->

## 下载repo

```
git clone https://review.mfunz.com/git-repo git-repo-core.git
```
>`服务端`和`客户端`
> - 服务端： `git-repo-core`
> - 客户端： `git-repo-core/repo`

1. 进入`git-repo-core`将`repo`拷贝到客户端或本地的`/user/bin/`下（或者自定义的目录下使用时通过绝对路径）
2. 指定拷贝后客户端使用的`repo`中的`REPO_URL`变量为`git-repo-core`的路径（服务器将是IP:path）
```
REPO_URL = '/home/xxx/test/repo-test/server/git-repo-core.git'
```
> edit: `vi client/repo`

3. 测试目录结构
```
$tree -L 2
.
├── client
│   └── repo
└── server
    └── git-repo-core.git
```
>pwd:`/home/xxx/test/repo-test`


## repo服务器


### 新建manifest仓库

在server目录下创建
```
mkdir -p repos/manifest
```

在manifest目录下添加`default.xml`文件。
``` xml
<?xml version="1.0" encoding="UTF-8"?>
<manifest>
	<remote name="origin"
		fetch="/home/xxx/test/repo-test/server/repos" />

	<default remote="origin" revision="master" />

	<project name="test1" path="test1"/>
	<project name="test2" path="test2"/>
  <project name="test3" path="tst333"/>

</manifest>
```
> file: default.xml

#### xml文件语法
* `remote`: 设置服务器端的路径和名称
    - `name`: 服务器端名称
    - `fetch`：指repo仓库服务器端所在的位置，可以是远程，也可以是本地，测试使用本地
    ```
    $ git remote -v
    origin	/home/xxx/test/repo-test/server/repos/test1 (fetch)
    origin	/home/xxx/test/repo-test/server/repos/test1 (push)
    ```
* `default`: 设置服务器端名和分支名
    - `remote`: 服务器端名称（与`remote`中的name相同）
    - `revision`: 分支名
    - ` sync-j`： 指定在sync操作时的线程数，（sync-j="4"）
* `project`: 设置repo管理的git仓库
    - `name`： git仓库服务端（远端）的名字
    - `path`： clone到本地的名字
    - `revision`： 指定需要获取的git提交点，可以定义成固定的branch，或者是明确的commit哈希值
    ```
    <project name="test1" path="test1" revision="088216c4e32e"/>
    ```
#### manifest文件格式

- <copyfile>标签

> 可以作为<project>标签的子标签，每一个<copyfile>标签表明了在repo sync的时候从src把文件拷贝到dest。 src相对于该project来说，dest相对于根目录来说。

- <linkfile>标签

> 和<copyfile>标签的作用类似，不过是不进行拷贝，而是进行一个符号链接

```
-       <project name="tools" path="tools"/>
+       <project name="tools" path="tools">
+               <linkfile dest="envsetup.sh" src="envsetup.sh"/>
+       </project>
+
```

- <include>标签

> 用来引入一个其他的manifest,有一个name属性指向被引用的manifest, 路径是相对于mamanifest库的根目录

#### 初始化仓库

1. 进入`manifest`目录
``` shell
$ git init
$ git add .
$ git commit -m "init manifest"
```
2. 返回`manifest`上一级目录
``` shell
$ git clone --bare manifest
```

3. 新建完成`manifest.git`仓库后，`manifest`可以删除
```
[xxx@xxx-pc]~/test/repo-test/server/repos
=====>$ls
manifest manifest.git
```

### 新建test1和test2仓库

``` shell
$ mkdir test1 test2
$ cd test1
$ echo test1 > readme.md
$ git init
$ git add .
$ git commit -m "init test1"
$ cd ..
$ git clone --bare test1
```
> `test2`仓库以相同的步骤建立

- 结果：
```
[xxx@xxx-pc]~/test/repo-test/server/repos
=====>$ls
manifest  manifest.git  test1  test1.git  test2  test2.git  test3  test3.git
```

## repo测试

进入client目录

### 初始化 repo init

``` shell
$./repo init -u /home/xxx/test/repo-test/server/repos/manifest.git
Get /home/xxx/test/repo-test/server/git-repo-core.git
remote: Counting objects: 4050, done.
remote: Compressing objects: 100% (1844/1844), done.
remote: Total 4050 (delta 2144), reused 4050 (delta 2144)
Receiving objects: 100% (4050/4050), 3.45 MiB | 31.58 MiB/s, done.
Resolving deltas: 100% (2144/2144), done.
From /home/xxx/test/repo-test/server/git-repo-core
 * [new branch]      stable     -> origin/stable
 * [new tag]         v1.0       -> v1.0
 ...
 * [new tag]         v1.9.4     -> v1.9.4
 * [new tag]         v1.9.5     -> v1.9.5
 * [new tag]         v1.9.6     -> v1.9.6
Get /home/xxx/test/repo-test/server/repos/manifest.git
remote: Counting objects: 9, done.        
remote: Compressing objects: 100% (6/6), done.        
remote: Total 9 (delta 2), reused 0 (delta 0)        
From /home/xxx/test/repo-test/server/repos/manifest
 * [new branch]      master     -> origin/master

Your identity is: xxx <xxx@xx.com>
If you want to change this, please re-run 'repo init' with --config-name

repo has been initialized in /home/xxx/test/repo-test/client
```
### 同步代码 repo sync

``` shell
$./repo sync
Fetching project test2
remote: Counting objects: 3, done.        
remote: Total 3 (delta 0), reused 0 (delta 0)        
From /home/xxx/test/repo-test/server/repos/test2
 * [new branch]      master     -> origin/master
Fetching project test1
remote: Counting objects: 3, done.        
remote: Total 3 (delta 0), reused 0 (delta 0)        
From /home/xxx/test/repo-test/server/repos/test1
 * [new branch]      master     -> origin/master
```
- 下载目录
```
$ls
repo  test1  test2  tst333
```

### 遍历repo每个仓库并执行相同代码 repo forall

``` shell
./repo forall -h
Usage: repo forall [<project>...] -c <command> [<arg>...]
repo forall -r str1 [str2] ... -c <command> [<arg>...]"

Options:
  -h, --help            show this help message and exit
  -r, --regex           Execute the command only on projects matching regex or
                        wildcard expression
  -i, --inverse-regex   Execute the command only on projects not matching
                        regex or wildcard expression
  -g GROUPS, --groups=GROUPS
                        Execute the command only on projects matching the
                        specified groups
  -c, --command         Command (and arguments) to execute
  -e, --abort-on-errors
                        Abort if a command exits unsuccessfully

  Output:
    -p                  Show project headers before output
    -v, --verbose       Show command error messages
    -j JOBS, --jobs=JOBS
                        number of commands to execute simultaneously
```

- 示例
``` shell
=====>$./repo forall -c "git log"
commit 088216c4e32e0257ec23f2ac61c87866f8e8dd98 (HEAD, origin/master, m/master)
Author: xxx <xxx@xx.com>
Date:   Thu Oct 11 20:04:17 2018 +0800

    init test1
commit c150415858ffbdfa7c010d35d66b6282cd7b3cbe (HEAD, origin/master, m/master)
Author: xxx <xxx@xx.com>
Date:   Thu Oct 11 20:05:19 2018 +0800

    init test2
```

### repo支持命令

``` shell
$./repo --trace
usage: repo COMMAND [ARGS]
The most commonly used repo commands are:
  abandon        Permanently abandon a development branch
  branch         View current topic branches
  branches       View current topic branches
  checkout       Checkout a branch for development
  cherry-pick    Cherry-pick a change.
  diff           Show changes between commit and working tree
  diffmanifests  Manifest diff utility
  download       Download and checkout a change
  grep           Print lines matching a pattern
  info           Get info on the manifest branch, current branch or unmerged branches
  init           Initialize repo in the current directory
  list           List projects and their associated directories
  overview       Display overview of unmerged project branches
  prune          Prune (delete) already merged topics
  rebase         Rebase local branches on upstream branch
  smartsync      Update working tree to the latest known good revision
  stage          Stage file(s) for commit
  start          Start a new branch for development
  status         Show the working tree status
  sync           Update working tree to the latest revision
  upload         Upload changes for code review
See 'repo help <command>' for more information on a specific command.
See 'repo help --all' for a complete list of recognized commands.
```


## 参考

- [本地/远程搭建repo](http://www.360doc.com/content/15/0122/22/426085_442956619.shtml)
- [简易repo服务器搭建](https://blog.csdn.net/eastmoon502136/article/details/72598297)
- [repo manifest文件格式说明](https://www.jianshu.com/p/d40444267e8d)
