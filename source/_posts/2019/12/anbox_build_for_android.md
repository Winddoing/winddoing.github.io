---
layout: post
title: anbox_build_for_android
date: '2019-12-11 16:36'
tags:
  - anbox
  - Android
categories:
  - 系统应用
---

Anbox 是 “Android in a box” 的缩写。Anbox 是一个基于`容器`的方法，可以在普通的GNU/Linux系统上启动完整的Android系统。

> https://github.com/anbox/anbox/blob/master/docs/build-android.md


<!--more-->

## Anbox


### Error

ubuntu18.04 for ARM64
```
error: ISO C forbids conversion of object pointer to function pointer type [-Werror=pedantic]
   func = (getauxval_func_t*)dlsym(libc_handle, "getauxval");
             ^
cc1: all warnings being treated as errors
```

> https://stackoverflow.com/questions/31526876/casting-when-using-dlsym

```
-set(C_AND_CXX_WARNINGS "-pedantic -Wall -Wextra")
+set(C_AND_CXX_WARNINGS "-Wextra")
```
删除掉`-Wall`和`-pedantic`这两个编译选项，可以正常编译

- `-Wall`：
- `-pedantic`:


## Android-for-anbox

### Download

```
curl https://mirrors.tuna.tsinghua.edu.cn/git/git-repo -o repo
chmod +x repo
export REPO_URL='https://mirrors.tuna.tsinghua.edu.cn/git/git-repo/'
```

```
repo init -u https://github.com/anbox/platform_manifests.git -b anbox --depth=1
repo sync -j4
while [ $? -ne 0 ]
do
    repo sync -j4
done
```
> 全部代码下载完成后总大小：144G， .repo的大小：125G

在进行repo sync之前使用清华的源替代谷歌源：

```
<remote  name="aosp"
         revision="refs/tags/android-7.1.1_r13"
-           fetch="https://android.googlesource.com/" />
+           fetch="https://aosp.tuna.tsinghua.edu.cn/" />

<default revision="refs/tags/android-7.1.1_r13"
         remote="aosp"
```
> From: .repo/manifests/default.xml

### Build

```
sudo apt install openjdk-8-jdk
```

```
export LC_ALL=C
source build/envsetup.sh
lunch anbox_x86_64-userdebug
make -j3
```


### Error


#### aidl_language_l

```
ninja: Entering directory `.'
[  0% 33/48163] Lex: aidl <= system/tools/aidl/aidl_language_l.ll
FAILED: /bin/bash -c "prebuilts/misc/linux-x86/flex/flex-2.5.39 -oout/host/linux-x86/obj/STATIC_LIBRARIES/libaidl-common_intermediates/aidl_language_l.cpp system/tools/aidl/aidl_language_l.ll"
flex-2.5.39: loadlocale.c:130:_nl_intern_locale_data: ?? 'cnt < (sizeof (_nl_value_type_LC_TIME) / sizeof (_nl_value_type_LC_TIME[0]))' ???
Aborted (core dumped)
[  0% 33/48163] JarJar: out/target/common/obj/JAVA_LIBRARIES/bouncycastle_intermediates/classes-jarjar.jar
ninja: build stopped: subcommand failed.
build/core/ninja.mk:148: recipe for target 'ninja_wrapper' failed
make: *** [ninja_wrapper] Error 1
```

解决方法：

```
export LC_ALL=C
```


#### VM

```
[ 30% 14248/46548] Building with Jack: out/target/common/obj/JAVA_LIBRARIES/framework_intermediates/with-local/classes.dex
FAILED: /bin/bash out/target/common/obj/JAVA_LIBRARIES/framework_intermediates/with-local/classes.dex.rsp
Out of memory error (version 1.2-rc4 'Carnac' (298900 f95d7bdecfceb327f9d201a1348397ed8a843843 by android-jack-team@google.com)).
GC overhead limit exceeded.
Try increasing heap size with java option '-Xmx<size>'.
Warning: This may have produced partial or corrupted output.
[ 30% 14248/46548] host C++: libartd <= art/runtime/native/java_lang_ref_FinalizerReference.cc
ninja: build stopped: subcommand failed.
build/core/ninja.mk:148: recipe for target 'ninja_wrapper' failed
make: *** [ninja_wrapper] Error 1>
```

错误日志里边列出了问题并且已经给出了解决方案 - 增加Java虚拟机的`-Xmx<size>`，即设置一个较大的堆内存上限


- 修改Jack的配置文件prebuilts/sdk/tools/jack-admin

```
JACK_SERVER_COMMAND="java -XX:MaxJavaStackTraceDepth=-1 -Djava.io.tmpdir=$TMPDIR $JACK_SERVER_VM_ARGUMENTS -cp $LAUNCHER_JAR $LAUNCHER_NAME"
```
修改内存：`-Xmx4096m`

```
JACK_SERVER_COMMAND="java -XX:MaxJavaStackTraceDepth=-1 -Djava.io.tmpdir=$TMPDIR $JACK_SERVER_VM_ARGUMENTS -Xmx4096m -cp $LAUNCHER_JAR $LAUNCHER_NAME"
```

- 重启jack-admin服务

```
./prebuilts/sdk/tools/jack-admin stop-server
./prebuilts/sdk/tools/jack-admin start-server
```

## anbox-modules

```
git clone https://github.com/anbox/anbox-modules.git
```

在anbox-modules安装完成后，需要对系统进行reboot，否则无法生成`/dev/binder`节点


## Boot


```
[Unit]
Description=Anbox Container Manager
After=network.target
Wants=network.target
ConditionPathExists=/home/wqshao/work1/android-for-anbox/anbox/android.img

[Service]
ExecStartPre=/sbin/modprobe ashmem_linux
ExecStartPre=/sbin/modprobe binder_linux
ExecStart=/usr/local/bin/anbox container-manager --daemon --privileged --data-path=/home/wqshao/work1/android-for-anbox/anbox-data/ --android-image=/home/wqshao/work1/android-for-anbox/anbox/android.img --use-rootfs-overlay

[Install]
WantedBy=multi-user.target
```
>/lib/systemd/system/anbox-container-manager.service

```
sudo systemctl start anbox-container-manager
```

```
anbox launch --package=org.anbox.appmgr --component=org.anbox.appmgr.AppViewActivity
```

```
systemctl | grep "anbox"

anbox system-info
```

## Net

```
nmcli con add type bridge ifname anbox0 -- connection.id anbox-net ipv4.method shared ipv4.addresses 192.168.250.1/24
```

## 参考

- [解决Out of memory error (version 1.2-rc4 'Carnac' (298900 ... by android-jack-team@google.com)).](https://blog.csdn.net/liangtianmeng/article/details/89522092)
- [Linux Gaming: Anbox - Android In A Box](https://magazine.odroid.com/article/linux-gaming-anbox-android-in-a-box/)
