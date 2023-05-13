#ifndef ARM6502_HEADER
#define ARM6502_HEADER

#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
	u32 opz[256];
	u32 readTbl[8];
	u32 writeTbl[8];
	u32 *memTbl[8];

	u32 regNz;
	u32 regrmem;
	u32 regA;
	u32 regX;
	u32 regY;
	u32 cycles;
	u8 *regPc;
	u32 regSp;

	u8 *lastBank;
	void *nextTimeout;
} M6502Core;

extern M6502Core m6502Base;

void m6502Reset(M6502Core *cpu);

void m6502SetNMIPin(bool set);
void m6502SetIRQPin(bool set);

#ifdef __cplusplus
}
#endif

#endif // ARM6502_HEADER
