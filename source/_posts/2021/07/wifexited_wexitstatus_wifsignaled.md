---
layout: post
title: WIFEXITED WEXITSTATUS WIFSIGNALED
date: '2021-07-16 17:37'
tags:
  - 进程
  - wait
categories:
  - 进程
abbrlink: 647daf2a
---

子进程退出状态

<!--more-->

If the exit status value (*note Program Termination::) of the child process is zero, then the status value reported by `waitpid` or `wait` is also zero. You can test for other kinds of information encoded in the returned status value using the following macros. These macros are defined in the header file `sys/wait.h`

## Macro: int WIFEXITED (int STATUS)

This macro returns a nonzero value if the child process terminated normally with `exit' or `_exit'.

## Macro: int WEXITSTATUS (int STATUS)

If `WIFEXITED' is true of STATUS, this macro returns the low-order 8 bits of the exit status value from the child process.`Note Exit Status`

## Macro: int WIFSIGNALED (int STATUS)

This macro returns a nonzero value if the child process terminated because it received a signal that was not handled. `Note Signal Handling`

> [进程退出的 exitcode](https://winddoing.github.io/post/7653.html)

## 参考

- [wait(2) — Linux manual page](https://www.man7.org/linux/man-pages/man2/waitpid.2.html)
- [WIFEXITED WEXITSTATUS WIFSIGNALED](http://blog.sina.com.cn/s/blog_636a55070101wtp5.html)
