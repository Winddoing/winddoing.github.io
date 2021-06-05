---
layout: post
title: 'gcc编译参数：-Wl,-Bsymbolic与-Bsymbolic'
date: '2021-06-05 14:25'
tags:
  - gcc
  - bsymbolic
categories:
  - 编译工具
---

在实际应用中，编译C++代码时使用了`-Wl,-Bsymbolic`参数编译后生成的动态库文件，在被加载使用时出现错误
```
** Error in `.a.out': free(): invalid pointer: 0x0000000000414320 ***
======= Backtrace: =========
/lib64/libc.so.6(+0x81299)[0x7ff6d99a1299]
```
同样的代码，同样的编译参数，编译生成静态库可以正常使用，但是动态库只要运行时就报错。将`-Wl,-Bsymbolic`参数删除不用或者改为`-Bsymbolic`后，编译生成的动态库均可以正常使用，这两个参数对程序编译存在什么影响？

<!--more-->

## -Bsymbolic

正常情况下，在linux平台上(不使用-Bsymbolic)，加载的目标文件中第一次出现的符号将在程序中一直被使用，不论是定义在静态可执行部分，还是在动态目标文件中。这是通过符号抢占(symbol preemption)来实现的。动态加载器构建符号表，所有的动态符号根据该符号表被决议。所以正常情况下，如果一个符号实例出现在动态库（DSO）中，但是已经在静态可执行文件或者之前加载的动态库中被定义，那么以前的定义也将被用于当前的动态库中。

> Binds references to all global symbols in a program to the definitions within a user's shared library.

链接器选项`-Bsymbolic`可以与`-shared`一起使用。 ld -shared -Bsymbolic与-pie非常相似。

`-Bsymbolic`遵循ELF DF_SYMBOLIC语义：所有定义的符号都是不可抢占的，优先使用本地符号


## -Wl,-Bsymbolic

> -Wl,option
>   Pass option as an option to the linker. If option contains commas, it is split into multiple options at the commas. You can use this syntax to pass an argument to the option. For example, -Wl,-Map,output.map passes -Map output.map to the linker. When using the GNU linker, you can also get the same effect with -Wl,-Map=output.map.
> > https://gcc.gnu.org/onlinedocs/gcc/Link-Options.html#Link-Options

`-Wl,-Bsymbolic`其中Wl表示将紧跟其后的参数，传递给连接器ld。`Bsymbolic`表示强制采用本地的全局变量定义，这样就不会出现动态链接库的全局变量定义被应用程序/动态链接库中的同名定义给覆盖了

最开始的错误，可能是由于某一个全局对象生成相同的符号表后，在程序进行free时，多次free造成的。


## 参考

- [ELF interposition and -Bsymbolic](https://maskray.me/blog/2021-05-16-elf-interposition-and-bsymbolic)
- [Symbolism and ELF files (or, what does -Bsymbolic do?)](https://flameeyes.blog/2012/10/07/symbolism-and-elf-files-or-what-does-bsymbolic-do/)
- [Bsymbolic](https://software.intel.com/content/www/us/en/develop/documentation/cpp-compiler-developer-guide-and-reference/top/compiler-reference/compiler-options/compiler-option-details/linking-or-linker-options/bsymbolic.html#bsymbolic)
- [Option -Bsymbolic 会导致严重副作用](https://blog.csdn.net/weixin_41964962/article/details/107209950)
- [解决动态库的符号冲突](https://www.cnblogs.com/tcxa/p/14813372.html)
