---
title: 面试题
categories: 随笔
tags:
  - 面试
abbrlink: 27055
date: 2016-08-18 23:07:24
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

## 宏

### 取最大值

```
#define PAD(v, p)  ((v + (p) - 1) & (~((p) - 1)))
```

### 判断奇偶

```
#define IS_POW2(x)  (((x) & (x - 1)) == 0)
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
        p += 6; /*累加的是p指针类型的宽度(4*6)*/
        printf("%p\n", p);
        return 0;
}
```
>输出： 0x18[24]

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
char* revstr(char *str)
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

## 指针与引用

>`C++`

``` C
#include <stdio.h>

void change(int*a, int &b, int c)
{
        c=*a;
        b=30;
        *a=20;
}

int main()
{
        int a=10, b=20, c=30;
        /*指针与引用*/
        change(&a,b,c);
        printf("%d,%d,%d\n",a,b,c);
        return 0;
}
```
>结果：20,30,30

``` C
#include<iostream>
#include<stdlib.h>

using namespace std;
void test(int &a)
{
        cout<<&a<<" "<<a<<endl<<endl;
}
int main(void)
{
        int a=1;
        cout<<&a<<" "<<a<<endl<<endl;
        test(a);
        return 0;
}
```
>0x7fffc646494c 1
>0x7fffc646494c 1

1. 指针传递是一种`值传递`的方式，他`传递的只是地址值`，值传递的时候中我们可以知道被调函数的形参会被当做一个局部变量来出来，会在栈中去给其分配空间用 来存储主调函数传输过来的值，该值只不过是主调函数中实参值的一个拷贝，所以在被调函数中去修改传输过来的值并不会去影响主调函数中的实参值。
2. 引用作为函数参数进行传递时，实质上`传递的是实参本身`，即传递进来的不是实参的一个拷贝，因此对形参的修改其实是对实参的修改，所以在用引用进行参数传递时，不仅节约时间，而且可以节约空间。
3. 指针是一个实体，而引用仅是个别名；
4. 引用不可以为空，当被创建的时候，必须初始化，而指针可以是空值，可以在任何时候被初始化。
5. 可以有const指针，但是没有const引用；
6. 指针可以有多级，但是引用只能是一级（int \*\*p；合法 而 int &&a是不合法的）
7. 指针和引用的自增(++)运算意义不一样；
8. 如果返回动态内存分配的对象或者内存，必须使用指针，引用可能引起内存泄漏；

## 指针与数组

## 关键字static

1. 在函数体，一个被声明为静态的变量在这一函数被调用过程中维持其值不变， 内存中的位置：`静态存储区`（**静态存储区在整个程序运行期间都存在**）
2. 在模块内（但在函数体外），一个被声明为静态的变量可以被模块内所用函数访问，但不能被模块外其它函数访问。它是一个本地的全局变量。
3. 在模块内，一个被声明为静态的函数只可被这一模块内的其它函数调用。那就是，这个函数被限制在声明它的模块的本地范围内使用。

## 关键字const

>左`数`右`指`

``` C
const int a;    //a：只读
int const a;    //a：只读
const int *a;   //"左"，指针a，数据不能变，数据只读
int * const a;  //"右"，指针a，指针不能变，地址只读
int const * a const;    //数据指针均只读
```
1. 关键字const的 作用是为给读你代码的人传达非常有用的信息，实际上，声明一个参数为常量是为了告诉了用户这个参数的应用目的。
2. 通过给编译器一些附加的信息，使用关键字const也许能产生更紧凑的代码。
3. 合理地使用关键字const可以使编译器很自然地保护那些不希望被改变的参数，防止其被无意的代码修改。简而言之，这样可以减少bug的出现。

## 关键字volatile

1. 并行设备的硬件寄存器（如：状态寄存器），防止编译器的优化
2. 一个中断服务子程序中会访问到的非自动变量(Non-automatic variables),(即，变量会在程序外被改变,每次都必须从内存中读取，而不能把他放在cache或寄存器中重复使用)
3. 多线程应用中被几个任务共享的变量

## float类型和0比较大小

```
const float EPSINON= 0.00001;
if((x >= -EPSINON) && (x <= EPSINON))>))
```
>不能直接用float类型的值与0进行“==”或“!=”比较

__标准C语言中:__
单精度float浮点格式的符号位=1，有效位=23，指数未=8，产生一个32位的表示。
双精度double浮点格式的符号位=1，有效位=52，指数位=11，产生一个64位的表示。

转成数值即为:V=(-1)^S * 1.M * 2^(E-127)

对于16.5转成二进制为00010000.1==>1.00001*2^4,
那么在内存的表示为:
符号位    指数4+127 = 131      尾数
0          10000011         00001 000000000000000000

在转换过程中由于需要往右移位, 可见对于float数整数部分越大,小数部分的精度就越低
对float数来说有效数字约为7位(2^23约等于10^7),所以整数部分占的位数越多,小数部分
的精度就越低,当整数部分超过9999999后小数部分已经完全无精度了

## 链表

### 二分查找

### B-树(B+树)

### 红黑树和AVL树

## 参考

1. [传指针和传指针引用的区别/指针和引用的区别（本质）](https://www.cnblogs.com/x_wukong/p/5712345.html)
2. [C语言中static变量详解 ](http://blog.chinaunix.net/uid-24611346-id-3193852.html)
