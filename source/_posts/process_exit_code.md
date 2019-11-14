---
title: 进程退出的exitcode
categories: 进程
tags:
  - 进程
  - exit_code
abbrlink: 7653
date: 2017-03-07 23:07:24
---

## 错误信息

内核打印

```
 Kernel panic - not syncing: Attempted to kill init! exitcode=0x0000000b
```
<!---more--->
## 分析

### 出错位置

``` C
 panic("Attempted to kill init! exitcode=0x%08x\n",
     father->signal->group_exit_code ?:
         father->exit_code);                                 
```
> kernel/exit.c

### exit_cede赋值

``` C
void do_exit(long code)
{
	...
	 tsk->exit_code = code;
	...
	exit_notify(tsk, group_dead);
	...
}
```

函数调用关系:
```
exit_notify
	|-> forget_original_parent(tsk);
				|-> find_new_reaper(father);
							|-> "Attempted to kill init! exitcode=0x%08x\n"
```

## 错误来源

在Android系统中,linux内核启动过程中,进入`用户空间`后,init进程执行过程中出现该错误

**由于在用户空间引起的内核错误,因此只能通过系统调用产生**

``` C
SYSCALL_DEFINE1(exit, int, error_code)                 
{
    do_exit((error_code&0xff)<<8);
}
```
在进入内核是do_exit取了用户空间传入的错误码的`低8位`

## 进程退出的错误码

在系统中的进程在正常和非正常退出时，都有一个表示当前进程退出状态的标识，即`退出码`

### 查看进程退出码

退出码代表的是一个进程退出的状态码, 可以使用wait函数进行查看。
``` C
void _exit(int status)，
```
>status表明了进程终止时的状态。当子进程使用_exit()后，父进程如果在用wait()等待子进程，那么wait()将会返回status状态，注意只有status的低8位（0~255）会返回给父进程

``` c
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>
#include <errno.h>

int main(void)
{
    int count = 1;
    int pid;
    int status;

    pid = fork( );
    printf("pid=%d\n", pid);

    if(pid < 0) {
        perror("fork error : ");
    } else if(pid == 0) {
        printf("This is son, his count is: %d (%p). and his pid is: %d\n",
                ++count, &count, getpid());
        sleep(3);
        _exit(0);
    } else {
        pid = wait(&status);

        printf("This is father, his count is: %d (%p), his pid is: %d, son exit status: %d[%08x]\n",
                count, &count, getpid(), status, status);
    }

    return 0;
}                                                                                                                                 
```
正常退出结果：
``` shell
=====>$./a.out
pid=4018
pid=0
This is son, his count is: 2 (0x7fff19658714). and his pid is: 4018
This is father, his count is: 1 (0x7fff19658714), his pid is: 4017, son exit status: 0[00000000]
```
在子进程sleep时将其kill掉的结果：
``` shell
=====>$./a.out &
[1] 4066
00:11 [xxx@machine]~/work/MyCode/systemcall/test
=====>$pid=4067
pid=0
This is son, his count is: 2 (0x7ffe19987d04). and his pid is: 4067

00:11 [xxx@machine]~/work/MyCode/systemcall/test
=====>$kill 4067
This is father, his count is: 1 (0x7ffe19987d04), his pid is: 4066, son exit status: 15[0000000f]
```
在进程正常退出时，子进程的状态码是`0`，而kill掉后变为了`15`.

>注：此时如果在linux终端下使用`echo $?`,获取的仅仅该进程的main函数的返回值。

### 退出码的含义

根据前面分析，在进程调用_exit退出时,是通过exit系统调用实现的，而这里的`0`和`15`,就是系统调用exit的参数`error_code`

**进程的退出状态不等于退出码，程退出时候的状态码是8位，高4位存储退出码，低4位存储导致进程退出的信号标志位**

>网上有人说16位，分别是高八位和低八位，还需确认

根据这段话的描述，之前测试中子进程的退出状态`0`和`15`中，退出码均为`0`,而退出时的singal不同，正常退出时为0，kill掉后变为15

### 制造段错误

在测试case中的子进程中，制造一个段错误，根据此时的分析子进程退出的状态码中的signal应该代表段错误
子进程中添加：
``` C
int *a;
*a = 3;
```
测试结果：
``` shell
=====>$./a.out
pid=4500
pid=0
This is son, his count is: 2 (0x7fff54e86d1c). and his pid is: 4500
This is father, his count is: 1 (0x7fff54e86d1c), his pid is: 4499, son exit status: 139[0000008b]
```
此时子进程的`退出码=8`，而`signal=b`

### 信号

linux内核中x86的信号列表：
``` C
#define SIGSEGV     11
#define SIGTERM     15
```
>arch/x86/include/uapi/asm/signal.h

| 信号 | 行为 | 产生原因 |
| ---- | ---- | --- |
| SIGTERM | 请求中断 | kill() 可以发 SIGTERM 过去；kill 命令默认也使用 SIGTERM 信号 |
| SIGSEGV | 无效内存引用| 段错误|

## 总结

进程在退出时都会将自己当前的状态告诉内核，而此时的`状态码`包含两种含义：

* 高4位代表当前进程的退出码
* 低4位代表使当前进程退出所使用的信号

**在本文最开始提到的错误也是由于`SIGSEGV`无效内存引用引起的。**

mips架构下的信号列表：

``` C
#define SIGTERM     15  /* Termination (ANSI).  */
```
>arch/mips/include/uapi/asm/signal.h

## 参考：

1. [ linux子进程退出状态值解析：waitpid() status意义解析](http://blog.csdn.net/eqiang8271/article/details/8225468)
