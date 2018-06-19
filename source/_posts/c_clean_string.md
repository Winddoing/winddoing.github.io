---
title: 去掉字符串末尾的空格 换行 回车
date: 2018-06-19 12:07:24
categories: 程序设计
tags: [字符串]
---


去掉字符串末尾多余字符：

<!--more-->


``` C
static void clean_string(char * const str) {
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
