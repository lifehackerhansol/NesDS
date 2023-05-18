
globalptr	.req r10	@ =wram_globals* ptr
addy		.req r12		;@ Keep this at r12 (scratch for APCS)

NDS_PALETTE		= 0x5000000

start_map m6502Size,globalptr	@6502.s

@ppuState:
	@RP2C02.s
_m_ scanline,4
_m_ scanlineHook,4
_m_ frame,4
_m_ cyclesPerScanline,4
_m_ lastScanline,4

_m_ fpsValue,4
_m_ adjustBlend,4

_m_ ppuState,0
_m_ vramAddr,4
_m_ vramAddr2,4
_m_ scrollX,4
_m_ scrollY,4
_m_ scrollYTemp,4
_m_ sprite0Y,4
_m_ readTemp,4
_m_ bg0Cnt,4
_m_ ppuBusLatch,1
_m_ sprite0X,1
_m_ vramAddrInc,1
_m_ ppuStat,1
_m_ toggle,1
_m_ ppuCtrl0,1
_m_ ppuCtrl0Frame,1
_m_ ppuCtrl1,1
_m_ ppuOamAdr,1
_m_ unused_align,3
#if !defined DEBUG
_m_ unusedAlign2,8
#endif
_m_ nesChrMap,16

_m_ loopy_t,4
_m_ loopy_x,4
_m_ loopy_y,4
_m_ loopy_v,4
_m_ loopy_shift,4

_m_ vromMask,4
_m_ vromBase,4
_m_ palSyncLine, 4

_m_ pixStart, 4
_m_ pixEnd, 4

_m_ newFrameHook,4
_m_ endFrameHook,4
_m_ hblankHook,4
_m_ ppuChrLatch,4

rp2C02Size:

;@----------------------------------------------------------------------------
