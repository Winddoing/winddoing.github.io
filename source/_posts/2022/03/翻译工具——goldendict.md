---
layout: post
title: 翻译工具——GoldenDict
date: '2022-03-17 12:01'
tags:
  - 工具
  - 翻译
  - GoldenDict
categories:
  - 工具
abbrlink: eba28245
---

[GoldenDict](http://www.goldendict.org)翻译软件可以划词翻译，并且可以跨软件，比有道词典显示速度快。

``` shell
sudo apt install goldendict
```

<!--more-->

## 配置中文语言

打开GoldenDict，【编辑】- 【首选项】-【界面语言】

修改完语言后，必须重启才能生效。

## 添加谷歌翻译

### 安装translate-shell

```
sudo apt-get install translate-shell
```

### 配置

打开GoldenDict，【编辑】-【词典】-【词典来源】-【程序】，点击【添加】，勾上【已启用】，填写【类型】和【名称】，在【命令行】中输入

```
trans -e google -s auto -t zh-CN -show-original y -show-original-phonetics n -show-translation y -no-ansi -show-translation-phonetics n -show-prompt-message n -show-languages y -show-original-dictionary n -show-dictionary n -show-alternatives n “%GDWORD%”
```
```
trans -e google -s auto -t zh-CN -show-original y -show-original-phonetics y -show-translation y -no-ansi -show-translation-phonetics n -show-prompt-message n -show-languages y -show-original-dictionary n -show-dictionary y -show-alternatives n "%GDWORD%"
```

- `类型`: 纯文本
- `名称`: Google (可以随意填写)

## 屏幕取词

配置快捷键`Ctrl+Alt`，只有同时按下是才会取词翻译。

【编辑】-【首选项】-【屏幕取词】


关闭翻译剪切板单词，防止在多次`Ctrl+c`时误触发。

【编辑】-【首选项】-【热键】



## 添加字典

下载地址： http://download.huzheng.org/zh_CN/


- http://download.huzheng.org/zh_CN/stardict-langdao-ce-gb-2.4.2.tar.bz2
- http://download.huzheng.org/zh_CN/stardict-langdao-ec-gb-2.4.2.tar.bz2
- http://download.huzheng.org/zh_CN/stardict-oxford-gb-2.4.2.tar.bz2
- http://download.huzheng.org/zh_CN/stardict-kdic-computer-gb-2.4.2.tar.bz2
