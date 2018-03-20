/*
 * Startup Code for MIPS32 XBURST X1000 CPU-core
 *
 * Copyright (c) 2013 Ingenic Semiconductor Co.,Ltd
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston,
 * MA 02111-1307 USA
 */

#include <config.h>
#include <version.h>
#include <asm/regdef.h>
#include <asm/mipsregs.h>
#include <asm/addrspace.h>
#include <asm/cacheops.h>
#include <asm/arch/base.h>

#define RESERVED_FOR_SC(x) .space 1536, x

	.set noreorder

	.globl _start
	.section .start_section
_start:
#ifdef CONFIG_SPL_JZMMC_SUPPORT
	/* magic value ("MSPL") */
	.word 0x4d53504c
	.space 508, 0
	RESERVED_FOR_SC(0)
#endif

#ifdef CONFIG_SPL_NOR_SUPPORT
	.word 0
#endif /* CONFIG_SPL_NOR_SUPPORT */

#if defined(CONFIG_SPL_SFC_SUPPORT) || defined(CONFIG_SPL_SPI_NAND)
	.word 0x03040506
	.word 0x55aa5502
#ifdef CONFIG_SPL_SFC_NOR
	.word 0xffff00aa
#else /*CONFIG_SPL_SFC_NAND*/
#define SSI_PPB	(CONFIG_SPI_NAND_PPB / 32)
#define SSI_BPP (CONFIG_SPI_NAND_BPP / 1024)
	.word (0x00000000 | (SSI_PPB<<16) | (SSI_BPP<<24))
#endif
	.word 0x00000000
#ifdef CONFIG_SPL_VERSION
	.word (0x00000000 | CONFIG_SPL_VERSION)
	.space (512-20),0
#else
	.space (512-16),0
#endif
	RESERVED_FOR_SC(0)
#endif

#if 0
loop:
	la      v0, 0xb0010000
	li      t0, 0x200
	sw      t0, 0x74(v0)
	sw      t0, 0x18(v0)
	sw      t0, 0x24(v0)
	sw      t0, 0x38(v0)
	sw      t0, 0x48(v0)
	li      t1, 0x7fffff
loop2:
	subu    t1, t1, 1
	nop
	bgtz    t1, loop2
	nop
	sw      t0, 0x44(v0)
	li      t1, 0x7fffff
loop3:
	subu    t1, t1, 1
	nop
	bgtz    t1, loop3
	nop
	b       loop
	nop
#endif

	/* Invalidate BTB */
	mfc0	v0, CP0_CONFIG, 7
	nop
	ori	v0, v0, 2
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

	/* enable bridge radical mode */
	la	t0, CPM_BASE
	lw	t1, 0x24(t0)
	ori	t1, t1, 0x22
	sw	t1, 0x24(t0)

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

#if 0

	li	t1, KSEG0		/* Start address */
	ori     t2, t1, CACHE_ALLOC_END	/* End address */
	la      t3, 0x1ffff000		/* Physical address and 4KB page mask */

cache_alloc_a_line:
	and     t4, t1, t3
	ori     t4, t4, 1		/* V bit of the physical tag */
	mtc0    t4, CP0_TAGLO, 0
	cache   INDEX_STORE_TAG_I, 0(t1)
	cache   INDEX_STORE_TAG_D, 0(t1)
	addiu   t1, t1, CONFIG_SYS_CACHELINE_SIZE
	bne     t1, t2, cache_alloc_a_line
	nop
#endif
#ifdef CONFIG_SPL_NOR_SUPPORT
	.extern __data_start
	.extern __data_end
	/*Init data section, nor spl*/
	la	t0, __data_start
	la	t1, __data_end
	la	t2, 0xF4000800
1:
	lw	t3, 0(t0)
	addiu	t0, t0, 4
	sw	t3, 0(t2)
	addiu	t2, t2, 4
	bne	t0, t1, 1b
	nop
#endif

	/* Set up stack */
#ifdef CONFIG_SPL_STACK
	li	sp, CONFIG_SPL_STACK
#endif

	j	board_init_f
	nop
