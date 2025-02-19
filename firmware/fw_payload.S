/*
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Copyright (c) 2019 Western Digital Corporation or its affiliates.
 *
 * Authors:
 *   Anup Patel <anup.patel@wdc.com>
 */

#include "fw_base.S"

	.section .entry, "ax", %progbits
	.align 3
	.global fw_boot_hart
	/*
	 * This function is called very early even before
	 * fw_save_info() is called.
	 * We can only use a0, a1, and a2 registers here.
	 * The boot HART id should be returned in 'a0'.
	 */
fw_boot_hart:
	li	a0, -1
	ret

	.section .entry, "ax", %progbits
	.align 3
	.global fw_save_info
	/*
	 * We can only use a0, a1, a2, a3, and a4 registers here.
	 * The a0, a1, and a2 registers will be same as passed by
	 * previous booting stage.
	 * Nothing to be returned here.
	 */
fw_save_info:
	ret

	.section .entry, "ax", %progbits
	.align 3
	.global fw_next_arg1
	/*
	 * We can only use a0, a1, and a2 registers here.
	 * The a0, a1, and a2 registers will be same as passed by
	 * previous booting stage.
	 * The next arg1 should be returned in 'a0'.
	 */
fw_next_arg1:
#ifdef FW_PAYLOAD_FDT_ADDR
	li	a0, FW_PAYLOAD_FDT_ADDR
#else
	add	a0, a1, zero
#endif
	ret

	.section .entry, "ax", %progbits
	.align 3
	.global fw_next_addr
	/*
	 * We can only use a0, a1, and a2 registers here.
	 * The next address should be returned in 'a0'.
	 */
fw_next_addr:
#ifdef FW_JUMP_ADDR
	lla a0, payload_bin
	/* 64-bit constants can only be loaded indirectly */
	lla a0, jump_addr_local
	ld a0, (a0)
#else
	lla	a0, payload_bin
#endif
	ret

	.section .entry, "ax", %progbits
	.align 3
	.global fw_next_mode
	/*
	 * We can only use a0, a1, and a2 registers here.
	 * The next address should be returned in 'a0'.
	 */
fw_next_mode:
	li	a0, PRV_S
	ret

	.section .entry, "ax", %progbits
	.align 3
	.global fw_options
	/*
	 * We can only use a0, a1, and a2 registers here.
	 * The 'a4' register will have default options.
	 * The next address should be returned in 'a0'.
	 */
fw_options:
	add	a0, zero, zero
	ret

	.section .payload, "ax", %progbits
	/* For some reason this overrides the linker script.
	*/
	.align 16
	.globl payload_bin
#ifdef FW_JUMP_ADDR
jump_addr_local:
	.dword FW_JUMP_ADDR
#endif
payload_bin:
#if defined(FW_PAYLOAD_PATH)
	.incbin	FW_PAYLOAD_PATH
#else
  // Use #include if you want to include the bytes as asm source.
  // See for details: https://groups.google.com/g/bazel-discuss/c/QZtmmW3B_w0
  #if defined(FW_PAYLOAD_PATH_INC)
	#include FW_PAYLOAD_PATH_INC
  #else
	wfi
	j	payload_bin
  #endif
#endif
