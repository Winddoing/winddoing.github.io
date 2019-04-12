---
layout: post
title: '[转]GCC下itoa函数的演变：itoa with GCC'
date: '2019-04-12 14:34'
tags:
  - itoa
  - gcc
categories:
  - 程序设计
  - GCC
---

转载链接：https://blog.csdn.net/u013074465/article/details/46499959

原文：http://www.strudel.org.uk/itoa/

这篇文章中有对部分函数的具体分析：对itoa函数的分析。

## 简介

> 我怎么在GCC下使用`itoa()`？

啊，C/C++！itoa()不是`ANSI C`标准而且它不能在linux下的GCC中工作（至少我使用的版本是这样的）。这是很让人沮丧的，特别是当你想让代码跨平台可用时（Windows/Linux/Solaris或其他任何机器）。

很多人说可以使用sprintf来写字符串但是sprintf不满足itoa()的一个特征：itoa函数`允许将int转换为除十进制以外其他进制的形式`。该文章包含一系列itoa函数实现的演化版本。较老的版本在文章后边。请确认你用的是最新版本。

<!--more-->

## 贡献

在我们继续之前，我要感谢以下为解决方案作出贡献的人。这个函数是由以下人员贡献的：Stuart Lowe (本文作者)，Robert Jan Schaper，Ray-Yuan Sheu， Rodrigo de Salvo Braz，Wes Garland，John Maloney，Brian Hunt，Fernando Corradi and Lukás Chmela。

## 演变过程

以下是早期的一个版本，由Robert Jan Schaper表述于Google groups：

### char* version 0.1

``` C
char* itoa(int val, int base){
    static char buf[32] = {0};
	int i = 30;
	for(; val && i ; --i, val /= base)
		buf[i] = "0123456789abcdef"[val % base];
	return &buf[i+1];
}
```
我所使用的版本和这个版本看起来不太一样，它更像是这样的形式：itoa(int value, char* buffer, int radix)。在最后，我给出了我自己使用std::string代替字符串的版本。

### std::string version 0.1

``` C
void my_itoa(int value, std::string& buf, int base){
	int i = 30;
	buf = "";
	for(; value && i ; --i, value /= base)
        buf = "0123456789abcdef"[value % base] + buf;
}
```
更新：(2005/02/11)

Ray-Yuan Sheu发邮件给我，他提出了一个更新版本：做了更多错误检测，例如基底base越界、负整数等。

更新：(2005/04/08)

Rodrigo de Salvo Braz指出了一个bug：当输入为0时没有返回。现在函数返回0。Luc Gallant也指出了这个bug。

### std::string version 0.2

``` C
/**
 * C++ version std::string style "itoa":
 */
std::string itoa(int value, unsigned int base) {
	const char digitMap[] = "0123456789abcdef";
	std::string buf;

        // Guard:
	if (base == 0 || base > 16) {
		// Error: may add more trace/log output here
		return buf;
	}

	// Take care of negative int:
	std::string sign;
	int _value = value;

	// Check for case when input is zero:
	if (_value == 0) return "0";

	if (value < 0) {
		_value = -value;
		sign = "-";
	}

	// Translating number to string with base:
	for (int i = 30; _value && i ; --i) {
		buf = digitMap[ _value % base ] + buf;
		_value /= base;
	}

	return sign.append(buf);

}
```
更新：(2005/05/07)

Wes Garland指出lltostr函数在Solaris和其他linux变体中存在。函数应该返回long long的`char *`形式处理多种数基。还有针对无符号数值的ulltostr函数。

更新：(2005/05/30)

John Maloney指出了之前函数的多个问题。一个主要问题是函数包含大量栈分配。他建议尽可能移除栈分配以加快算法速度。char* 版本比上述的代码快至少10倍。新版本的std::string比原来的快3倍。尽管char*版本更快，但是你必须检查以确保为函数输出分配了足够的空间。


### std::string version 0.3

``` C
/**
 * C++ version std::string style "itoa":
 */
std::string itoa(int value, int base) {
	enum { kMaxDigits = 35 };
	std::string buf;
	buf.reserve( kMaxDigits ); // Pre-allocate enough space.

	// check that the base if valid
	if (base < 2 || base > 16) return buf;
	int quotient = value;

	// Translating number to string with base:
	do {
		buf += "0123456789abcdef"[ std::abs( quotient % base ) ];
		quotient /= base;
	} while ( quotient );

	// Append the negative sign for base 10
	if ( value < 0 && base == 10) buf += '-';
	std::reverse( buf.begin(), buf.end() );

	return buf;
}
```

### char *version 0.2

``` C
/**
 * C++ version char* style "itoa":
 */
char* itoa( int value, char* result, int base ) {
	// check that the base if valid
	if (base < 2 || base > 16) { *result = 0; return result; }

	char* out = result;
	int quotient = value;

	do {
		*out = "0123456789abcdef"[ std::abs( quotient % base ) ];
		++out;
		quotient /= base;
	} while ( quotient );

	// Only apply negative sign for base 10
	if ( value < 0 && base == 10) *out++ = '-';
	std::reverse( result, out );
	*out = 0;
	return result;
}
```
更新：(2006/10/15)

Luiz Gon?lves告诉我：尽管itoa不是ANSI标准函数，但是该函数来自很多开发包并且被写进了很多教科书。他提出了一个来自于Kernighan & Ritchie'sAnsi C的完全基于ANSI C的版本。基底base错误通过返回空字符来表述，并且没有分配内存。这个std::string版本和C++的`char* itoa()`版本在下方提供，做了一些细微的修改。

*** 译注：下面的方法是最容易想到的：***

``` C
/**
 * Ansi C "itoa" based on Kernighan & Ritchie's "Ansi C":
 */
void strreverse(char* begin, char* end) {
	char aux;
	while(end>begin)
		aux=*end, *end--=*begin, *begin++=aux;
}

void itoa(int value, char* str, int base) {
	static char num[] = "0123456789abcdefghijklmnopqrstuvwxyz";
	char* wstr=str;
	int sign;

       // Validate base
	if (base<2 || base>35){ *wstr='\0'; return; }

        // Take care of sign
	if ((sign=value) < 0) value = -value;

	// Conversion. Number is reversed.
	do {
              *wstr++ = num[value%base];
        } while(value/=base);
	if(sign<0) *wstr++='-';
	*wstr='\0';

	// Reverse string
	strreverse(str,wstr-1);
}

/**
 * Ansi C "itoa" based on Kernighan & Ritchie's "Ansi C"
 * with slight modification to optimize for specific architecture:
 */

void strreverse(char* begin, char* end) {
	char aux;
	while(end>begin)
		aux=*end, *end--=*begin, *begin++=aux;
}

void itoa(int value, char* str, int base) {
	static char num[] = "0123456789abcdefghijklmnopqrstuvwxyz";
	char* wstr=str;
	int sign;
	div_t res;

	// Validate base
	if (base<2 || base>35){ *wstr='\0'; return; }

	// Take care of sign
	if ((sign=value) < 0) value = -value;

	// Conversion. Number is reversed.
	do {
		res = div(value,base);
		*wstr++ = num[res.rem];
	}while(value=res.quot);
	if(sign<0) *wstr++='-';
	*wstr='\0';

	// Reverse string
	strreverse(str,wstr-1);
}
```

更新：(2009/07/08)

过去一年我收到了一些改进`std::string`和`char *`版本的代码。我最终有时间测试了这些代码。在std::string版本中，Brian Hunt建议将reverse移到base的检查之后，保存内存分配。这样可以加快速度。


### std::string version 0.4

``` C
/**
 * C++ version 0.4 std::string style "itoa":
 */
std::string itoa(int value, int base) {
	std::string buf;

	// check that the base if valid
	if (base < 2 || base > 16) return buf;

	enum { kMaxDigits = 35 };
	buf.reserve( kMaxDigits ); // Pre-allocate enough space.

	int quotient = value;

	// Translating number to string with base:
	do {
		buf += "0123456789abcdef"[ std::abs( quotient % base ) ];
		quotient /= base;
	} while ( quotient );

	// Append the negative sign
	if ( value < 0) buf += '-';

	std::reverse( buf.begin(), buf.end() );
	return buf;
}
```

还有一些针对char*版本的建议。Fernando Corradi提议使用abs()因为仅仅使用一次，不使用取余操作（%）而是通过手动计算除数。这样可以加快速度：

### char  *version 0.3

``` C
/**
 * C++ version 0.3 char* style "itoa":
 */
char* itoa( int value, char* result, int base ) {
	// check that the base if valid

	if (base < 2 || base > 16) { *result = 0; return result; }

	char* out = result;
	int quotient = abs(value);

	do {
		const int tmp = quotient / base;
		*out = "0123456789abcdef"[ quotient - (tmp*base) ];
		++out;
		quotient = tmp;
	} while ( quotient );

	// Apply negative sign
	if ( value < 0) *out++ = '-';

	std::reverse( result, out );
	*out = 0;
	return result;
}
```
### char* version 0.4

Lukás Chmela重写了代码，该函数不再有“最小负数”bug：

``` C
 /**
 * C++ version 0.4 char* style "itoa":
 * Written by Lukás Chmela
 * Released under GPLv3.
 */
char* itoa(int value, char* result, int base) {
	// check that the base if valid
	if (base < 2 || base > 36) { *result = '\0'; return result; }

	char* ptr = result, *ptr1 = result, tmp_char;
	int tmp_value;

	do {
		tmp_value = value;
		value /= base;
		*ptr++ = "zyxwvutsrqponmlkjihgfedcba9876543210123456789
                abcdefghijklmnopqrstuvwxyz" [35 + (tmp_value - value * base)];
	} while ( value );

	// Apply negative sign
	if (tmp_value < 0) *ptr++ = '-';
	*ptr-- = '\0';
	while(ptr1 < ptr) {
		tmp_char = *ptr;
		*ptr--= *ptr1;
		*ptr1++ = tmp_char;
	}
	return result;
}
```

## 最新版本

下面是最新版本的itoa，你可以根据喜好选择char*或std::string版本。我没有将基于Kernighan & Ritchie的版本放在这个部分，因为我不确定其版权的状态。然而，下列函数已经被上述提到的人开发并且是可以使用的。

### std::string version 0.4

``` C
/**
 * C++ version 0.4 std::string style "itoa":
 * Contributions from Stuart Lowe, Ray-Yuan Sheu,
 * Rodrigo de Salvo Braz, Luc Gallant, John Maloney
 * and Brian Hunt
 */
std::string itoa(int value, int base) {

	std::string buf;

	// check that the base if valid
	if (base < 2 || base > 16) return buf;

	enum { kMaxDigits = 35 };
	buf.reserve( kMaxDigits ); // Pre-allocate enough space.

	int quotient = value;

	// Translating number to string with base:
	do {
		buf += "0123456789abcdef"[ std::abs( quotient % base ) ];
		quotient /= base;
	} while ( quotient );

	// Append the negative sign
	if ( value < 0) buf += '-';

	std::reverse( buf.begin(), buf.end() );
	return buf;
}
```

### char* version 0.4

``` C
/**
 * C++ version 0.4 char* style "itoa":
 * Written by Lukás Chmela
 * Released under GPLv3.
 */
char* itoa(int value, char* result, int base) {
	// check that the base if valid
	if (base < 2 || base > 36) { *result = '\0'; return result; }

	char* ptr = result, *ptr1 = result, tmp_char;
	int tmp_value;

	do {
		tmp_value = value;
		value /= base;
		*ptr++ = "zyxwvutsrqponmlkjihgfedcba9876543210123456789
                abcdefghijklmnopqrstuvwxyz" [35 + (tmp_value - value * base)];
	} while ( value );

	// Apply negative sign
	if (tmp_value < 0) *ptr++ = '-';
	*ptr-- = '\0';
	while(ptr1 < ptr) {
		tmp_char = *ptr;
		*ptr--= *ptr1;
		*ptr1++ = tmp_char;
	}
	return result;
}
```

## 性能对比

我已经对itoa的各个版本做了测试，研究其转换-32768到32768之间整数，基底在2到20之间时所需要的平均时间（代码仅仅在基底最高位16有效，因此其余的base仅仅是作为测试）。测试结果如下表所示：

| function  | relative time  |
|:-|:-:|
| char* style "itoa" (v 0.2) <br/> char* itoa(int value, char* result, int base)  |  1.0 (XP, Cygwin, g++) |
| char* style "itoa" (v 0.3) <br/> char* itoa(int value, char* result, int base)  |  0.93 |
| char* style "itoa" (v 0.4) <br/> char* itoa(int value, char* result, int base)  |  0.72 |
| Ansi C "itoa" based on Kernighan & Ritchie's "Ansi C" with modification to optimize for specific architecture <br/>void itoa(int value, char* str, int base)  | 0.92  |
| std::string style "itoa" (v 0.3) <br/> std::string itoa(int value, int base)  | 41.5  |
| std::string style "itoa" (v 0.4) <br/> std::string itoa(int value, int base)  | 40.8  |
