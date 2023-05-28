@---------------------------------------------------------------------------------
	#include "equates.h"
@---------------------------------------------------------------------------------
	.global mapper111init
@---------------------------------------------------------------------------------
.section .text,"ax"
@---------------------------------------------------------------------------------
mapper111init:
@---------------------------------------------------------------------------------
	.word void,void,void,void

	adr r1,mapper111write4000
	str_ r1,m6502WriteTbl+8
	adr r1,mapper111write
	str_ r1,m6502WriteTbl+12

	bx lr

mapper111write4000:
        cmp addy,#0x5000
        bcc IO_W
mapper111write:
	tst addy,#0x1000
	bxeq lr
	stmfd sp!,{r0,lr}
	bl map89ABCDEF_
	ldmfd sp,{r0}
	mov r0,r0,lsr#4
	and r0,r0,#1
	bl chr01234567_
	ldmfd sp!,{r0,lr}
	tst r0,#0x20
	b mirror1_
