---
layout: post
title: 'C语言中char*和char[]的区别'
date: '2018-09-07 09:31'
categories:
  - 程序设计
tags:
  - 指针
abbrlink: 44009
---

- `char *c` : char型指针，只表示所指向的内存单元
- `char []` : 表示数组型的内存单元

**结论**： `char a[]`或`char a[0]`形式的定义在`结构体`中不占内存大小。

<!--more-->

**以下所有测试在`64bit`系统中进行，结果与32bit系统存在差别。**
``` C
#include <stdio.h>
#include <stdlib.h>

int main()
{
    int int_a;                                                                 
    int* int_a_p;                                                              
    char char_b;                                                               
    char* char_b_p;                                                            
    printf("\tSystem Data Width:\n");                                          
    printf("sizeof int(%ld), int*(%ld), char(%ld), char*(%ld)\n",              
            sizeof(int_a), sizeof(int_a_p), sizeof(char_b), sizeof(char_b_p));

	char *c1 = "a b c d";
	char c2[] = "a b c d";

	printf("c1: %s\n", c1);
	printf("c2: %s\n", c2);

	printf("c1-c1[0]=%c\n", c1[0]);
	printf("c2-c2[0]=%c\n", c2[0]);

	//c1[0] = 'x'; /* Segmentation fault (core dumped) */
	c2[0] = 'y';

	printf("c1-c1[0]=%c\n", c1[0]);
	printf("c2-c2[0]=%c\n", c2[0]);

	struct sc1 {
		char a;
		char *b;
	};
	struct sc2 {
		char a;
		char b[];
	};
    struct sc2_1 {                
    char a;                   
    char b[0];                
    };                            
	printf("sc1: sizeof-char*  = %ld\n", sizeof(struct sc1)); //8 + 8
	printf("sc2: sizeof-char[] = %ld\n", sizeof(struct sc2)); //1
    printf("sc2_1: packed sizeof-char[0] = %ld\n", sizeof(struct sc2_1)); //1

	struct __attribute__ ((__packed__)) sc3 {
		char a;
		char *b;
	};
	struct __attribute__ ((__packed__)) sc4 {
		char a;
		char b[];
	};
	printf("sc3: packed sizeof-char*  = %ld\n", sizeof(struct sc3)); //1 + 8
	printf("sc4: packed sizeof-char[] = %ld\n", sizeof(struct sc4)); //1
	return 0;
}
```

* 运行：
```
System Data Width:
sizeof int(4), int*(8), char(1), char*(8)
c1: a b c d
c2: a b c d
c1-c1[0]=a
c2-c2[0]=a
c1-c1[0]=a
c2-c2[0]=y
sc1: sizeof-char*  = 16
sc2: sizeof-char[] = 1
sc2_1: packed sizeof-char[0] = 1
sc3: packed sizeof-char*  = 9
sc4: packed sizeof-char[] = 1
```

## 内存地址对比

``` C
struct sc1 sc1_a;                                    
printf("\tsc1_a addr: %p\n", &sc1_a);                
printf("\tsc1_a.a addr: %p\n", &sc1_a.a);            
printf("\tsc1_a.b addr: %p\n", &sc1_a.b);            

struct sc2 sc2_a, sc2_b;                             
printf("\tsc2_a addr: %p\n", &sc2_a);                
printf("\tsc2_a.a addr: %p\n", &sc2_a.a);            
printf("\tsc2_a.b addr: %p\n", &sc2_a.b);            
printf("\tsc2_b addr: %p\n", &sc2_b);                
```
* 运行结果：
```
sc1_a addr: 0x7ffd44ed7d60
sc1_a.a addr: 0x7ffd44ed7d60
sc1_a.b addr: 0x7ffd44ed7d68
sc2_a addr: 0x7ffd44ed7d7e
sc2_a.a addr: 0x7ffd44ed7d7e
sc2_a.b addr: 0x7ffd44ed7d7f
sc2_b addr: 0x7ffd44ed7d7f
```

- 在结构体中使用`char buf[]`形式的定义，不占用内存空间

## 应用

内核部分结构体：如MMC中sdhci的结构体定义
``` C
struct sdhci_host {
    ...
    unsigned long private[0] ____cacheline_aligned;
};
```
利于将自定义结构体部分和公共结构体之间相关联。

自定义结构体：
``` C
struct sdhci_custom {
    int xxx;
};

struct sdhci_host *host;
struct sdhci_custom *custom;

//一次性申请内存看见
host = kmalloc(sizeof(struct sdhci_host) + sizeof(struct sdhci_custom));

//自定义结构体位置
custom = host->private;
```

## 参考

* [`____cacheline_aligned`和`____cacheline_aligned_in_smp`](https://blog.csdn.net/u010383937/article/details/78528750)
