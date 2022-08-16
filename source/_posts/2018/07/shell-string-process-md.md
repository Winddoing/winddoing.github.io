---
layout: post
title: Shell字符串处理——配置文件获取版本号
date: '2018-07-31 09:45'
categories:
  - shell
  - 字符串处理
tags:
  - shell
abbrlink: 35545
---

字符串的截取和最后一个字符的删除

<!--more-->

配置文件：
```
software_version  = xxxxxxx-V1.0.2
hdmi_info=1920*1080p@60@48000
wlan_ip=  0.0.0.0
mac_address=  00:00:00:00:00:00
encode_rate  =8192
wfd_mode_tcp  =true
```

过滤脚本：
``` shell
CFGD_CONF="${OSDRV_DIR}/conf/db/cfgd.conf"
software_version=`grep "software_version" ${CFGD_CONF} | awk '{sub(/.$/,"")}1' | awk '{print $3}'`

echo "current software_version: [${software_version}]"
```

* `awk '{sub(/.$/,"")}1'`: 去掉最后一个字符
* `awk '{print $3}'`：输出版本号

>直接使用grep得到的`software_version`这行最后一个字符是`？`，影响输出结果因此要去掉
