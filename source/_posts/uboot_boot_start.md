---
title: uboot
date: 2018-03-19 23:07:24
categories: uboot
tags: [uboot, boot]
---


uboot引导系统启动, UBoot包含两个阶段的启动，一个是SPL启动，一个是正常的启动我们称为第二阶段Uboot。当然，我们也可以选择使用SPL和不使用，主要根据CPU中的SRAM（或者cache，bootram阶段需要初始化完成）的大小，如果不能放下uboot大小，则必须先使用SPL启动，进行DDR的初始化，以获取更大的可以空间。

```
+----------------+-----------------------------------+
|                |                                   |
|  spl           |             uboot                 |
|                |                                   |
+----------------+-----------------------------------+
```

在编译的过程中,这两个阶段通过`CONFIG_SPL_BUILD`宏将编译分离。拥有不同的配置，所以许多地方的宏是和SPL的不一样。而且链接的文件也不一致。
* SPL：
```
./arch/mips/cpu/xburst/x1000/u-boot-spl.lds
```
* uboot：
```
/arch/mips/cpu/u-boot.lds
```

<!--more-->

## 目的

![uboot stage](/images/uboot/uboot_stage.png)

## 流程:

![uboot boot](/images/uboot/uboot_boot.png)

## SPL
```
u-boot-spl.lds
ENTRY: _start (start.S)
		\->board_init_f (soc.c)
			->board_init_r (spl.c)
```
### u-boot-spl.lds

``` C
#define CONFIG_SPL_TEXT_BASE        0xf4001000                     
#define CONFIG_SPL_MAX_SIZE     (12 * 1024)                        
```
``` asm
MEMORY { .sram : ORIGIN = CONFIG_SPL_TEXT_BASE,\
		LENGTH = CONFIG_SPL_MAX_SIZE }

OUTPUT_ARCH(mips)
ENTRY(_start)
SECTIONS
{
	.text      :
	{
		__start = .;
		*(.start_section*)
		*(.text*)
	} >.sram
	...

	.bss : {                          
		. = ALIGN(4);                 
		__bss_start = .;              
		*(.sbss.*)                    
		*(.bss.*)                     
		*(COMMON)                     
		. = ALIGN(4);                 
		__bss_end = .;                
	} >.sram                          
	...
}
```
>[u-boot-spl.lds](/downloads/uboot/u-boot-spl.lds)

在bootram将SPL搬到静态ram中后，执行SPL的代码将从`_start`开始。

### start.S

``` C
#define CONFIG_SYS_SDRAM_BASE       0x80000000 /* cached (KSEG0) address */  
#define CONFIG_SYS_INIT_SP_OFFSET   0x400000   
```

```
#define RESERVED_FOR_SC(x) .space 1536, x

	.set noreorder

	.globl _start
	.section .start_section
_start:
	/* magic value ("MSPL") */
	.word 0x4d53504c
	.space 508, 0
	RESERVED_FOR_SC(0)

#ifdef CONFIG_SPL_VERSION
	.word (0x00000000 | CONFIG_SPL_VERSION)
	.space (512-20),0
#else
	.space (512-16),0
#endif

	/* Invalidate BTB */
	mfc0	v0, CP0_CONFIG, 7
	nop
	ori	v0, v0, 2 /* MMU类型：BAT类型*/
	mtc0	v0, CP0_CONFIG, 7
	nop

	/*
	 * CU0=UM=EXL=IE=0, BEV=ERL=1, IP2~7=1
	 */
	li	t0, 0x0040FC04
	mtc0	t0, CP0_STATUS

	/* CAUSE register */
	/* IV=1, use the specical interrupt vector (0x200) */
	li	t1, 0x00800000
	mtc0	t1, CP0_CAUSE

	.set push
	.set	mips32
init_caches:
	li	t0, CONF_CM_CACHABLE_NONCOHERENT
	mtc0	t0, CP0_CONFIG
	nop

	/* enable idx-store-data cache insn */
	li      t0, 0x20000000
	mtc0    t0, CP0_ECC

	li	t1, KSEG0		/* Start address */
#define CACHE_ALLOC_END (CONFIG_SYS_DCACHE_SIZE)

	ori     t2, t1, CACHE_ALLOC_END	/* End address */
	mtc0	zero, CP0_TAGLO, 0
	mtc0	zero, CP0_TAGLO, 1
cache_clear_a_line:
	cache   INDEX_STORE_TAG_I, 0(t1)
	cache   INDEX_STORE_TAG_D, 0(t1)
	addiu   t1, t1, CONFIG_SYS_CACHELINE_SIZE
	bne     t1, t2, cache_clear_a_line
	nop
	.set pop

	/* Set up stack */
#ifdef CONFIG_SPL_STACK
	li	sp, CONFIG_SPL_STACK
#endif

	j	board_init_f
	nop
```
>[start.S](/downloads/uboot/start.S)

1. 设置spl的空间布局,加载识别区域，SC填充区域等
2. 选择MMU类型
3. 通过SR，使能异常向量和配置中断屏蔽位
4. 配置一个特殊的中断异常入口（0x200） 
5. 初始化cache
6. 跳转`board_init_f`


### soc.c

#### board_init_f
``` C
void board_init_f(ulong dummy)
{
	/*Set global data pointer*/
	gd = &gdata;

	/*Setup global info*/
	gd->arch.gi = &ginfo;

	gpio_init();

	/*Init uart first*/
	enable_uart_clk();

#ifdef CONFIG_SPL_SERIAL_SUPPORT
	preloader_console_init();
#endif
	printf("ERROR EPC %x\n", read_c0_errorepc());

	debug("Timer init\n");
	timer_init();

#ifdef CONFIG_SPL_CORE_VOLTAGE
	debug("Set core voltage:%dmv\n", CONFIG_SPL_CORE_VOLTAGE);
	spl_regulator_set_voltage(REGULATOR_CORE, CONFIG_SPL_CORE_VOLTAGE);
#endif
#ifdef CONFIG_SPL_MEM_VOLTAGE
	debug("Set mem voltage:%dmv\n", CONFIG_SPL_MEM_VOLTAGE);
	spl_regulator_set_voltage(REGULATOR_MEM, CONFIG_SPL_MEM_VOLTAGE);
#endif

	debug("CLK stop\n");
	clk_prepare();

	debug("PLL init\n");
	pll_init();

	debug("CLK init\n");
	clk_init();

#ifdef CONFIG_HW_WATCHDOG
	debug("WATCHDOG init\n");
	hw_watchdog_init();
#endif
	debug("SDRAM init\n");
	sdram_init();

#ifdef CONFIG_DDR_TEST
	ddr_basic_tests();
#endif

	/*Clear the BSS*/
	memset(__bss_start, 0, (char *)&__bss_end - __bss_start);

	debug("board_init_r\n");
	board_init_r(NULL, 0);
}
```
>file: arch/mips/cpu/xburst/x1000/soc.c

1. 初始化GPIO
2. 使能串口时钟，初始化串口
3. 初始化timer
4. 初始化时钟,配置CPU，DDR和外设的时钟大小
5. 初始化看门狗
6. 初始化DDR
7. 清除BSS段

##### 为什么要清除BSS段？

``` C
/* Clear the BSS */                                      
memset(__bss_start, 0, (char *)&__bss_end - __bss_start);
```

>可执行程序包括BSS段、代码段、数据段。BSS（Block Started by Symbol）通常指用来存放程序中未初始化的全局变量和静态变量的一块内存区域，特点是可读可写，在程序执行之前BSS段会自动清0。所以，未初始化的全局变量在程序执行之前已经成0

bss段起源于unix中。变量分两种，`全局变量`和`局部变量`。局部变量是保留在栈中的，根据C语言规定，如果对局部变量不进行初始化，初始值是不确定的，在栈中位置也不固定。全局变量有专门的数据段存储，且初始化值为0，且位置是固定的。综上，数据分为俩种，`位置固定（全局，数据段）`，`位置不固定（局部-栈里）`。

其实，数据段里的这么多`全局变量都初始化为0存在目标文件中是没有必要的，增大了存储空间使用`。所以就把数据段里边数据，也即未初始化全局变量存放到了BSS段里边. 并未占有真正的空间。`当有目标文件被载入的时候，清除bss段，将全局变量清0`, 其实也是在为bss段分配空间.



#### board_init_r

``` C
void board_init_r(gd_t *dummy1, ulong dummy2)
{
	u32 boot_device;
	char *cmdargs = NULL;
	debug(">>spl:board_init_r()\n");

#ifdef CONFIG_SYS_SPL_MALLOC_START
	mem_malloc_init(CONFIG_SYS_SPL_MALLOC_START,
			CONFIG_SYS_SPL_MALLOC_SIZE);
#endif

#ifndef CONFIG_PPC
	/*
	 * timer_init() does not exist on PPC systems. The timer is initialized
	 * and enabled (decrementer) in interrupt_init() here.
	 */
	timer_init();
#endif

#ifdef CONFIG_SPL_BOARD_INIT
	spl_board_init();
#endif
	boot_device = spl_boot_device();
	debug("boot device - %d\n", boot_device);
#ifdef CONFIG_PALLADIUM
	spl_board_prepare_for_linux();
#endif
	switch (boot_device) {
	case BOOT_DEVICE_MMC1:
	case BOOT_DEVICE_MMC2:
	case BOOT_DEVICE_MMC2_2:
		spl_mmc_load_image();
		break;
	...
	default:
		debug("SPL: Un-supported Boot Device\n");
		hang();
	}

	switch (spl_image.os) {
	case IH_OS_U_BOOT:
		debug("Jumping to U-Boot\n");
		break;
#ifdef CONFIG_SPL_OS_BOOT
	case IH_OS_LINUX:
		debug("Jumping to Linux\n");
		spl_board_prepare_for_linux();

		cmdargs = cmdargs ? cmdargs : CONFIG_SYS_SPL_ARGS_ADDR;
		cmdargs = spl_board_process_bootargs(cmdargs);

		debug("get cmdargs: %s.\n", cmdargs);
		jump_to_image_linux((void *)cmdargs);
#endif
	default:
		debug("Unsupported OS image.. Jumping nevertheless..\n");
	}

	jump_to_image_no_args(&spl_image);
}
```
>file: common/spl/spl.c

1. 从存储介质（sd/emmc）读取uboot，并跳转到uboot执行
2. 在SPL运行完后，已可以直接加载kernel或相应的BIN文件执行

### 执行C代码所必需的条件或者环境？

``` C
la  sp, STACK_TOP   // sp         
j   main                          
nop                               
```
1. 禁止看门狗，防止CPU不断的重启
2. 设置堆栈

### SPL执行阶段其栈空间的位置？

```
    TCSM
	+-------------+ <-+ 0xb2400000
	|  .data .bss |       4K
	+----------+--+ <-+ 0xb2401000
	|    stack |  |       4K
	+----------v--+ <-+ 0xb2402000
	|             |
	|             |
	|             |
	|   load spl  |       24KB
	|             |
	|             |
	|             |
	|             |
	+-------------+ <-+ 0xb2408000
```

CPU上电后，在bootrom中执行时，由于其是固化的代码段（只读）。因此在上电初期将Data段，BSS段以及栈指定到TCSM中（一个静态RAM，CPU上电即可以使用）。bootrom中一些外围设备如sd boot的SD控制器等初始化完成后，在SD卡中将SPL加载到TCSM中，bootrom的PC跳入SPL进行执行，此时***依然使用bootrom的栈空间***。

## uboot
