---
title: uImage dump成反汇编
categories:
  - Linux内核
tags:
  - umage
  - 反汇编
abbrlink: 17694
date: 2017-10-28 23:07:24
---

> 通过Linux调试使用的uImage文件,进行反汇编查看CPU的具体执行指令

<!-- more -->

## uImage的组成

```
+------+-----------------------------+
|      |                             |
|  64k |          zImage             |
|      |                             |
+------+-----------------------------+
```

## 解压

如果时zImage可以直接进行解压操作

### 去除64k头信息

```
dd if=uImage of=Image.gz bs=1 skip=64
```
### zip解压

```
gunzip Image.gz
```
生成'Image',CPU执行的二进制代码

## 获取二进制的执行指令码

>通过gcc的工具将二进制的指令码反汇编,CPU的取指是以word进行,也就是每一个wrod对应一条指令

```C
#include<stdio.h>

int main(int argc, char *argv[])
{
    FILE *ifp = fopen(argv[1],"r");
	FILE *ofp = fopen(argv[2],"wt");
	fprintf(ofp,"#include <stdio.h>\n");
	fprintf(ofp,"int main(int argc, char *argv[])\n");
	fprintf(ofp,"{");
	fprintf(ofp,"\tasm volatile (");
	while(!feof(ifp)){
		unsigned int d;
		fread(&d,1,4,ifp);
		fprintf(ofp,"\t\t\".word 0x%08x   \\t\\n\"\n",d);
	}
	fprintf(ofp,"\t);");
	fprintf(ofp,"return 0;");
	fprintf(ofp,"}");
	fclose(ifp);
	fclose(ofp);
    return 0;
}
```
使用:

```
gcc m.c -o m

./m Image Image.c
```
Image.c

``` C
#include <stdio.h>
int main(int argc, char *argv[])
{	asm volatile (		".word 0x00000000   \t\n"
		".word 0x00000000   \t\n"
		".word 0x00000000   \t\n"
		".word 0x00000000   \t\n"
		".word 0x00000000   \t\n"
		".word 0x00000000   \t\n"
		...
	);

	return 0;
}
```
## 反汇编

```
$mips-linux-gnu-gcc Image.c -o Image
$mips-linux-gnu-objdump -Dz Image > Image.S
```

Image.S

```
00400640 <main>:
400640:   27bdfff8    addiu   sp,sp,-8
400644:   afbe0004    sw  s8,4(sp)
400648:   03a0f025    move    s8,sp
40064c:   afc40008    sw  a0,8(s8)
400650:   afc5000c    sw  a1,12(s8)
400654:   00000000    nop
...
400a54:   3c05805f    lui a1,0x805f <==== Load Address: 80010000
400a58:   3c06805f    lui a2,0x805f
400a5c:   aca404cc    sw  a0,1228(a1)
400a60:   24c60444    addiu   a2,a2,1092
400a64:   0804078d    j   101e34 <_DYNAMIC-0x2fe384>
400a68:   24a504cc    addiu   a1,a1,1228
400a6c:   3c028065    lui v0,0x8065
400a70:   90422000    lbu v0,8192(v0)

```
*注意*:无法进行函数跳转的判断

## 将PC指针替换成内核入口地址

```python
#!/usr/bin/env python

fp = open("Image.S","r")
iaddr = 0x80010000
flag = 0
for line in fp.readlines():
    if "400654: 00000000" in line:
        flag = 1
    if flag == 1:
        s = line.split(":")
        if len(s) > 1:
            addr = s[0]
            data = s[1]
            print("%08x:\t %s" % (iaddr,s[1])),
            iaddr = iaddr + 4
fp.close()
```

```
python a.py > uImage.S
```
*注意*:文件权限问题,可以无法读取文件数据

## 结果

### uImage.S

```
800103f8:       00000000    nop
800103fc:       00000000    nop
80010400:       3c05805f    lui a1,0x805f
80010404:       3c06805f    lui a2,0x805f
80010408:       aca404cc    sw  a0,1228(a1)
8001040c:       24c60444    addiu   a2,a2,1092
80010410:       0804078d    j   101e34 <_DYNAMIC-0x2fe384>
80010414:       24a504cc    addiu   a1,a1,1228
```
### vmlinux.S

```
80010400 <run_init_process>:
80010400:   3c05805f    lui a1,0x805f
80010404:   3c06805f    lui a2,0x805f
80010408:   aca404cc    sw  a0,1228(a1)
8001040c:   24c60444    addiu   a2,a2,1092
80010410:   0804078d    j   80101e34 <do_execve>
80010414:   24a504cc    addiu   a1,a1,1228

```
