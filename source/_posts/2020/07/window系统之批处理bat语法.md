---
layout: post
title: windows系统之批处理bat语法
date: '2020-07-27 14:54'
tags:
  - bat
  - windows
  - 批处理
  - 脚本
categories:
  - 工具
  - winodws
abbrlink: 29269ff3
---

windows下的批处理工具`bat`的基本语法和使用

<!--more-->
这里只是遇到的一些简单用法具体的详细可以通过`关键字`+`/?`查看详细的帮助文档。

```visual basic
set /? #注意在CMD中输入查看，powershel不知道为什么没有输出
```

内置命令：`help`

```visual basic
C:\>help
有关某个命令的详细信息，请键入 HELP 命令名
ASSOC          显示或修改文件扩展名关联。
ATTRIB         显示或更改文件属性。
BREAK          设置或清除扩展式 CTRL+C 检查。
BCDEDIT        设置启动数据库中的属性以控制启动加载。
CACLS          显示或修改文件的访问控制列表(ACL)。
CALL           从另一个批处理程序调用这一个。
CD             显示当前目录的名称或将其更改。
CHCP           显示或设置活动代码页数。
CHDIR          显示当前目录的名称或将其更改。
CHKDSK         检查磁盘并显示状态报告。
CHKNTFS        显示或修改启动时间磁盘检查。
CLS            清除屏幕。
CMD            打开另一个 Windows 命令解释程序窗口。
COLOR          设置默认控制台前景和背景颜色。
COMP           比较两个或两套文件的内容。
COMPACT        显示或更改 NTFS 分区上文件的压缩。
CONVERT        将 FAT 卷转换成 NTFS。你不能转换
               当前驱动器。
COPY           将至少一个文件复制到另一个位置。
DATE           显示或设置日期。
DEL            删除至少一个文件。
DIR            显示一个目录中的文件和子目录。
DISKPART       显示或配置磁盘分区属性。
DOSKEY         编辑命令行、撤回 Windows 命令并
               创建宏。
DRIVERQUERY    显示当前设备驱动程序状态和属性。
ECHO           显示消息，或将命令回显打开或关闭。
ENDLOCAL       结束批文件中环境更改的本地化。
ERASE          删除一个或多个文件。
EXIT           退出 CMD.EXE 程序(命令解释程序)。
FC             比较两个文件或两个文件集并显示
               它们之间的不同。
FIND           在一个或多个文件中搜索一个文本字符串。
FINDSTR        在多个文件中搜索字符串。
FOR            为一组文件中的每个文件运行一个指定的命令。
FORMAT         格式化磁盘，以便用于 Windows。
FSUTIL         显示或配置文件系统属性。
FTYPE          显示或修改在文件扩展名关联中使用的文件
               类型。
GOTO           将 Windows 命令解释程序定向到批处理程序
               中某个带标签的行。
GPRESULT       显示计算机或用户的组策略信息。
GRAFTABL       使 Windows 在图形模式下显示扩展
               字符集。
HELP           提供 Windows 命令的帮助信息。
ICACLS         显示、修改、备份或还原文件和
               目录的 ACL。
IF             在批处理程序中执行有条件的处理操作。
LABEL          创建、更改或删除磁盘的卷标。
MD             创建一个目录。
MKDIR          创建一个目录。
MKLINK         创建符号链接和硬链接
MODE           配置系统设备。
MORE           逐屏显示输出。
MOVE           将一个或多个文件从一个目录移动到另一个
               目录。
OPENFILES      显示远程用户为了文件共享而打开的文件。
PATH           为可执行文件显示或设置搜索路径。
PAUSE          暂停批处理文件的处理并显示消息。
POPD           还原通过 PUSHD 保存的当前目录的上一个
               值。
PRINT          打印一个文本文件。
PROMPT         更改 Windows 命令提示。
PUSHD          保存当前目录，然后对其进行更改。
RD             删除目录。
RECOVER        从损坏的或有缺陷的磁盘中恢复可读信息。
REM            记录批处理文件或 CONFIG.SYS 中的注释(批注)。
REN            重命名文件。
RENAME         重命名文件。
REPLACE        替换文件。
RMDIR          删除目录。
ROBOCOPY       复制文件和目录树的高级实用工具
SET            显示、设置或删除 Windows 环境变量。
SETLOCAL       开始本地化批处理文件中的环境更改。
SC             显示或配置服务(后台进程)。
SCHTASKS       安排在一台计算机上运行命令和程序。
SHIFT          调整批处理文件中可替换参数的位置。
SHUTDOWN       允许通过本地或远程方式正确关闭计算机。
SORT           对输入排序。
START          启动单独的窗口以运行指定的程序或命令。
SUBST          将路径与驱动器号关联。
SYSTEMINFO     显示计算机的特定属性和配置。
TASKLIST       显示包括服务在内的所有当前运行的任务。
TASKKILL       中止或停止正在运行的进程或应用程序。
TIME           显示或设置系统时间。
TITLE          设置 CMD.EXE 会话的窗口标题。
TREE           以图形方式显示驱动程序或路径的目录
               结构。
TYPE           显示文本文件的内容。
VER            显示 Windows 的版本。
VERIFY         告诉 Windows 是否进行验证，以确保文件
               正确写入磁盘。
VOL            显示磁盘卷标和序列号。
XCOPY          复制文件和目录树。
WMIC           在交互式命令 shell 中显示 WMI 信息。

有关工具的详细信息，请参阅联机帮助中的命令行参考。
```

## bat脚本

在windows下bat脚本的文件名后缀一般为`bat`或`cmd`

## bat语法

### 文件操作

| 命令           | 描述                                        | 对应linux命令 |
| -------------- | ------------------------------------------- | :-----------: |
| `cd`           | 显示当前目录名或改变当前目录                |     `cd`      |
| `dir`          | 显示目录中的文件和子目录列表                |     `ls`      |
| `mkdir`/`md`   | 创建目录                                    |    `mkdir`    |
| `pushd`        | 保存当前目录，并切换目录，如`pushd c:\work` |    `pushd`    |
| `popd`         | 恢复当前目录为刚才保存的，如`popd`          |    `popd`     |
| `del`          | 删除一个或多个文件,`del xxx /f`             |     `rm`      |
| `rd`           | 删除目录， `rd /s /q build`                 |               |
| `mklink`       | 创建符号链接                                |     `ln`      |
| `rename`/`ren` | 重命名文件                                  |     `mv`      |
| `copy`         | 将一份或多份文件复制到另一个位置            |     `cp`      |
| `type`         | 显示文本文件的内容                          |     `cat`     |

### 常用操作

| 命令    | 描述                                                 |
| ------- | ---------------------------------------------------- |
| `cls`   | 清除屏幕                                             |
| `pause` | 暂停批处理文件的处理并显示消息:`请按任意键继续. . .` |
|         |                                                      |



### 内置变量

`%var%`：变量的引用，通过两个%号即可引用该变量的值使用

- 自定义变量，多用于脚本
- 系统内置变量

| 系统内置变量名           | 变量值                    |
| ------------------------ | ------------------------- |
| %SYSTEMROOT%             | `C:\Windows`              |
| %ERRORLEVEL%             | 程序返回码，正确返回0     |
| %PROCESSOR_ARCHITECTURE% | 判断系统位数，比如`AMD64` |
| %cd%                     | 当前路径，比如`C:\Users`  |
| %~dp0                    | 当前路径，比如`C:\Users\` |
| NUL                      | 相当于，linux中的dev/null |

### 特殊符号

| 符号 | 描述     |
| ---- | -------- |
| `@`  | 回显屏蔽 |
| `^`  | 转义符   |
|      |          |



### 注释与打印

#### rem 和 ::

- `rem`: 注释命令，一般用来给程序加上注解，该命令后的内容不被执行，但能回显
- ` ::` 也可以起到rem 的注释作用, 而且更简洁有效，其后的字符行在执行时不会回显, 无论是否用echo on打开命令行回显状态, 因为命令解释器不认为他是一个有效的命令行



#### echo 和 @

`@`字符放在命令前将关闭该命令回显，无论此时echo是否为打开状态

### 变量设置—set

设置环境变量

```bat
set var=abcdefg
#or
set "var=abcdefg"
```

参数：

>  SET /A expression
>  SET /P variable=[promptString]

- `/a` ：可以用各种表达式为变量赋值

  ```visual basic
   set /a var=1+1 #var=2
  ```

- `/p` ：可以在用户输入前加一段说明性的描述，即想让用户输入什么内容之类的说明

  ```
  set /p var=请输入变量的值：
  ```

#### 清空变量名

```bat
set VARNAME=
#or
set "VARNAME="
```





### 数值检查运算符

| 比较运算符 | 描述       |
| ---------- | ---------- |
| EQU        | 等于       |
| NEQ        | 不等于     |
| LSS        | 小于       |
| LEQ        | 小于或等于 |
| GTR        | 大于       |
| GEQ        | 大于或等于 |


### 流程控制

#### if

> IF [NOT] ERRORLEVEL number command
> IF [NOT] string1==string2 command
> IF [NOT] EXIST filename command
>
>   NOT               指定只有条件为 false 的情况下，Windows 才
>                     应该执行该命令。
>
>   ERRORLEVEL number 如果最后运行的程序返回一个等于或大于
>                     指定数字的退出代码，指定条件为 true。
>
>   string1==string2  如果指定的文字字符串匹配，指定条件为 true。
>
>   EXIST filename    如果指定的文件名存在，指定条件为 true。
>
>   command           如果符合条件，指定要执行的命令。如果指定的
>                     条件为 FALSE，命令后可跟 ELSE 命令，该命令将
>                     在 ELSE 关键字之后执行该命令。

- `/I` : 如果指定说明要进行的字符串比较不分大小写,

  ```visual basic
   @IF /I NOT "%swr%"=="y" GOTO opengles
  ```


#### goto 和 :

跳转到指定的标号处。

在批处理中允许以`:xxx`来构建一个标号，然后用`goto xxx`跳转到标号`:xxx`处，然后执行标号后的命令。

```visual basic
@echo off
:start
set /a var+=1
echo %var%
    if %var% leq 3 goto start
pause
```



### CMD窗口名

设置cmd窗口的标题

```visual basic
title 新标题     #可以看到cmd窗口的标题栏变了
```



### setlocal 与 endlocal 命令

>开始与终止批处理文件中环境改动的本地化操作。在执行 Setlocal 之后所做的环境改动只限于批处理文件。要还原原先的设置，必须执行 Endlocal。达到批处理文件结尾时，对于该批处理文件的每个尚未执行的 Setlocal 命令，都会有一个隐含的 Endlocal 被执行。Endlocal结束批处理文件中环境改动的本地化操作。在执行Endlocal 之后所做的环境改动不再仅限于批处理文件。批处理文件结束后，原先的设置无法还原。

```bat
>setlocal /?
开始批处理文件中环境改动的本地化操作。在执行 SETLOCAL 之后
所做的环境改动只限于批处理文件。要还原原先的设置，必须执
行 ENDLOCAL。达到批处理文件结尾时，对于该批处理文件的每个
尚未执行的 SETLOCAL 命令，都会有一个隐含的 ENDLOCAL 被执行。

SETLOCAL

如果启用命令扩展，则 SETLOCAL 更改如下:

SETLOCAL 批命令现在可以接受可选参数:
        ENABLEEXTENSIONS / DISABLEEXTENSIONS
            启用或禁用命令处理器扩展。这些
            参数比 CMD /E:ON 或 /E:OFF
            开关有优先权。请参阅 CMD /? 获取详细信息。
        ENABLEDELAYEDEXPANSION / DISABLEDELAYEDEXPANSION
            启用或禁用延缓环境变量
            扩展。这些参数比 CMD
            /V:ON 或 /V:OFF 开关有优先权。请参阅 CMD /? 获取详细信息。
无论在 SETLOCAL 命令之前的设置是什么，这些修改会一直
生效，直到出现相应的 ENDLOCAL 命令。

在给定参数的情况下，
SETLOCAL 命令将设置 ERRORLEVEL 值。如果给定两个有效参数中的一个，另一个未给定，
则该值为零。
通过以下方法，你可以在批脚本中
使用此项来确定扩展是否可用:

    VERIFY OTHER 2>nul
```




## 示例

### 获取管理员权限

```bat
@echo off
@cd /d "%~dp0"
@set "ERRORLEVEL="
@CMD /C EXIT 0
@"%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system" >nul 2>&1
@if NOT "%ERRORLEVEL%"=="0" (
@powershell -Command Start-Process ""%0"" -Verb runAs 2>nul
@exit
)
```





## 参考

- [bat脚本的基本命令语法](https://www.cnblogs.com/lizm166/p/11132601.html)
- [批处理命令——set](https://www.cnblogs.com/Braveliu/p/5081084.html)
- [Windows脚本 - %~dp0的含义](https://www.cnblogs.com/smwikipedia/archive/2009/03/30/1424749.html)
