---
title: uboot
date: 2018-03-19 23:07:24
categories: uboot
tags: [uboot, boot]
---

Bootloader 是在操作系统运行之前执行的一段小程序。通过这段小程序，我们可以初始化硬件设备、建立内存空间的映射表，从而建立适当的系统软硬件环境，为最终调用操作系统内核做好准备。

uboot引导系统启动, UBoot包含两个阶段的启动，一个是SPL启动，一个是正常的启动我们称为第二阶段Uboot。当然，我们也可以选择使用SPL和不使用，主要根据CPU中的SRAM（或者cache，bootram阶段需要初始化完成）的大小，如果不能放下uboot大小，则必须先使用SPL启动，进行DDR的初始化，以获取更大的可以空间。

>Version: u-boot-201307

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
>[u-boot-spl.lds](/downloads/uboot/u-boot-spl.lds.txt)

在bootram将SPL搬到静态ram中后，执行SPL的代码将从`_start`开始。

### start.S

``` asm
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
>[start.S](/downloads/uboot/spl_start.S)

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

```
u-boot.lds
__start （start.S）
	->board_init_f (arch/mips/lib/board.c)
		->relocate_code (start.S)
				->board_init_r (arch/mips/lib/board.c)
```

### u-boot.lds

```
OUTPUT_ARCH(mips)
ENTRY(_start)
SECTIONS
{
	. = 0x00000000;

	. = ALIGN(4);
	.text : {
		*(.text*)
	}
	...
	. = ALIGN(4);
	.data : {
		*(.data*)
	}

	. = .;
	_gp = ALIGN(16) + 0x7ff0;  /*32KB*/

	...
```
>[u-boot.lds](/downloads/uboot/u-boot.lds.txt)



### start.S

``` C
#define CONFIG_SYS_SDRAM_BASE       0x80000000 /* cached (KSEG0) address */
#define CONFIG_SYS_INIT_SP_OFFSET   0x400000
```

``` asm
.set noreorder

.globl _start
.text
_start:
/* Initialize $gp */
bal	1f
 nop
.word	_gp
1:
lw	gp, 0(ra)

/* Set up temporary stack */
li	sp, CONFIG_SYS_SDRAM_BASE + CONFIG_SYS_INIT_SP_OFFSET

la	t9, board_init_f
jr	t9
 nop
```
>[start.S](/downloads/uboot/uboot_start.S)

1. 重新设置栈指针`0x80400000`,
2. 跳转`board_init_f`

>`CONFIG_SYS_SDRAM_BASE ＝ 0x8000 0000` ，是 MIPS 虚拟寻址空间中`kseg0`段的起始地址（参考《 See MIPS Run 》），它经过 CPU TLB 翻译后是 DRAM 内存的起始物理地址。

#### 为什么不直接跳转，而使用`jr`


### board.c

#### uboot内存布局：

``` C
#define CONFIG_SYS_SDRAM_BASE       0x80000000 /* cached (KSEG0) address */
#define CONFIG_SYS_SDRAM_MAX_TOP    0x90000000 /* don't run into IO space */
#define CONFIG_SYS_INIT_SP_OFFSET   0x400000
#define CONFIG_SYS_LOAD_ADDR        0x88000000
#define CONFIG_SYS_MEMTEST_START    0x80000000
#define CONFIG_SYS_MEMTEST_END      0x88000000
#define CONFIG_SYS_TEXT_BASE        0x80100000
#define CONFIG_SYS_MONITOR_BASE     CONFIG_SYS_TEXT_BASE
```
```
+-------------------+ <-+ 0x9000 0000
|                   |
|                   |
|                   |
|     LOAD_ADDR     |
|                   |
|                   |
+-------------------+ <-+ 0x8800 0000
|                   |
|                   |
|                   |
|                   |
|                   |
|                   |
+-------------------+ <-+ 0x8040 0000
|                   |
|      STACK        |
|                   |
+-------------------+ <-+ 0x8010 0000
|     TEXT BASE     |
+-------------------+ <-+ 0x8000 0000
```

#### board_init_f

``` C
void board_init_f(ulong bootflag)
{
	gd_t gd_data, *id;
	bd_t *bd;
	init_fnc_t **init_fnc_ptr;
	ulong addr, addr_sp, len;
	ulong *s;

	/* Pointer is writable since we allocated a register for it.
	 */
	gd = &gd_data;
	/* compiler optimization barrier needed for GCC >= 3.4 */
	__asm__ __volatile__("" : : : "memory");

	memset((void *)gd, 0, sizeof(gd_t));

	for (init_fnc_ptr = init_sequence; *init_fnc_ptr; ++init_fnc_ptr) {
		if ((*init_fnc_ptr)() != 0)
			hang();
	}

	/*
	 * Now that we have DRAM mapped and working, we can
	 * relocate the code and continue running from DRAM.
	 */
	addr = CONFIG_SYS_SDRAM_BASE + gd->ram_size;
#ifdef CONFIG_SYS_SDRAM_MAX_TOP
	addr = MIN(addr, CONFIG_SYS_SDRAM_MAX_TOP);
#endif

	/* We can reserve some RAM "on top" here.
	 */

	/* round down to next 4 kB limit.
	 */
	addr &= ~(4096 - 1);
	printf("Top of RAM usable for U-Boot at: %08lx\n", addr);
#ifdef CONFIG_LCD
#ifdef CONFIG_FB_ADDR
	gd->fb_base = CONFIG_FB_ADDR;
#else
	/* reserve memory for LCD display (always full pages) */
	addr = lcd_setmem(addr);
	printf("Reserving %ldk for LCDC at: %08lx\n", len >> 10, addr);
	gd->fb_base = addr;
#endif /* CONFIG_FB_ADDR */
#endif /* CONFIG_LCD */

	/* Reserve memory for U-Boot code, data & bss
	 * round down to next 16 kB limit
	 */
	len = bss_end() - CONFIG_SYS_MONITOR_BASE;
	addr -= len;
	addr &= ~(16 * 1024 - 1);

	printf("Reserving %ldk for U-Boot at: %08lx\n", len >> 10, addr);

	 /* Reserve memory for malloc() arena.
	 */
	addr_sp = addr - TOTAL_MALLOC_LEN;
	printf("Reserving %dk for malloc() at: %08lx\n",
			TOTAL_MALLOC_LEN >> 10, addr_sp);

	/*
	 * (permanently) allocate a Board Info struct
	 * and a permanent copy of the "global" data
	 */
	addr_sp -= sizeof(bd_t);
	bd = (bd_t *)addr_sp;
	gd->bd = bd;
	printf("Reserving %zu Bytes for Board Info at: %08lx\n",
			sizeof(bd_t), addr_sp);

	addr_sp -= sizeof(gd_t);
	id = (gd_t *)addr_sp;
	printf("Reserving %zu Bytes for Global Data at: %08lx\n",
			sizeof(gd_t), addr_sp);

	/* Reserve memory for boot params.
	 */
	addr_sp -= CONFIG_SYS_BOOTPARAMS_LEN;
	bd->bi_boot_params = addr_sp;
	printf("Reserving %dk for boot params() at: %08lx\n",
			CONFIG_SYS_BOOTPARAMS_LEN >> 10, addr_sp);

	/*
	 * Finally, we set up a new (bigger) stack.
	 *
	 * Leave some safety gap for SP, force alignment on 16 byte boundary
	 * Clear initial stack frame
	 */
	addr_sp -= 16;
	addr_sp &= ~0xF;
	s = (ulong *)addr_sp;
	*s-- = 0;
	*s-- = 0;
	addr_sp = (ulong)s;
	printf("Stack Pointer at: %08lx\n", addr_sp);

	/*
	 * Save local variables to board info struct
	 */
	bd->bi_memstart	= CONFIG_SYS_SDRAM_BASE;	/* start of DRAM */
	bd->bi_memsize	= gd->ram_size;		/* size of DRAM in bytes */
	bd->bi_baudrate	= gd->baudrate;		/* Console Baudrate */

	memcpy(id, (void *)gd, sizeof(gd_t));

	relocate_code(addr_sp, id, addr);

	/*NOTREACHED - relocate_code() does not return*/
}
```

* 调用init_sequence 函数队列，对板子进行一些初始化

``` C
/*
 * initialization sequence configurable to the user.
 *
 * The requirements for any new initalization function is simple: it
 * receives a pointer to the "global data" structure as it's only
 * argument, and returns an integer return code, where 0 means
 * "continue" and != 0 means "fatal error, hang the system".
 */
typedef int (init_fnc_t)(void);

init_fnc_t *init_sequence[] = {
	 board_early_init_f,
	 timer_init,
	 env_init,		/* initialize environment */
#ifdef CONFIG_INCA_IP
	 incaip_set_cpuclk,	/* set cpu clock according to env. variable */
#endif
	 init_baudrate,		/* initialize baudrate settings */
	 serial_init,		/* serial communications setup */
	 console_init_f,
	 display_banner,		/* say that we are here */
	 checkboard,
	 init_func_ram,
	 NULL,
};
```
* 为uboot在DRAM中执行准备条件

#### relocate_code

重定位，U-boot 将自己的代码段、数据段、 BSS 段等搬到在 DRAM 中。

``` asm
/*
 * void relocate_code (addr_sp, gd, addr_moni)
 *
 * This "function" does not return, instead it continues in RAM
 * after relocating the monitor code.
 *
 * a0 = addr_sp
 * a1 = gd
 * a2 = destination address
 */
	.globl	relocate_code
	.ent	relocate_code
relocate_code:
	move	sp, a0			# set new stack pointer

	li	t0, CONFIG_SYS_MONITOR_BASE
	sub	t6, a2, t0		# t6 <-- relocation offset

	la	t3, in_ram
	lw	t2, -12(t3)		# t2 <-- __image_copy_end
	move	t1, a2

	add	gp, t6			# adjust gp

	/*
	 * t0 = source address
	 * t1 = target address
	 * t2 = source end address
	 */
1:
	lw	t3, 0(t0)
	sw	t3, 0(t1)
	addu	t0, 4
	blt	t0, t2, 1b
	 addu	t1, 4

	/* If caches were enabled, we would have to flush them here. */

	/* flush d-cache */
	li	t0, KSEG0
	or	t1, t0, CONFIG_SYS_DCACHE_SIZE
2:
	cache	INDEX_WRITEBACK_INV_D, 0(t0)
	bne	t0, t1, 2b
	 addi	t0, CONFIG_SYS_CACHELINE_SIZE

	sync

	/* flush i-cache */
	li	t0, KSEG0
	or	t1, t0, CONFIG_SYS_ICACHE_SIZE
3:
	cache	INDEX_INVALIDATE_I, 0(t0)
	bne	t0, t1, 3b
	 addi	t0, CONFIG_SYS_CACHELINE_SIZE

	/* Invalidate BTB */
	mfc0	t0, CP0_CONFIG, 7
	nop
	ori	t0, 2
	mtc0	t0, CP0_CONFIG, 7
	nop

	/* Jump to where we've relocated ourselves */
	addi	t0, a2, in_ram - _start
	jr	t0
	 nop

	.word	__rel_dyn_end
	.word	__rel_dyn_start
	.word	__image_copy_end
	.word	_GLOBAL_OFFSET_TABLE_
	.word	num_got_entries

in_ram:
	/*
	 * Now we want to update GOT.
	 *
	 * GOT[0] is reserved. GOT[1] is also reserved for the dynamic object
	 * generated by GNU ld. Skip these reserved entries from relocation.
	 */
	lw	t3, -4(t0)		# t3 <-- num_got_entries
	lw	t4, -8(t0)		# t4 <-- _GLOBAL_OFFSET_TABLE_
	add	t4, t6			# t4 now holds relocated _G_O_T_
	addi	t4, t4, 8		# skipping first two entries
	li	t2, 2
1:
	lw	t1, 0(t4)
	beqz	t1, 2f
	 add	t1, t6
	sw	t1, 0(t4)
2:
	addi	t2, 1
	blt	t2, t3, 1b
	 addi	t4, 4

	/* Update dynamic relocations */
	lw	t1, -16(t0)		# t1 <-- __rel_dyn_start
	lw	t2, -20(t0)		# t2 <-- __rel_dyn_end

	b	2f			# skip first reserved entry
	 addi	t1, 8

1:
	lw	t3, -4(t1)		# t3 <-- relocation info

	sub	t3, 3
	bnez	t3, 2f			# skip non R_MIPS_REL32 entries
	 nop

	lw	t3, -8(t1)		# t3 <-- location to fix up in FLASH

	lw	t4, 0(t3)		# t4 <-- original pointer
	add	t4, t6			# t4 <-- adjusted pointer

	add	t3, t6			# t3 <-- location to fix up in RAM
	sw	t4, 0(t3)

2:
	blt	t1, t2, 1b
	 addi	t1, 8			# each rel.dyn entry is 8 bytes

	/*
	 * Clear BSS
	 *
	 * GOT is now relocated. Thus __bss_start and __bss_end can be
	 * accessed directly via $gp.
	 */
	la	t1, __bss_start		# t1 <-- __bss_start
	la	t2, __bss_end		# t2 <-- __bss_end

1:
	sw	zero, 0(t1)
	blt	t1, t2, 1b
	 addi	t1, 4

	move	a0, a1			# a0 <-- gd
	la	t9, board_init_r
	jr	t9
	 move	a1, a2

	.end	relocate_code
```

#### board_init_r

>This is the next part if the initialization sequence: we are now running from RAM and have a "normal" C environment, i. e. global data can be written, BSS has been cleared, the stack size in not that critical any more, etc.

此时已在DRAM中运行。

``` C
void board_init_r(gd_t *id, ulong dest_addr)
{
#ifndef CONFIG_SYS_NO_FLASH
	ulong size;
#endif
	bd_t *bd;

	gd = id;
	gd->flags |= GD_FLG_RELOC;	/* tell others: relocation done */

	printf("Now running in RAM - U-Boot at: %08lx\n", dest_addr);

	gd->relocaddr = dest_addr;
	gd->reloc_off = dest_addr - CONFIG_SYS_MONITOR_BASE;

	monitor_flash_len = image_copy_end() - dest_addr;

	board_early_init_r();

	serial_initialize();

	bd = gd->bd;

	/* The Malloc area is immediately below the monitor copy in DRAM */
	mem_malloc_init(CONFIG_SYS_MONITOR_BASE + gd->reloc_off -
			TOTAL_MALLOC_LEN, TOTAL_MALLOC_LEN);

#ifndef CONFIG_SYS_NO_FLASH
	/* configure available FLASH banks */
	size = flash_init();
	display_flash_config(size);
	bd->bi_flashstart = CONFIG_SYS_FLASH_BASE;
	bd->bi_flashsize = size;

#if CONFIG_SYS_MONITOR_BASE == CONFIG_SYS_FLASH_BASE
	bd->bi_flashoffset = monitor_flash_len;	/* reserved area for U-Boot */
#else
	bd->bi_flashoffset = 0;
#endif
#else
	bd->bi_flashstart = 0;
	bd->bi_flashsize = 0;
	bd->bi_flashoffset = 0;
#endif
	...
#ifdef CONFIG_GENERIC_MMC
	puts("MMC:   ");
	mmc_initialize(bd);
#endif

	/* relocate environment function pointers etc. */
	env_relocate();


/*leave this here (after malloc(), environment and PCI are working)*/
	/* Initialize stdio devices */
	stdio_init();

	jumptable_init();

	/* Initialize the console (after the relocation and devices init) */
	console_init_r();

	/* Initialize from environment */
	load_addr = getenv_ulong("loadaddr", 16, load_addr);


#ifdef CONFIG_USB_GADGET
extern void board_usb_init(void);
	board_usb_init();
#endif

#if defined(CONFIG_MISC_INIT_R)
	/* miscellaneous platform dependent initialisations */
	misc_init_r();
#endif

#ifdef CONFIG_BITBANGMII
	bb_miiphy_init();
#endif
#if defined(CONFIG_CMD_NET)
	puts("Net:   ");
	eth_initialize(gd->bd);
#endif

	/* main_loop() can return to retry autoboot, if so just run it again. */
	for (;;)
		main_loop();
	/*NOTREACHED - no way out of command loop except booting*/
}
```

1. 初始化串口
2. 初始化系统内存分配函数
3. 如果使用MMC存储介质，初始化MMC设备
4. 初始化环境变量的指针,将 env_ptr 指针及其指向的地址初始化，用来存放环境变量结构体，然后将 flash 中的环境变量拷贝到内存中。
5. 初始化sdio设备
6. 初始化网络设备
7. 进去命令循环（即整个boot的工作循环），接受用户从串口输入的命令，然后进行相应的工作


### main_loop


``` C
void main_loop(void)
{
	...
	bootstage_mark_name(BOOTSTAGE_ID_MAIN_LOOP, "main_loop");

	/*刷新LCD*/
#if defined(CONFIG_UPDATE_TFTP)
	update_tftp(0UL);
#endif /* CONFIG_UPDATE_TFTP */
/*从环境变量中取得bootdelay 内核等待延时*/
#ifdef CONFIG_BOOTDELAY
	process_boot_delay();
#endif
	/*
	 * Main Loop for Monitor Command Processing
	 */
	for (;;) {
		len = readline (CONFIG_SYS_PROMPT);

		flag = 0;	/* assume no special flags for now */
		if (len > 0)
			strcpy (lastcommand, console_buffer);
		else if (len == 0)
			flag |= CMD_FLAG_REPEAT;

		if (len == -1)
			puts ("<INTERRUPT>\n");
		else
			rc = run_command(lastcommand, flag); //执行命令

		if (rc <= 0) {
			/* invalid command or not repeatable, forget it */
			lastcommand[0] = 0;
		}
	}
}
```
>file:common/main.c


### do_bootm

将内核解压缩，然后调用do_bootm_linux引导内核


### do_bootm_linux

启动内核
