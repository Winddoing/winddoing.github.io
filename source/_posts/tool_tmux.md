---
title: tmux
categories: 工具
tags:
  - tmux
abbrlink: 40876
date: 2018-03-21 23:07:24
---

tmux是一个优秀的终端复用软件，split窗口。可以在一个terminal下打开多个终端。
即使非正常掉线，也能保证当前的任务运行，这一点对于远程SSH访问特别有用，网络不好的情况下仍然能保证工作现场不丢失。SSH重新连接以后，就可以直接回到原来的工作环境，不但提高了工作效率，还降低了风险，增加了安全性。

tmux完全使用键盘控制窗口，实现窗口的切换功能

```
sudo apt-get install tmux
```
<!--more-->

## 快捷键


## 配置

>[my tmux.conf](https://raw.githubusercontent.com/Winddoing/vim_work_config/master/.tmux.conf)

tmux的系统级配置文件为`/etc/tmux.conf`，用户级配置文件为`~/.tmux.conf`。配置文件实际上就是tmux的命令集合，也就是说每行配置均可在进入命令行模式后输入生效。
