I64 audioGranularity = 20;

//Auto Frame Skip
I64 autoFrameskip = FALSE;

I64 frameDelay = 120;

// Sound modes: 0 (Ch 01), 1 (Ch 02), 2 (Auto), 3 (Off)

// User-defined settings, defaults
I64 soundMode=2;
I64 soundEnable=TRUE;
I64 useKeyboard=TRUE;
I64 useGamePad=FALSE;
I64 LCDScale=2;

U8 *ROMPath = CAlloc(1024);
StrPrint(ROMPath, DirCur);

//Frameskip Amount (Auto frameskip setting allows the script to change this.)
I64 frameskipAmount = 0;

//Frameskip base factor
I64 frameskipBaseFactor = 10;

//Maximum Frame Skip
I64 frameskipMax = 29;

//Interval for the emulator loop.
I64 loopInterval = 17;

//Target number of machine cycles per loop. (4,194,300 / 1000 * 17)
I64 machineCyclesPerLoop = 17826;

//Override MBC RAM disabling and always allow reading and writing to the banks.
I64 overrideMBC = TRUE;

//Override to allow for MBC1 instead of ROM only (compatibility for broken 3rd-party cartridges).
I64 overrideMBC1 = TRUE;

//Give priority to GameBoy mode
I64 priorizeGameBoyMode = TRUE;

//Sample Rate
I64 sampleRate = 70000;
