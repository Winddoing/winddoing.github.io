---
title: C代码片段
date: 2018-06-19 12:07:24
categories: 程序设计
tags: [C]
---

记录一些遇到代码片段：

<!--more-->

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