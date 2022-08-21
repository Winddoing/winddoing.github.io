---
layout: post
title: printk打印输出级别—15
date: '2022-06-22 14:13'
tags:
  - printk
  - linux
categories:
  - Linux内核
abbrlink: aabf231e
---

```
# cat /proc/sys/kernel/printk
15      4       1       7
```
在正常的printk日志输出级别中只有`0～7`，为何会出现`15`？

> 原因是内核lock的状态检测到异常后，在进行相关锁状态信息输出前，将console的level配置成`15`

<!--more-->

## printk级别

```
int console_printk[4] = {
    CONSOLE_LOGLEVEL_DEFAULT,   /* console_loglevel */
    MESSAGE_LOGLEVEL_DEFAULT,   /* default_message_loglevel */
    CONSOLE_LOGLEVEL_MIN,       /* minimum_console_loglevel */
    CONSOLE_LOGLEVEL_DEFAULT,   /* default_console_loglevel */
};
EXPORT_SYMBOL_GPL(console_printk);
```
> kernel/printk/printk.c

出现异常时调整的是`console_loglevel`，其默认值为:

```
#define CONSOLE_LOGLEVEL_DEFAULT CONFIG_CONSOLE_LOGLEVEL_DEFAULT

CONFIG_CONSOLE_LOGLEVEL_DEFAULT=7 //内核配置
```

kernel日志等级：

```
/* integer equivalents of KERN_<LEVEL> */
#define LOGLEVEL_SCHED      -2  /* Deferred messages from sched code
                     * are set to this special level */
#define LOGLEVEL_DEFAULT    -1  /* default (or last) loglevel */
#define LOGLEVEL_EMERG      0   /* system is unusable */
#define LOGLEVEL_ALERT      1   /* action must be taken immediately */
#define LOGLEVEL_CRIT       2   /* critical conditions */
#define LOGLEVEL_ERR        3   /* error conditions */
#define LOGLEVEL_WARNING    4   /* warning conditions */
#define LOGLEVEL_NOTICE     5   /* normal but significant condition */
#define LOGLEVEL_INFO       6   /* informational */
#define LOGLEVEL_DEBUG      7   /* debug-level messages */
```
> include/linux/kern_levels.h


## console_loglevel

```
#define console_loglevel (console_printk[0])
```

调整接口：

```
#define CONSOLE_LOGLEVEL_MOTORMOUTH 15  /* You can't shut this one up */


static inline void console_verbose(void)
{
    if (console_loglevel)
        console_loglevel = CONSOLE_LOGLEVEL_MOTORMOUTH;
}
```
> include/linux/printk.h

也就是通过`console_verbose`接口，将console等级调整为`15`.


## console_verbose的调用流程

```
print_unlock_imbalance_bug
  \-> debug_locks_off
    \-> console_verbose //打开console全部输出，级别15 lib/debug_locks.c
  \-> dump_stack
```
