---
date: '2015-06-07 10:50'
layout: post
title: linux下字符串操作常用函数
thread: 166
categories:
  - 程序设计
tags:
  - 字符串
abbrlink: 43508
---

### 字符串长度函数
        size_t strlen(const char *string);
### 不受限制的字符串函数
        char *strcpy(char *dst, const char *src);
        char *strcat(char *dst, const char *src);
        int strcmp(const char *s1, const char *s2);
<!---more--->
### 字符串查找
        /*
         + 功能：查找字符串s中首次出现字符c的位置
         + 说明：返回首次出现c的位置的指针，如果s中不存在c则返回NULL。
         */
        char *strchr(const char *str, int ch);
        //同上
        char *strrchr(const char *str, int ch);

### 大小写字符转换函数
        int tolower(int ch);
        int toupper(int ch);
### 内存操作函数
        void *memcpy(void *dst, const void *src, size_t length);
        void *memmove(void *dst, const void *src, size_t length);
        void *memcmp(const void *a, const void *b, size_t length);
        void *memset(void *a, int ch, size_t length);

**不断更新**
