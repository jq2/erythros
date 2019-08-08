U0 matchLYC()
{
    // LY - LYC Compare
    // If LY==LCY
    if (memory[0xFF44] == memory[0xFF45]) {
        memory[0xFF41] |= 0x04; // set STAT bit 2: LY-LYC coincidence flag
        if (LYCMatchTriggerSTAT) {
            memory[0xFF0F] |= 0x2; // set IF bit 1
        }
    } else {
        memory[0xFF41] &= 0xFB; // reset STAT bit 2 (LY!=LYC)
    }
}
U0 notifyScanline()
{

    renderBG_ScanLine;
    //renderWIN_ScanLine;
}

U0 scanLineMode0()
{
    // H-Blank
    if (modeSTAT != 0) {
        if (mode0TriggerSTAT || (mode2TriggerSTAT && STATTracker == 0)) {
            memory[0xFF0F] |= 0x2; // if STAT bit 3 -> set IF bit1
        }
        notifyScanline;
        STATTracker = 2;
        modeSTAT = 0;
    }
}
U0 scanLineMode2()
{
    // OAM in use
    if (modeSTAT != 2) {
        if (mode2TriggerSTAT) {
            memory[0xFF0F] |= 0x2; // set IF bit 1
        }
        STATTracker = 1;
        modeSTAT = 2;
    }
}
U0 scanLineMode3()
{
    // OAM in use
    if (modeSTAT != 3) {
        if (mode2TriggerSTAT && STATTracker == 0) {
            memory[0xFF0F] |= 0x2; // set IF bit 1
        }
        STATTracker = 1;
        modeSTAT = 3;
    }
}

// Scan Line and STAT Mode Control
U0 scanLine(I64 line)
{
    //When turned off = Do nothing!
    if (LCDisOn) {
        if (line < 143) {
            //We're on a normal scan line:
            if (LCDTicks < 20) {
                scanLineMode2; // mode2: 80 cycles
            } else if (LCDTicks < 63) {
                scanLineMode3; // mode3: 172 cycles
            } else if (LCDTicks < 114) {
                scanLineMode0; // mode0: 204 cycles
            } else {
                //We're on a new scan line:
                LCDTicks -= 114;
                actualScanLine = ++memory[0xFF44];
                matchLYC;
                if (STATTracker != 2) {
                    if (mode0TriggerSTAT) {
                        memory[0xFF0F] |= 0x2; // set IF bit 1
                    }
                }
                STATTracker = 0;
                scanLineMode2; // mode2: 80 cycles
                if (LCDTicks >= 114) {
                    //We need to skip 1 or more scan lines:
                    notifyScanline;
                    scanLine(actualScanLine); //Scan Line and STAT Mode Control
                }
            }
        } else if (line == 143) {
            //We're on the last visible scan line of the LCD screen:
            if (LCDTicks < 20) {
                scanLineMode2; // mode2: 80 cycles
            } else if (LCDTicks < 63) {
                scanLineMode3; // mode3: 172 cycles
            } else if (LCDTicks < 114) {
                scanLineMode0; // mode0: 204 cycles
            } else {
                //Starting V-Blank:
                //Just finished the last visible scan line:
                LCDTicks -= 114;
                actualScanLine = ++memory[0xFF44];
                matchLYC;
                if (mode1TriggerSTAT) {
                    memory[0xFF0F] |= 0x2; // set IF bit 1
                }
                if (STATTracker != 2) {
                    if (mode0TriggerSTAT) {
                        memory[0xFF0F] |= 0x2; // set IF bit 1
                    }
                }
                STATTracker = 0;
                modeSTAT = 1;
                memory[0xFF0F] |= 0x1; // set IF flag 0
                //LCD off takes at least 2 frames.
                if (drewBlank > 0) {
                    --drewBlank;
                }
                if (LCDTicks >= 114) {
                    //We need to skip 1 or more scan lines:
                    scanLine(actualScanLine); //Scan Line and STAT Mode Control
                }
            }
        } else if (line < 153) {
            //In VBlank
            if (LCDTicks >= 114) {
                //We're on a new scan line:
                LCDTicks -= 114;
                actualScanLine = ++memory[0xFF44];
                matchLYC;
                if (LCDTicks >= 114) {
                    //We need to skip 1 or more scan lines:
                    scanLine(actualScanLine); //Scan Line and STAT Mode Control
                }
            }
        } else {
            //VBlank Ending (We're on the last actual scan line)
            if (memory[0xFF44] == 153) {

                memory[0xFF44] = 0; //LY register resets to 0 early.
                matchLYC; //LY==LYC Test is early here (Fixes specific one-line glitches (example: Kirby2 intro)).
            }
            if (LCDTicks >= 114) {
                //We reset back to the beginning:
                LCDTicks -= 114;
                actualScanLine = 0;
                scanLineMode2; // mode2: 80 cycles
                if (LCDTicks >= 114) {
                    //We need to skip 1 or more scan lines:
                    scanLine(actualScanLine); //Scan Line and STAT Mode Control
                }
            }
        }
    }
}
