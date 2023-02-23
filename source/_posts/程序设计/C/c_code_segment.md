---
title: C代码片段
categories:
  - 程序设计
  - C
tags:
  - c
  - 代码片段
abbrlink: 16839
date: 2018-06-19 12:07:24
---

记录一些遇到代码片段：

<!--more-->

## atexit()程序终止时调用注册函数

C 库函数 int atexit(void (*func)(void)) 当程序正常终止时，调用指定的函数 func。您可以在任何地方注册你的终止函数，但它会在程序终止的时候被调用。

``` C
#include <stdio.h>
#include <stdlib.h>

void functionA ()
{
   printf("这是函数A\n");
}

int main ()
{
   /* 注册终止函数 */
   atexit(functionA );

   printf("启动主程序...\n");

   printf("退出主程序...\n");

   return(0);
}
```

## 去掉字符串末尾多余字符：回车 空格

``` C
static void clean_string(char * const str)
{
	char *start = str;
	char *end = str;
	char *p = str;

	while(*p) {
		switch(*p) {
		case ' ':
		case '\r':
		case '\n':
			if(str != start) {
			*start = *p;
			start++;
		}
		break;
		default:
			*start = *p;
			start++;
			end = start;
		}
		p++;
	}
	*end = '\0';
}
```

## 生成随机数： 异或

``` C
static void seedrand_val2()
{
	struct timeval tv;
	unsigned int rand_val = 0;

	gettimeofday(&tv, NULL);

	//秒(tv.tv_sec)和微秒(tv.tv_usec)和进程ID的位进行异或操作生成随机数
	rand_val = tv.tv_sec^tv.tv_usec^getpid();

	printf("%s: rand_val=%d\n", __func__, rand_val);
}
```

## 伪随机数：rand

```
srand((unsigned)time(NULL));

#define MIN_BANDWIDTH   60
#define MAX_BANDWIDTH   200
#define random() (MIN_BANDWIDTH + (int)((double)rand() / ((double)RAND_MAX+1.0) * (MAX_BANDWIDTH - MIN_BANDWIDTH)))
```
> 随机范围：60~200
