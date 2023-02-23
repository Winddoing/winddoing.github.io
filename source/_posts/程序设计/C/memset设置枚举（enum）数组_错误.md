---
layout: post
title: memset设置枚举（enum）数组--错误
date: '2019-07-10 22:03'
tags:
  - memset
categories:
  - 程序设计
  - C
abbrlink: 50726
---

在最近的工作中，遇到了一个`memset`的问题，由于比较特殊在此记录一下。

需求：申请一个enum类型的数据，进行操作均正常，但是使用memset进行统一赋值时，数组各个元素均达不到预期效果。

如果枚举成员值是1，通过memset设置枚举类型数组内存值其结果将变为`0x01010101`,而不是`0x00000001`

<!--more-->

## 测试程序

``` C
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

enum tst {
	a1 = 0,
	a2,
	a3 = 5,
	a4,
};

int main(int argc, const char *argv[])
{
	int i = 0;
	enum tst* test = (enum tst*)malloc(sizeof(enum tst) * 10);

	printf("test=%p, sizeof enum tst=%ld\n", test, sizeof(enum tst));

	for (i = 0; i < 10; i++) {
		test[i] = a2;
	}
	for (i = 0; i < 10; i++) {
		printf("test[%d]=%d\n", i, test[i]);
	}

	printf("a1=%d, a2=%d, a3=%d, a4=%d\n", a1, a2, a3, a4);

	printf("===> func: %s, line: %d\n", __func__, __LINE__);
	memset(test, a1, sizeof(enum tst) * 10);

	for (i = 0; i < 10; i++) {
		printf("test[%d]=%d 0x%08x\n", i, test[i], test[i]);
	}

	printf("===> func: %s, line: %d\n", __func__, __LINE__);
	memset(test, a2, sizeof(enum tst) * 10);

	for (i = 0; i < 10; i++) {
		printf("test[%d]=%d 0x%08x\n", i, test[i], test[i]);
	}

	printf("===> func: %s, line: %d\n", __func__, __LINE__);
	memset(test, a3, sizeof(enum tst) * 10);

	for (i = 0; i < 10; i++) {
		printf("test[%d]=%d 0x%08x\n", i, test[i], test[i]);
	}

	printf("===> func: %s, line: %d\n", __func__, __LINE__);
	memset(test, a4, sizeof(enum tst) * 10);

	for (i = 0; i < 10; i++) {
		printf("test[%d]=%d 0x%08x\n", i, test[i], test[i]);
	}
	free(test);

	return 0;
}
```

## 运行结果：

```
test=0x7fffce4d3260, sizeof enum tst=4
test[0]=1
test[1]=1
test[2]=1
test[3]=1
test[4]=1
test[5]=1
test[6]=1
test[7]=1
test[8]=1
test[9]=1
a1=0, a2=1, a3=5, a4=6
===> func: main, line: 37
test[0]=0 0x00000000
test[1]=0 0x00000000
test[2]=0 0x00000000
test[3]=0 0x00000000
test[4]=0 0x00000000
test[5]=0 0x00000000
test[6]=0 0x00000000
test[7]=0 0x00000000
test[8]=0 0x00000000
test[9]=0 0x00000000
===> func: main, line: 44
test[0]=16843009 0x01010101
test[1]=16843009 0x01010101
test[2]=16843009 0x01010101
test[3]=16843009 0x01010101
test[4]=16843009 0x01010101
test[5]=16843009 0x01010101
test[6]=16843009 0x01010101
test[7]=16843009 0x01010101
test[8]=16843009 0x01010101
test[9]=16843009 0x01010101
===> func: main, line: 51
test[0]=84215045 0x05050505
test[1]=84215045 0x05050505
test[2]=84215045 0x05050505
test[3]=84215045 0x05050505
test[4]=84215045 0x05050505
test[5]=84215045 0x05050505
test[6]=84215045 0x05050505
test[7]=84215045 0x05050505
test[8]=84215045 0x05050505
test[9]=84215045 0x05050505
===> func: main, line: 58
test[0]=101058054 0x06060606
test[1]=101058054 0x06060606
test[2]=101058054 0x06060606
test[3]=101058054 0x06060606
test[4]=101058054 0x06060606
test[5]=101058054 0x06060606
test[6]=101058054 0x06060606
test[7]=101058054 0x06060606
test[8]=101058054 0x06060606
test[9]=101058054 0x06060606
```
- 枚举类型的大小占`4字节`
- `memset`后所有的内存值，将别设置为枚举成员的值的十六进制，但是只占1字节，其中4字节全部相同
- 测试如果枚举类型成员的值大于256（0x400），设置的内存值将是其底8位

## 原因

```
void *memset(void *s, int c, size_t n);
```
> The memset() function fills the first n bytes of the memory area pointed to by s with the constant byte c.

memset函数将内存的每个字节设置为第二个参数（在第二个参数被截断之后,因为是按照`字节`进行设置）。 由于枚举（通常）是int的大小，将得到错误的结果,它唯一有效的是枚举值为`0`.

**`memset`设置内存值是以字节为单位处理，因此所设置的数值范围是`0~0xff`**
