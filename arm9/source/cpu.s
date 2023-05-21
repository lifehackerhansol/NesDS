#ifdef __arm__

@---------------------------------------------------------------------------------
	#include "equates.h"
	#include "M6502mac.h"
@---------------------------------------------------------------------------------
	.global NSF_Run
	.global EMU_Run
	.global CPU_reset
	.global pcm_scanlineHook
	.global CheckI
	.global ntsc_pal_reset

pcmirqbakup = mapperData+24
pcmirqcount = mapperData+28

	.syntax unified
	.arm

#if GBA
	.section .ewram, "ax", %progbits	;@ For the GBA
#else
	.section .text, "ax"				;@ For anything else
#endif
	.align 2
@---------------------------------------------------------------------------------
NSF_Run:
@---------------------------------------------------------------------------------
	adr r1,nsfOut
	str r1,returnAddress

	ldr r0, =__nsfPlay
	ldr r0, [r0]
	ands r0, r0, r0
	beq noPlay

	ldr r0, =__nsfInit
	ldr r0, [r0]
	ands r0, r0, r0
	beq noInit

	mov r0, #0
	mov r1, m6502zpage
	ldr r2, =0x2000/4
	bl filler

	ldr r1, =nsfExtraChipSelect
	ldr r1, [r1]
	tst r1, #4
	bne 0f

	ldr r1, =wram
	ldr r2, =0x2000/4
	bl filler
0:
	ldr_ r0,cyclesPerScanline
	add cycles,cycles,r0, lsl#14

	ldr addy, =0x4015
	mov r0, #0xf
	bl soundwrite
		ldr addy, =0x4017
		mov r0, #0xc0
		bl soundwrite
		ldr addy, =0x4080
		mov r0, #0x80
		bl soundwrite
		ldr addy, =0x408a
		mov r0, #0xe8
		bl soundwrite

	ldr m6502pc, =0x4710
	encodePC
	ldr r0, =__nsfSongNo
	ldr m6502a, [r0]
	orr m6502a, m6502a, m6502a, lsl#24
	ldr r0, =__nsfSongMode
	ldr m6502x, [r0]
	mov m6502y, #0
	ldr r0,=NES_RAM+0x100
	str_ r0, m6502RegSP
	orr cycles,#CYC_I

	mov r0, #0
	ldr r1, =__nsfInit
	str r0, [r1]
	b handleScanlineHook

noInit:
	ldr_ r0,cyclesPerScanline
	add cycles,cycles,r0, lsl#8

	ldr_ r1,m6502LastBank
	sub m6502pc,m6502pc,r1
	cmp m6502pc, #0x4700
	bne handleScanlineHook

	ldr m6502pc, =0x4720
	encodePC
	ldr r0,=NES_RAM+0x100
	str_ r0, m6502RegSP
	mov m6502a, #0
	b handleScanlineHook

noPlay:
	ldr_ r0,cyclesPerScanline
	add cycles,cycles,r0, lsl#8

	ldr m6502pc, =0x4700
	encodePC
	ldr r0,=NES_RAM+0x100
	str_ r0, m6502RegSP
	b handleScanlineHook

nsfOut:
	adr_ r2,m6502Regs
	stmia r2,{m6502nz-m6502pc}	@ save 6502 state
	bl updatesound
	ldmfd sp!,{m6502nz-m6502pc,globalptr,m6502zpage,pc}

@---------------------------------------------------------------------------------
@cycles ran out
@---------------------------------------------------------------------------------
line0:
	mov r0,#0
	strb_ r0,ppuStat			@ vbl clear, sprite0 clear
	str_ r0,scanline			@ reset scanline count
	bl m6502SetNMIPin			@ Clear NMI Pin

	bl newframe					@ display update

	mov r0,#0
	bl ppusync

	ldr_ r0,cyclesPerScanline
	ldr_ r1,frame
	tst r1,#1
	subeq r0,r0,#CYCLE			@ Every other frame has 1 less PPU cycle.
	add cycles,cycles,r0
	adr r0,line1_to_119
	str r0,returnAddress
	b handleScanlineHook
@---------------------------------------------------------------------------------
line1_to_119:
	ldr_ r0,cyclesPerScanline
	add cycles,cycles,r0

	ldr_ r0,scanline
	add r0,r0,#1
	str_ r0,scanline
	cmp r0,#119
	beq line119

	bl ppusync
	b handleScanlineHook
@---------------------------------------------------------------------------------
line119:
	bl ppusync

	ldrb_ r0,ppuCtrl0
	strb_ r0,ppuCtrl0Frame		@ Contra likes this

	adr addy,line120_to_240
	str addy,returnAddress
	b handleScanlineHook
@---------------------------------------------------------------------------------
line120_to_240:
	ldr_ r0,cyclesPerScanline
	add cycles,cycles,r0

	ldr_ r0,scanline
	add r0,r0,#1
	str_ r0,scanline

	cmp r0,#240
	adreq addy,line241
	streq addy,returnAddress
	blne ppusync
	b handleScanlineHook
@---------------------------------------------------------------------------------
line241:
NMIDELAY = 7*CYCLE


	add cycles,cycles,#NMIDELAY	@ NMI is delayed a few cycles..

@	ldrb_ r1,ppuStat
@	orr r1,r1,#0x90		@ vbl & vram write
	mov r1,#0x80		@ vbl flag
	strb_ r1,ppuStat

	adr addy,line241NMI
	str addy,returnAddress
	b handleScanlineHook
@---------------------------------------------------------------------------------
line241NMI:
	ldr_ r0,frame
	add r0,r0,#1
	str_ r0,frame

	ldrb_ r0,ppuCtrl0
	tst r0,#0x80
	beq 0f			@ NMI?
	mov r0,#1
	bl m6502SetNMIPin
0:
	sub cycles,cycles,#NMIDELAY

	@--- end of EMU_Run
	adr_ r2,m6502Regs
	stmia r2,{m6502nz-m6502pc}	@ save 6502 state

	bl refreshNESjoypads

	bl updatesound

	adr lr, 2f
	ldr_ pc, endFrameHook
2:
	ldmfd sp!,{m6502nz-m6502pc,globalptr,m6502zpage,pc}

@---------------------------------------------------------------------------------
EMU_Run:
@---------------------------------------------------------------------------------
	stmfd sp!,{m6502nz-m6502pc,globalptr,m6502zpage,lr}

	ldr globalptr,=globals
	ldr_ m6502zpage,m6502MemTbl+0

	adr_ r0,m6502Regs
	ldmia r0,{m6502nz-m6502pc}	@restore 6502 state

	ldr_ r0,cyclesPerScanline
	add cycles,cycles,r0

	mov r0,#241
	str_ r0,scanline

	adr r1,line242_to_end
	str r1,returnAddress

	ldr_ r1,emuFlags
	tst r1, #NSFFILE
	bne NSF_Run

	b handleScanlineHook
@---------------------------------------------------------------------------------
line242_to_end:
	ldr_ r0,cyclesPerScanline
	add cycles,cycles,r0

	ldr_ r1,scanline
	ldr_ r2,lastScanline
	add r1,r1,#1
	str_ r1,scanline
	cmp r1,r2
	bne handleScanlineHook

	adr addy,line0
	str addy,returnAddress
	b handleScanlineHook

returnAddress:
	.long 0
@---------------------------------------------------------------------------------
pcm_scanlineHook:
@---------------------------------------------------------------------------------
	@ldr addy,=pcmctrl
	@ldr r2,[addy]
	@tst r2,#0x1000			@Is PCM on?
	@beq hk0
	b hk0

	ldr_ r0,pcmirqcount
@	ldr_ r1,cyclesPerScanline
@	subs r0,r0,r1,lsr#4
	subs r0,r0,#121			@Fire Hawk=122
	str_ r0,pcmirqcount
	bpl hk0

	tst r2,#0x40			@Is PCM loop on?
	ldrne_ r0,pcmirqbakup
	strne_ r0,pcmirqcount
	bne hk0
	tst r2,#0x80			@Is PCM IRQ on?
	orrne r2,r2,#0x8000		@set pcm IRQ bit in R4015
	bic r2,r2,#0x1000		@clear channel 5
	str r2,[addy]
	bne CheckI
hk0:
	bx lr

handleScanlineHook:
//	adr lr,slhRet
//	ldr_ pc,scanlineHook
//slhRet:
//	ldr lr,returnAddress
//	b m6502Run
	ldr lr,returnAddress
	stmfd sp!,{lr}
	ldr lr,=m6502CheckIrqs
	ldr_ pc,scanlineHook
@---------------------------------------------------------------------------------
CheckI:					@ Check Interrupt Disable
@---------------------------------------------------------------------------------
	tst cycles,#CYC_I
	ldreq r12,=0xFFFE
	beq irq6502				@ Take irq
	bx lr
@---------------------------------------------------------------------------------
ntsc_pal_reset:
@---------------------------------------------------------------------------------
@---NTSC/PAL
	mov r2, globalptr
	ldr globalptr,=globals

	ldr_ r1,emuFlags
	tst r1,#PALTIMING

//	ldreq r1,=341*CYCLE		@NTSC		(113+2/3)*3
//	ldrne r1,=320*CYCLE		@PAL		(106+9/16)*3
	mov r1,#113*CYCLE
	str_ r1,cyclesPerScanline
	mov globalptr, r2

	bx lr
@---------------------------------------------------------------------------------
CPU_reset:	@ Called by loadcart (r0-r9 are free to use)
@---------------------------------------------------------------------------------
	stmfd sp!,{lr}

	ldr r0,=m6502Base
	bl m6502Init

@---NTSC/PAL
	bl ntsc_pal_reset

	bl m6502Reset

	ldmfd sp!,{lr}
	bx lr
;@----------------------------------------------------------------------------
	.end
#endif // #ifdef __arm__
