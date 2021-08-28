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

## 常见常量

### PROJECT_SOURCE_DIR与CMAKE_SOURCE_DIR

- 这两个变量所指的路径是一样的，编译时的顶层路径
- CMAKE_SOURCE_DIR确实引用了定义顶级CMakeLists.txt的文件夹。 但是，PROJECT_SOURCE_DIR引用包含最新`project()`命令的CMakeLists.txt文件夹。
- CMAKE_SOURCE_DIR: 真对于“主”目录
- PROJECT_SOURCE_DIR： 针对于“子”目录
- [Are CMAKE_SOURCE_DIR and PROJECT_SOURCE_DIR the same in CMake?](https://stackoverflow.com/questions/32028667/are-cmake-source-dir-and-project-source-dir-the-same-in-cmake#:~:text=CMAKE_SOURCE_DIR%20does%20indeed%20refer%20to%20the%20folder%20where,a%20subdirectory%20with%20its%20own%20project%20called%20Inner.)

### PROJECT_BINARY_DIR与PROJECT_SOURCE_DIR

- 这两个变量所指路径也是一样的，都表示编译时生成的结果和中间文件存放位置
- 与上面类似

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

## 引入外部项目

### 子模块

```
add_subdirectory(xxx)
```

### 编译时下载项目并引入

```
include(ExternalProject)

set(SPDLOG_ROOT ${CMAKE_BINARY_DIR}/thirdparty/SPDLOG)
set(SPDLOG_GIT_TAG  v1.4.1)  # 指定版本
set(SPDLOG_GIT_URL      https://github.com/gabime/spdlog.git)  # 指定git仓库地址
set(SPDLOG_CONFIGURE    cd ${SPDLOG_ROOT}/src/SPDLOG && cmake -D CMAKE_INSTALL_PREFIX=${SPDLOG_ROOT} .)  # 指定配置指令（注意此处修改了安装目录，否则默认情况下回安装到系统目录）
set(SPDLOG_MAKE         cd ${SPDLOG_ROOT}/src/SPDLOG && make)  # 指定编译指令（需要覆盖默认指令，进入我们指定的SPDLOG_ROOT目录下）
set(SPDLOG_INSTALL      cd ${SPDLOG_ROOT}/src/SPDLOG && make install)  # 指定安装指令（需要覆盖默认指令，进入我们指定的SPDLOG_ROOT目录下）

ExternalProject_Add(SPDLOG
        PREFIX            ${SPDLOG_ROOT}
        GIT_REPOSITORY    ${SPDLOG_GIT_URL}
        GIT_TAG           ${SPDLOG_GIT_TAG}
        CONFIGURE_COMMAND ${SPDLOG_CONFIGURE}
        BUILD_COMMAND     ${SPDLOG_MAKE}
        INSTALL_COMMAND   ${SPDLOG_INSTALL}
)

# 指定编译好的静态库文件的路径
set(SPDLOG_LIB       ${SPDLOG_ROOT}/lib/spdlog/libspdlog.a)
# 指定头文件所在的目录
set(SPDLOG_INCLUDE_DIR   ${SPDLOG_ROOT}/include)
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

### 取消yum自动依赖关系

```
set(CPACK_RPM_PACKAGE_AUTOREQPROV " no")
```
> 在`no`前面（或后面）需要**添加空格**才能使其工作。 cpack的RPM模块似乎有一个错误，这使得它不会让您将某些变量设置为短于3个字符的任何长度。

参考：https://stackoverflow.com/questions/14658034/how-do-you-make-it-so-that-cpack-doesnt-add-required-libraries-to-an-rpm

手动设置必要软件依赖：

```
set(CPACK_RPM_PACKAGE_REQUIRES "python >= 2.5.0, cmake >= 2.8")
```

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
  list(APPEND CPACK_RPM_EXCLUDE_FROM_AUTO_FILELIST_ADDITION "/usr/local")         
  list(APPEND CPACK_RPM_EXCLUDE_FROM_AUTO_FILELIST_ADDITION "/usr/local/lib")     
  list(APPEND CPACK_RPM_EXCLUDE_FROM_AUTO_FILELIST_ADDITION "/usr/local/bin")     
  list(APPEND CPACK_RPM_EXCLUDE_FROM_AUTO_FILELIST_ADDITION "/usr/lib/systemd")   
  list(APPEND CPACK_RPM_EXCLUDE_FROM_AUTO_FILELIST_ADDITION "/usr/lib/systemd/system")
  list(APPEND CPACK_RPM_EXCLUDE_FROM_AUTO_FILELIST_ADDITION "/etc/ld.so.conf.d")
  list(APPEND CPACK_RPM_EXCLUDE_FROM_AUTO_FILELIST_ADDITION "/home/xxx")
  ```

## 参考

- [CPackRPM](https://www.w3cschool.cn/doc_cmake_3_8/cmake_3_8-module-cpackrpm.html)
- [cmake的使用-if-else的逻辑流程详解](https://blog.csdn.net/andrewgithub/article/details/108249065)
- [Cmake获取编译时间添加版本信息](https://blog.csdn.net/JCYAO_/article/details/115179015)
- [【CMake】cmake的install指令](https://blog.csdn.net/qq_38410730/article/details/102837401)
- [CMake 基本常用语法 CMakeLists.txt](https://blog.csdn.net/q345911572/article/details/105250633)
- [CMake之引入外部项目的三种方法](https://zhuanlan.zhihu.com/p/102050750)
