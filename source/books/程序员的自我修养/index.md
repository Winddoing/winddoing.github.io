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
> - 在ELF的`链接视图`(编译)中,不同的属性称为`Section`
> - 在ELF的`装载视图`(运行)中,不同的属性称为`Segment`


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

1. `权限控制`, 当程序被装载后,数据和指令分别被映射到两个虚存区域.由于数据局域对进程来说是`可读写`的,指令区域对进程来说是`只读`的,所以这两个虚存区域的权限可以被分别设置成可读写和只读.这样可以**防止程序被有意或无意的修改.**
2. CPU的设计角度出发,现代CPU都有着缓存(Cache)体系.指令区和数据区的分离有利于提高程序的局部性.现代CPU的缓存一般都设计成**数据缓存(D-Cache)和指令缓存(I-Cache)分离,所以程序的指令和数据分开存放对CPU的缓存命中率提高有好处.**
3. `指令共享`, 当系统中运行多个该程序的副本时,它们的指令都是一样的,所以内存中只需要保存一份程序的指令部分.


## 挖掘SimpleSection.o

示例分析ELF格式的文件

``` C
/*#############################################################
 *     File Name	: SimpleSection.c
 *     Author		: winddoing
 *     Created Time	: 2018年12月18日 星期二 15时17分55秒
 *     Description	:
 *          gcc -c SimpleSection.c -o SimpleSection.o
 *          gcc version 7.3.0 (Ubuntu 7.3.0-27ubuntu1~18.04)
 *############################################################*/

int printf(const char* format, ...);

int global_init_var = 84;
int global_uninit_var;

void func1(int i)
{
    printf("%d\n", i);
}

int main(int argc, const char *argv[])
{
    static int static_var = 85;
    static int static_var2;

    int a = 1;
    int b;

    func1(static_var + static_var2 + a + b);

    return a;
}
```
系统环境: ubuntu18.04 64bit, gcc version 7.3.0

```
gcc -c SimpleSection.c -o SimpleSection.o
```
> `-c`: 表示只编译不链接


Object文件的内部结构:

```
$objdump -h SimpleSection.o
```
> - `-h`: 打印ELF文件各个段的基本信息
> - `-x`: 全部详细打印输出



``` C
SimpleSection.o:     file format elf64-x86-64

Sections:
Idx Name          Size      VMA               LMA               File off  Algn
  0 .text         0000005e  0000000000000000  0000000000000000  00000040  2**0
                  CONTENTS, ALLOC, LOAD, RELOC, READONLY, CODE
  1 .data         00000008  0000000000000000  0000000000000000  000000a0  2**2
                  CONTENTS, ALLOC, LOAD, DATA
  2 .bss          00000004  0000000000000000  0000000000000000  000000a8  2**2
                  ALLOC
  3 .rodata       00000004  0000000000000000  0000000000000000  000000a8  2**0
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  4 .comment      0000002b  0000000000000000  0000000000000000  000000ac  2**0
                  CONTENTS, READONLY
  5 .note.GNU-stack 00000000  0000000000000000  0000000000000000  000000d7  2**0
                  CONTENTS, READONLY
  6 .eh_frame     00000058  0000000000000000  0000000000000000  000000d8  2**3
                  CONTENTS, ALLOC, LOAD, RELOC, READONLY, DATA
```


|  Section Name | 注释  |
|:-:|:-:|
| .text  | 代码段  |
| .data  | 数据段  |
| .bss  | BSS段  |
| .rodata  | 只读数据段  |
| .comment  | 注释信息段  |
| .note.GNU-stack  | 堆栈提示段  |
| .eh_frame   | 展开堆栈所需的调用帧信息  |

> eh_frame,    http://blog.51cto.com/zorro/1034925


### ELF的结构

```
+----------------------+
|                      |
|                      |
|                      |
|      Other Data      |
|                      |
|                      |
|                      |
|                      |
+----------------------+ 0x0000 00d8
|       .eh_frame      |
+----------------------+ 0x0000 00d7
|                      |
|       .comment       |
|                      |
+----------------------+ 0x0000 00ac
|       .rodata        |
|                      |
+----------------------+ 0x0000 00a8
|        .data         |
+----------------------+ 0x0000 00a0
|                      |
|                      |
|        .text         |
|                      |
|                      |
+----------------------+ 0x0000 0040
|                      |
|     ELF Header       |
|                      |
+----------------------+ 0x0000 0000
```

查看ELF文件中代码段,数据段,和BSS段的长度,`size`命令

```
$size SimpleSection.o
   text	   data	    bss	    dec	    hex	filename
    186	      8	      4	    198	     c6	SimpleSection.o
```

### 代码段

```
$objdump -s -d SimpleSection.o
```
> - `-s`: 将所有段的内容以十六进制的方式打印出来
> - `-d`: 将所有包含指令的段反汇编

``` C
SimpleSection.o:     file format elf64-x86-64

Contents of section .text:
 0000 554889e5 4883ec10 897dfc8b 45fc89c6  UH..H....}..E...
 0010 488d3d00 000000b8 00000000 e8000000  H.=.............
 0020 0090c9c3 554889e5 4883ec20 897dec48  ....UH..H.. .}.H
 0030 8975e0c7 45f80100 00008b15 00000000  .u..E...........
 0040 8b050000 000001c2 8b45f801 c28b45fc  .........E....E.
 0050 01d089c7 e8000000 008b45f8 c9c3      ..........E...
Contents of section .data:
 0000 54000000 55000000                    T...U...
Contents of section .rodata:
 0000 25640a00                             %d..
Contents of section .comment:
 0000 00474343 3a202855 62756e74 7520372e  .GCC: (Ubuntu 7.
 0010 332e302d 32377562 756e7475 317e3138  3.0-27ubuntu1~18
 0020 2e303429 20372e33 2e3000             .04) 7.3.0.
Contents of section .eh_frame:
 0000 14000000 00000000 017a5200 01781001  .........zR..x..
 0010 1b0c0708 90010000 1c000000 1c000000  ................
 0020 00000000 24000000 00410e10 8602430d  ....$....A....C.
 0030 065f0c07 08000000 1c000000 3c000000  ._..........<...
 0040 00000000 3a000000 00410e10 8602430d  ....:....A....C.
 0050 06750c07 08000000                    .u......

Disassembly of section .text:

0000000000000000 <func1>:
   0:	55                   	push   %rbp
   1:	48 89 e5             	mov    %rsp,%rbp
   4:	48 83 ec 10          	sub    $0x10,%rsp
   8:	89 7d fc             	mov    %edi,-0x4(%rbp)
   b:	8b 45 fc             	mov    -0x4(%rbp),%eax
   e:	89 c6                	mov    %eax,%esi
  10:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # 17 <func1+0x17>
  17:	b8 00 00 00 00       	mov    $0x0,%eax
  1c:	e8 00 00 00 00       	callq  21 <func1+0x21>
  21:	90                   	nop
  22:	c9                   	leaveq
  23:	c3                   	retq

0000000000000024 <main>:
  24:	55                   	push   %rbp
  25:	48 89 e5             	mov    %rsp,%rbp
  28:	48 83 ec 20          	sub    $0x20,%rsp
  2c:	89 7d ec             	mov    %edi,-0x14(%rbp)
  2f:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  33:	c7 45 f8 01 00 00 00 	movl   $0x1,-0x8(%rbp)
  3a:	8b 15 00 00 00 00    	mov    0x0(%rip),%edx        # 40 <main+0x1c>
  40:	8b 05 00 00 00 00    	mov    0x0(%rip),%eax        # 46 <main+0x22>
  46:	01 c2                	add    %eax,%edx
  48:	8b 45 f8             	mov    -0x8(%rbp),%eax
  4b:	01 c2                	add    %eax,%edx
  4d:	8b 45 fc             	mov    -0x4(%rbp),%eax
  50:	01 d0                	add    %edx,%eax
  52:	89 c7                	mov    %eax,%edi
  54:	e8 00 00 00 00       	callq  59 <main+0x35>
  59:	8b 45 f8             	mov    -0x8(%rbp),%eax
  5c:	c9                   	leaveq
  5d:	c3                   	retq
```

### 数据段和只读数据段

- 数据段: `.data`主要存放`初始化`了的**全局静态变量**和**局部静态变量**
> 在SimpleSection.c示例中, 有这样两个变量`global_init_var`和`static_var`, 一共8字节,所以`.data`段的大小将是8字节

- 只读数据段: `.rodata`存放的只读数据.一般是程序中的**只读变量**(const修饰的变量)和**字符串常量**
> **好处:**
> - 操作系统在加载时,将`.rodata`段映射成只读后,任何对这个段的操作,将被视为非法操作,保证了程序的安全性
> - 在嵌入式平台中,有些存储器是采用的只读存储器,如ROM,这样将`rodata`段放在该存储区域就可以保证程序访问存储器的正确性(比如固化在CPU中的bootram的数据段映射)

``` shell
$objdump -s SimpleSection.o
```

``` C
Contents of section .data:
 0000 54000000 55000000                    T...U...
Contents of section .rodata:
 0000 25640a00                             %d..
```

`global_init_var=84`十六进制表示`54`,占四字节,由于是**小端模式Little Endian**, 排列顺序:[54 00 00 00]

### BBS段

- BBS段: `.bss`存放`未初始化`的**全局变量**和**局部静态变量**
> 在示例中`global_uninit_var`和`static_var2`两个变量将存放在BSS段,准确说就是.bss段为其预留空间,但是我们看到该段大小只有4字节,而这两个变量的大小是8字节.

不同的语言与不同的编译器实现有关,有些编译器会将**全局的未初始化变量**存放到BSS段,有些则不存放,只是预留一个**未定义的全局变量符号**,等到最终链接成可执行文件时,再在BSS段分配空间.(弱符号和强符号)

**编译单元内部可见的静态变量**(static修饰),的确存放在BSS段

``` shell
$objdump -h SimpleSection.o
```

``` C
Sections:
Idx Name          Size      VMA               LMA               File off  Algn
  2 .bss          00000004  0000000000000000  0000000000000000  000000a8  2**2
                  ALLOC
```

### 其他段

|    常用段名    | 说明                                                                        |
|:--------------:|:----------------------------------------------------------------------------|
|   `.rodata1`   | Read only Data 只存放只读数据,比如字符串常量,全局const变量,和`.rodata`一样  |
|   `.comment`   | 存放编译器版本信息,比如字符串:".GCC: (Ubuntu 7.3.0-27ubuntu1~18.04) 7.3.0." |
|    `.debug`    | 调试信息                                                                    |
|   `.dynamic`   | 动态链接信息                                                                |
|    `.hash`     | 符号哈希表                                                                  |
|    `.line`     | 调试时的行号表,即源代码行号与编译后指令的对应表                             |
|    `.note`     | 额外的编译器信息,比如程序的公司名,发布版本号                                |
|   `.strtab`    | String Table字符串表,用于存储ELF文件中用到的各种字符串                      |
|   `.symtab`    | Symbol Table符号表                                                          |
|  `.shstrtab`   | Section String Table 段名表                                                 |
| `.plt` `.got`  | 动态链接的跳转表和全局入口表                                                |
| `.init` `fini` | 程序初始化和终结代码段                                                      |

- 将一个二进制文件,比如图片,音乐作为目标文件中的一个段, 使用`objcopy`工具

``` shell
$objcopy -I binary -O elf64-x86-64  pic.jpg pic.o
```

``` shell
$objdump -ht pic.o
```

``` C
pic.o:     file format elf64-little

Sections:
Idx Name          Size      VMA               LMA               File off  Algn
  0 .data         000799df  0000000000000000  0000000000000000  00000040  2**0
                  CONTENTS, ALLOC, LOAD, DATA
SYMBOL TABLE:
0000000000000000 l    d  .data	0000000000000000 .data
0000000000000000 g       .data	0000000000000000 _binary_pic_jpg_start
00000000000799df g       .data	0000000000000000 _binary_pic_jpg_end
00000000000799df g       *ABS*	0000000000000000 _binary_pic_jpg_size
```
符号`_binary_pic_jpg_start`,`_binary_pic_jpg_end`,`_binary_pic_jpg_size`表示该图片文件所在内存中的起始地址,结束地址和大小.可以在程序中直接声明并使用它们.

### 自定义段

GCC提供的一种扩展机制,可以指定变量所处的段.

> 比如为了满足某些硬件的内存或IO地址布局,将某些变量或代码放到指定的段

在全局变量或函数前加`"__attribute__((section("name")))"`属性就可以把相应的变量或函数放到以`"name"`作为段名的段中
``` C
__attribute__((section("FOO"))) int global = 42;
__attribute__((section("BAR"))) void foo()
{

}
```

## ELF文件结构描述

```
+----------------------+
|     ELF Header       |
+----------------------+
|        .text         |
+----------------------+
|        .data         |
+----------------------+
|        .bss          |
+----------------------+
|        ...           |
+----------------------+
|    other sections    |
+----------------------+
| Section header table | <== 段表: 描述ELF文件所有段的信息
+----------------------+
|   String Tables      |
|                      |
|   Symbol Tables      |
|                      |
|                      |
+----------------------+
```

> ELF文件分析工具: `readelf`

### 头文件

``` shell
$readelf -h SimpleSection.o
```
> - `-h`: Display the ELF file header

```
头            ELF Header:
ELF魔数          Magic:   7f 45 4c 46 02 01 01 00 00 00 00 00 00 00 00 00
文件机器字节长度   Class:                             ELF64
数据存储方式      Data:                              2's complement, little endian
版本            Version:                           1 (current)
运行平台         OS/ABI:                            UNIX - System V
ABI版本         ABI Version:                       0
ELF重定位类型    Type:                              REL (Relocatable file)
硬件平台         Machine:                           Advanced Micro Devices X86-64
硬件平台版本      Version:                           0x1
入口地址         Entry point address:               0x0
程序入口         Start of program headers:          0 (bytes into file)
段表位置         Start of section headers:          1112 (bytes into file)
                Flags:                             0x0
                Size of this header:               64 (bytes)
                Size of program headers:           0 (bytes)
                Number of program headers:         0
                Size of section headers:           64 (bytes)
                Number of section headers:         13
                Section header string table index: 12
```

* 数据结构定义

``` C
typedef struct
{
  unsigned char e_ident[EI_NIDENT]; /* Magic number and other info */
  Elf64_Half    e_type;         /* Object file type */
  Elf64_Half    e_machine;      /* Architecture */
  Elf64_Word    e_version;      /* Object file version */
  Elf64_Addr    e_entry;        /* Entry point virtual address */
  Elf64_Off e_phoff;        /* Program header table file offset */
  Elf64_Off e_shoff;        /* Section header table file offset */
  Elf64_Word    e_flags;        /* Processor-specific flags */
  Elf64_Half    e_ehsize;       /* ELF header size in bytes */
  Elf64_Half    e_phentsize;        /* Program header table entry size */
  Elf64_Half    e_phnum;        /* Program header table entry count */
  Elf64_Half    e_shentsize;        /* Section header table entry size */
  Elf64_Half    e_shnum;        /* Section header table entry count */
  Elf64_Half    e_shstrndx;     /* Section header string table index */
} Elf64_Ehdr;
```
> file: /usr/include/elf.h

>**ELF魔数**: 最开始的4个字节所有的ELF文件 都必须相同,分别是`0x7f`,`0x45`,`0x4c`, `0x46`
> - 第一个字节对应ASCII字符: DEL字符
> - 后面3个字符对应ASCII字符: E, L, F

### 段表

**段表**:保存各个段的基本属性,描述各个段的信息,如段名,段的长度,在文件中的偏移,读写权限等

``` shell
$readelf -S SimpleSection.o
```
> - `-S`: Display the sections' header,每个段的头信息

```
There are 13 section headers, starting at offset 0x458:

Section Headers:
  [Nr] Name              Type             Address           Offset
       Size              EntSize          Flags  Link  Info  Align
  [ 0]                   NULL             0000000000000000  00000000
       0000000000000000  0000000000000000           0     0     0
  [ 1] .text             PROGBITS         0000000000000000  00000040
       000000000000005e  0000000000000000  AX       0     0     1
  [ 2] .rela.text        RELA             0000000000000000  00000348
       0000000000000078  0000000000000018   I      10     1     8
  [ 3] .data             PROGBITS         0000000000000000  000000a0
       0000000000000008  0000000000000000  WA       0     0     4
  [ 4] .bss              NOBITS           0000000000000000  000000a8
       0000000000000004  0000000000000000  WA       0     0     4
  [ 5] .rodata           PROGBITS         0000000000000000  000000a8
       0000000000000004  0000000000000000   A       0     0     1
  [ 6] .comment          PROGBITS         0000000000000000  000000ac
       000000000000002b  0000000000000001  MS       0     0     1
  [ 7] .note.GNU-stack   PROGBITS         0000000000000000  000000d7
       0000000000000000  0000000000000000           0     0     1
  [ 8] .eh_frame         PROGBITS         0000000000000000  000000d8
       0000000000000058  0000000000000000   A       0     0     8
  [ 9] .rela.eh_frame    RELA             0000000000000000  000003c0
       0000000000000030  0000000000000018   I      10     8     8
  [10] .symtab           SYMTAB           0000000000000000  00000130
       0000000000000198  0000000000000018          11    11     8
  [11] .strtab           STRTAB           0000000000000000  000002c8
       000000000000007c  0000000000000000           0     0     1
  [12] .shstrtab         STRTAB           0000000000000000  000003f0
       0000000000000061  0000000000000000           0     0     1
Key to Flags:
  W (write), A (alloc), X (execute), M (merge), S (strings), I (info),
  L (link order), O (extra OS processing required), G (group), T (TLS),
  C (compressed), x (unknown), o (OS specific), E (exclude),
  l (large), p (processor specific)
```

* 各段在文件的分布:
```
start +------------------+0x0000 0000
      |   ELF Header     |
      |   e_shoff=0x458 +--------------------+
      +------------------+0x0000 0040        |
      |                  |                   |
      |     .text        |                   |
      |                  |                   |
      +------------------+0x0000 00a0        |
      |     .data        |                   |
      +------------------+0x0000 00a8        |
      |     .rodata      |                   |
      +------------------+0x0000 00ac        |
      |                  |                   |
      |     .comment     |                   |
      +------------------+0x0000 00d7        |
      | .note.GNU|stack  |                   |
      +------------------+0x0000 00d8        |
      |     .eh_frame    |                   |
      |                  |                   |
      |                  |                   |
      |                  |                   |
      +------------------+0x0000 0130        |
      |     .symtab      |                   |
      |                  |                   |
      |                  |                   |
      |                  |                   |
      +------------------+0x0000 02c8        |
      |     .strtab      |                   |
      |                  |                   |
      |                  |                   |
      |                  |                   |
      +------------------+0x0000 0348        |
      |    .rela.text    |                   |
      |                  |                   |
      |                  |                   |
      +------------------+0x0000 03c0        |
      |  .rela.eh_frame  |                   |
      |                  |                   |
      |                  |                   |
      +------------------+0x0000 03f0        |
      |     .shstrtab    |                   |
      |                  |                   |
      |               <--+0x0000 0451        |
      |                  |                   |
      +------------------+0x0000 0458 <------+
      |                  |
      |   Section Table  |
      |                  |
      |                  |
      |                  |
      |                  |
      |                  |
 end  +------------------+0x0000 0798
```
> 文件大小:SimpleSection.o = 1944 = 0x798 Bit

**段的名字只是在编译和链接过程中有意义,不能正真代表段的类型**

- `.rela.text`: 重定位表(Relocation Table), 链接器处理目标文件时,对目标文件中的某些部位进行重定位,即代码段和数据段中那些绝对地址的引用位置.
- `.strtab`: 字符串表(String Table), 用于保存普通的字符串
- `.shstrtab`: 段表字符串表(Section Header String Table), 用于保存段表中用到的字符串

### 字符串表

ELF文件中对字符串的存储,由于不确定其长度,没有固定的结构进行表示.常用的做法是将字符串集中起来存放在一个表中,使用字符串在表中的偏移来引用字符串

- 字符串表:

| 偏移 | +0 | +1 | +2 | +3 | +4 | +5 | +6 | +7 | +8 | +9 |
|:----:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|
|  +0  | \0 | h  | e  | l  | l  | o  | w  | o  | r  | l  |
| +10  | d  | \0 | M  | y  | v  | a  | r  | i  | a  | b  |
| +20  | l  | e  | \0 |    |    |    |    |    |    |    |

- 引用

| 偏移 | 字符串     |
|:----:|:-----------|
|  0   | 空字符串   |
|  1   | helloworld |
|  6   | wrold      |
|  12  | Myvariable |

> 字符串表在ELF中以段的形式保存

|     段      | 段名                                      | 含义                       |
|:-----------:|:------------------------------------------|:---------------------------|
|  `.strtab`  | 字符串表(String  Table)                   | 用于保存普通字符串         |
| `.shstrtab` | 段表字符串表(Section Header String Table) | 用于保存段表中用到的字符串 |

## 链接的接口--符号

> 链接的本质就是把多个不同的目标文件(.o)之间相互"粘"到一起

在链接中,将函数和变量统称为`符号`(Symbol),函数名和变量名统称为`符号名`(Symbol Name)

### 特殊符号

| 符号  |  作用 |
|:-:|:-:|
| __executable_start  | 程序起始地址(注意不是程序入口地址,是程序最开始执行的地址)  |
| __etext\_etext\etext  | 代码段结束地址,即代码段最末尾的地址  |
| _edata\edata  | 数据段结束地址  |
| _end\end  | 程序结束地址  |

> 以上地址都是程序装载是的`虚拟地址`

### extern "C"

C++为了兼容C,在符号管理上使用`extern "C"`

``` C
extern "C" {
  int func(int);
  int var;
}
```

### 弱符号和强符号

|  名称  |     英文      | 示例                              |
|:------:|:-------------:|:----------------------------------|
| 弱符号 |  Weak Symbol  | 编译器默认,未初始化的全局变量     |
| 强符号 | Strong Symbol | 编译器默认,函数和初始化的全局变量 |

#### 弱符号的定义

通过GCC的`"__attribute__((weak))"`定义任何一个强符号为弱符号

``` C
extern int ext;

int weak;
int strong = 1;
__attribute__((weak)) weak2 = 2;

int main()
{
  return 0;
}
```

> - `weak`和`waek2`是弱符号
> - `strong`和`main`是强符号
> - `ext`既非强符号也非弱符号,其是一个外部变量的引用

#### 链接器的处理规则

* 规则1: 不允许强符号多次定义.
* 规则2: 如果一个符号在某一个目标文件中定义为强符号,在其他目标文件中定义为弱符号,那么选择强符号.
* 规则3: 如果一个符号在所有目标文件中都是弱符号,那么选择其中占用空间最大的一个.

### 强引用(Strong Reference)和弱引用(Weak Reference)

在GCC中，可以通过`__attribute__((weakref))`扩展关键字来声明一个外部函数的引用为弱引用

``` C
__attribute__((weakref)) void foo();

int main()
{
    return 0
}
```

**`弱符合`和`强符号`在库的定义使用中，弱符号可以被用户自定义的强符合所覆盖，从而使得程序可以使用自定义版本函数，方便程序扩展模块的裁剪和组合**

## 静态链接

> 将相同性质的段合并到一起，如所有输入文件的`.text`段合并到输出文件的`.text`段

### 链接

链接器一般采用`两步`链接：
- 第一步： 空间与地址分配
- 第二部： 符号解析与定位

```
$ld a.o b.o -e main -o ab
```
> - `-e main`: 表示将main函数作为程序入口，ld链接器默认的程序入口为`_start`

### ld链接脚本

> 控制链接过程，就是控制`输入段`如何变成`输出段`。

- 输入段（Input Section）： 输入文件中的段
- 输出段（Output Section）：输出文件中的段

#### ld链接脚本语法

链接脚本由一系列语句构成，语句分两种，一种是`命令语句`，另一种是`赋值语句`。

链接脚本语法与C语言相似：
- 语句之间使用分号“`；`”作为分隔符
- 表达式与运算符
  - `+`、 `-`、 `*`、 `/`、 `+=`、 `-=`、 `*=`、 `&`、 `|`、 `>>`、 `<<`
- 注释和字符引用
  - 注释：`/**/`

命令语句：

|        命令语句        | 说明                                                                                                                                 |
|:----------------------:|:-------------------------------------------------------------------------------------------------------------------------------------|
|     ENTRY(symbol)      | 指定符号的入口地址。入口地址即进程执行的第一条用户空间的指令所在进程地址空间的地址，它被指定在ELF文件头Elf32_Ehdr中的e_entry成员中。 |
|   STARTUP(filename)    | 将文件filename作为链接过程中的第一个输入文件                                                                                         |
|    SEARCH_DIR(path)    | 将路径path加入到ld链接器的库查找目录。与“`-Lpath`”命令作用相同                                                                       |
| INPUT(file, file, ...) | 将指定文件作为链接过程中的输入文件                                                                                                   |
|    INCLUDE filename    | 将指定文件包含到链接脚本                                                                                                             |
|    PROVIDE(symbol)     | 在链接脚本中定义某个符号                                                                                                             |

语法格式：
```
SECTIONS
{
    ...
    secname : {contents}
    ...
}
```
> secname: 表示输出段段名

#### 示例

```
ENTRY(nomain)
SECTIONS
{
    - = 0x08048000 + SIZEOF_HEADERS;

    tinytext : { *(.text) *(.data) *(.rodata)}

    /DISCARD/ : { *(.comment)}
}
```
解析：
- `ENTRY(nomain)`: 指定程序入口为nomain()函数
- `SECTIONS`： 链接脚本主体
- `. = 0x08048000 + SIZEOF_HEADERS`：将当前虚拟地址设置成0x08048000+SIZEOF_HEADERS, SIZEOF_HEADERS为输出文件头大小。
- `tinytext : { *(.text) *(.data) *(.rodata)}`： 段的转换，即为所以输入文件中的名字为".text" ".data" ".rodata"的段依次合并到输出文件的"tinytext"。
- `/DISCARD/ : { *(.comment)}`： 将所有输入文件中的".comment"的段丢弃，不保存到输出文件

***
# 装载与动态链接

## 可执行文件的装载与进程



***
# 库与运行库


***
# 工具

## gcc

### -fno-builtin

> 关闭内置函数优化选项

## objdump

## objcopy

## readelf

## nm

## strip

## ar

> 查看函数库里的详细情况和用多个对象文件生成一个库文件

```
$ar
Usage: ar [emulation options] [-]{dmpqrstx}[abcDfilMNoPsSTuvV] [--plugin <name>] [member-name] [count] archive-file file...
       ar -M [<mri-script]
 commands:
  d            - delete file(s) from the archive
  m[ab]        - move file(s) in the archive
  p            - print file(s) found in the archive
  q[f]         - quick append file(s) to the archive
  r[ab][f][u]  - replace existing or insert new file(s) into the archive
  s            - act as ranlib
  t            - display contents of archive
  x[o]         - extract file(s) from the archive
```

```
ar -t libname.a
```
> 显示所有对象文件(.o文件)的列表

```
ar -rv libname.a  objfile1.o objfile2.o ... objfilen.o
```
> 把objfile1.o--objfilen.o打包成一个库文件

## ld

```
ld --help
Usage: ld [options] file...
Options:
  -e ADDRESS: 指定程序入口
  -T FILE：读取链接脚本（*.ld）
```

***
