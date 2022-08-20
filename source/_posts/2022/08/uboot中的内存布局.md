---
layout: post
title: uboot中的内存布局
date: '2022-08-16 14:47'
tags:
  - 内存
  - uboot
categories:
  - uboot
abbrlink: 3f3c28cc
---

arm64平台中spl+uboot的内存布局，比如代码段、堆栈等的位置。

- spl的大小限制，与堆栈大小的关系？
- 代码重定位？

<!--more-->

环境：
  - CPU： `arm64`（cortex-a53）
  - uboot版本： `U-Boot 2021.01`


## SPL

在uboot代码中，通过宏`CONFIG_SPL_XXX`来区分SPL。

### SRAM空间

SRAM是spl代码段、数据段的存储空间和运行空间，也就是所有的可操作的地址范围均在SRAM内，spl直接访问总线地址（物理地址）。

总大小`256KB`，地址范围`0xFF78 0000～0xFF7B FFFF`

bootrom将spl外部存储介质拷贝到SRAM中特定地址（SPL代码段基址），并从该该地址跳转执行spl代码。

### 自定义参数配置

spl编译生成后的大小限制，在menuconfig中进行配置：

```
CONFIG_SPL_SIZE_LIMIT=0x20000       #128KB

CONFIG_SPL_TEXT_BASE=0xFF781000

CONFIG_SPL_SYS_MALLOC_F_LEN=0x3000  #12KB
```
也就是说当前uboot中编译生成的spl大小不能超过128KB，如果超过时uboot会在编译过程中警告提示。

- `CONFIG_SPL_TEXT_BASE`: SPL中定义代码段基址
- `CONFIG_SPL_SIZE_LIMIT`: SPL中定义镜像大小的最大值
- `CONFIG_SPL_SYS_MALLOC_F_LEN`： SPL中定义堆栈空间的大小


代码段与栈大小配置：

```
/* Physical memory map */
#define CONFIG_IRAM_BASE            0xFF780000                    #spl代码中无用，只在当前配置文件中使用

#define CONFIG_SPL_MAX_SIZE         (SZ_128K - SZ_16K - SZ_4K)    #减4K ???，应该是想除去bootrom预留的4K
#define SPL_STACK_BSS_ADDRESS       (CONFIG_IRAM_BASE + SZ_128K )
#define CONFIG_SPL_BSS_MAX_SIZE     SZ_32K

#define CONFIG_SPL_STACK            (SPL_STACK_BSS_ADDRESS-16)    #栈地址减16(0x10)？？？

/*  BSS setup */
#define CONFIG_SPL_BSS_START_ADDR   SPL_STACK_BSS_ADDRESS
```
> uboot中的配置文件（include/configs/目录下）定义

- `CONFIG_SPL_MAX_SIZE`: spl镜像的最大大小，包括text, data, rodata, and linker lists sections，但是不包括BBS段
- `CONFIG_SPL_STACK`: spl栈的起始地址，**栈的增长方向：由高地址到低地址**
- `CONFIG_SPL_BSS_START_ADDR`: spl的BBS链接地址
- `CONFIG_SPL_BSS_MAX_SIZE`: 分配给spl BBS的内存最大值

### 未使用参数配置

- `CONFIG_SPL_MAX_FOOTPRINT`： 分配给SPL的最大内存大小，包括BSS。SPL链接器检查从`_start`到`__bss_end`使用的实际内存不超过它。`CONFIG_SPL_MAX_FOOTPRINT`和`CONFIG_SPL_BSS_MAX_SIZE`不能同时定义。
- `CONFIG_SYS_SPL_MALLOC_START`： SPL中使用的`malloc池`的起始地址。 当设置此选项时，在SPL中使用完整的malloc，在spl_init()函数之前，因为由它配置malloc池，如果定义了CONFIG_SYS_MALLOC_F，则可以使用简单的malloc()。
- `CONFIG_SYS_SPL_MALLOC_SIZE`： 配置SPL中malloc池的大小。

### u-boot-spl.lds

通用链接文件：`SPL_LDSCRIPT=arch/arm/cpu/u-boot-spl.lds`

链接文件的处理命令：

```
aarch64-none-linux-gnu-gcc -E -Wp,-MD,spl/.u-boot-spl.lds.d -D__KERNEL__ -D__UBOOT__  -DCONFIG_SPL_BUILD  -D__ARM__          
-mstrict-align  -ffunction-sections -fdata-sections -fno-common -ffixed-r9     
-fno-common -ffixed-x18 -pipe -march=armv8-a -D__LINUX_ARM_ARCH__=8  
-I./arch/arm/mach-vanxum/include -Ispl/include -Iinclude   -I./arch/arm/include -include ./include/linux/kconfig.h  
-nostdinc -isystem /home/xx/tools/prebuilts/aarch64-none-linux-gnu/bin/../lib/gcc/aarch64-none-linux-gnu/10.2.1/include
-include ./include/u-boot/u-boot.lds.h -include ./include/config.h -DCPUDIR=arch/arm/cpu/armv8  
-DIMAGE_MAX_SIZE="(SZ_64K + SZ_32K + SZ_16K -SZ_4K)" -DIMAGE_TEXT_BASE=0xFF781000
-ansi -D__ASSEMBLY__ -x assembler-with-cpp -std=c99 -P
-o spl/u-boot-spl.lds arch/arm/cpu/armv8/u-boot-spl.lds
```

编译后生产当前CPU的lds链接文件：
```
MEMORY { .sram : ORIGIN = 0xFF781000,
  LENGTH = (0x00010000 + 0x00008000 + 0x00004000 -0x00001000) }
MEMORY { .sdram : ORIGIN = (0xFF780000 + 0x00020000 ),
  LENGTH = 0x00008000 }
OUTPUT_FORMAT("elf64-littleaarch64", "elf64-littleaarch64", "elf64-littleaarch64")
OUTPUT_ARCH(aarch64)
ENTRY(_start)
SECTIONS
{
 .text : {
  . = ALIGN(8);
  *(.__image_copy_start)
  arch/arm/cpu/armv8/start.o (.text*)
  *(.text*)
 } >.sram
 .rodata : {
  . = ALIGN(8);
  *(SORT_BY_ALIGNMENT(SORT_BY_NAME(.rodata*)))
 } >.sram
 .data : {
  . = ALIGN(8);
  *(.data*)
 } >.sram
 .u_boot_list : {
  . = ALIGN(8);
  KEEP(*(SORT(.u_boot_list*)));
 } >.sram
 .image_copy_end : {
  . = ALIGN(8);
  *(.__image_copy_end)
 } >.sram
 .end : {
  . = ALIGN(8);
  *(.__end)
 } >.sram
 _image_binary_end = .;
 .bss_start (NOLOAD) : {
  . = ALIGN(8);
  KEEP(*(.__bss_start));
 } >.sdram
 .bss (NOLOAD) : {
  *(.bss*)
   . = ALIGN(8);
 } >.sdram
 .bss_end (NOLOAD) : {
  KEEP(*(.__bss_end));
 } >.sdram
 /DISCARD/ : { *(.dynsym) }
 /DISCARD/ : { *(.dynstr*) }
 /DISCARD/ : { *(.dynamic*) }
 /DISCARD/ : { *(.plt*) }
 /DISCARD/ : { *(.interp*) }
 /DISCARD/ : { *(.gnu*) }
}
```

### SARM的内存布局

![uboot SPL SRAM 布局](/images/2022/08/uboot_spl_sram_布局.png)
>空间大了，分配起来就是任性！
> 为了使SPL可用镜像尽可能的大，spl可以利用bootrom的堆栈空间，这样编译生成的spl镜像最大就可以到188KB

- BBS段定义的过大，实际`2K`应该就差不多了。
- 栈空间只指定了起始地址，为啥没有定义其大小？？
- malloc的地址范围？？？—— 当前SPL中没有配置这部分空间，因此也就无法使用malloc。


实际spl中各段的地址与大小：
```
$aarch64-none-linux-gnu-readelf -S spl/u-boot-spl
There are 21 section headers, starting at offset 0x1e7790:

Section Headers:
  [Nr] Name              Type             Address           Offset
       Size              EntSize          Flags  Link  Info  Align
  [ 0]                   NULL             0000000000000000  00000000
       0000000000000000  0000000000000000           0     0     0
  [ 1] .text             PROGBITS         00000000ff781000  00001000
       00000000000153b4  0000000000000000  AX       0     0     8
  [ 2] .rodata           PROGBITS         00000000ff7963b8  000163b8
       0000000000003f46  0000000000000000   A       0     0     8
  [ 3] .data             PROGBITS         00000000ff79a300  0001a300
       000000000000031c  0000000000000000  WA       0     0     8
  [ 4] .u_boot_list      PROGBITS         00000000ff79a620  0001a620
       0000000000000fd8  0000000000000000  WA       0     0     8
  [ 5] .image_copy_end   PROGBITS         00000000ff79b5f8  0001b5f8
       0000000000000000  0000000000000000   W       0     0     1
  [ 6] .end              PROGBITS         00000000ff79b5f8  0001b5f8
       0000000000000000  0000000000000000  WA       0     0     1
  [ 7] .bss_start        NOBITS           00000000ff7a0000  00020000
       0000000000000000  0000000000000000  WA       0     0     1
  [ 8] .bss              NOBITS           00000000ff7a0000  00020000
       00000000000003c0  0000000000000000  WA       0     0     64
  [ 9] .bss_end          NOBITS           00000000ff7a03c0  00020000
       0000000000000000  0000000000000000  WA       0     0     1
  [10] .debug_line       PROGBITS         0000000000000000  0001b5f8
       0000000000037991  0000000000000000           0     0     1
  [11] .debug_info       PROGBITS         0000000000000000  00052f89
       00000000000acbaa  0000000000000000           0     0     1
  [12] .debug_abbrev     PROGBITS         0000000000000000  000ffb33
       0000000000019c78  0000000000000000           0     0     1
  [13] .debug_aranges    PROGBITS         0000000000000000  001197b0
       0000000000006580  0000000000000000           0     0     16
  [14] .debug_str        PROGBITS         0000000000000000  0011fd30
       000000000001021b  0000000000000001  MS       0     0     1
  [15] .comment          PROGBITS         0000000000000000  0012ff4b
       000000000000005d  0000000000000001  MS       0     0     1
  [16] .debug_loc        PROGBITS         0000000000000000  0012ffa8
       000000000009a9f1  0000000000000000           0     0     1
  [17] .debug_ranges     PROGBITS         0000000000000000  001ca9a0
       0000000000010850  0000000000000000           0     0     16
  [18] .symtab           SYMTAB           0000000000000000  001db1f0
       0000000000008eb0  0000000000000018          19   1051     8
  [19] .strtab           STRTAB           0000000000000000  001e40a0
       000000000000361d  0000000000000000           0     0     1
  [20] .shstrtab         STRTAB           0000000000000000  001e76bd
       00000000000000cc  0000000000000000           0     0     1
Key to Flags:
  W (write), A (alloc), X (execute), M (merge), S (strings), I (info),
  L (link order), O (extra OS processing required), G (group), T (TLS),
  C (compressed), x (unknown), o (OS specific), E (exclude),
  p (processor specific)
```


### 实际BBS段大小

在spl的配置中，我们已经定义了BBS段的最大值，而是实际编译后的spl镜像中bbs段的实际大小是多少？

将spl镜像进行反汇编：
``` shell
$ aarch64-none-linux-gnu-objdump -D spl/u-boot-spl > a.s
```

清除BBS段内存：
```
/*
 * Clear BSS section
 */
    ldr x0, =__bss_start        /* this is auto-relocated! */
    ldr x1, =__bss_end          /* this is auto-relocated! */
clear_loop:
    str xzr, [x0], #8
    cmp x0, x1
    b.lo    clear_loop

    /* call board_init_r(gd_t *id, ulong dest_addr) */
    mov x0, x18             /* gd_t */
    ldr x1, [x18, #GD_RELOCADDR]    /* dest_addr */
    b   board_init_r            /* PC relative jump */
```
> file: /arch/arm/lib/crt0_64.S

其中`__bss_start`和`__bss_end`表示BBS段的起始和结束地址，这两个地址在lds链接文件中定义，实际编译时进行赋值。

反汇编后的实际结果：
```
00000000ff781708 <_main>:
    ff781708:   58000300    ldr x0, ff781768 <clear_loop+0x18>
    ff78170c:   927cec1f    and sp, x0, #0xfffffffffffffff0
    ff781710:   910003e0    mov x0, sp
    ...
    ff781744:   9100001f    mov sp, x0
    ff781748:   58000140    ldr x0, ff781770 <clear_loop+0x20>    #ldr x0, =__bss_start
    ff78174c:   58000161    ldr x1, ff781778 <clear_loop+0x28>    #ldr x1, =__bss_end

00000000ff781750 <clear_loop>:
    ...
    ff781768:   ff79fff0    .inst   0xff79fff0 ; undefined        #SPL栈的起始地址
    ff78176c:   00000000    udf #0
    ff781770:   ff7a0000    .inst   0xff7a0000 ; undefined        #BBS段的起始地址
    ff781774:   00000000    udf #0
    ff781778:   ff7a03c0    .inst   0xff7a03c0 ; undefined        #BBS段的结束地址
    ff78177c:   00000000    udf #0
```
BBS段的实际大小：0xff7a03c0 - 0xff7a0000 = 0x3c0 = `960Byte`

- bbs段的大小检测：
  ```
  #if defined(CONFIG_SPL_BSS_MAX_SIZE)
  ASSERT(__bss_end - __bss_start <= (CONFIG_SPL_BSS_MAX_SIZE), \
      "SPL image BSS too big");
  #endif
  ```
  > file: arch/arm/cpu/u-boot-spl.lds

### 堆栈空间的大小

```
#define CONFIG_SPL_STACK            (SPL_STACK_BSS_ADDRESS-16)    #栈地址减16(0x10)？？？
```
`CONFIG_SPL_STACK`指定栈的起始地址时减去了16Byte，是为了防止栈地址在进行`16Byte对齐`时越界。

spl的`_main`函数部分：
```
ENTRY(_main)
  ldr x0, =(CONFIG_SPL_STACK)

  bic sp, x0, #0xf    /* 16-byte alignment for ABI compliance */
  mov x0, sp
  bl  board_init_f_alloc_reserve
  mov sp, x0
  /* set up gd here, outside any C code */
  mov x18, x0
  bl  board_init_f_init_reserve

  mov x0, #0
  bl  board_init_f

  ...
```
> file: arch/arm/lib/crt0_64.S


在SPL为啥没有指定栈空间大小，难道不担心栈溢出或覆盖吗？？？

``` C
ulong board_init_f_alloc_reserve(ulong top)                                       
{                                                                               
    /* Reserve early malloc arena */                                            
#if CONFIG_VAL(SYS_MALLOC_F_LEN)                                                
    top -= CONFIG_VAL(SYS_MALLOC_F_LEN);                                        
#endif                                                                          
    /* LAST : reserve GD (rounded up to a multiple of 16 bytes) */              
    top = rounddown(top-sizeof(struct global_data), 16);                        

    return top;                                                                 
}                                                                               
```

```
CONFIG_SPL_SYS_MALLOC_F_LEN=0x3000  #12KB
```
因此`CONFIG_SPL_SYS_MALLOC_F_LEN`指定的`12KB`是栈空间大小。

同时`CONFIG_SPL_SYS_MALLOC_F_LEN`的目的也是为了在uboot将spl编译完后进行空间大小限制计算，防止运行过程中栈信息将代码段覆盖。

如果定义了`CONFIG_SPL_STACK_R`参数，将重定位堆栈信息，以上的确定的堆栈的起始地址，将发生变化。

### malloc

当前配置中没有使能malloc相关接口。

#### early malloc arena

``` C
void board_init_f_init_reserve(ulong base)    
{    
  ...                                         
  #if CONFIG_VAL(SYS_MALLOC_F_LEN)                    
    /* go down one 'early malloc arena' */          
    gd->malloc_base = base;                         
  #endif                                              
  ...
}
```
只定义了堆的起始地址。

如果想要使用malloc相关接口函数，需要增加其他配置，这里暂不做详细描述。


### SPL镜像的大小限制计算

在spl编译阶段会根据以上定义的相关配置，计算spl的大小与实际SARM空间之间的限制，如果超过SARM时将会报出警告。

```
ifneq ($(CONFIG_SPL_SIZE_LIMIT),0x0)
SPL_SIZE_CHECK = @$(call size_check,$@,$$(tools/spl_size_limit))
else
SPL_SIZE_CHECK =
endif
```
> file: Makefile

在Makefile进行spl实际大小与配置的限制大小的检测，如果不符合限制要求，将报警告提示。而最终的限制大小是由`spl_size_limit`程序计算而来。

``` C
int main(int argc, char *argv[])
{
    int spl_size_limit = 0;

#ifdef CONFIG_SPL_SIZE_LIMIT
    spl_size_limit = CONFIG_SPL_SIZE_LIMIT;

#ifdef CONFIG_SPL_SIZE_LIMIT_SUBTRACT_GD
    spl_size_limit -= GENERATED_GBL_DATA_SIZE;
#endif
#ifdef CONFIG_SPL_SIZE_LIMIT_SUBTRACT_MALLOC
    spl_size_limit -= CONFIG_SPL_SYS_MALLOC_F_LEN;
#endif
#ifdef CONFIG_SPL_SIZE_LIMIT_PROVIDE_STACK
    spl_size_limit -= CONFIG_SPL_SIZE_LIMIT_PROVIDE_STACK;
#endif
#endif

    printf("%d", spl_size_limit);
    return 0;
}
```
> file: tools/spl_size_limit.c

`CONFIG_SPL_SIZE_LIMIT`所限制的SPL大小，包含了堆栈空间的大小。

但是我认为在上面程序中应该减去BBS段的大小，这样剩余的空间就可以是代码段的大小，不然有可能spl过大导致代码段占用BBS段的空间，而使运行时出现异常。


### SPL的目的

- 初始化DDR，使用SRAM的小空间换去DDR的大空间。
- 加载uboot或kernel到DDR（大空间），并运行。

为了进行DDR的初始化，就需要进行`时钟`的初始化，以及`串口`（为了调试信息输出）


spl在内存初始化完成后，将uboot从外部存储介质拷贝到DDR中的特定地址（uboot代码段基址），并从该地址跳转执行uboot代码。

spl确定uboot代码段基址的方法，先读取1个block的头部信息，并解析出其中uboot的加载地址（代码段基址）。


## uboot

uboot的运行空间在DDR中，因此编译生成的镜像是对DDR地址空间的划分。

### DDR

DDR容量的大小由具体的产品定义，可以是1G或者2G等，但是存在一个DDR可用容量的最大值，外部选取的DDR不能超过该值。

DDR可用容量的最大值：由SOC内部总线地址（DDR物理地址）的映射关系决定。

比如，SOC内部DDR地址范围映射为`0x0000 0000 ～ 0xFBFF FFFF`，那么DDR的最大可用容量就为0xFBFFFFFF=3.9GB

- 如果外部选用DDR超过最大容量会咋样？？？

  涉及到的模块`DDR控制器`、`SOC内部总线地址宽度`


- 如果外部DDR超过最大容量后，对SPL中DDR的初始化是否存在影响？？？



### 配置参数


memconfig中定义的配置参数：
```
CONFIG_SYS_TEXT_BASE=0x00200000
CONFIG_SYS_MALLOC_F_LEN=0x3000  #12KB
```
- `CONFIG_SYS_TEXT_BASE`: 配置代码段基址
- `CONFIG_SYS_MALLOC_F_LEN`: 配置堆栈空间大小



配置文件中定义的配置参数：
```
#define CONFIG_SYS_SDRAM_BASE       0x00000000       

#define CONFIG_SYS_INIT_SP_ADDR     0x00300000       
#define CONFIG_SYS_MALLOC_LEN       SZ_32M                                                                

#define CONFIG_SYS_LOAD_ADDR        0x00880000     
#define CONFIG_SYS_BOOTM_LEN        SZ_64M
```
- `CONFIG_SYS_SDRAM_BASE`: 指定SDRAM的物理起始地址, **这里必须是0**
- `CONFIG_SYS_INIT_SP_ADDR`: 指定栈的起始地址
- `CONFIG_SYS_MALLOC_LEN`: 指定为malloc()使用保留的DRAM大小。
- `CONFIG_SYS_LOAD_ADDR`: 指定kernel在DRAM中的加载地址， ？？？
- `CONFIG_SYS_BOOTM_LEN`: 指定kernel镜像的大小，默认8M，可以根据实际需求修改比如64M。



### u-boot.lds

通用链接文件：`arch/arm/cpu/u-boot.lds`

链接文件的处理命令：
```
aarch64-none-linux-gnu-gcc -E -Wp,-MD,./.u-boot.lds.d -D__KERNEL__ -D__UBOOT__   -D__ARM__           
-fno-pic  -mstrict-align  -ffunction-sections -fdata-sections -fno-common -ffixed-r9     
-fno-common -ffixed-x18 -pipe -march=armv8-a -D__LINUX_ARM_ARCH__=8  
-I./arch/arm/mach-vanxum/include -Iinclude   -I./arch/arm/include -include ./include/linux/kconfig.h  
-nostdinc -isystem /home/xx/tools/prebuilts/aarch64-none-linux-gnu/bin/../lib/gcc/aarch64-none-linux-gnu/10.2.1/include
-ansi -include ./include/u-boot/u-boot.lds.h
-DCPUDIR=arch/arm/cpu/armv8  -D__ASSEMBLY__ -x assembler-with-cpp -std=c99 -P
-o u-boot.lds arch/arm/cpu/armv8/u-boot.lds
```

编译后生成的特有链接文件：
```
OUTPUT_FORMAT("elf64-littleaarch64", "elf64-littleaarch64", "elf64-littleaarch64")
OUTPUT_ARCH(aarch64)
ENTRY(_start)
SECTIONS
{
 . = 0x00000000;
 . = ALIGN(8);
 .text :
 {
  *(.__image_copy_start)
  arch/arm/cpu/armv8/start.o (.text*)
 }
 .efi_runtime : {
                __efi_runtime_start = .;
  *(.text.efi_runtime*)
  *(.rodata.efi_runtime*)
  *(.data.efi_runtime*)
                __efi_runtime_stop = .;
 }
 .text_rest :
 {
  *(.text*)
 }
 . = ALIGN(8);
 .rodata : { *(SORT_BY_ALIGNMENT(SORT_BY_NAME(.rodata*))) }
 . = ALIGN(8);
 .data : {
  *(.data*)
 }
 . = ALIGN(8);
 . = .;
 . = ALIGN(8);
 .u_boot_list : {
  KEEP(*(SORT(.u_boot_list*)));
 }
 . = ALIGN(8);
 .efi_runtime_rel : {
                __efi_runtime_rel_start = .;
  *(.rel*.efi_runtime)
  *(.rel*.efi_runtime.*)
                __efi_runtime_rel_stop = .;
 }
 . = ALIGN(8);
 .image_copy_end :
 {
  *(.__image_copy_end)
 }
 . = ALIGN(8);
 .rel_dyn_start :
 {
  *(.__rel_dyn_start)
 }
 .rela.dyn : {
  *(.rela*)
 }
 .rel_dyn_end :
 {
  *(.__rel_dyn_end)
 }
 _end = .;
 . = ALIGN(8);
 .bss_start : {
  KEEP(*(.__bss_start));
 }
 .bss : {
  *(.bss*)
   . = ALIGN(8);
 }
 .bss_end : {
  KEEP(*(.__bss_end));
 }
 /DISCARD/ : { *(.dynsym) }
 /DISCARD/ : { *(.dynstr*) }
 /DISCARD/ : { *(.dynamic*) }
 /DISCARD/ : { *(.plt*) }
 /DISCARD/ : { *(.interp*) }
 /DISCARD/ : { *(.gnu*) }
}
```
- 链接文件的开始地址为啥是`. = 0x00000000`？？？
- 地址是虚拟地址还是物理地址？？？
- 代码段基址是0x200000,链接文件开始地址是0？？？


### DDR的内存布局

![uboot内存划分](/images/2022/08/uboot内存划分.png)

uboot镜像的各段详细数据：
```
$aarch64-none-linux-gnu-readelf -S u-boot
There are 24 section headers, starting at offset 0x48ff90:

Section Headers:
  [Nr] Name              Type             Address           Offset
       Size              EntSize          Flags  Link  Info  Align
  [ 0]                   NULL             0000000000000000  00000000
       0000000000000000  0000000000000000           0     0     0
  [ 1] .text             PROGBITS         0000000000200000  00010000
       0000000000000158  0000000000000000  AX       0     0     8
  [ 2] .text_rest        PROGBITS         0000000000200800  00010800
       000000000005abfc  0000000000000000  AX       0     0     2048
  [ 3] .rodata           PROGBITS         000000000025b400  0006b400
       0000000000016f6e  0000000000000000   A       0     0     8
  [ 4] .hash             HASH             0000000000272370  00082370
       0000000000000018  0000000000000004   A       0     0     8
  [ 5] .data             PROGBITS         0000000000272388  00082388
       0000000000004688  0000000000000000  WA       0     0     8
  [ 6] .got              PROGBITS         0000000000276a10  00086a10
       0000000000000008  0000000000000008  WA       0     0     8
  [ 7] .got.plt          PROGBITS         0000000000276a18  00086a18
       0000000000000018  0000000000000008  WA       0     0     8
  [ 8] .u_boot_list      PROGBITS         0000000000276a30  00086a30
       0000000000002eb8  0000000000000000  WA       0     0     8
  [ 9] .rela.dyn         RELA             00000000002798e8  000898e8
       000000000000d428  0000000000000018   A       0     0     8
  [10] .bss_start        PROGBITS         0000000000286d10  00096d10
       0000000000000000  0000000000000000  WA       0     0     1
  [11] .bss              NOBITS           0000000000286d40  00096d10
       000000000000f988  0000000000000000  WA       0     0     64
  [12] .bss_end          PROGBITS         00000000002966c8  000a66c8
       0000000000000000  0000000000000000  WA       0     0     1
  [13] .debug_line       PROGBITS         0000000000000000  000a66c8
       0000000000078130  0000000000000000           0     0     1
  [14] .debug_info       PROGBITS         0000000000000000  0011e7f8
       000000000017ba49  0000000000000000           0     0     1
  [15] .debug_abbrev     PROGBITS         0000000000000000  0029a241
       00000000000349d3  0000000000000000           0     0     1
  [16] .debug_aranges    PROGBITS         0000000000000000  002cec20
       000000000000b3f0  0000000000000000           0     0     16
  [17] .debug_str        PROGBITS         0000000000000000  002da010
       000000000001e452  0000000000000001  MS       0     0     1
  [18] .comment          PROGBITS         0000000000000000  002f8462
       000000000000005d  0000000000000001  MS       0     0     1
  [19] .debug_loc        PROGBITS         0000000000000000  002f84bf
       0000000000145ff6  0000000000000000           0     0     1
  [20] .debug_ranges     PROGBITS         0000000000000000  0043e4c0
       0000000000026550  0000000000000000           0     0     16
  [21] .symtab           SYMTAB           0000000000000000  00464a10
       0000000000020568  0000000000000018          22   4116     8
  [22] .strtab           STRTAB           0000000000000000  00484f78
       000000000000af38  0000000000000000           0     0     1
  [23] .shstrtab         STRTAB           0000000000000000  0048feb0
       00000000000000e0  0000000000000000           0     0     1
Key to Flags:
  W (write), A (alloc), X (execute), M (merge), S (strings), I (info),
  L (link order), O (extra OS processing required), G (group), T (TLS),
  C (compressed), x (unknown), o (OS specific), E (exclude),
  p (processor specific)
```


### BBS段大小

BBS段在编辑阶段根据实际使用的大小确定，只是在uboot启动阶段将其对应的地址位置清除一下(与SPL中操作一样)。

```
000000000020180c <relocation_return>:                                          
  20180c:   97fffa3d    bl  200100 <c_runtime_cpu_setup>                       
  201810:   58000140    ldr x0, 201838 <clear_loop+0x20>                       
  201814:   58000161    ldr x1, 201840 <clear_loop+0x28>                       

0000000000201818 <clear_loop>:                                                 
  201818:   f800841f    str xzr, [x0], #8                                      
  20181c:   eb01001f    cmp x0, x1                                             
  201820:   54ffffc3    b.cc    201818 <clear_loop>  // b.lo, b.ul, b.last     
  201824:   aa1203e0    mov x0, x18                                            
  201828:   f9403a41    ldr x1, [x18, #112]                                    
  20182c:   14005304    b   21643c <board_init_r>                              
  201830:   00300000    .inst   0x00300000 ; NYI                               
  201834:   00000000    udf #0                                                 
  201838:   00286d10    .inst   0x00286d10 ; NYI       #__bss_start                        
  20183c:   00000000    udf #0                                                 
  201840:   002966c8    .inst   0x002966c8 ; NYI       #__bss_end                        
  201844:   00000000    udf #0                                                 
```

### 堆栈空间大小

栈空间的设置与SPL代码复用，只是配置参数不同，当前配置的栈大小相同，均为`12KB`

``` C
ulong board_init_f_alloc_reserve(ulong top)                               
{                                                                         
    /* Reserve early malloc arena */                                      
#if CONFIG_VAL(SYS_MALLOC_F_LEN)                                          
    top -= CONFIG_VAL(SYS_MALLOC_F_LEN);                                  
#endif                                                                    
    /* LAST : reserve GD (rounded up to a multiple of 16 bytes) */        
    top = rounddown(top-sizeof(struct global_data), 16);                  

    return top;                                                           
}                                                                         
```
> file: common/init/board_init.c

```
CONFIG_SYS_MALLOC_F_LEN=0x3000  #12KB
```

### malloc


#### early malloc arena

这部分malloc区域与栈空间共用，总大小12KB，栈空间向下增长，malloc向上增长。


#### malloc arena

在配置文件中定义了malloc的空间大小`CONFIG_SYS_MALLOC_LEN=SZ_32M`，那其地址范围是？？？，也就是堆的起始地址。

``` C
/*                                                                              
 * If the environment is in RAM, allocate extra space for it in the malloc      
 * region.                                                                      
 */                                                                             
#if defined(CONFIG_ENV_IS_EMBEDDED)                                             
#define TOTAL_MALLOC_LEN    CONFIG_SYS_MALLOC_LEN                               
#elif (CONFIG_ENV_ADDR + CONFIG_ENV_SIZE < CONFIG_SYS_MONITOR_BASE) || \        
      (CONFIG_ENV_ADDR >= CONFIG_SYS_MONITOR_BASE + CONFIG_SYS_MONITOR_LEN) || \
      defined(CONFIG_ENV_IS_IN_NVRAM)                                           
#define TOTAL_MALLOC_LEN    (CONFIG_SYS_MALLOC_LEN + CONFIG_ENV_SIZE)           
#else                                                                           
#define TOTAL_MALLOC_LEN    CONFIG_SYS_MALLOC_LEN                                     
#endif                                                                          
```
> file: include/env_internal.h

`CONFIG_SYS_MALLOC_LEN`指定的malloc的大小，可能也与环境变量空间大小一起划分，因此最终需要的内存空间大小为`TOTAL_MALLOC_LEN`。

``` C
static int initr_malloc(void)
{
  ...
  malloc_start = gd->relocaddr - TOTAL_MALLOC_LEN;                                                                                                                                                                                      
     mem_malloc_init((ulong)map_sysmem(malloc_start, TOTAL_MALLOC_LEN),          
             TOTAL_MALLOC_LEN);       
  ...                                 
}
```
在`initr_malloc`函数中对malloc进行初始化，此时可以其确定malloc的起始地址与`gd->relocaddr`相关。

``` C
static int setup_dest_addr(void)     
{                                    
  ...
#ifdef CONFIG_SYS_SDRAM_BASE                              
  gd->ram_base = CONFIG_SYS_SDRAM_BASE;                 
#endif                                                    
  gd->ram_top = gd->ram_base + get_effective_memsize();
  gd->ram_top = board_get_usable_ram_top(gd->mon_len);  
  gd->relocaddr = gd->ram_top;                          
  debug("Ram top: %08lX\n", (ulong)gd->ram_top);        

  ...
}
```
在`setup_dest_addr`中配置了`gd->ram_top`和`gd->relocaddr`的值。

get_effective_memsize获取有效的内存大小`gd->ram_size`, 而ram_size是解析设备树中的`memory`节点获取。

```
memory@00000000 {                  
    reg = <0x0 0x0 0x0 0x78000000>;
    device_type = "memory";        
};                                 
```
ram_size = 0x78000000 = 1920MB = 1.9GB


```
gd->ram_base = CONFIG_SYS_SDRAM_BASE = 0x0
gd->ram_top = 0x78000000
gd->relocaddr = 0x78000000
```

因此malloc区域的起始地址`malloc_start = 0x78000000 - SZ_32M`


### 代码重定位


### MMU


### Cache


### 虚拟物理地址映射


## 其他

### 编译步骤详细信息

在make后追加`V=1`

```
$make V=1 spl/u-boot-spl.bin
```

```
$make V=1 u-boot.lds
```

### asm-offset

```
int main(void)
{
    /* Round up to make sure size gives nice stack alignment */
    DEFINE(GENERATED_GBL_DATA_SIZE,
        (sizeof(struct global_data) + 15) & ~15);

    DEFINE(GENERATED_BD_INFO_SIZE,
        (sizeof(struct bd_info) + 15) & ~15);

    DEFINE(GD_SIZE, sizeof(struct global_data));

    DEFINE(GD_BD, offsetof(struct global_data, bd));
#if CONFIG_VAL(SYS_MALLOC_F_LEN)
    DEFINE(GD_MALLOC_BASE, offsetof(struct global_data, malloc_base));
#endif

    DEFINE(GD_RELOCADDR, offsetof(struct global_data, relocaddr));

    DEFINE(GD_RELOC_OFF, offsetof(struct global_data, reloc_off));

    DEFINE(GD_START_ADDR_SP, offsetof(struct global_data, start_addr_sp));

    DEFINE(GD_NEW_GD, offsetof(struct global_data, new_gd));

    return 0;
}
```
> file: lib/asm-offsets.c


### gd结构体的定义


## 参考

- [uboot启动流程——MIPS](https://winddoing.github.io/post/47503.html)
- [【u-boot-2018.11】make工具之fixdep](https://blog.csdn.net/linuxweiyh/article/details/100179968)
