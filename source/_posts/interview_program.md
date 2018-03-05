---
title: 面试题
date: 2016-08-18 23:07:24
categories: 随笔
tags: [面试]
---



<!--more-->


## union

``` C
#include<stdio.h>

union aa{
        int i;
        char a[2];
};

int main()
{
        union aa b;
        b.i = 0; //初始化内存空间，如果不清最后的b.i为随机值
        b.a[0] = 10;
        b.a[1] = 1;
        printf("%d\n", b.i);
        printf("%d\n", (1 << 8) | (10));
        return 0;
}
```
>结果： 266(256+10)

1. union 类型的特点是不同类型的数据共享同一段内存，union 结构体的大小为其所含占内存`最大成员大小`，但在同一时刻只能有一类成员存储于其中
2. 计算机存储的大小端不同，最后的输出结果不一定。

## 大小端

1. `Little endian`和`Big endian`是CPU存放数据的两种不同顺序
2. `Big endian`第一个字节是最高位字节（按照从低地址到高地址的顺序存放数据的高位字节到低位字节）
3. `Little endian`第一个字节是最低位字节（按照从低地址到高地址的顺序存放数据的低位字节到高位字节）


* 共同体所有数据共用同一块地址空间
``` C
#include <stdio.h>

union aa{
        int i;
        char j;
};

int main()
{
        union aa a;
        a.i = 1;

        if ( a.j == 1 )
            printf("little-endian\n");  
        else
            printf("big-endian\n");  
        return 0;
}
```

* 指针强制类型转换
``` c
#include <stdio.h>  
int main()  
{  
    int a = 1;  
    char * p = (char*)&a;  
    if (*p == 1)   
        printf("little-endian\n");  
    else  
        printf("big-endian\n");  

    return 0;  
}  
```

## 内存对齐

1. 数据类型自身的对齐值：char型数据自身对齐值为1字节，short型数据为2字节，int/float型为4字节，double型为8字节
2. 结构体或类的自身对齐值：其成员中自身对齐值`最大`的那个值
3. 指定对齐值：`#pragma pack (value)`时的指定对齐值value。
4. 数据成员、结构体和类的有效对齐值：自身对齐值和指定对齐值中较小者，即有效对齐值=min{自身对齐值，当前指定的pack值}

``` C
struct std1{
	int a;     //4
	char b;   //1
			  //占空3
	float c;   //4
	char d;   //1
			  //占空3
	double e; //8
}
sizeof(std1) = 24

struct std2{
	char c;  //1
			 //占空1
	short s;  //2
};
sizeof(std2) = 4
```

## 数据类型

``` C
#include <stdio.h>

int main()
{
        int *p = 0;
        p += 6; //累加的是p指针类型的宽度（4*6）
        printf("%p\n", p);
        return 0;
}
```
>输出： 0x18（24）

## 进程间通信

1. 管道
2. 消息队列：消息队列是由消息的链表，存放在内核中并由消息队列标识符标识，消息队列克服了信号传递信息少、管道只能承载无格式字节流以及缓冲区大小受限等缺点
3. 共享内存
4. 信号量：信号量是一个计数器，可以用来控制多个进程对共享资源的访问。
5. socket
6. 信号（sinal）：信号是一种比较复杂的通信方式，用于通知接收进程某个事件已经发生

>[进程间通信的方式——信号、管道、消息队列、共享内存](https://www.cnblogs.com/LUO77/p/5816326.html)

## 字符串反转

``` C
char *revstr(char *str)
{
    char    *start = str;
    char    *end = str + strlen(str) - 1;
    char    ch;

    if (str != NULL) {
        while (start < end) {
            ch = *start;
            *start++ = *end;
            *end-- = ch;
        }
    }
    return str;
}
```

``` C
#include<stdio.h>                                    
int my_strlen(char *str)                             
{                                                    
        if(*str == '\0')                             
                return 0;                            
        else                                         
                return my_strlen(str+1) + 1;         
}                                                    

void reverse_string(char *string)                    
{                                                    
        int len = my_strlen(string);                 
        if(len <= 1)                                 
                return ;                             
        else {                                       
                char temp = string[0];               
                string[0] = string[len-1];           
                string[len-1] = '\0';                
                reverse_string(string+1);            
                string[len-1] = temp;                
        }                                            
}                                                    
int main() {                                         
        char ch[] = "abcdefghijklmno";               

        printf("0:%s\n",ch);                         
        reverse_string(ch);                          
        printf("1:%s\n",ch);                         

        return 0;                                    
}                                                    
```
## 链表
