---
layout: post
title: C与C++混合编译
date: '2020-04-29 09:45'
tags:
  - 编译
  - C
  - C++
categories:
  - 编译工具
abbrlink: 74f3b3c3
---

在C代码中引用C++编译的库时，编译错误处理

<!--more-->

```
undefined reference to `std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::~basic_string()'
undefined reference to `std::allocator<char>::~allocator()'
undefined reference to `std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::~basic_string()'
undefined reference to `std::allocator<char>::~allocator()'
undefined reference to `std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::~basic_string()'
undefined reference to `std::allocator<char>::~allocator()'
undefined reference to `__cxa_free_exception'
undefined reference to `std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::~basic_string()'
undefined reference to `std::allocator<char>::~allocator()'
undefined reference to `std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::~basic_string()'
undefined reference to `std::allocator<char>::~allocator()'
undefined reference to `std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::~basic_string()'
undefined reference to `std::allocator<char>::~allocator()'
```
>链接时的错误信息

## 原因

### 编译器版本不兼容

添加编译选项

``` shell
-D_GLIBCXX_USE_CXX11_ABI=1
```
> cmake: `add_definitions(-D_GLIBCXX_USE_CXX11_ABI=1)`

### 未引用C++库

``` shell
-lstdc++
```
> camke: `target_link_libraries(exe_target stdc++)`
