---
date: 2014-5-10
layout: post
title: '正则表达式(regular expression) [^,*]与[^,]*区别'
thread: 166
categories:
  - shell
  - 正则表达式
tags:
  - shell
abbrlink: 10189
---

### 正则表达式(Regular Expression) [^,*]与[^,]*区别：
  1. $ sed 's/[^,]*/{&}/' example.txt

  ![01](/assets/img/article-image/2014-03-06/01.png)
  2. $ sed 's/[^,*]/{&}/' example.txt

  ![02](/assets/img/article-image/2014-03-06/02.png)

#### 使用此特殊字符匹配任意字符或字符串的重复多次表达式。例如：compu*t将匹配字符u一次或多次。

  ![03](/assets/img/article-image/2014-03-06/03.png)

 * 只匹配[ ] 内字符。可以是一个单字符，也可以是字符序列
 * []在指定模式匹配的范围或限制方面很有用。结合使用*与[ ]更是有益，
 * 例如:[ A - Z a - Z ] *将匹配所有单词
 *注意* :^符号的使用，当直接用在第一个括号里，意指否定或不匹配括号里内容。

#### 如:[^a-zA-Z]匹配任一非字母型字符，而[ ^ 0 - 9 ]匹配任一非数字型字符。
 * $ sed 's/[^,*]/{&}/' example.txt
 * 表示把开头不是一个或多个“，”时的第一个字符加上{}

  ![04](/assets/img/article-image/2014-03-06/04.png)

只对第一个字符“1”加上了{}，主要原因是[ ]内的字符一次只匹配一个。

* 表示把不是“，”之前的所有字符串，加上{}

  ![05](/assets/img/article-image/2014-03-06/05.png)

### 截取字符串
- 原文本文件 example.txt
102,John Smith,IT Manager
103,Raj Reddy,Sysadmin
104,Anand Ram,Developer
105,Jane Miller,Sales Manager
,123
,lin,feng
,,,sss

#### 截取非数字的所有字符  --失败
* $ sed 's/[^0-9]*/ /' example.txt

  ![06](/assets/img/article-image/2014-03-06/06.png)
- 失败原因：[^0-9]表示匹配一非数字型字符，而[^0-9]*表示一或多个非数字型字符，但只要有一个字符匹配成立，就进行替换。

#### 截取非数字的所有字符  --成功
* $ sed 's/[^0-9].*/ /' example.txt

  ![07](/assets/img/article-image/2014-03-06/07.png)
