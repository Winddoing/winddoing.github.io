---
layout: post
title: cmake
date: '2019-05-21 11:19'
tags:
  - makefile
categories:
  - 编译工具
abbrlink: 24934
---

`cmake`使用技巧记录

<!--more-->

## 显示编译详细信息

打印make进行编译过程中详细的gcc/g++参数信息。

```
make VERBOSE=1
```
> 在CMakeLists.txt中配置`set(CMAKE_VERBOSE_MAKEFILE ON)`


## debug调试

- 使用set命令，修改CMake文件

```
SET(CMAKE_CXX_FLAGS_DEBUG "$ENV{CXXFLAGS} -O0 -Wall -g")
```

- 使用环境变量

```
mkdir Debug
cd Debug
cmake -DCMAKE_BUILD_TYPE=Debug ..
```

## 生成编译命令文件 - compile_commands.json

```
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
```
或
```
cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
```
将在编译目录下生成`compile_commands.json`文件

## 添加版本及git信息

```
execute_process(
    COMMAND git rev-parse --short HEAD
    OUTPUT_VARIABLE COMMIT_HASH
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)
add_definitions( -DCOMMIT_HASH=\"${COMMIT_HASH}\")

execute_process(
    COMMAND git symbolic-ref --short -q HEAD
    OUTPUT_VARIABLE BRANCH_NAME
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)
add_definitions( -DBRANCH_NAME=\"${BRANCH_NAME}\")

# 当前编译时间
string(TIMESTAMP COMPILE_TIME %Y%m%d_%H%M%S)
```

## install命令

install用于指定在安装时运行的规则。它可以用来安装很多内容，可以包括目标二进制、动态库、静态库以及文件、目录、脚本等
```
install(TARGETS <target>... [...])
install({FILES | PROGRAMS} <file>... [...])
install(DIRECTORY <dir>... [...])
install(SCRIPT <file> [...])
install(CODE <code> [...])
install(EXPORT <export-name> [...])
```

## cpack打包

### 打包rpm

- 组件打包
  ```
  cpack_add_component
  ```
```
# 设置每个分组打包成一个 rpm 包
set(CPACK_COMPONENTS_GROUPING ONE_PER_GROUP)
# 设置支持 COMPONENT
set(CPACK_RPM_COMPONENT_INSTALL ON)

include(CPack)

# 添加一个名为 AComponent 的 component
cpack_add_component(AComponent
    DISPLAY_NAME  "A program"
    DESCRIPTION   "The program for test"
    GROUP Aprogram)
# 添加一个名为 BComponent 的 component
cpack_add_component(BComponent
    DISPLAY_NAME  "B program"
    DESCRIPTION   "The program for test"
    GROUP Bprogram)
# 添加一个名为 Aprogram 的 group, 这个名字会作为 rpm 包名字的一部分
cpack_add_component_group(Aprogram)
# 添加一个名为 Bprogram 的 group
cpack_add_component_group(Bprogram)

set(CPACK_RPM_Aprogram_PACKAGE_SUMMARY "Aprogram. Build: git-${BRANCH_NAME}-${COMMIT_HASH}")
set(CPACK_RPM_Bprogram_PACKAGE_SUMMARY "Bprogram. Build: git-${BRANCH_NAME}-${COMMIT_HASH}")

# 组件Bprogram安装之后执行的脚本
set(CPACK_RPM_Bprogram_POST_INSTALL_SCRIPT_FILE "${CMAKE_CURRENT_SOURCE_DIR}/script/postinst.sh")
```

### 安装前后的动作

```
# 设置安装前执行的脚本文件 preinst
set(CPACK_RPM_PRE_INSTALL_SCRIPT_FILE "${CMAKE_CURRENT_SOURCE_DIR}/scripts/preinst.sh")
# 设置卸载前执行的脚本文件 prerm
set(CPACK_RPM_PRE_UNINSTALL_SCRIPT_FILE "${CMAKE_CURRENT_SOURCE_DIR}/scripts/prerm.sh")
# 设置安装后执行的脚本文件 postinst
set(CPACK_RPM_POST_INSTALL_SCRIPT_FILE "${CMAKE_CURRENT_SOURCE_DIR}/scripts/postinst.sh")
# 设置卸载后执行的脚本文件 postrm
set(CPACK_RPM_POST_UNINSTALL_SCRIPT_FILE “${CMAKE_CURRENT_SOURCE_DIR}/scripts/postrm.sh")
```
> 如果执行脚本出现权限问题,不要使用chmod u+x来赋权限,最好使用chmod 0777

## rpm包的安装

```
rpm -ivh --nodeps --replacefiles test.rpm
```
> - `--nodeps`: 忽略依赖软件包
> - `--replacefiles`: 替换包或文件 用于替换原有包，覆盖安装
> - `--force`: 忽略冲突，强行安装
> - `--test`: 测试安装，但不真正执行安装，即dry run模式

## 常见问题

### 安装rpm包时出现filesystem-3.2-25.el7.x86_64冲突

```
file /home from install of example-1.0.0-1.x86_64 conflicts with file from package filesystem-3.2-25.el7.x86_64
```
- 原因：
  1. 打包时存在新建目录
  2. 打包时将home目录也打包其中

- 解决方法：
  1. 针对第一种，最好不要新建目录，如果是必须的在安装时强制安装
  2. 针对第二种，添加如下配置
  ```
  set(CPACK_RPM_EXCLUDE_FROM_AUTO_FILELIST_ADDITION "/home")
  list(APPEND CPACK_RPM_EXCLUDE_FROM_AUTO_FILELIST_ADDITION "/home/xxx")
  ```

## 参考

- [CPackRPM](https://www.w3cschool.cn/doc_cmake_3_8/cmake_3_8-module-cpackrpm.html)
- [cmake的使用-if-else的逻辑流程详解](https://blog.csdn.net/andrewgithub/article/details/108249065)
- [Cmake获取编译时间添加版本信息](https://blog.csdn.net/JCYAO_/article/details/115179015)
- [【CMake】cmake的install指令](https://blog.csdn.net/qq_38410730/article/details/102837401)
