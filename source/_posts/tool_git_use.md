---
title: Git操作
categories:
  - 工具
tags:
  - git
abbrlink: 53101
date: 2016-10-07 23:07:24
---

记录平时对git的使用方法和技巧

<!--- more --->

## 创建本地git库
```
mkdir test.git
```
进入test.git
```
git init --bare --shared
```

> Window下进行跨平台的clone操作，下载链接前需要添加`ssh`
> ```
> git remote add origin ssh://hostname@192.168.1.1:/test.git
> ```
> Linux:
> ```
> git remote add origin hostname@192.168.1.1:/test.git
> ```

## 创建分支
```
git branch branch_name
```
删除本地分支：
```
git branch -d branch_name
```

## 切换分支
```
git checkout  branch_name
```

## 下载
```
git clone  URL
```
下载较大工程：
```
git clone --depth=1 URL
```
> depth用于指定克隆深度，为1即表示只克隆最近一次commit.

## 创建本地镜像仓库
```
git clone --mirror <URL>
```
- 更新镜像库
```
git remote update
```

## 日志
```
git commit
```

### 日志规范

```
<type>(<scope>): <subject>
// 空一行
<body>
// 空一行
<footer>
```

#### type

- `feat`：新功能（feature）
- `fix`：修补bug
- `docs`：文档（documentation）
- `style`： 格式（不影响代码运行的变动）
- `refactor`：重构（即不是新增功能，也不是修改bug的代码变动）
- `test`：增加测试
- `chore`：构建过程或辅助工具的变动

#### scope

`scope`用于说明 commit 影响的范围，比如数据层、控制层、视图层等等，视项目不同而不同。

#### subject

subject是 commit 目的的简短描述，不超过50个字符。填写要求：以动词开头

## 提交
```
git push 远程库名  分支名
```

## 更新
```
git pull 远程库名  分支名
```

## 添加代码
```
git add <filename>
git add -A    #添加所有修改
```

## 查看日志
```
git log
git log -n     #查看前n条日志
git log --stat  #查看日志的修改情况
git log -p       #查看日志的具体修改
git log <filename/dirname>  #查看该文件或目录的修改日志
git log -S [keyword]  #在提交log中搜索关键词
```

### tig

> 命令行下查看git历史提交记录的工具

## 回退
```
git reset HEAD <filename> #将该文件从缓冲区撤回
```
## 查看远程库
```
git remote -v
```
添加远程库：
```
git remote add <name> <url>
```

## 获取远程库中的最新版本，但与git pull 不同它不会merge
```
git  fetch  远程库名  分支名
```
作用：可以对比远程库与当前本地的差异。

## 查看标签
```
git tag
```
作用：一个稳定的版本或者完成一个功能，为了发布或者保存而打的标签，主要是发布

## 切换标签
```
git checkout <Tag>
```

## 暂存当前改动

```
git stash
```
>保存当前工作进度，会把暂存区和工作区的改动保存起来。执行完这个命令后，在运行git status命令，就会发现当前是一个干净的工作区，没有任何改动。使用git stash save 'message...'可以添加一些注释

```
git stash list
```
>显示保存进度的列表。也就意味着，git stash命令可以多次执行。

```
git stash pop [–index] [stash_id]
```
>git stash pop 恢复最新的进度到工作区。git默认会把工作区和暂存区的改动都恢复到工作区。

```
git stash apply [–index] [stash_id]
```
>除了不删除恢复的进度之外，其余和git stash pop 命令一样。

```
git stash drop [stash_id]
```
> 删除一个存储的进度。如果不指定stash_id，则默认删除最新的存储进度。

```
git stash clear
```
>删除所有存储的进度。

## 恢复本地错误操作

```
git reflog
```
> 查看所有分支的所有操作记录（包括已经被删除的 commit 记录和 reset 的操作）

```
$git reflog -h
usage: git reflog [ show | expire | delete ]
```
> - `show`: 显示所有条目,缺省值
> - `expire`: 删除掉更老的reflog条目
> - `delete`: 从reflog中删除一个条目

## 模块管理

1. 添加模块
```
git submodule add projectB.git projectB
```

2. 使用子模块
```
git submodule init
git submodule update
```
> 克隆项目后，默认子模块目录下无任何内容。需要在项目根目录执行此命令完成子模块的下载
>
> **在clone整个项目时添加递归参数:`--recurse-submodules`**

3. 删除子模块

    1. `rm -rf 子模块目录` 删除子模块目录及源码
    2. `vi .gitmodules` 删除项目目录下.gitmodules文件中子模块相关条目
    3. `vi .git/config` 删除配置项中子模块相关条目
    4. `rm .git/module/*` 删除模块下的子模块目录，每个子模块对应一个目录，注意只删除对应的子模块目录即可

执行完成后，再执行添加子模块命令即可，如果仍然报错，执行如下：
```
git rm --cached 子模块名称
```

## commit统计

可以大致了解一下每个人对这个项目提交的commit数量和大致的贡献度

``` shell
git summary
```

## git获取最近一次提交的commit-id

- 获取完整commit id
```
git rev-parse HEAD
```

- 获取short commit id
```
git rev-parse --short HEAD
```

## .git无法忽略target,或者不生效的情况

`.gitignore`未生效，原因是.gitignore只能忽略那些原来没有被track的文件，如果某些文件已经被纳入了版本管理中，则修改.gitignore是无效的。那么解决方法就是先把本地缓存删除（改变成未track状态），然后再提交

```
git rm -r --cached .
git add .
git commit -m 'update .gitignore'
```

## 强制更新代码

```
git push origin master --force
```
- 错误：
```
remote: error: denying non-fast-forward refs/heads/master (you should pull first)
```
> 该消息表示您不允许进行非快进推送, 远程存储库很可能在其配置中`denyNonFastforwards = true`, 要更改设置，请执行`git config receive.denynonfastforwards false`

## 从git中打包代码

- 打包某一个分支
```
git archive --format=tar.gz --output "output.tar.gz" master
```
- 打包某一个commit
```
git archive --format=tar.gz --output "output.tar.gz" ac1c53d
```
- 打包某些目录
```
git archive --format=tar.gz --output "output.tar.gz" master dir1 dir2
```
## 合并代码

- 合并指定分支到当前分支
```
git merge [branch_name]
```

- 选择一个commit，合并到当前分支
```
git cherry-pick [branch_name]
```
## 查看信息

- 查看指定文件什么人在什么时间修改过
```
git blame [filename]
```

## git服务器

```
git daemon --export-all --verbose --base-path=.
```
- `--export-all`: “--base-path”下所有的repo仓库
- `--base-path=.`: 定义为当前目录
- `--verbose`: 任何操作都会给当前repo通知

## svn仓库迁移至git

- svn的日志提交者与git相关用户进行绑定
```
svn log -q | awk -F '|' '/^r/ {sub("^ ", "", $2); sub(" $", "", $2); print $2" = "$2" <"$2">"}' | sort -u > users.txt
```
> `users.txt`的意义仅在于，将svn里面的提交者日志，注意是提交者，不是svn里面所有的用户信息都得关联

```
aaa = git-aaa <aaa@xx.com> #用户名 邮件地址
bbb = git-bbb <bbb@xx.com>
```

- 使用`git-svn`进行下载并提交

```
sudo apt install git-svn
```

```
git svn clone <SVN_URL> --no-metadata --trunk="svnproject" --tags="tags" --branches="svnbranches" --authors-file=users.txt --preserve-empty-dirs project-dir
```

- `--no-metadata`: 阻止git导出SVN包含的一些无用信息
- `--trunk="svnproject"`: 指定导出仓库的主干项目路径，默认trunk
- `--tags="tags"`: 日志标记
- `--branches="svnbranches"`: 指定svn的分支项目路径
- `--authors-file=users.txt`: 指定svn帐号在git中的映射
- `--preserve-empty-dirs`: 保留原SVN项目中的空目录

```
git remote add origin <GIT-URL>
```

```
git push origin master #--all
```

## 修改已提交的用户名和邮箱

``` shell
git filter-branch --commit-filter '
if [ "$GIT_AUTHOR_EMAIL" = "old_email@email.com" ];
then
    GIT_AUTHOR_NAME="new_name";
    GIT_AUTHOR_EMAIL="new_email@email.com";
    git commit-tree "$@";
else
    git commit-tree "$@";
    fi' HEAD
```
>**注**:可以修改但是在github中还是可以看到之前的用户名,效果不太好

- [7.6 Git 工具 - 重写历史](https://git-scm.com/book/zh/v2/Git-%E5%B7%A5%E5%85%B7-%E9%87%8D%E5%86%99%E5%8E%86%E5%8F%B2)

## 命令行工具——tig

- commit操作： `上/下键`可以选择log中的commit
- 查看修改信息： `j/k`
- 展示commit-id： `shift+x`

## 删除已删除文件或目录的所以历史记录

- 删除文件
``` shell
git filter-branch --force --index-filter 'git rm --cached --ignore-unmatch pom.xml' --prune-empty --tag-name-filter cat -- --all
```

- 删除目录
``` shell
git filter-branch --force --index-filter 'git rm --cached -r --ignore-unmatch qemu/qemu-4.2.0/' --prune-empty --tag-name-filter cat -- --all
```

- 删除回收
```
rm -rf .git/refs/original/
git reflog expire --expire=now --all
git gc --prune=now
git gc --aggressive --prune=now
```

## rebase方式合并分支，分支在一条线

1. checkout到需要合并的分支feature
``` shell
git checkout feature
```
2. 在feature分支上合并master分支的修改，生成一个新的分支版本
``` shell
git rebase master
```
3. 如果存在冲突解决冲突
``` shell
git mergetool
git rebase —continue
```
4. checkout到master分支
``` shell
git checkout master
```
5. 合并新的feature分支到master分支
``` shell
git merge feature
```
6. 合并完毕，可以删除feature分支
``` shell
git branch --delete feature
```
7. 提交更新
``` shell
git push origin master --force
```

## 删除已提交的commit

``` shell
git rebase -i [commit-id]
```
> commit-id: 为要删除的commit的下一个commit号

示例：
``` shell
pick 1821834 add gnuplot test
pick 5522ce1 add gnuplot test shell

# Rebase e6fcac3..5522ce1 onto e6fcac3 (2 commands)
#
# Commands:
# p, pick <commit> = use commit
# r, reword <commit> = use commit, but edit the commit message
# e, edit <commit> = use commit, but stop for amending
# s, squash <commit> = use commit, but meld into previous commit
# f, fixup <commit> = like "squash", but discard this commit's log message
# x, exec <command> = run command (the rest of the line) using shell
# b, break = stop here (continue rebase later with 'git rebase --continue')
# d, drop <commit> = remove commit
# l, label <label> = label current HEAD with a name
# t, reset <label> = reset HEAD to a label
# m, merge [-C <commit> | -c <commit>] <label> [# <oneline>]
# .       create a merge commit using the original merge commit's
# .       message (or the oneline, if no original merge commit was
# .       specified). Use -c <commit> to reword the commit message.
#
# These lines can be re-ordered; they are executed from top to bottom.
#
# If you remove a line here THAT COMMIT WILL BE LOST.
#
# However, if you remove everything, the rebase will be aborted.
#
# Note that empty commits are commented out
```
> 将需要删除的commit前面的`pick`改写为`drop`后，保存退出

- 退出后，可能存在冲突通过`git mergetool`解决掉冲突后，使用`git rebase —continue`继续直到解决完所有冲突提示rebase成功，删除完成。
- 如果中途不想删除后，可以通过`git rebase --abort`终止删除动作

## 仓库地址为http时,用户名密码保存

``` shell
git config --global credential.helper store
```
> 需要在第一次使用该仓库时,输入用户名密码后,会以配置文件(.git-credentials)保存到本地,后期使用不再需要输入用户名密码

删除保存的用户名密码配置文件:`rm ~/.git-credentials`

## 当前仓库信息

``` shell
remote=$(git remote -v | grep fetch | awk '{print $2}')
branch=$(git symbolic-ref --short -q HEAD)
tag=$(git log -1 --decorate=short --oneline|grep -Eo 'tag: (.*)[,)]+'|awk '{print $2}'|sed 's/)//g'|sed 's/,//g')
commit=$(git rev-parse --short HEAD)
mesg=$(git log -1 --pretty=format:%B)

echo "$lib info: branch=$branch, tag=$tag, commit=$commit, mesg=$mesg"
```

## git show/diff tab显示宽度

设置Tab显示为4个字符的宽度
```
git config --global core.pager 'less -x1,5'
```

设置Tab显示为8个字符的宽度（默认）
```
git config --global core.pager 'less'
```

## 错误处理

### git clone

```
fatal: The remote end hung up unexpectedly
fatal: early EOF
fatal: index-pack failed
```

```
git config --add core.compression -1
```
> compression 是压缩的意思，从clone的终端输出就知道，服务器会压缩目标文件，然后传输到客户端，客户端再解压。取值为 [-1, 9]，-1 以 zlib 为默认压缩库，0 表示不进行压缩，1..9 是压缩速度与最终获得文件大小的不同程度的权衡，数字越大，压缩越慢，当然得到的文件会越小。



## DoTo

1. [Git 最佳实践：分支管理](http://blog.jobbole.com/109466/)
2. [git-config(1) Manual Page](https://mirrors.edge.kernel.org/pub/software/scm/git/docs/git-config.html)
