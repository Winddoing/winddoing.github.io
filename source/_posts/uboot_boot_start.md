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
	.set noreorder
	.set mips32r2

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

	 ...
```
>[start.S](/downloads/uboot/start.S)

1. 设置栈指针的位置`0x80400000`
2. 跳转`board_init_f`

#### DDR没有初始化完成，该地址`0x80400000`指向那段空间？


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

1. timer_init为什么执行两次？

## uboot
