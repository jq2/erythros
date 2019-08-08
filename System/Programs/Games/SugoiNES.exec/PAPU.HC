// vim: set ft=c:

#define DMC_MODE_NORMAL 0
#define DMC_MODE_LOOP   1
#define DMC_MODE_IRQ    2

#define CPU_FREQ_NTSC   1789772.5
#define SAMPLE_RATE     48000
#define FRAME_RATE      60

//#define BUFFER_SIZE     16384
#define BUFFER_SIZE     4096

CFifoI64 *audio_fifo_L = FifoI64New(BUFFER_SIZE);
CFifoI64 *audio_fifo_R = FifoI64New(BUFFER_SIZE);

I64 SQR_dutyLookup[32] =
{
	0, 1, 0, 0, 0, 0, 0, 0,
	0, 1, 1, 0, 0, 0, 0, 0,
	0, 1, 1, 1, 1, 0, 0, 0,
	1, 0, 0, 1, 1, 1, 1, 1
};

I64 SQR_impLookup[32] =
{
	1,-1, 0, 0, 0, 0, 0, 0,
	1, 0,-1, 0, 0, 0, 0, 0,
	1, 0, 0, 0,-1, 0, 0, 0,
	-1, 0, 1, 0, 0, 0, 0, 0
};

I64 PAPU_lengthLookup[32] = {
	0x0A, 0xFE,
	0x14, 0x02,
	0x28, 0x04,
	0x50, 0x06,
	0xA0, 0x08,
	0x3C, 0x0A,
	0x0E, 0x0C,
	0x1A, 0x0E,
	0x0C, 0x10,
	0x18, 0x12,
	0x30, 0x14,
	0x60, 0x16,
	0xC0, 0x18,
	0x48, 0x1A,
	0x10, 0x1C,
	0x20, 0x1E
};

class ChannelSquare
{
I64 dutyLookup[32];
I64 impLookup[32];
I64 sqr1;
I64 isEnabled;
I64 lengthCounterEnable;
I64 sweepActive;
I64 envDecayDisable;
I64 envDecayLoopEnable;
I64 envReset;
I64 sweepCarry;
I64 updateSweepPeriod;
I64 progTimerCount;
I64 progTimerMax;
I64 lengthCounter;
I64 squareCounter;
I64 sweepCounter;
I64 sweepCounterMax;
I64 sweepMode;
I64 sweepShiftAmount;
I64 envDecayRate;
I64 envDecayCounter;
I64 envVolume;
I64 masterVolume;
I64 dutyMode;
I64 sweepResult;
I64 sampleValue;
I64 vol;
};

class ChannelTriangle
{
I64 isEnabled;
I64 sampleCondition;
I64 lengthCounterEnable;
I64 lcHalt;
I64 lcControl;
I64 progTimerCount;
I64 progTimerMax;
I64 triangleCounter;
I64 lengthCounter;
I64 linearCounter;
I64 lcLoadValue;
I64 sampleValue;
I64 tmp;
};

class ChannelNoise
{
I64 isEnabled;
I64 envDecayDisable;
I64 envDecayLoopEnable;
I64 lengthCounterEnable;
I64 envReset;
I64 shiftNow;
I64 lengthCounter;
I64 progTimerCount;
I64 progTimerMax;
I64 envDecayRate;
I64 envDecayCounter;
I64 envVolume;
I64 masterVolume;
I64 shiftReg;
I64 randomBit;
I64 randomMode;
I64 sampleValue;
I64 accValue;
I64 accCount;
I64 tmp;
};

class ChannelDM
{
I64 isEnabled;
I64 hasSample;
I64 irqGenerated;
I64 playMode;
I64 dmaFrequency;
I64 dmaCounter;
I64 deltaCounter;
I64 playStartAddress;
I64 playAddress;
I64 playLength;
I64 playLengthCounter;
I64 shiftCounter;
I64 reg4012;
I64 reg4013;
I64 sample;
I64 dacLsb;
I64 data;
};

class PAPU2A03
{
ChannelSquare square1;
ChannelSquare square2;
ChannelTriangle triangle;
ChannelNoise noise;
ChannelDM dmc;
I64 frameIrqCounter;
I64 frameIrqCounterMax;
I64 initCounter;
I64 channelEnableValue;
I64 sampleRate;
I64 lengthLookup[32];
I64 dmcFreqLookup[16];
I64 noiseWavelengthLookup[16];
I64 square_table[32 * 16];
I64 tnd_table[204 * 16];
I64 frameIrqEnabled;
I64 frameIrqActive;
I64 initingHardware;
I64 masterFrameCounter;
I64 derivedFrameCounter;
I64 countSequence;
I64 sampleTimer;
I64 frameTime;
I64 sampleTimerMax;
I64 sampleCount;
I64 masterVolume;
I64 extraCycles;
};

PAPU2A03 PAPU;

U0 PAPU_initBuffers()
{
	FifoI64Flush(audio_fifo_L);
	FifoI64Flush(audio_fifo_R);
}

U0 PAPU_audioSample(I64 l, I64 r)
{
	FifoI64Ins(audio_fifo_L, l);
	FifoI64Ins(audio_fifo_R, r);
}

U0 PAPU_initLengthLookup(PAPU2A03 *papu)
{
	MemCpy(&papu->lengthLookup, &PAPU_lengthLookup, sizeof(I64)*32);
}

U0 PAPU_initDmcFrequencyLookup(PAPU2A03 *papu)
{
	papu->dmcFreqLookup[0x0] = 0xd60;
	papu->dmcFreqLookup[0x1] = 0xbe0;
	papu->dmcFreqLookup[0x2] = 0xaa0;
	papu->dmcFreqLookup[0x3] = 0xa00;
	papu->dmcFreqLookup[0x4] = 0x8f0;
	papu->dmcFreqLookup[0x5] = 0x7f0;
	papu->dmcFreqLookup[0x6] = 0x710;
	papu->dmcFreqLookup[0x7] = 0x6b0;
	papu->dmcFreqLookup[0x8] = 0x5f0;
	papu->dmcFreqLookup[0x9] = 0x500;
	papu->dmcFreqLookup[0xa] = 0x470;
	papu->dmcFreqLookup[0xb] = 0x400;
	papu->dmcFreqLookup[0xc] = 0x350;
	papu->dmcFreqLookup[0xd] = 0x2a0;
	papu->dmcFreqLookup[0xe] = 0x240;
	papu->dmcFreqLookup[0xf] = 0x1b0;
}

U0 PAPU_initNoiseWavelengthLookup(PAPU2A03 *papu)
{
	papu->noiseWavelengthLookup[0x0] = 0x004;
	papu->noiseWavelengthLookup[0x1] = 0x008;
	papu->noiseWavelengthLookup[0x2] = 0x010;
	papu->noiseWavelengthLookup[0x3] = 0x020;
	papu->noiseWavelengthLookup[0x4] = 0x040;
	papu->noiseWavelengthLookup[0x5] = 0x060;
	papu->noiseWavelengthLookup[0x6] = 0x080;
	papu->noiseWavelengthLookup[0x7] = 0x0a0;
	papu->noiseWavelengthLookup[0x8] = 0x0ca;
	papu->noiseWavelengthLookup[0x9] = 0x0fe;
	papu->noiseWavelengthLookup[0xa] = 0x17c;
	papu->noiseWavelengthLookup[0xb] = 0x1fc;
	papu->noiseWavelengthLookup[0xc] = 0x2fa;
	papu->noiseWavelengthLookup[0xd] = 0x3f8;
	papu->noiseWavelengthLookup[0xe] = 0x7f2;
	papu->noiseWavelengthLookup[0xf] = 0xfe4;
}

U0 PAPU_initDACTables(PAPU2A03 *papu)
{
	I64 value;
	I64 ival, i;
	I64 max_sqr = 0;
	I64 max_tnd = 0;
	for (i = 0; i < 32 * 16; i++) {
		value = 95.52 / (8128.0 / (i / 16.0) + 100.0);
		value *= 0.98411;
		value *= 50000.0;
		ival = Floor(value);

		papu->square_table[i] = ival;
		if (ival > max_sqr) {
			max_sqr = ival;
		}
	}

	for (i = 0; i < 204 * 16; i++) {
		value = 163.67 / (24329.0 / (i / 16.0) + 100.0);
		value *= 0.98411;
		value *= 50000.0;
		ival = Floor(value);

		papu->tnd_table[i] = ival;
		if (ival > max_tnd) {
			max_tnd = ival;
		}
	}
}

I64 PAPU_getLengthMax(PAPU2A03 *papu, I64 value)
{
	return papu->lengthLookup[value >> 3];
}

I64 PAPU_getNoiseWaveLength(PAPU2A03 *papu, I64 value)
{
	if (value >= 0 && value < 0x10) {
		return papu->noiseWavelengthLookup[value];
	}
	return 0;
}

I64 PAPU_getDmcFrequency(PAPU2A03 *papu, I64 value)
{
	if (value >= 0 && value < 0x10)
	{
		return papu->dmcFreqLookup[value];
	}
	return 0;
}

// SQUARE

I64 Square_getLengthStatus(ChannelSquare *sqr)
{
	if (sqr->lengthCounter == 0 || !sqr->isEnabled)
	{
		return 0;
	}
	else
	{
		return 1;
	}
}

U0 Square_updateSampleValue(ChannelSquare *sqr)
{
	if (sqr->isEnabled && sqr->lengthCounter > 0 && sqr->progTimerMax > 7) {
		if (
		        sqr->sweepMode == 0 &&
		        sqr->progTimerMax + (sqr->progTimerMax >> sqr->sweepShiftAmount) > 4095
		        ) {
			sqr->sampleValue = 0;
		} else {
			sqr->sampleValue =
			        sqr->masterVolume *
			        sqr->dutyLookup[(sqr->dutyMode << 3) + sqr->squareCounter];
		}
	} else {
		sqr->sampleValue = 0;
	}
}

U0 Square_setEnabled(ChannelSquare *sqr, I64 value)
{
	sqr->isEnabled = value;
	if (!value) {
		sqr->lengthCounter = 0;
	}
	Square_updateSampleValue(sqr);
}

U0 Square_writeReg(PAPU2A03 *papu, ChannelSquare *sqr, U16 address, U8 value)
{
	I64 addrAdd;
	if (sqr->sqr1)
	{
		addrAdd = 0;
	}
	else
	{
		addrAdd = 4;
	}
	if (address == 0x4000 + addrAdd)
	{
		// Volume/Envelope decay:
		sqr->envDecayDisable = (value & 0x10) != 0;
		sqr->envDecayRate = value & 0xF;
		sqr->envDecayLoopEnable = (value & 0x20) != 0;
		sqr->dutyMode = (value >> 6) & 0x3;
		sqr->lengthCounterEnable = (value & 0x20) == 0;
		if (sqr->envDecayDisable)
		{
			sqr->masterVolume = sqr->envDecayRate;
		}
		else
		{
			sqr->masterVolume = sqr->envVolume;
		}
		Square_updateSampleValue(sqr);
	}
	else if (address == 0x4001 + addrAdd)
	{
		// Sweep:
		sqr->sweepActive = (value & 0x80) != 0;
		sqr->sweepCounterMax = (value >> 4) & 7;
		sqr->sweepMode = (value >> 3) & 1;
		sqr->sweepShiftAmount = value & 7;
		sqr->updateSweepPeriod = TRUE;
	}
	else if (address == 0x4002 + addrAdd)
	{
		// Programmable timer:
		sqr->progTimerMax &= 0x700;
		sqr->progTimerMax |= value;
	}
	else if (address == 0x4003 + addrAdd)
	{
		// Programmable timer, length counter
		sqr->progTimerMax &= 0xFF;
		sqr->progTimerMax |= (value & 0x7) << 8;

		if (sqr->isEnabled) {
			sqr->lengthCounter = PAPU_getLengthMax(papu, value & 0xF8);
		}
		sqr->envReset = TRUE;
	}
}

U0 Square_clockSweep(ChannelSquare *sqr)
{
	if (--sqr->sweepCounter <= 0)
	{
		sqr->sweepCounter = sqr->sweepCounterMax + 1;
		if (
		        sqr->sweepActive &&
		        sqr->sweepShiftAmount > 0 &&
		        sqr->progTimerMax > 7
		        )
		{
			// Calculate result from shifter:
			sqr->sweepCarry = FALSE;
			if (sqr->sweepMode == 0)
			{
				sqr->progTimerMax += sqr->progTimerMax >> sqr->sweepShiftAmount;
				if (sqr->progTimerMax > 4095)
				{
					sqr->progTimerMax = 4095;
					sqr->sweepCarry = TRUE;
				}
			}
			else
			{
				sqr->progTimerMax =
				        sqr->progTimerMax -
				        ((sqr->progTimerMax >> sqr->sweepShiftAmount) -
				         (sqr->sqr1 == 1));
			}
		}
	}
	if (sqr->updateSweepPeriod)
	{
		sqr->updateSweepPeriod = FALSE;
		sqr->sweepCounter = sqr->sweepCounterMax + 1;
	}
}

U0 Square_clockEnvDecay(ChannelSquare *sqr)
{
	if (sqr->envReset)
	{
		// Reset envelope:
		sqr->envReset = FALSE;
		sqr->envDecayCounter = sqr->envDecayRate + 1;
		sqr->envVolume = 0xF;
	}
	else if (--sqr->envDecayCounter <= 0)
	{
		// Normal handling:
		sqr->envDecayCounter = sqr->envDecayRate + 1;
		if (sqr->envVolume > 0)
		{
			sqr->envVolume--;
		}
		else
		{
			if (sqr->envDecayLoopEnable)
			{
				sqr->envVolume = 0xF;
			}
			else
			{
				sqr->envVolume = 0;
			}
		}
	}
	if (sqr->envDecayDisable)
	{
		sqr->masterVolume = sqr->envDecayRate;
	}
	else
	{
		sqr->masterVolume = sqr->envVolume;
	}
	Square_updateSampleValue(sqr);
}

U0 Square_clockLengthCounter(ChannelSquare *sqr)
{
	if (sqr->lengthCounterEnable && sqr->lengthCounter > 0) {
		sqr->lengthCounter--;
		if (sqr->lengthCounter == 0) {
			Square_updateSampleValue(sqr);
		}
	}
}

U0 Square_reset(ChannelSquare *sqr)
{
	sqr->progTimerCount = 0;
	sqr->progTimerMax = 0;
	sqr->lengthCounter = 0;
	sqr->squareCounter = 0;
	sqr->sweepCounter = 0;
	sqr->sweepCounterMax = 0;
	sqr->sweepMode = 0;
	sqr->sweepShiftAmount = 0;
	sqr->envDecayRate = 0;
	sqr->envDecayCounter = 0;
	sqr->envVolume = 0;
	sqr->masterVolume = 0;
	sqr->dutyMode = 0;
	sqr->vol = 0;
	sqr->isEnabled = FALSE;
	sqr->lengthCounterEnable = FALSE;
	sqr->sweepActive = FALSE;
	sqr->sweepCarry = FALSE;
	sqr->envDecayDisable = FALSE;
	sqr->envDecayLoopEnable = FALSE;
}

U0 Square_init(ChannelSquare *sqr, I64 isSqr1=FALSE)
{
	MemSet(sqr, 0, sizeof(ChannelSquare));
	MemCpy(&sqr->dutyLookup, &SQR_dutyLookup, sizeof(I64)*32);
	MemCpy(&sqr->impLookup, &SQR_impLookup, sizeof(I64)*32);
	sqr->sqr1 = isSqr1;
	Square_reset(sqr);
}

// TRIANGLE

U0 Triangle_clockTriangleGenerator(ChannelTriangle *tri)
{
	tri->triangleCounter++;
	tri->triangleCounter &= 0x1f;
}

U0 Triangle_clockProgrammableTimer(ChannelTriangle *tri, I64 nCycles)
{
	if (tri->progTimerMax > 0) {
		tri->progTimerCount += nCycles;
		while (
		        tri->progTimerMax > 0 &&
		        tri->progTimerCount >= tri->progTimerMax
		        ) {
			tri->progTimerCount -= tri->progTimerMax;
			if (
			        tri->isEnabled &&
			        tri->lengthCounter > 0 &&
			        tri->linearCounter > 0
			        ) {
				Triangle_clockTriangleGenerator(tri);
			}
		}
	}
}

U0 Triangle_updateSampleCondition(ChannelTriangle *tri)
{
	tri->sampleCondition =
	        tri->isEnabled &&
	        tri->progTimerMax > 7 &&
	        tri->linearCounter > 0 &&
	        tri->lengthCounter > 0;
}

U0 Triangle_writeReg(PAPU2A03 *papu, ChannelTriangle *tri, U16 address, U8 value)
{
	if (address == 0x4008)
	{
		// New values for linear counter:
		tri->lcControl = (value & 0x80) != 0;
		tri->lcLoadValue = value & 0x7F;

		// Length counter enable:
		tri->lengthCounterEnable = !tri->lcControl;
	}
	else if (address == 0x400A)
	{
		// Programmable timer:
		tri->progTimerMax &= 0x700;
		tri->progTimerMax |= value;
	}
	else if (address == 0x400b)
	{
		// Programmable timer, length counter
		tri->progTimerMax &= 0xFF;
		tri->progTimerMax |= (value & 0x07) << 8;
		tri->lengthCounter = PAPU_getLengthMax(papu, value & 0xF8);
		tri->lcHalt = TRUE;
	}
	Triangle_updateSampleCondition(tri);
}

U8 Triangle_readReg(PAPU2A03 *papu, ChannelTriangle *tri, U16 address)
{
	return 0;
}

I64 Triangle_getLengthStatus(ChannelTriangle *tri)
{
	if (tri->lengthCounter == 0 || !tri->isEnabled)
	{
		return 0;
	}
	else
	{
		return 1;
	}
}

U0 Triangle_clockLinearCounter(ChannelTriangle *tri)
{
	if (tri->lcHalt) {
		// Load:
		tri->linearCounter = tri->lcLoadValue;
		Triangle_updateSampleCondition(tri);
	} else if (tri->linearCounter > 0)
	{
		// Decrement:
		tri->linearCounter--;
		Triangle_updateSampleCondition(tri);
	}
	if (!tri->lcControl)
	{
		// Clear halt flag:
		tri->lcHalt = FALSE;
	}
}

U0 Triangle_clockLengthCounter(ChannelTriangle *tri)
{
	if (tri->lengthCounterEnable && tri->lengthCounter > 0)
	{
		tri->lengthCounter--;
		if (tri->lengthCounter == 0)
		{
			Triangle_updateSampleCondition(tri);
		}
	}
}

U0 Triangle_setEnabled(ChannelTriangle *tri, I64 value)
{
	tri->isEnabled = value;
	if (!value) {
		tri->lengthCounter = 0;
	}
	Triangle_updateSampleCondition(tri);
}

U0 Triangle_reset(ChannelTriangle *tri)
{
	tri->progTimerCount = 0;
	tri->progTimerMax = 0;
	tri->triangleCounter = 0;
	tri->isEnabled = FALSE;
	tri->sampleCondition = FALSE;
	tri->lengthCounter = 0;
	tri->lengthCounterEnable = FALSE;
	tri->linearCounter = 0;
	tri->lcLoadValue = 0;
	tri->lcHalt = TRUE;
	tri->lcControl = FALSE;
	tri->tmp = 0;
	tri->sampleValue = 0xF;
}

U0 Triangle_init(ChannelTriangle *tri)
{
	MemSet(tri, 0, sizeof(ChannelTriangle));
	Triangle_reset(tri);
}

// NOISE

I64 Noise_getLengthStatus(ChannelNoise *noise)
{
	if (noise->lengthCounter == 0 || !noise->isEnabled)
	{
		return 0;
	}
	else
	{
		return 1;
	}
}

U0 Noise_updateSampleValue(ChannelNoise *noise)
{
	if (noise->isEnabled && noise->lengthCounter > 0)
	{
		noise->sampleValue = noise->randomBit * noise->masterVolume;
	}
}

U0 Noise_setEnabled(ChannelNoise *noise, I64 value)
{
	noise->isEnabled = value;
	if (!value)
	{
		noise->lengthCounter = 0;
	}
	Noise_updateSampleValue(noise);
}

U0 Noise_writeReg(PAPU2A03 *papu, ChannelNoise *noise, U16 address, U8 value)
{
	if (address == 0x400C)
	{
		// Volume/Envelope decay:
		noise->envDecayDisable = (value & 0x10) != 0;
		noise->envDecayRate = value & 0xF;
		noise->envDecayLoopEnable = (value & 0x20) != 0;
		noise->lengthCounterEnable = (value & 0x20) == 0;
		if (noise->envDecayDisable)
		{
			noise->masterVolume = noise->envDecayRate;
		}
		else
		{
			noise->masterVolume = noise->envVolume;
		}
	}
	else if (address == 0x400E)
	{
		// Programmable timer:
		noise->progTimerMax = PAPU_getNoiseWaveLength(papu, value & 0xF);
		noise->randomMode = value >> 7;
	}
	else if (address == 0x400F)
	{
		// Length counter
		noise->lengthCounter = PAPU_getLengthMax(papu, value & 248);
		noise->envReset = TRUE;
	}
}

U0 Noise_clockEnvDecay(ChannelNoise *noise)
{
	if (noise->envReset)
	{
		// Reset envelope:
		noise->envReset = FALSE;
		noise->envDecayCounter = noise->envDecayRate + 1;
		noise->envVolume = 0xF;
	}
	else if (--noise->envDecayCounter <= 0)
	{
		// Normal handling:
		noise->envDecayCounter = noise->envDecayRate + 1;
		if (noise->envVolume > 0) {
			noise->envVolume--;
		}
		else
		{
			if (noise->envDecayLoopEnable)
			{
				noise->envVolume = 0xF;
			}
			else
			{
				noise->envVolume = 0;
			}
		}
	}
	if (noise->envDecayDisable)
	{
		noise->masterVolume = noise->envDecayRate;
	}
	else
	{
		noise->masterVolume = noise->envVolume;
	}
}

U0 Noise_clockLengthCounter(ChannelNoise *noise)
{
	if (noise->lengthCounterEnable && noise->lengthCounter > 0)
	{
		noise->lengthCounter--;
		if (noise->lengthCounter == 0)
		{
			Noise_updateSampleValue(noise);
		}
	}
}

U0 Noise_reset(ChannelNoise *noise)
{
	noise->progTimerCount = 0;
	noise->progTimerMax = 0;
	noise->isEnabled = FALSE;
	noise->lengthCounter = 0;
	noise->lengthCounterEnable = FALSE;
	noise->envDecayDisable = FALSE;
	noise->envDecayLoopEnable = FALSE;
	noise->shiftNow = FALSE;
	noise->envDecayRate = 0;
	noise->envDecayCounter = 0;
	noise->envVolume = 0;
	noise->masterVolume = 0;
	noise->shiftReg = 1;
	noise->randomBit = 0;
	noise->randomMode = 0;
	noise->sampleValue = 0;
	noise->tmp = 0;
}

U0 Noise_init(ChannelNoise *noise)
{
	MemSet(noise, 0, sizeof(ChannelNoise));
	noise->shiftReg = 1 << 14;
	Noise_reset(noise);
}

// DMC [TODO]

U0 DMC_setEnabled(ChannelDM *dm, I64 value)
{
	if (!dm->isEnabled && value)
	{
		dm->playLengthCounter = dm->playLength;
	}
	dm->isEnabled = value;
}

I64 DMC_getIrqStatus(ChannelDM *dm)
{
	return dm->irqGenerated;
}

I64 DMC_getLengthStatus(ChannelDM *dm)
{
	if (dm->playLengthCounter == 0)
	{
		return 0;
	}
	else
	{
		return 1;
	}
}

U0 DMC_writeReg(PAPU2A03 *papu, ChannelDM *dm, U16 address, U8 value)
{
	if (address == 0x4010)
	{
		// Play mode, DMA Frequency
		if (value >> 6 == 0)
		{
			dm->playMode = DMC_MODE_NORMAL;
		}
		else if (((value >> 6) & 1) == 1)
		{
			dm->playMode = DMC_MODE_LOOP;
		}
		else if (value >> 6 == 2)
		{
			dm->playMode = DMC_MODE_IRQ;
		}

		if ((value & 0x80) == 0)
		{
			dm->irqGenerated = FALSE;
		}
		dm->dmaFrequency = PAPU_getDmcFrequency(papu, value & 0xF);
	}
	else if (address == 0x4011)
	{
		// Delta counter load register:
		dm->deltaCounter = (value >> 1) & 63;
		dm->dacLsb = value & 1;
		dm->sample = (dm->deltaCounter << 1) + dm->dacLsb; // update sample value
	}
	else if (address == 0x4012)
	{
		// DMA address load register
		dm->playStartAddress = (value << 6) | 0x0C000;
		dm->playAddress = dm->playStartAddress;
		dm->reg4012 = value;
	}
	else if (address == 0x4013)
	{
		// Length of play code
		dm->playLength = (value << 4) + 1;
		dm->playLengthCounter = dm->playLength;
		dm->reg4013 = value;
	}
	else if (address == 0x4015)
	{
		// DMC/IRQ Status
		if (((value >> 4) & 1) == 0)
		{
			// Disable:
			dm->playLengthCounter = 0;
		}
		else
		{
			// Restart:
			dm->playAddress = dm->playStartAddress;
			dm->playLengthCounter = dm->playLength;
		}
		dm->irqGenerated = FALSE;
	}
}

U0 DMC_nextSample(ChannelDM *dm)
{
	// Fetch byte:
	dm->data = MMU.RAM[dm->playAddress];
	//this.papu.nes.cpu.haltCycles(4); TODO

	dm->playLengthCounter--;
	dm->playAddress++;
	if (dm->playAddress > 0xFFFF) {
		dm->playAddress = 0x8000;
	}
	dm->hasSample = TRUE;
}

U0 DMC_endOfSample(ChannelDM *dm)
{
	if (dm->playLengthCounter == 0 && dm->playMode == DMC_MODE_LOOP)
	{
		// Start from beginning of sample:
		dm->playAddress = dm->playStartAddress;
		dm->playLengthCounter = dm->playLength;
	}

	if (dm->playLengthCounter > 0)
	{
		// Fetch next sample:
		DMC_nextSample(dm);

		if (dm->playLengthCounter == 0)
		{
			// Last byte of sample fetched, generate IRQ:
			if (dm->playMode == DMC_MODE_IRQ) {
				// Generate IRQ:
				dm->irqGenerated = TRUE;
			}
		}
	}
}

U0 DMC_clockDmc(ChannelDM *dm)
{
	// Only alter DAC value if the sample buffer has data:
	if (dm->hasSample)
	{
		if ((dm->data & 1) == 0)
		{
			// Decrement delta:
			if (dm->deltaCounter > 0)
			{
				dm->deltaCounter--;
			}
		}
		else
		{
			// Increment delta:
			if (dm->deltaCounter < 63)
			{
				dm->deltaCounter++;
			}
		}

		// Update sample value:
		if (dm->isEnabled)
		{
			dm->sample = (dm->deltaCounter << 1) + dm->dacLsb;
		}
		else
		{
			dm->sample = 0;
		}

		// Update shift register:
		dm->data >>= 1;
	}

	dm->dmaCounter--;
	if (dm->dmaCounter <= 0) {
		// No more sample bits.
		dm->hasSample = FALSE;
		DMC_endOfSample(dm);
		dm->dmaCounter = 8;
	}

	if (dm->irqGenerated) {
		papu_request_irq = TRUE;
	}
}


U0 DMC_reset(ChannelDM *dm)
{
	dm->isEnabled = FALSE;
	dm->irqGenerated = FALSE;
	dm->playMode = DMC_MODE_NORMAL;
	dm->dmaFrequency = 0;
	dm->dmaCounter = 0;
	dm->deltaCounter = 0;
	dm->playStartAddress = 0;
	dm->playAddress = 0;
	dm->playLength = 0;
	dm->playLengthCounter = 0;
	dm->sample = 0;
	dm->dacLsb = 0;
	dm->shiftCounter = 0;
	dm->reg4012 = 0;
	dm->reg4013 = 0;
	dm->data = 0;
}

U0 DMC_init(ChannelDM *dm)
{
	MemSet(dm, 0, sizeof(ChannelDM));
	DMC_reset(dm);
}

U0 PAPU_updateChannelEnable(PAPU2A03 *papu, I64 value)
{
	// Updates channel enable status.
	// This is done on writes to the
	// channel enable register (0x4015).
	papu->channelEnableValue = value & 0xFFFF;
	Square_setEnabled(&papu->square1, (value & 1) != 0);
	Square_setEnabled(&papu->square2, (value & 2) != 0);
	Triangle_setEnabled(&papu->triangle, (value & 4) != 0);
	Noise_setEnabled(&papu->noise, (value & 8) != 0);
	DMC_setEnabled(&papu->dmc, (value & 16) != 0);
}

U0 PAPU_frameCounterTick(PAPU2A03 *papu)
{
	papu->derivedFrameCounter++;
	if (papu->derivedFrameCounter >= papu->frameIrqCounterMax) {
		papu->derivedFrameCounter = 0;
	}
	if (papu->derivedFrameCounter == 1 || papu->derivedFrameCounter == 3) {
		// Clock length & sweep:
		Triangle_clockLengthCounter(&papu->triangle);
		Square_clockLengthCounter(&papu->square1);
		Square_clockLengthCounter(&papu->square2);
		Noise_clockLengthCounter(&papu->noise);
		Square_clockSweep(&papu->square1);
		Square_clockSweep(&papu->square2);
	}
	if (papu->derivedFrameCounter >= 0 && papu->derivedFrameCounter < 4) {
		// Clock linear & decay:
		Square_clockEnvDecay(&papu->square1);
		Square_clockEnvDecay(&papu->square2);
		Noise_clockEnvDecay(&papu->noise);
		Triangle_clockLinearCounter(&papu->triangle);
	}
	if (papu->derivedFrameCounter == 3 && papu->countSequence == 0) {
		// Enable IRQ:
		papu->frameIrqActive = TRUE;
	}
	// End of 240Hz tick
}

U0 PAPU_setMasterVolume(PAPU2A03 *papu, I64 value)
{
	if (value < 0) {
		value = 0;
	}
	if (value > 256) {
		value = 256;
	}
	papu->masterVolume = value;
}

U0 PAPU_resetCounter(PAPU2A03 *papu)
{
	if (papu->countSequence == 0)
	{
		papu->derivedFrameCounter = 4;
	}
	else
	{
		papu->derivedFrameCounter = 0;
	}
}

U8 PAPU_readReg(PAPU2A03 *papu, U16 address)
{
	// Read 0x4015:
	U8 tmp = 0;
	tmp |= Square_getLengthStatus(&papu->square1);
	tmp |= Square_getLengthStatus(&papu->square2) << 1;
	tmp |= Triangle_getLengthStatus(&papu->triangle) << 2;
	tmp |= Noise_getLengthStatus(&papu->noise) << 3;
	tmp |= DMC_getLengthStatus(&papu->dmc) << 4;
	if (papu->frameIrqActive && papu->frameIrqEnabled)
	{
		tmp |= 1 << 6;
	}
	else
	{
		tmp |= 0 << 6;
	}
	tmp |= DMC_getIrqStatus(&papu->dmc) << 7;
	papu->frameIrqActive = FALSE;
	papu->dmc.irqGenerated = FALSE;
	return tmp;
}

U0 PAPU_writeReg(PAPU2A03 *papu, U16 address, U8 value)
{
	if (address >= 0x4000 && address < 0x4004) {
		// Square Wave 1 Control
		Square_writeReg(papu, &papu->square1, address, value);
		// console.log("Square Write");
	} else if (address >= 0x4004 && address < 0x4008) {
		// Square 2 Control
		Square_writeReg(papu, &papu->square2, address, value);
	} else if (address >= 0x4008 && address < 0x400c) {
		// Triangle Control
		Triangle_writeReg(papu, &papu->triangle, address, value);
	} else if (address >= 0x400c && address <= 0x400f) {
		// Noise Control
		Noise_writeReg(papu, &papu->noise, address, value);
	} else if (address == 0x4010) {
		// DMC Play mode & DMA frequency
		DMC_writeReg(papu, &papu->dmc, address, value);
	} else if (address == 0x4011) {
		// DMC Delta Counter
		DMC_writeReg(papu, &papu->dmc, address, value);
	} else if (address == 0x4012) {
		// DMC Play code starting address
		DMC_writeReg(papu, &papu->dmc, address, value);
	} else if (address == 0x4013) {
		// DMC Play code length
		DMC_writeReg(papu, &papu->dmc, address, value);
	} else if (address == 0x4015) {
		// Channel enable
		PAPU_updateChannelEnable(papu, value);

		if (value != 0 && papu->initCounter > 0) {
			// Start hardware initialization
			papu->initingHardware = TRUE;
		}

		// DMC/IRQ Status
		DMC_writeReg(papu, &papu->dmc, address, value);
	} else if (address == 0x4017) {
		// Frame counter control
		papu->countSequence = (value >> 7) & 1;
		papu->masterFrameCounter = 0;
		papu->frameIrqActive = FALSE;

		if (((value >> 6) & 0x1) == 0) {
			papu->frameIrqEnabled = TRUE;
		} else {
			papu->frameIrqEnabled = FALSE;
		}

		if (papu->countSequence == 0) {
			// NTSC:
			papu->frameIrqCounterMax = 4;
			papu->derivedFrameCounter = 4;
		} else {
			// PAL:
			papu->frameIrqCounterMax = 5;
			papu->derivedFrameCounter = 0;
			PAPU_frameCounterTick(papu);
		}
	}
}

U0 PAPU_clockFrameCounter(PAPU2A03 *papu, I64 nCycles)
{
	if (papu->initCounter > 0) {
		if (papu->initingHardware) {
			papu->initCounter -= nCycles;
			if (papu->initCounter <= 0) {
				papu->initingHardware = FALSE;
			}
			return;
		}
	}

	// Don't process ticks beyond next sampling:
	nCycles += papu->extraCycles;
	I64 maxCycles = papu->sampleTimerMax - papu->sampleTimer;
	if (nCycles << 10 > maxCycles) {
		papu->extraCycles = ((nCycles << 10) - maxCycles) >> 10;
		nCycles -= papu->extraCycles;
	} else {
		papu->extraCycles = 0;
	}

	// Clock DMC:
	if (papu->dmc.isEnabled) {
		papu->dmc.shiftCounter -= nCycles << 3;
		while (papu->dmc.shiftCounter <= 0 && papu->dmc.dmaFrequency > 0) {
			papu->dmc.shiftCounter += papu->dmc.dmaFrequency;
			DMC_clockDmc(&papu->dmc);
		}
	}

	// Clock Triangle channel Prog timer:
	if (papu->triangle.progTimerMax > 0) {
		papu->triangle.progTimerCount -= nCycles;
		while (papu->triangle.progTimerCount <= 0) {
			papu->triangle.progTimerCount += papu->triangle.progTimerMax + 1;
			if (papu->triangle.linearCounter > 0 && papu->triangle.lengthCounter > 0) {
				papu->triangle.triangleCounter++;
				papu->triangle.triangleCounter &= 0x1f;

				if (papu->triangle.isEnabled) {
					if (papu->triangle.triangleCounter >= 0x10) {
						// Normal value.
						papu->triangle.sampleValue = papu->triangle.triangleCounter & 0xf;
					} else {
						// Inverted value.
						papu->triangle.sampleValue = 0xf - (papu->triangle.triangleCounter & 0xf);
					}
					papu->triangle.sampleValue <<= 4;
				}
			}
		}
	}

	// Clock Square channel 1 Prog timer:
	papu->square1.progTimerCount -= nCycles;
	if (papu->square1.progTimerCount <= 0) {
		papu->square1.progTimerCount += (papu->square1.progTimerMax + 1) << 1;

		papu->square1.squareCounter++;
		papu->square1.squareCounter &= 0x7;
		Square_updateSampleValue(&papu->square1);
	}

	// Clock Square channel 2 Prog timer:
	papu->square2.progTimerCount -= nCycles;
	if (papu->square2.progTimerCount <= 0) {
		papu->square2.progTimerCount += (papu->square2.progTimerMax + 1) << 1;

		papu->square2.squareCounter++;
		papu->square2.squareCounter &= 0x7;
		Square_updateSampleValue(&papu->square2);
	}

	// Clock noise channel Prog timer:
	I64 acc_c = nCycles;
	I64 tmp2;
	if (papu->noise.randomMode == 0)
	{
		tmp2 = 1;
	}
	else
	{
		tmp2 = 6;
	}
	if (papu->noise.progTimerCount - acc_c > 0) {
		// Do all cycles at once:
		papu->noise.progTimerCount -= acc_c;
		papu->noise.accCount += acc_c;
		papu->noise.accValue += acc_c * papu->noise.sampleValue;
	} else {
		// Slow-step:
		while (acc_c-- > 0) {
			if (--papu->noise.progTimerCount <= 0 && papu->noise.progTimerMax > 0) {
				// Update noise shift register:
				papu->noise.shiftReg <<= 1;
				papu->noise.tmp =
				        ((papu->noise.shiftReg << (tmp2)) ^
				         papu->noise.shiftReg) &
				        0x8000;
				if (papu->noise.tmp != 0) {
					// Sample value must be 0.
					papu->noise.shiftReg |= 0x01;
					papu->noise.randomBit = 0;
					papu->noise.sampleValue = 0;
				} else {
					// Find sample value:
					papu->noise.randomBit = 1;
					if (papu->noise.isEnabled && papu->noise.lengthCounter > 0) {
						papu->noise.sampleValue = papu->noise.masterVolume;
					} else {
						papu->noise.sampleValue = 0;
					}
				}

				papu->noise.progTimerCount += papu->noise.progTimerMax;
			}

			papu->noise.accValue += papu->noise.sampleValue;
			papu->noise.accCount++;
		}
	}

	// Frame IRQ handling:
	if (papu->frameIrqEnabled && papu->frameIrqActive) {
		papu_request_irq = TRUE;
	}

	// Clock frame counter at double CPU speed:
	papu->masterFrameCounter += nCycles << 1;
	if (papu->masterFrameCounter >= papu->frameTime) {
		// 240Hz tick:
		papu->masterFrameCounter -= papu->frameTime;
		PAPU_frameCounterTick(papu);
	}

	// Clock sample timer:
	papu->sampleTimer += nCycles << 10;
	if (papu->sampleTimer >= papu->sampleTimerMax) {
		// Sample channels:
		PAPU_audioSample(PAPU.square1.sampleValue + PAPU.square2.sampleValue + (PAPU.triangle.sampleValue/6) + PAPU.noise.sampleValue + PAPU.dmc.sample/2,
		                 PAPU.square1.sampleValue + PAPU.square2.sampleValue + (PAPU.triangle.sampleValue/6) + PAPU.noise.sampleValue + PAPU.dmc.sample/2);
		papu->sampleTimer -= papu->sampleTimerMax;
	}
}

U0 PAPU_reset(PAPU2A03 *papu)
{
	papu->sampleRate = SAMPLE_RATE;
	papu->sampleTimerMax = Floor(
	        (1024.0 * CPU_FREQ_NTSC * FRAME_RATE) /
	        (SAMPLE_RATE * 60.0)
	        );
	papu->frameTime = Floor(
	        (14915.0 * FRAME_RATE) / 60.0
	        );
	papu->sampleTimer = 0;

	PAPU_updateChannelEnable(papu, 0);
	papu->masterFrameCounter = 0;
	papu->derivedFrameCounter = 0;
	papu->countSequence = 0;
	papu->sampleCount = 0;
	papu->initCounter = 2048;
	papu->frameIrqEnabled = FALSE;
	papu->initingHardware = FALSE;

	PAPU_resetCounter(papu);

	Square_reset(&papu->square1);
	Square_reset(&papu->square2);
	Triangle_reset(&papu->triangle);
	Noise_reset(&papu->noise);
	DMC_reset(&papu->dmc);

	papu->frameIrqEnabled = FALSE;
	papu->frameIrqCounterMax = 4;
	papu->channelEnableValue = 0xFF;
}

U0 initPAPU(PAPU2A03 *papu)
{
	PAPU_initBuffers;
	I64 i;
	MemSet(papu, 0, sizeof(PAPU2A03));
	papu->frameIrqCounterMax = 4;
	papu->initCounter = 2048;
	papu->sampleRate = SAMPLE_RATE;
	papu->masterVolume = 256;
	Square_init(&papu->square1, TRUE);
	Square_init(&papu->square2);
	Triangle_init(&papu->triangle);
	Noise_init(&papu->noise);
	DMC_init(&papu->dmc);

	PAPU_initLengthLookup(papu);
	PAPU_initDmcFrequencyLookup(papu);
	PAPU_initNoiseWavelengthLookup(papu);
	PAPU_initDACTables(papu);

	for (i = 0; i < 0x14; i++) {
		if (i == 0x10) {
			PAPU_writeReg(papu, 0x4010, 0x10);
		} else {
			PAPU_writeReg(papu, 0x4000 + i, 0);
		}
	}

	PAPU_reset(papu);
	PAPU_setMasterVolume(papu, 1);
}