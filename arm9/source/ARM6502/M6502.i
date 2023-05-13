
				;@ r0,r1,r2=temp regs
	m6502nz		.req r3			;@ Bit 31=N, Z=1 if bits 0-7=0
	m6502_rmem	.req r4			;@ m6502ReadTbl
	m6502a		.req r5			;@ Bits 0-23=0, also used to clear bytes in memory
	m6502x		.req r6			;@ Bits 0-23=0
	m6502y		.req r7			;@ Bits 0-23=0
	cycles		.req r8			;@ Also VDIC flags
	m6502pc		.req r9
	globalptr	.req r10		;@ =wram_globals* ptr
	m6502ptr	.req r10
	m6502zpage	.req r11		;@ ZeroPage RAM ptr
	addy		.req r12		;@ Keep this at r12 (scratch for APCS)

;@----------------------------------------------------------------------------
	.equ CYC_SHIFT, 8
	.equ CYCLE, 1<<CYC_SHIFT	;@ One cycle
	.equ CYC_MASK, CYCLE-1		;@ Mask
;@----------------------------------------------------------------------------
;@ cycle flags- (stored in cycles reg for speed)

	.equ CYC_C, 0x01			;@ Carry bit
	.equ CYC_I, 0x04			;@ IRQ mask
	.equ CYC_D, 0x08			;@ Decimal bit
	.equ CYC_V, 0x40			;@ Overflow bit
@----------------------------------------------------------------------------

	.struct 0					;@ Changes section so make sure it is set before real code.
m6502Opz:			.skip 256*4
m6502ReadTbl:		.skip 8*4
m6502WriteTbl:		.skip 8*4
m6502MemTbl:		.skip 8*4
m6502StateStart:
m6502Regs:
m6502RegNZ:			.skip 4
m6502rmem:			.skip 4
m6502RegA:			.skip 4
m6502RegX:			.skip 4
m6502RegY:			.skip 4
m6502Cycles:		.skip 4
m6502RegPC:			.skip 4
m6502RegSP:			.skip 4
m6502LastBank:		.skip 4
m6502NextTimeout:	.skip 4
m6502Size:

;@----------------------------------------------------------------------------
