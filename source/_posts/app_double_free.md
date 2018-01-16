---
title: double free or corruption (fasttop)
date: 2018-01-15 23:07:24
categories: 程序设计
tags: [app, free]
---

```
*** Error in `./rixitest-static-ok': double free or corruption (fasttop): 0x76e006f0 ***`
```

>在进行多线程编程的时候，可能出现`double free` 问题。主要是在多线程函数中有个对`new`出来的变量进行操作，但是未加锁同步导致的。只要在在对new变量进行读写操作之前，加个锁，就可以避免该问题的产生。

`0x76e006f0` : 多次`free`的变量地址，变量（或对象）通过`new`得到的，地址空间在堆里。

在多线程测试中，由于其中一个线程因为异常而exit(-1)退出时，另外的线程也可能因为异常对象的生命周期结束而执行析构函数去delete同一个变量。
<!--more-->

## exit and _exit

>用于终止一个程序

``` C
void exit(int status);
void _exit(int status);
```
![exit_and__exit](/images/app/exit_and__exit.png)

`_exit`直接进入内核，`exit`则先执行一些清除处理（在进程退出之前要检查文件状态，将文件缓冲区中的内容写回文件）再进入内核


调用`_exit`函数时，其会关闭进程所有的文件描述符，清理内存以及其他一些内核清理函数，但不会刷新流（stdin,stdout,stderr…）.`exit`函数是在`_exit`函数之上增加了一个封装，写回文件缓存区中的内容


## 析构函数何时被调用

析构函数在下边3种情况时被调用：

1. 对象生命周期结束，被销毁时；
2. delete指向对象的指针时，或delete指向对象的基类类型指针，而其基类虚构函数是虚函数时；
3. 对象i是对象o的成员，o的析构函数被调用时，对象i的析构函数也被调用。


## Sample

``` C
#include <iostream>
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <pthread.h>

using namespace std;

class Test
{
	public:
		Test(int i) 
		{
			m_i = i; 
			printf("%s: construct %d\n", __func__, m_i);
		};
		~Test() 
		{
			printf("%s: destruct %d\n", __func__,  m_i);
		};
	private:
		int m_i;
};

Test t_1(1);

void *threadFunc(void *arg)
{
	Test t_3(3);

/*	exit(1);*/
	return NULL;
}

int main(int argc, char* argv[])
{
	pthread_t thread; 
	int err;
	Test t_2(2);

	err = pthread_create(&thread, NULL, threadFunc, NULL);
	if (err != 0)
		printf("pthread_create fail!!!\n");

	pthread_join(thread,NULL);
	printf("Hello World\n");

	return 0;
/*	exit (0);*/
/*	_exit(0);*/
}
```

### main(return), threadFunc(return)

```
Test: construct 1
Test: construct 2
Test: construct 3
~Test: destruct 3
Hello World
~Test: destruct 2
~Test: destruct 1
```
### main(return)，threadFunc(exit)

```
Test: construct 1
Test: construct 2
Test: construct 3
~Test: destruct 1
```

### main(exit)，threadFunc(return)

```
Test: construct 1
Test: construct 2
Test: construct 3
~Test: destruct 3
Hello World
~Test: destruct 1
```

### main(_exit)，threadFunc(return)

```
Test: construct 1
Test: construct 2
Test: construct 3
~Test: destruct 3
Hello World
```
