---
title: 程序员的自我修养
date: 2018-09-17 10:07:24
comments: false
---

{% centerquote %} 程序员的自我修养  链接、装载与库 {% endcenterquote %}


# 温故而知新

## 内存不够怎么办

> 任何将计算机上有限的物理内存分配给多个程序使用

如果采用直接使用物理内存空间执行程序,存在一下问题:

1. 地址空间不隔离
>所有程序直接访问物理地址,程序所使用的内存空间不是相互隔离的,程序容易被有意或者无意的修改,使其崩溃.

2. 内存使用率低
>整个程序都加载到内存中占用大量空间,执行新的程序空间不足时,也需要换入换出大量数据.

3. 程序运行地址不确定
> 程序在编写时,其实是编译成可执行文件时,它访问数据和指令跳转时的目的地址很多都是固定的,地址不确定会造成很大麻烦.

** 解决方法: `增加中间层`** 使用一种间接的地址访问方法 --- `虚拟地址(Virtual Address)`

把程序给出的地址看作是一种虚拟地址,然后通过某些映射方法,将这个虚拟地址转换成实际的物理地址.


## 隔离

地址空间: 所谓地址空间是个比较抽象的概念,你可以把它想象成一个很大的数组,每个数组的元素是一个字节,而这个数组大小由地址空间的地址长度(地址线的个数)决定,比如32位地址空间大小为2^32=4 294 967 296字节,即4G

虚拟地址空间:指虚拟的,人们想象出来的地址空间,其实它并不存在,每一个进程都有自己独立的虚拟地址空间,而且每个进程只能访问自己的地址空间,这样就有效的做到了`进程的隔离`

### 分段(Segmentation)

> 基本思路: 把一段与程序所需要的内存空间大小的虚拟空间映射到某个地址空间

```
                                           +-------------------+
                                           |                   |
                                           |                   |
0x0640 0000+----------------XX             |                   |
           |                | XXXX         |                   |
           |                |    XXXXXXXXXXX-------------------+0x7000 0000
           |                |              |                   |         +
           |                |              |                   |         |
           |                |              |                   |         |
           |  Virtual Addr  |              |                   |         |
           |  Space of B    |              |      Physical     |         |
           |                |              |  Address Space    |         |
           |                |    map       |      of B         |         |
           |                |              |                   |         v
           |                |              |                   |       100MB
           |                |              |                   |         ^
           |                |              |                   |         |
           |                |              |                   |         |
           |                |              |                   |         |
0x0000 0000+----------------XXX            |                   |         |
                               XXXX        |                   |         |
                                  XXXX     |                   |         +
0x00A0 0000+----------------XX       XXXXXX+-------------------+0x00c0 0000
           |  Virtual Addr  |XXX           |                   |
           |  Apace of A    |  XXXXXXXXXXXXX-------------------+0x00B0 0000
           |                |              | Physical Address  |
0x0000 0000+----------------X    map       |    Space of A     |        10MB
                            XXXXX          |                   |
                                 XXXXXXXXXXX-------------------+0x0010 0000
                                           |                   |
                                           |                   |
                                           +-------------------+0x0000 0000
```

分段可以解决第一个和第三个问题.

1. **地址隔离**: 程序A和程序被映射到两块不同的物理空间区域，他们之间没有任何重叠．如果程序Ａ访问访问虚拟空间的地址超过了0x00A0 0000这个范围，那么硬件就会判断这是一个非法访问，拒绝这个地址请求，并将这个请求报告给操作系统或监控程序，由它决定处理．
2. **固定程序运行地址**：每个程序而言不需要关心虚拟地址与物理地址之间的映射，相当于其透明的，程序编写只需要按照从地址0x0000 0000到0x00A0 0000来编写程序，放置变量，程序不需要重定位．

### 分页(Paging)

分段是对整个程序而言，其换入换出将增加大量的磁盘访问操作,从而严重影响速度,因此利用`程序的局部性原理`使用更小粒度的内存分割和映射方法,就是`分页(Paging)`

> 分页的基本方法是把地址空间人为的等分成固定大小的页,每一页的大小由硬件决定,或硬件支持多种大小的页,由操作系统选择决定页的大小

页大小: MIPS 8K

#### Page Fault

![page_fault_flow](/images/2018/12/page_fault_flow.png)

> 进程的虚拟地址空间按`页`进行分割后,把常用的数据和代码页装载到内存中,把不常用的数据和代码页保存在磁盘中,当需要用到的时候再把它从磁盘中取出来即可.

假设进程`Process1`,`Process2`,他们进程中的部分虚拟页面被映射到了物理页面,比如VP0,VP1和VP7映射到PP0,PP2和PP3,但是一部分在磁盘中比如DP0,DP1.
- 如果程序运行时,只是有到了VP0,VP1和VP7的页空间,将不存在任何异常,程序正常运行
- 如果程序运行是,访问到了VP2和VP3的页空间,由于这两个页不在内存中,在磁盘中DP0和DP1中,因此硬件会捕获到这个信息,这就是`段错误(Page Fault)`

#### 页映射--数据保护

>在页映射时,可以对每个页设置权限属性,谁可以修改,谁可以访问,而只有操作系统有修改页属性的权利

> **Linux内核中如何实现???**

#### MMU (Memory Management Unit)

> CPU内部集成的一个硬件部件

```
+-------------+               +-----------+              +----------------+
|             |    Virtual    |           |   Physical   |    Physical    |
|     CPU     +--------------->    MMU    +-------------->     Memory     |
|             |    Address    |           |   Address    |                |
+-------------+               +-----------+              +----------------+
```
- 所谓CPU的`总线地址`大多数情况下就是指`物理地址`


## 线程 -- Thread

> **线程**: `执行流的最小单元`,有时也称`轻量级进程`,

- 一个标准的线程由`线程ID`,`当前指令指针(PC)`,`寄存器集合`和`堆栈`组成
- 通常,一个进程由一个到多个线程组成,各个线程之间共享程序的内存空间(包括代码段,数据段,堆等)及一些进程级资源(如打开文件和信号)

```
+--------------------------------------------------------------+
| +----------------------------------------------------------+ |
| |    代码     |     数据     |    进程空间      |   打开文件   | |
| +------------+--------------+----------------+-------------+ |
|                                                              |
|  +-------------+     +-------------+    +--------------+     |
|  | +---------+ |     | +---------+ |    | +----------+ |     |
|  | |  寄存器  | |     | | 寄存器   | |    | |  寄存器   | |     |
|  | +---------+ |     | +---------+ |    | +----------+ |     |
|  |             |     |             |    |              |     |
|  | +---------+ |     | +---------+ |    | +----------+ |     |
|  | |   栈    | |     | |    栈    | |    | |   栈     | |     |
|  | +---------+ |     | +---------+ |    | +----------+ |     |
|  |             |     |             |    |              |     |
|  |             |     |             |    |              |     |
|  |             |     |             |    |              |     |
|  |             |     |             |    |              |     |
|  |             |     |             |    |              |     |
|  |             |     |             |    |              |     |
|  |             |     |             |    |              |     |
|  |             |     |             |    |              |     |
|  |             |     |             |    |              |     |
|  |             |     |             |    |              |     |
|  | Main Thread |     |   Thread 1  |    |   Thread 2   |     |
|  +-------------+     +-------------+    +--------------+     |
+--------------------------------------------------------------+
```

### 线程的访问权限

| 线程私有 | 线程之间共享(进程所有)                      |
|:--------:|:--------------------------------------------|
| 局部变量 | 全局变量                                    |
| 函数参数 | 堆上的数据                                  |
| TLS数据  | 函数里的静态变量                            |
|    -     | 程序代码,任何线程都有权利读取并执行任何代码 |
|    -     | 打开的文件, A线程打开的文件可以由线程B读写  |

### 线程调度

线程的三种状态:
- **运行(Runing)**: 此时线程正在执行
- **就绪(Ready)**: 此时线程可以立刻运行,但是CPU已经被占用
- **等待(Wait)**: 此时线程正在等待某一事件(通常指I/O或同步)发生,无法执行

```
                 无运行线程,且本线程被选中
     +------------------------------------------+
     |                                          |
     |                                          |
     |                                          |
     |                                          |
+----v-----+                              +-----+-----+
|          |         时间片用尽             |           |
|  Runing  +------------------------------>   Ready   |
|          |                              |           |
+----+-----+                              +-----^-----+
     |                                          |
     |                                          |
 开始等待                                      等待结束
     |                                          |
     |             +----------+                 |
     |             |          |                 |
     +------------->   Wait   +-----------------+
                   |          |
                   +----------+
```

### 线程安全

>多线程并发执行时,数据的一致性

#### 竞争与原子操作

- 原子(Atomic):指单指令操作

#### 锁与同步

1. **二元信号量**: 最简单的一种锁,它只有两种状态:`占用`与`非占用`.适用只能被唯一一个线程独占访问的资源
2. **互斥量(Mutex)**:与二元信号量类似,资源仅同时允许一个线程访问,但是互斥量是哪个线程获取互斥量,必须哪个线程释放互斥量
3. **临界区**:互斥量保护的范围,就是临界区
4. **读写锁**:读写锁两种获取方式`共享的(Shared)`和`独占的(Exclusive)`,适用频繁读取,只是偶尔写入的场景
5. **条件变量**: 类似于一个栅栏,一个条件变量可以被多个线程等待,当时间发生时(条件变量被唤醒),所有线程可以一起恢复执行

### 可重入(Reentrant)与线程安全

一个函数可重入的**特点**:

1. 不使用任何(局部)静态或全局的非const变量
2. 不使用任何(局部)静态或全局的非const变量的变量
3. 仅依赖调用函数提供的参数
4. 不依赖任何单个资源的锁(mutex等)
5. 不调用任何不可重入函数


### 过度优化

过度优化带来的问题:
1. `编译器调整顺序`:编译器为提高执行速度,将一些结果保存临时寄存器中
2. `CPU动态调度换序`: CPU的动态调度,在执行过程中,为了提高效率,几个互补相关的指令,可能被交换执行,或者同时执行

解决方法:
1. `volatile`关键字阻止过度优化
    - 阻止编译器为了提高速度将一个变量缓存到寄存器不写回
    - 阻止编译器调整操作volatile变量的指令顺序
2. `barrier`指令, 一条barrier指令会阻止CPU将该指令之前的指令交换到barrier指令之后,也就是说CPU执行到barrier指令时,前面的所有指令已经执行完成


***
# 静态链接

## GCC编译过程
```
$gcc hello.c
```
>编译的过程可以分解成4个步骤:`预处理(Prepressing)`,`编译(Compilation)`,`汇编(Assembly)`和`链接(Linking)`

![Gcc编译过程](/images/2018/12/gcc编译过程.png)

### 预编译-Prepressing

```
gcc -E hello.c -o hello.i
或
cpp hello.c > hello.i
```
预编译过程主要处理源代码中以`"#"`开始的预编译指令.比如"#include", "#define"

处理规则:
* 将所有的`"#define"`删除,并且展开所有的宏定义
* 处理所有条件预编译指令,比如`"#if"`, `"ifdef"`, `"#elif"`, `"#else"`, `"#endif"`
* 处理`"#include"`预编译指令,将包含的文件插入到该预编译指令的位置,注意这个过程是递归进行的,也就是说被包含的文件可能还包含其他文件
* 删除所有注释`"//"`和`"/* */"`
* 添加行号和文件标识,比如#2 "hello.c" 2,以便于编译时编译器产生调试用的行号信息及用于编译时产生编译错误和警告时能够显示行号
* 保留所有的`"#pragma"`编译器指令,因为编译器需要使用它们

### 编译-Compilation

```
gcc -S hello.i -o hello.s
```

编译的过程就是把预处理完的文件进行一系列词法分析,语法分析,语义分析及优化后生成相应的汇编代码文件

### 汇编-Assembly

```
gcc -c hello.s -o hello.o
或
as hello.s -o hello.o
```

### 链接-Linking

通过`ld`链接一些必要的文件使其生成一个可执行文件


### 示例: Gcc 7.3.0

环境编译器及系统: `gcc version 7.3.0 (Ubuntu 7.3.0-27ubuntu1~18.04)`

```
gcc hello.c -v
```
- `-v`: 显示编译器调用处理的细节
- `-save-temps`: 不删除中间临时文件,如\*.i, \*.s


```
=====>$gcc hello.c -v  -save-temps
Using built-in specs.
COLLECT_GCC=gcc
COLLECT_LTO_WRAPPER=/usr/lib/gcc/x86_64-linux-gnu/7/lto-wrapper
OFFLOAD_TARGET_NAMES=nvptx-none
OFFLOAD_TARGET_DEFAULT=1
Target: x86_64-linux-gnu
Configured with: ../src/configure -v --with-pkgversion='Ubuntu 7.3.0-27ubuntu1~18.04' --with-bugurl=file:///usr/share/doc/gcc-7/README.Bugs --enable-languages=c,ada,c++,go,brig,d,fortran,objc,obj-c++ --prefix=/usr --with-gcc-major-version-only --program-suffix=-7 --program-prefix=x86_64-linux-gnu- --enable-shared --enable-linker-build-id --libexecdir=/usr/lib --without-included-gettext --enable-threads=posix --libdir=/usr/lib --enable-nls --with-sysroot=/ --enable-clocale=gnu --enable-libstdcxx-debug --enable-libstdcxx-time=yes --with-default-libstdcxx-abi=new --enable-gnu-unique-object --disable-vtable-verify --enable-libmpx --enable-plugin --enable-default-pie --with-system-zlib --with-target-system-zlib --enable-objc-gc=auto --enable-multiarch --disable-werror --with-arch-32=i686 --with-abi=m64 --with-multilib-list=m32,m64,mx32 --enable-multilib --with-tune=generic --enable-offload-targets=nvptx-none --without-cuda-driver --enable-checking=release --build=x86_64-linux-gnu --host=x86_64-linux-gnu --target=x86_64-linux-gnu
Thread model: posix
gcc version 7.3.0 (Ubuntu 7.3.0-27ubuntu1~18.04)
COLLECT_GCC_OPTIONS='-v' '-save-temps' '-mtune=generic' '-march=x86-64'
 /usr/lib/gcc/x86_64-linux-gnu/7/cc1 -E -quiet -v -imultiarch x86_64-linux-gnu hello.c -mtune=generic -march=x86-64 -fpch-preprocess -fstack-protector-strong -Wformat -Wformat-security -o hello.i
ignoring nonexistent directory "/usr/local/include/x86_64-linux-gnu"
ignoring nonexistent directory "/usr/lib/gcc/x86_64-linux-gnu/7/../../../../x86_64-linux-gnu/include"
#include "..." search starts here:
#include <...> search starts here:
 /usr/lib/gcc/x86_64-linux-gnu/7/include
 /usr/local/include
 /usr/lib/gcc/x86_64-linux-gnu/7/include-fixed
 /usr/include/x86_64-linux-gnu
 /usr/include
End of search list.
COLLECT_GCC_OPTIONS='-v' '-save-temps' '-mtune=generic' '-march=x86-64'


 /usr/lib/gcc/x86_64-linux-gnu/7/cc1 -fpreprocessed hello.i -quiet -dumpbase hello.c -mtune=generic -march=x86-64 -auxbase hello -version -fstack-protector-strong -Wformat -Wformat-security -o hello.s
GNU C11 (Ubuntu 7.3.0-27ubuntu1~18.04) version 7.3.0 (x86_64-linux-gnu)
	compiled by GNU C version 7.3.0, GMP version 6.1.2, MPFR version 4.0.1, MPC version 1.1.0, isl version isl-0.19-GMP

GGC heuristics: --param ggc-min-expand=100 --param ggc-min-heapsize=131072
GNU C11 (Ubuntu 7.3.0-27ubuntu1~18.04) version 7.3.0 (x86_64-linux-gnu)
	compiled by GNU C version 7.3.0, GMP version 6.1.2, MPFR version 4.0.1, MPC version 1.1.0, isl version isl-0.19-GMP

GGC heuristics: --param ggc-min-expand=100 --param ggc-min-heapsize=131072
Compiler executable checksum: c8081a99abb72bbfd9129549110a350c
COLLECT_GCC_OPTIONS='-v' '-save-temps' '-mtune=generic' '-march=x86-64'


 as -v --64 -o hello.o hello.s
GNU assembler version 2.30 (x86_64-linux-gnu) using BFD version (GNU Binutils for Ubuntu) 2.30
COMPILER_PATH=/usr/lib/gcc/x86_64-linux-gnu/7/:/usr/lib/gcc/x86_64-linux-gnu/7/:/usr/lib/gcc/x86_64-linux-gnu/:/usr/lib/gcc/x86_64-linux-gnu/7/:/usr/lib/gcc/x86_64-linux-gnu/
LIBRARY_PATH=/usr/lib/gcc/x86_64-linux-gnu/7/:/usr/lib/gcc/x86_64-linux-gnu/7/../../../x86_64-linux-gnu/:/usr/lib/gcc/x86_64-linux-gnu/7/../../../../lib/:/lib/x86_64-linux-gnu/:/lib/../lib/:/usr/lib/x86_64-linux-gnu/:/usr/lib/../lib/:/usr/lib/gcc/x86_64-linux-gnu/7/../../../:/lib/:/usr/lib/
COLLECT_GCC_OPTIONS='-v' '-save-temps' '-mtune=generic' '-march=x86-64'

 /usr/lib/gcc/x86_64-linux-gnu/7/collect2 -plugin /usr/lib/gcc/x86_64-linux-gnu/7/liblto_plugin.so -plugin-opt=/usr/lib/gcc/x86_64-linux-gnu/7/lto-wrapper -plugin-opt=-fresolution=hello.res -plugin-opt=-pass-through=-lgcc -plugin-opt=-pass-through=-lgcc_s -plugin-opt=-pass-through=-lc -plugin-opt=-pass-through=-lgcc -plugin-opt=-pass-through=-lgcc_s --sysroot=/ --build-id --eh-frame-hdr -m elf_x86_64 --hash-style=gnu --as-needed -dynamic-linker /lib64/ld-linux-x86-64.so.2 -pie -z now -z relro /usr/lib/gcc/x86_64-linux-gnu/7/../../../x86_64-linux-gnu/Scrt1.o /usr/lib/gcc/x86_64-linux-gnu/7/../../../x86_64-linux-gnu/crti.o /usr/lib/gcc/x86_64-linux-gnu/7/crtbeginS.o -L/usr/lib/gcc/x86_64-linux-gnu/7 -L/usr/lib/gcc/x86_64-linux-gnu/7/../../../x86_64-linux-gnu -L/usr/lib/gcc/x86_64-linux-gnu/7/../../../../lib -L/lib/x86_64-linux-gnu -L/lib/../lib -L/usr/lib/x86_64-linux-gnu -L/usr/lib/../lib -L/usr/lib/gcc/x86_64-linux-gnu/7/../../.. hello.o -lgcc --push-state --as-needed -lgcc_s --pop-state -lc -lgcc --push-state --as-needed -lgcc_s --pop-state /usr/lib/gcc/x86_64-linux-gnu/7/crtendS.o /usr/lib/gcc/x86_64-linux-gnu/7/../../../x86_64-linux-gnu/crtn.o
COLLECT_GCC_OPTIONS='-v' '-save-temps' '-mtune=generic' '-march=x86-64'
```
**注意**:在链接时使用的是`collect2`,不是`ld`,那么二者有什么关系??

>`collect2`是`ld`链接器的一个`封装`,最终还是要调用ld来完成链接工作,collect2的作用是在实现main函数的代码前对目标文件中命名的特殊符号进行收集. 这些特殊的符号表明它们是全局构造函数或在main前执行，collect2会生成一个临时的.c文件，将这些符号的地址收集成一个数组，然后放到这个.c文件里面，编译后与其他目标文件一起被链接到最终的输出文件中。在这里我们没有加-nostdlib,所以自然不会调用__main,也就不会链接main函数所需引用的目标文件,也就不会对那些特殊的符号进行收集.


## 目标文件--Object File

目标文件及可执行文件,主要格式Windows下`PE(Portable Executable)`和Linux的`ELF(Executable Linkable Format)`,他们都是`COFF(Common file format)`的变种

>可执行文件按照可执行文件格式存储,`动态链接库(DLL, Dynamic Linking Library)`及`静态链接库(Static Linking Library)`文件都是按照可执行文件格式存储

### 文件格式-ELF

* ELF格式文件分类:

| ELF文件类型  | 说明  | 示例  |
|:-:|:-:|:-:|
| 可重定位文件(Relocatablr File)  | 包含代码和数据,可以被用来链接成可执行文件或共享目标文件,`静态链接库属于这类`  |  Linux的.o, Windows的.obj |
| 可执行文件(Executable File)  | 包含可以直接执行的程序,它的代表就是ELF可执行文件,一般没有扩展名  | 比如/bin/bash文件, Windows的.exe  |
| 共享目标文件(Share Object File)  | 包含代码和数据,可以在两种情况下使用,一种链接器使用生成目标文件,另一种动态链接器可以将几个共享目标文件和可执行文件结合,作为进程映像一起运行  | Linux的.so, Windows的DLL  |
| 核心转储文件(Core Dump File)  | 当进程意外终止时,系统可以将该进程的地址空间内容及终止时的一些其他信息转存到核心转储文件  | Linux下的core dump  |

* 查看

```
=====>$file a.out
a.out: ELF 64-bit LSB shared object, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, for GNU/Linux 3.2.0, BuildID[sha1]=fadad58a4fd9204e015da490f57908c27ba46ccf, not stripped
```

### ELF的格式

目标文件的内容包含代码和数据,还有链接时必要的一些信息,比如符号表,调试信息,字符串等.一般目标文件将这些信息按不同的属性,以`"节"(Section)`的形式存储,有时候也就`"段"(Segment)`,在一般情况下都表示一个一定长度的区域

> `Section`与`Segment`的区别:???
> - 在ELF的`链接视图`中,不同的属性称为`Section`
> - 在ELF的`装载视图`中,不同的属性称为`Segment`


ELF文件:

| Executable File / Object File | 说明                                         |
|:-----------------------------:|:---------------------------------------------|
|          File Header          | 包含一个`段表(Section Table)`                |
|         .text section         | 代码段, 机器指令                             |
|         .data section         | 数据段, 全局变量和局部静态变量数据           |
|         .bss section          | 未初始化的全局变量和局部静态变量,默认值为`0` |

**注**:
- `段表`,是一个描述文件中各个段的数组,描述了文件中各个段在文件中的偏移位置及段的属性等
- `.bss`, 只是为未初始化的全局变量和局部静态变量预留位置而已,它并没有内容,所以它在文件中也不占空间

**总体来说,程序源代码被编译后主要分成两种段, `程序指令`和`程序数据`,代码段属于程序指令,而数据段和.bss段 属于程序数据**

### 数据和指令分段的好处



***
# 装载与动态链接


***
# 库与运行库


***
