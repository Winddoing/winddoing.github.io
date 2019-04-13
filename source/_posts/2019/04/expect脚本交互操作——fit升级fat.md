---
layout: post
title: expect脚本交互操作——FIT升级FAT
date: '2019-04-13 14:12'
tags:
  - expect
  - AP
categories:
  - 工具
---

## 需求
> 脚本自动控制通过SSH自动登录到路由器，并执行相关命令进行自动升级

** shell脚本无法完成这种交互，最终选择`expect`脚本进行操作**

<!--more-->


## expect

expect用于自动化地执行linux环境下的命令行交互任务，例如`scp`、`ssh`之类需要用户手动输入密码然后确认的任务

### 安装

```
sudo apt-get install expect
```
> 操作系统：ubuntu18.04

### 基础语法

expect的实现核心是`spawn` `expect` `send` `set`

|   关键字   | 作用                                                                                                                         |
|:----------:|:-----------------------------------------------------------------------------------------------------------------------------|
|   spawn    | 调用要执行的命令                                                                                                             |
|   expect   | 等待命令提示信息的出现，也就是捕获用户输入提示                                                                               |
|    send    | 发送要交互的值，替代用户手动输入内容                                                                                         |
|    set     | 设置变量值                                                                                                                   |
|  interact  | 执行完成后保持交互状态，把控制权交给控制台，这个时候就可以手工操作了。如果没有这一句登录完成后会退出，而不是留在远程终端上。 |
| expect eof | 这个一定要加，与spawn对应表示捕获终端输出信息终止，类似于if....endif                                                         |

expect脚本必须以`interact`或`expect eof`结束，执行自动化任务通常`expect eof`就可以

**脚本第一行必须是`#!/usr/bin/expect`，第一行注释也不行，否则执行报错**

``` shell
#!/usr/bin/expect
set timeout 5  //设置超时时间5秒
set server [lindex $argv 0]  //传入的第一个参数
set user [lindex $argv 1]
set passwd [lindex $argv 2]

spawn ssh -l $user $server   //执行ssh命令

//如果匹配到了yes/no就发送yes，接着在匹配password，发送密码
expect {
"*yes/no" { send "yes\r"; exp_continue}
"*password:" { send "$passwd\r" }
}

expect *Last login*

//执行完成后保持交互状态，把控制权交给控制台，就可以手工操作
interact
```

## 示例--FIT升级FAT

**还不能完全自动执行,中间确定reboot操作无法自动执行**

### shell脚本

``` shell
#!/bin/bash

netstat=$(ping -c1 169.254.1.1 |grep transmitted |awk '{print $4}')
if [ "$netstat" -eq "0" ]; then
    echo "      ***********************************"
    echo "      * Network connection disconnected *"
    echo "      ***********************************"
    echo "Configuring a local network, IP: 169.254.1.100"
    exit 1
fi

ssh-keygen -f "$home/.ssh/known_hosts" -R "169.254.1.1"


cat > update.exp << EOF
#!/usr/bin/expect -f

#set timeout 10

spawn ssh admin@169.254.1.1

expect {
"*yes/no" { send "yes\r"; exp_continue}
"*password:" { send "admin@huawei.com\r" }
}

expect "<Huawei>"
send "system-view\r"
send "ap-mode-switch prepare\r"
send "ap-mode-switch check\r"

send "ap-mode-switch tftp FatAP3010DN-V2_V200R008C10SPC500.bin 169.254.1.100\r"
expect {"Y/N]:" { send "Y\r"}}

expect eof
EOF

chmod a+x update.exp
./update.exp
rm ./update.exp

netstat=$(ping -c3 169.254.1.1 |grep transmitted |awk '{print $4}')
while [ "$netstat" -ne "0" ]
do
    echo -n "#"
    netstat=$(ping -c3 169.254.1.1 |grep transmitted |awk '{print $4}')
done

echo "Firmware upgrade succeeded"

echo ""
echo "Device restart ..."

netstat=$(ping -c3 169.254.1.1 |grep transmitted |awk '{print $4}')
while [ "$netstat" -eq "0" ]
do
    echo -n "*"
    netstat=$(ping -c3 169.254.1.1 |grep transmitted |awk '{print $4}')
done

echo "Device restart succeeded"
echo "over"
echo "over"
```
### expect脚本

``` shell
#!/usr/bin/expect -f

#set timeout 10

spawn ssh admin@169.254.1.1

expect {
"*yes/no" { send "yes\r"; exp_continue}
"*password:" { send "admin@huawei.com\r" }
}

expect "<Huawei>"
send "system-view\r"
send "ap-mode-switch prepare\r"
send "ap-mode-switch check\r"

send "ap-mode-switch tftp FatAP3010DN-V2_V200R008C10SPC500.bin 169.254.1.100\r"
expect {"Y/N]:" { send "Y\r"}}  //这个处理存在问题无法自动输入Y

expect eof
```

## 参考

* [Shell脚本学习之expect命令](https://www.cnblogs.com/lixigang/articles/4849527.html)
