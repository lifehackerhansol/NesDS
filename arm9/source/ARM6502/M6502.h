#ifndef ARM6502_HEADER
#define ARM6502_HEADER

#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
	void *opz[256];
	u32 *memTbl[8];
	void *readTbl[8];
	void *writeTbl[8];

	u32 regNz;
	u32 regA;
	u32 regX;
	u32 regY;
	u32 regrmem;
	u32 cycles;
	u8 *regPc;
	u32 regSp;
	u8 irqPending;
	u8 nmiPin;
	u8 padding[2];

	u8 *lastBank;
	int oldCycles;
	void *nextTimeout;
#ifdef DEBUG
	u32 brkCount;
	u32 badOpCount;
#endif
} M6502Core;

void m6502Init(M6502Core *cpu);

void m6502Reset(M6502Core *cpu);

void m6502SetNMIPin(bool set);
void m6502SetIRQPin(bool set);

#ifdef __cplusplus
}
#endif

#endif // ARM6502_HEADER
