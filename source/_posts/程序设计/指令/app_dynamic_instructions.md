---
title: 动态指令
categories:
  - 程序设计
  - 指令
tags:
  - 指令
abbrlink: 40422
date: 2018-03-13 23:07:24
---

通过程序动态生成指令，然后进行执行

```
 +------------> +-------+ <--+生成指令，写入buffer
 |              |       |
 +              |       |
PC              |       |
                | buffer|
                |       |
                |       |
                |       |
                +-------+
```

<!--more-->


``` C
uint32_t *InstBuf;
InstBuf = (uint32_t)malloc(size);

for (int i = 0; i < 16: i++) {
	InstBuf[i] = 0x03e00008; /* JR RA */
}

void (*f)(void);
f = (void (*)(void))(InstBuf);
(*f)();
```


