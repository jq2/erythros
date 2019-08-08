switch (opcode)
{
    case 0:
        break;
    
    case 1:
        registerC = memoryRead(programCounter);
        registerB = memoryRead((programCounter + 1) & 0xFFFF);
        programCounter = (programCounter + 2) & 0xFFFF;
        break;
    
    case 2:
        memoryWrite((registerB << 8) + registerC, registerA);
        break;
    
    case 3:
        temp_var = (((registerB << 8) + registerC) + 1);
        registerB = ((temp_var >> 8) & 0xFF);
        registerC = (temp_var & 0xFF);
        break;
    
    case 4:
        registerB = ((registerB + 1) & 0xFF);
        FZero = (registerB == 0);
        FHalfCarry = ((registerB & 0xF) == 0);
        FSubtract = FALSE;
        break;
    
    case 5:
        registerB = unsbtub(registerB - 1);
        FZero = (registerB == 0);
        FHalfCarry = ((registerB & 0xF) == 0xF);
        FSubtract = TRUE;
        break;
    
    case 6:
        registerB = memoryRead(programCounter);
        programCounter = (programCounter + 1) & 0xFFFF;
        break;
    
    case 7:
        FCarry = ((registerA & 0x80) == 0x80);
        registerA = ((registerA << 1) & 0xFF) | (registerA >> 7);
        FZero = FSubtract = FHalfCarry = FALSE;
        break;
    
    case 8:
        temp_var = (memoryRead((programCounter + 1) & 0xFFFF) << 8) + memoryRead(programCounter);
        memoryWrite(temp_var, stackPointer & 0xFF);
        memoryWrite((temp_var + 1) & 0xFFFF, stackPointer >> 8);
        programCounter = (programCounter + 2) & 0xFFFF;
        break;
    
    case 9:
        n2 = (registerB << 8) + registerC;
        dirtySum = registersHL + n2;
        FHalfCarry = ((registersHL & 0xFFF) + (n2 & 0xFFF) > 0xFFF);
        FCarry = (dirtySum > 0xFFFF);
        registersHL = (dirtySum & 0xFFFF);
        FSubtract = FALSE;
        break;
    
    case 10:
        registerA = memoryRead((registerB << 8) + registerC);
        break;
    
    case 11:
        temp_var = unswtuw(((registerB << 8) + registerC) - 1);
        registerB = (temp_var >> 8);
        registerC = (temp_var & 0xFF);
        break;
    
    case 12:
        registerC = ((registerC + 1) & 0xFF);
        FZero = (registerC == 0);
        FHalfCarry = ((registerC & 0xF) == 0);
        FSubtract = FALSE;
        break;
    
    case 13:
        registerC = unsbtub(registerC - 1);
        FZero = (registerC == 0);
        FHalfCarry = ((registerC & 0xF) == 0xF);
        FSubtract = TRUE;
        break;
    
    case 14:
        registerC = memoryRead(programCounter);
        programCounter = (programCounter + 1) & 0xFFFF;
        break;
    
    case 15:
        FCarry = ((registerA & 1) == 1);
        registerA = (registerA >> 1) + ((registerA & 1) << 7);
        FZero = FSubtract = FHalfCarry = FALSE;
        break;
    
    case 16:
        break;
    
    case 17:
        registerE = memoryRead(programCounter);
        registerD = memoryRead((programCounter + 1) & 0xFFFF);
        programCounter = (programCounter + 2) & 0xFFFF;
        break;
    
    case 18:
        memoryWrite((registerD << 8) + registerE, registerA);
        break;
    
    case 19:
        temp_var = (((registerD << 8) + registerE) + 1);
        registerD = ((temp_var >> 8) & 0xFF);
        registerE = (temp_var & 0xFF);
        break;
    
    case 20:
        registerD = ((registerD + 1) & 0xFF);
        FZero = (registerD == 0);
        FHalfCarry = ((registerD & 0xF) == 0);
        FSubtract = FALSE;
        break;
    
    case 21:
        registerD = unsbtub(registerD - 1);
        FZero = (registerD == 0);
        FHalfCarry = ((registerD & 0xF) == 0xF);
        FSubtract = TRUE;
        break;
    
    case 22:
        registerD = memoryRead(programCounter);
        programCounter = (programCounter + 1) & 0xFFFF;
        break;
    
    case 23:
        carry_flag = t((FCarry),1,0);
        FCarry = ((registerA & 0x80) == 0x80);
        registerA = ((registerA << 1) & 0xFF) | carry_flag;
        FZero = FSubtract = FHalfCarry = FALSE;
        break;
    
    case 24:
        programCounter = nswtuw(programCounter + usbtsb(memoryRead(programCounter)) + 1);
        break;
    
    case 25:
        n2 = (registerD << 8) + registerE;
        dirtySum = registersHL + n2;
        FHalfCarry = ((registersHL & 0xFFF) + (n2 & 0xFFF) > 0xFFF);
        FCarry = (dirtySum > 0xFFFF);
        registersHL = (dirtySum & 0xFFFF);
        FSubtract = FALSE;
        break;
    
    case 26:
        registerA = memoryRead((registerD << 8) + registerE);
        break;
    
    case 27:
        temp_var = unswtuw(((registerD << 8) + registerE) - 1);
        registerD = (temp_var >> 8);
        registerE = (temp_var & 0xFF);
        break;
    
    case 28:
        registerE = ((registerE + 1) & 0xFF);
        FZero = (registerE == 0);
        FHalfCarry = ((registerE & 0xF) == 0);
        FSubtract = FALSE;
        break;
    
    case 29:
        registerE = unsbtub(registerE - 1);
        FZero = (registerE == 0);
        FHalfCarry = ((registerE & 0xF) == 0xF);
        FSubtract = TRUE;
        break;
    
    case 30:
        registerE = memoryRead(programCounter);
        programCounter = (programCounter + 1) & 0xFFFF;
        break;
    
    case 31:
        carry_flag = t((FCarry),0x80,0);
        FCarry = ((registerA & 1) == 1);
        registerA = (registerA >> 1) + carry_flag;
        FZero = FSubtract = FHalfCarry = FALSE;
        break;
    
    case 32:
        if (!FZero) {
            programCounter = nswtuw(programCounter + usbtsb(memoryRead(programCounter)) + 1);
            ++CPUTicks;
        } else {
            programCounter = (programCounter + 1) & 0xFFFF;
        }
        break;
    
    case 33:
        registersHL = (memoryRead((programCounter + 1) & 0xFFFF) << 8) + memoryRead(programCounter);
        programCounter = (programCounter + 2) & 0xFFFF;
        break;
    
    case 34:
        memoryWrite(registersHL, registerA);
        registersHL = ((registersHL + 1) & 0xFFFF);
        break;
    
    case 35:
        registersHL = ((registersHL + 1) & 0xFFFF);
        break;
    
    case 36:
        H = (((registersHL >> 8) + 1) & 0xFF);
        FZero = (H == 0);
        FHalfCarry = ((H & 0xF) == 0);
        FSubtract = FALSE;
        registersHL = (H << 8) + (registersHL & 0xFF);
        break;
    
    case 37:
        H = unsbtub((registersHL >> 8) - 1);
        FZero = (H == 0);
        FHalfCarry = ((H & 0xF) == 0xF);
        FSubtract = TRUE;
        registersHL = (H << 8) + (registersHL & 0xFF);
        break;
    
    case 38:
        registersHL = (memoryRead(programCounter) << 8) + (registersHL & 0xFF);
        programCounter = (programCounter + 1) & 0xFFFF;
        break;
    
    case 39:
        temp_var = registerA;
        if (FCarry) {
            temp_var |= 0x100;
        }
        if (FHalfCarry) {
            temp_var |= 0x200;
        }
        if (FSubtract) {
            temp_var |= 0x400;
        }
        registerA = (temp_var = DAATable[temp_var]) >> 8;
        FZero = ((temp_var & 0x80) == 0x80);
        FSubtract = ((temp_var & 0x40) == 0x40);
        FHalfCarry = ((temp_var & 0x20) == 0x20);
        FCarry = ((temp_var & 0x10) == 0x10);
        break;
    
    case 40:
        if (FZero) {
            programCounter = nswtuw(programCounter + usbtsb(memoryRead(programCounter)) + 1);
            ++CPUTicks;
        } else {
            programCounter = (programCounter + 1) & 0xFFFF;
        }
        break;
    
    case 41:
        ;
        FHalfCarry = ((registersHL & 0xFFF) > 0x7FF);
        FCarry = (registersHL > 0x7FFF);
        registersHL = ((2 * registersHL) & 0xFFFF);
        FSubtract = FALSE;
        break;
    
    case 42:
        registerA = memoryRead(registersHL);
        registersHL = ((registersHL + 1) & 0xFFFF);
        break;
    
    case 43:
        registersHL = unswtuw(registersHL - 1);
        break;
    
    case 44:
        L = ((registersHL + 1) & 0xFF);
        FZero = (L == 0);
        FHalfCarry = ((L & 0xF) == 0);
        FSubtract = FALSE;
        registersHL = (registersHL & 0xFF00) + L;
        break;
    
    case 45:
        L = unsbtub((registersHL & 0xFF) - 1);
        FZero = (L == 0);
        FHalfCarry = ((L & 0xF) == 0xF);
        FSubtract = TRUE;
        registersHL = (registersHL & 0xFF00) + L;
        break;
    
    case 46:
        registersHL = (registersHL & 0xFF00) + memoryRead(programCounter);
        programCounter = (programCounter + 1) & 0xFFFF;
        break;
    
    case 47:
        registerA ^= 0xFF;
        FSubtract = FHalfCarry = TRUE;
        break;
    
    case 48:
        if (!FCarry) {
            programCounter = nswtuw(programCounter + usbtsb(memoryRead(programCounter)) + 1);
            ++CPUTicks;
        } else {
            programCounter = (programCounter + 1) & 0xFFFF;
        }
        break;
    
    case 49:
        stackPointer = (memoryRead((programCounter + 1) & 0xFFFF) << 8) + memoryRead(programCounter);
        programCounter = (programCounter + 2) & 0xFFFF;
        break;
    
    case 50:
        memoryWrite(registersHL, registerA);
        registersHL = unswtuw(registersHL - 1);
        break;
    
    case 51:
        stackPointer = (stackPointer + 1) & 0xFFFF;
        break;
    
    case 52:
        temp_var = ((memoryRead(registersHL) + 1) & 0xFF);
        FZero = (temp_var == 0);
        FHalfCarry = ((temp_var & 0xF) == 0);
        FSubtract = FALSE;
        memoryWrite(registersHL, temp_var);
        break;
    
    case 53:
        temp_var = unsbtub(memoryRead(registersHL) - 1);
        FZero = (temp_var == 0);
        FHalfCarry = ((temp_var & 0xF) == 0xF);
        FSubtract = TRUE;
        memoryWrite(registersHL, temp_var);
        break;
    
    case 54:
        memoryWrite(registersHL, memoryRead(programCounter));
        programCounter = (programCounter + 1) & 0xFFFF;
        break;
    
    case 55:
        FCarry = TRUE;
        FSubtract = FHalfCarry = FALSE;
        break;
    
    case 56:
        if (FCarry) {
            programCounter = nswtuw(programCounter + usbtsb(memoryRead(programCounter)) + 1);
            ++CPUTicks;
        } else {
            programCounter = (programCounter + 1) & 0xFFFF;
        }
        break;
    
    case 57:
        dirtySum = registersHL + stackPointer;
        FHalfCarry = ((registersHL & 0xFFF) + (stackPointer & 0xFFF) > 0xFFF);
        FCarry = (dirtySum > 0xFFFF);
        registersHL = (dirtySum & 0xFFFF);
        FSubtract = FALSE;
        break;
    
    case 58:
        registerA = memoryRead(registersHL);
        registersHL = unswtuw(registersHL - 1);
        break;
    
    case 59:
        stackPointer = unswtuw(stackPointer - 1);
        break;
    
    case 60:
        registerA = ((registerA + 1) & 0xFF);
        FZero = (registerA == 0);
        FHalfCarry = ((registerA & 0xF) == 0);
        FSubtract = FALSE;
        break;
    
    case 61:
        registerA = unsbtub(registerA - 1);
        FZero = (registerA == 0);
        FHalfCarry = ((registerA & 0xF) == 0xF);
        FSubtract = TRUE;
        break;
    
    case 62:
        registerA = memoryRead(programCounter);
        programCounter = (programCounter + 1) & 0xFFFF;
        break;
    
    case 63:
        FCarry = !FCarry;
        FSubtract = FHalfCarry = FALSE;
        break;
    
    case 64:
        //Do nothing...
        break;
    
    case 65:
        registerB = registerC;
        break;
    
    case 66:
        registerB = registerD;
        break;
    
    case 67:
        registerB = registerE;
        break;
    
    case 68:
        registerB = (registersHL >> 8);
        break;
    
    case 69:
        registerB = (registersHL & 0xFF);
        break;
    
    case 70:
        registerB = memoryRead(registersHL);
        break;
    
    case 71:
        registerB = registerA;
        break;
    
    case 72:
        registerC = registerB;
        break;
    
    case 73:
        //Do nothing...
        break;
    
    case 74:
        registerC = registerD;
        break;
    
    case 75:
        registerC = registerE;
        break;
    
    case 76:
        registerC = (registersHL >> 8);
        break;
    
    case 77:
        registerC = (registersHL & 0xFF);
        break;
    
    case 78:
        registerC = memoryRead(registersHL);
        break;
    
    case 79:
        registerC = registerA;
        break;
    
    case 80:
        registerD = registerB;
        break;
    
    case 81:
        registerD = registerC;
        break;
    
    case 82:
        //Do nothing...
        break;
    
    case 83:
        registerD = registerE;
        break;
    
    case 84:
        registerD = (registersHL >> 8);
        break;
    
    case 85:
        registerD = (registersHL & 0xFF);
        break;
    
    case 86:
        registerD = memoryRead(registersHL);
        break;
    
    case 87:
        registerD = registerA;
        break;
    
    case 88:
        registerE = registerB;
        break;
    
    case 89:
        registerE = registerC;
        break;
    
    case 90:
        registerE = registerD;
        break;
    
    case 91:
        //Do nothing...
        break;
    
    case 92:
        registerE = (registersHL >> 8);
        break;
    
    case 93:
        registerE = (registersHL & 0xFF);
        break;
    
    case 94:
        registerE = memoryRead(registersHL);
        break;
    
    case 95:
        registerE = registerA;
        break;
    
    case 96:
        registersHL = (registerB << 8) + (registersHL & 0xFF);
        break;
    
    case 97:
        registersHL = (registerC << 8) + (registersHL & 0xFF);
        break;
    
    case 98:
        registersHL = (registerD << 8) + (registersHL & 0xFF);
        break;
    
    case 99:
        registersHL = (registerE << 8) + (registersHL & 0xFF);
        break;
    
    case 100:
        //Do nothing...
        break;
    
    case 101:
        registersHL = ((registersHL & 0xFF) << 8) + (registersHL & 0xFF);
        break;
    
    case 102:
        registersHL = (memoryRead(registersHL) << 8) + (registersHL & 0xFF);
        break;
    
    case 103:
        registersHL = (registerA << 8) + (registersHL & 0xFF);
        break;
    
    case 104:
        registersHL = (registersHL & 0xFF00) + registerB;
        break;
    
    case 105:
        registersHL = (registersHL & 0xFF00) + registerC;
        break;
    
    case 106:
        registersHL = (registersHL & 0xFF00) + registerD;
        break;
    
    case 107:
        registersHL = (registersHL & 0xFF00) + registerE;
        break;
    
    case 108:
        registersHL = (registersHL & 0xFF00) + (registersHL >> 8);
        break;
    
    case 109:
        //Do nothing...
        break;
    
    case 110:
        registersHL = (registersHL & 0xFF00) + memoryRead(registersHL);
        break;
    
    case 111:
        registersHL = (registersHL & 0xFF00) + registerA;
        break;
    
    case 112:
        memoryWrite(registersHL, registerB);
        break;
    
    case 113:
        memoryWrite(registersHL, registerC);
        break;
    
    case 114:
        memoryWrite(registersHL, registerD);
        break;
    
    case 115:
        memoryWrite(registersHL, registerE);
        break;
    
    case 116:
        memoryWrite(registersHL, (registersHL >> 8));
        break;
    
    case 117:
        memoryWrite(registersHL, (registersHL & 0xFF));
        break;
    
    case 118:
        if (untilEnable == 1) {
            
            programCounter = nswtuw(programCounter - 1);
        } else {
            if (!halt && !IME && (memory[0xFF0F] & memory[0xFFFF] & 0x1F) > 0) {
                skipPCIncrement = TRUE;
            }
            halt = TRUE;
            while (halt && (stopEmulator & 1) == 0) {
                
                bitShift = 0;
                testbit = 1;
                interrupts = memory[0xFFFF] & memory[0xFF0F];
                while (bitShift < 5) {
                    //Check to see if an interrupt is enabled AND requested.
                    if ((testbit & interrupts) == testbit) {
                        halt = FALSE; //Get out of halt state if in halt state.
                        return; //Let the main interrupt handler compute the interrupt.
                    }
                    testbit = 1 << ++bitShift;
                }
                CPUTicks = 1; //1 machine cycle under HALT...
                //Timing:
                updateCore();
            }
            //Throw an error on purpose to exit out of the loop.
            //throw new Exception('HALT_OVERRUN');
        }
        break;
    
    case 119:
        memoryWrite(registersHL, registerA);
        break;
    
    case 120:
        registerA = registerB;
        break;
    
    case 121:
        registerA = registerC;
        break;
    
    case 122:
        registerA = registerD;
        break;
    
    case 123:
        registerA = registerE;
        break;
    
    case 124:
        registerA = (registersHL >> 8);
        break;
    
    case 125:
        registerA = (registersHL & 0xFF);
        break;
    
    case 126:
        registerA = memoryRead(registersHL);
        break;
    
    case 127:
        //Do Nothing...
        break;
    
    case 128:
        dirtySum = registerA + registerB;
        FHalfCarry = (dirtySum & 0xF) < (registerA & 0xF);
        FCarry = (dirtySum > 0xFF);
        registerA = dirtySum & 0xFF;
        FZero = (registerA == 0);
        FSubtract = FALSE;
        break;
    
    case 129:
        dirtySum = registerA + registerC;
        FHalfCarry = (dirtySum & 0xF) < (registerA & 0xF);
        FCarry = (dirtySum > 0xFF);
        registerA = dirtySum & 0xFF;
        FZero = (registerA == 0);
        FSubtract = FALSE;
        break;
    
    case 130:
        dirtySum = registerA + registerD;
        FHalfCarry = (dirtySum & 0xF) < (registerA & 0xF);
        FCarry = (dirtySum > 0xFF);
        registerA = dirtySum & 0xFF;
        FZero = (registerA == 0);
        FSubtract = FALSE;
        break;
    
    case 131:
        dirtySum = registerA + registerE;
        FHalfCarry = (dirtySum & 0xF) < (registerA & 0xF);
        FCarry = (dirtySum > 0xFF);
        registerA = dirtySum & 0xFF;
        FZero = (registerA == 0);
        FSubtract = FALSE;
        break;
    
    case 132:
        dirtySum = registerA + (registersHL >> 8);
        FHalfCarry = (dirtySum & 0xF) < (registerA & 0xF);
        FCarry = (dirtySum > 0xFF);
        registerA = dirtySum & 0xFF;
        FZero = (registerA == 0);
        FSubtract = FALSE;
        break;
    
    case 133:
        dirtySum = registerA + (registersHL & 0xFF);
        FHalfCarry = (dirtySum & 0xF) < (registerA & 0xF);
        FCarry = (dirtySum > 0xFF);
        registerA = dirtySum & 0xFF;
        FZero = (registerA == 0);
        FSubtract = FALSE;
        break;
    
    case 134:
        dirtySum = registerA + memoryRead(registersHL);
        FHalfCarry = (dirtySum & 0xF) < (registerA & 0xF);
        FCarry = (dirtySum > 0xFF);
        registerA = dirtySum & 0xFF;
        FZero = (registerA == 0);
        FSubtract = FALSE;
        break;
    
    case 135:
        dirtySum = registerA * 2;
        FHalfCarry = (dirtySum & 0xF) < (registerA & 0xF);
        FCarry = (dirtySum > 0xFF);
        registerA = dirtySum & 0xFF;
        FZero = (registerA == 0);
        FSubtract = FALSE;
        break;
    
    case 136:
        dirtySum = registerA + registerB + t((FCarry),1,0);
        FHalfCarry = ((registerA & 0xF) + (registerB & 0xF) + t((FCarry),1,0) > 0xF);
        FCarry = (dirtySum > 0xFF);
        registerA = dirtySum & 0xFF;
        FZero = (registerA == 0);
        FSubtract = FALSE;
        break;
    
    case 137:
        dirtySum = registerA + registerC + t((FCarry),1,0);
        FHalfCarry = ((registerA & 0xF) + (registerC & 0xF) + t((FCarry),1,0) > 0xF);
        FCarry = (dirtySum > 0xFF);
        registerA = dirtySum & 0xFF;
        FZero = (registerA == 0);
        FSubtract = FALSE;
        break;
    
    case 138:
        dirtySum = registerA + registerD + t((FCarry),1,0);
        FHalfCarry = ((registerA & 0xF) + (registerD & 0xF) + t((FCarry),1,0) > 0xF);
        FCarry = (dirtySum > 0xFF);
        registerA = dirtySum & 0xFF;
        FZero = (registerA == 0);
        FSubtract = FALSE;
        break;
    
    case 139:
        dirtySum = registerA + registerE + t((FCarry),1,0);
        FHalfCarry = ((registerA & 0xF) + (registerE & 0xF) + t((FCarry),1,0) > 0xF);
        FCarry = (dirtySum > 0xFF);
        registerA = dirtySum & 0xFF;
        FZero = (registerA == 0);
        FSubtract = FALSE;
        break;
    
    case 140:
        tempValue = (registersHL >> 8);
        dirtySum = registerA + tempValue + t((FCarry),1,0);
        FHalfCarry = ((registerA & 0xF) + (tempValue & 0xF) + t((FCarry),1,0) > 0xF);
        FCarry = (dirtySum > 0xFF);
        registerA = dirtySum & 0xFF;
        FZero = (registerA == 0);
        FSubtract = FALSE;
        break;
    
    case 141:
        tempValue = (registersHL & 0xFF);
        dirtySum = registerA + tempValue + t((FCarry),1,0);
        FHalfCarry = ((registerA & 0xF) + (tempValue & 0xF) + t((FCarry),1,0) > 0xF);
        FCarry = (dirtySum > 0xFF);
        registerA = dirtySum & 0xFF;
        FZero = (registerA == 0);
        FSubtract = FALSE;
        break;
    
    case 142:
        tempValue = memoryRead(registersHL);
        dirtySum = registerA + tempValue + t((FCarry),1,0);
        FHalfCarry = ((registerA & 0xF) + (tempValue & 0xF) + t((FCarry),1,0) > 0xF);
        FCarry = (dirtySum > 0xFF);
        registerA = dirtySum & 0xFF;
        FZero = (registerA == 0);
        FSubtract = FALSE;
        break;
    
    case 143:
        dirtySum = (registerA * 2) + t((FCarry),1,0);
        FHalfCarry = ((registerA & 0xF) + (registerA & 0xF) + t((FCarry),1,0) > 0xF);
        FCarry = (dirtySum > 0xFF);
        registerA = dirtySum & 0xFF;
        FZero = (registerA == 0);
        FSubtract = FALSE;
        break;
    
    case 144:
        dirtySum = registerA - registerB;
        FHalfCarry = (registerA & 0xF) < (registerB & 0xF);
        FCarry = (dirtySum < 0);
        registerA = unsbtub(dirtySum);
        FZero = (registerA == 0);
        FSubtract = TRUE;
        break;
    
    case 145:
        dirtySum = registerA - registerC;
        FHalfCarry = (registerA & 0xF) < (registerC & 0xF);
        FCarry = (dirtySum < 0);
        registerA = unsbtub(dirtySum);
        FZero = (registerA == 0);
        FSubtract = TRUE;
        break;
    
    case 146:
        dirtySum = registerA - registerD;
        FHalfCarry = (registerA & 0xF) < (registerD & 0xF);
        FCarry = (dirtySum < 0);
        registerA = unsbtub(dirtySum);
        FZero = (registerA == 0);
        FSubtract = TRUE;
        break;
    
    case 147:
        dirtySum = registerA - registerE;
        FHalfCarry = (registerA & 0xF) < (registerE & 0xF);
        FCarry = (dirtySum < 0);
        registerA = unsbtub(dirtySum);
        FZero = (registerA == 0);
        FSubtract = TRUE;
        break;
    
    case 148:
        temp_var = registersHL >> 8;
        dirtySum = registerA - temp_var;
        FHalfCarry = (registerA & 0xF) < (temp_var & 0xF);
        FCarry = (dirtySum < 0);
        registerA = unsbtub(dirtySum);
        FZero = (registerA == 0);
        FSubtract = TRUE;
        break;
    
    case 149:
        dirtySum = registerA - (registersHL & 0xFF);
        FHalfCarry = (registerA & 0xF) < (registersHL & 0xF);
        FCarry = (dirtySum < 0);
        registerA = unsbtub(dirtySum);
        FZero = (registerA == 0);
        FSubtract = TRUE;
        break;
    
    case 150:
        temp_var = memoryRead(registersHL);
        dirtySum = registerA - temp_var;
        FHalfCarry = (registerA & 0xF) < (temp_var & 0xF);
        FCarry = (dirtySum < 0);
        registerA = unsbtub(dirtySum);
        FZero = (registerA == 0);
        FSubtract = TRUE;
        break;
    
    case 151:
        //number - same number == 0
        registerA = 0;
        FHalfCarry = FCarry = FALSE;
        FZero = FSubtract = TRUE;
        break;
    
    case 152:
        dirtySum = registerA - registerB - t((FCarry),1,0);
        FHalfCarry = ((registerA & 0xF) - (registerB & 0xF) - t((FCarry),1,0) < 0);
        FCarry = (dirtySum < 0);
        registerA = unsbtub(dirtySum);
        FZero = (registerA == 0);
        FSubtract = TRUE;
        break;
    
    case 153:
        dirtySum = registerA - registerC - t((FCarry),1,0);
        FHalfCarry = ((registerA & 0xF) - (registerC & 0xF) - t((FCarry),1,0) < 0);
        FCarry = (dirtySum < 0);
        registerA = unsbtub(dirtySum);
        FZero = (registerA == 0);
        FSubtract = TRUE;
        break;
    
    case 154:
        dirtySum = registerA - registerD - t((FCarry),1,0);
        FHalfCarry = ((registerA & 0xF) - (registerD & 0xF) - t((FCarry),1,0) < 0);
        FCarry = (dirtySum < 0);
        registerA = unsbtub(dirtySum);
        FZero = (registerA == 0);
        FSubtract = TRUE;
        break;
    
    case 155:
        dirtySum = registerA - registerE - t((FCarry),1,0);
        FHalfCarry = ((registerA & 0xF) - (registerE & 0xF) - t((FCarry),1,0) < 0);
        FCarry = (dirtySum < 0);
        registerA = unsbtub(dirtySum);
        FZero = (registerA == 0);
        FSubtract = TRUE;
        break;
    
    case 156:
        temp_var = registersHL >> 8;
        dirtySum = registerA - temp_var - t((FCarry),1,0);
        FHalfCarry = ((registerA & 0xF) - (temp_var & 0xF) - t((FCarry),1,0) < 0);
        FCarry = (dirtySum < 0);
        registerA = unsbtub(dirtySum);
        FZero = (registerA == 0);
        FSubtract = TRUE;
        break;
    
    case 157:
        dirtySum = registerA - (registersHL & 0xFF) - t((FCarry),1,0);
        FHalfCarry = ((registerA & 0xF) - (registersHL & 0xF) - t((FCarry),1,0) < 0);
        FCarry = (dirtySum < 0);
        registerA = unsbtub(dirtySum);
        FZero = (registerA == 0);
        FSubtract = TRUE;
        break;
    
    case 158:
        temp_var = memoryRead(registersHL);
        dirtySum = registerA - temp_var - t((FCarry),1,0);
        FHalfCarry = ((registerA & 0xF) - (temp_var & 0xF) - t((FCarry),1,0) < 0);
        FCarry = (dirtySum < 0);
        registerA = unsbtub(dirtySum);
        FZero = (registerA == 0);
        FSubtract = TRUE;
        break;
    
    case 159:
        //Optimized SBC A:
        if (FCarry) {
            FZero = FALSE;
            FSubtract = FHalfCarry = FCarry = TRUE;
            registerA = 0xFF;
        } else {
            FHalfCarry = FCarry = FALSE;
            FSubtract = FZero = TRUE;
            registerA = 0;
        }
        break;
    
    case 160:
        registerA &= registerB;
        FZero = (registerA == 0);
        FHalfCarry = TRUE;
        FSubtract = FCarry = FALSE;
        break;
    
    case 161:
        registerA &= registerC;
        FZero = (registerA == 0);
        FHalfCarry = TRUE;
        FSubtract = FCarry = FALSE;
        break;
    
    case 162:
        registerA &= registerD;
        FZero = (registerA == 0);
        FHalfCarry = TRUE;
        FSubtract = FCarry = FALSE;
        break;
    
    case 163:
        registerA &= registerE;
        FZero = (registerA == 0);
        FHalfCarry = TRUE;
        FSubtract = FCarry = FALSE;
        break;
    
    case 164:
        registerA &= (registersHL >> 8);
        FZero = (registerA == 0);
        FHalfCarry = TRUE;
        FSubtract = FCarry = FALSE;
        break;
    
    case 165:
        registerA &= (registersHL & 0xFF);
        FZero = (registerA == 0);
        FHalfCarry = TRUE;
        FSubtract = FCarry = FALSE;
        break;
    
    case 166:
        registerA &= memoryRead(registersHL);
        FZero = (registerA == 0);
        FHalfCarry = TRUE;
        FSubtract = FCarry = FALSE;
        break;
    
    case 167:
        //number & same number = same number
        FZero = (registerA == 0);
        FHalfCarry = TRUE;
        FSubtract = FCarry = FALSE;
        break;
    
    case 168:
        registerA ^= registerB;
        FZero = (registerA == 0);
        FSubtract = FHalfCarry = FCarry = FALSE;
        break;
    
    case 169:
        registerA ^= registerC;
        FZero = (registerA == 0);
        FSubtract = FHalfCarry = FCarry = FALSE;
        break;
    
    case 170:
        registerA ^= registerD;
        FZero = (registerA == 0);
        FSubtract = FHalfCarry = FCarry = FALSE;
        break;
    
    case 171:
        registerA ^= registerE;
        FZero = (registerA == 0);
        FSubtract = FHalfCarry = FCarry = FALSE;
        break;
    
    case 172:
        registerA ^= (registersHL >> 8);
        FZero = (registerA == 0);
        FSubtract = FHalfCarry = FCarry = FALSE;
        break;
    
    case 173:
        registerA ^= (registersHL & 0xFF);
        FZero = (registerA == 0);
        FSubtract = FHalfCarry = FCarry = FALSE;
        break;
    
    case 174:
        registerA ^= memoryRead(registersHL);
        FZero = (registerA == 0);
        FSubtract = FHalfCarry = FCarry = FALSE;
        break;
    
    case 175:
        //number ^ same number == 0
        registerA = 0;
        FZero = TRUE;
        FSubtract = FHalfCarry = FCarry = FALSE;
        break;
    
    case 176:
        registerA |= registerB;
        FZero = (registerA == 0);
        FSubtract = FCarry = FHalfCarry = FALSE;
        break;
    
    case 177:
        registerA |= registerC;
        FZero = (registerA == 0);
        FSubtract = FCarry = FHalfCarry = FALSE;
        break;
    
    case 178:
        registerA |= registerD;
        FZero = (registerA == 0);
        FSubtract = FCarry = FHalfCarry = FALSE;
        break;
    
    case 179:
        registerA |= registerE;
        FZero = (registerA == 0);
        FSubtract = FCarry = FHalfCarry = FALSE;
        break;
    
    case 180:
        registerA |= (registersHL >> 8);
        FZero = (registerA == 0);
        FSubtract = FCarry = FHalfCarry = FALSE;
        break;
    
    case 181:
        registerA |= (registersHL & 0xFF);
        FZero = (registerA == 0);
        FSubtract = FCarry = FHalfCarry = FALSE;
        break;
    
    case 182:
        registerA |= memoryRead(registersHL);
        FZero = (registerA == 0);
        FSubtract = FCarry = FHalfCarry = FALSE;
        break;
    
    case 183:
        //number | same number == same number
        FZero = (registerA == 0);
        FSubtract = FCarry = FHalfCarry = FALSE;
        break;
    
    case 184:
        dirtySum = registerA - registerB;
        FHalfCarry = (unsbtub(dirtySum) & 0xF) > (registerA & 0xF);
        FCarry = (dirtySum < 0);
        FZero = (dirtySum == 0);
        FSubtract = TRUE;
        break;
    
    case 185:
        dirtySum = registerA - registerC;
        FHalfCarry = (unsbtub(dirtySum) & 0xF) > (registerA & 0xF);
        FCarry = (dirtySum < 0);
        FZero = (dirtySum == 0);
        FSubtract = TRUE;
        break;
    
    case 186:
        dirtySum = registerA - registerD;
        FHalfCarry = (unsbtub(dirtySum) & 0xF) > (registerA & 0xF);
        FCarry = (dirtySum < 0);
        FZero = (dirtySum == 0);
        FSubtract = TRUE;
        break;
    
    case 187:
        dirtySum = registerA - registerE;
        FHalfCarry = (unsbtub(dirtySum) & 0xF) > (registerA & 0xF);
        FCarry = (dirtySum < 0);
        FZero = (dirtySum == 0);
        FSubtract = TRUE;
        break;
    
    case 188:
        dirtySum = registerA - (registersHL >> 8);
        FHalfCarry = (unsbtub(dirtySum) & 0xF) > (registerA & 0xF);
        FCarry = (dirtySum < 0);
        FZero = (dirtySum == 0);
        FSubtract = TRUE;
        break;
    
    case 189:
        dirtySum = registerA - (registersHL & 0xFF);
        FHalfCarry = (unsbtub(dirtySum) & 0xF) > (registerA & 0xF);
        FCarry = (dirtySum < 0);
        FZero = (dirtySum == 0);
        FSubtract = TRUE;
        break;
    
    case 190:
        dirtySum = registerA - memoryRead(registersHL);
        FHalfCarry = (unsbtub(dirtySum) & 0xF) > (registerA & 0xF);
        FCarry = (dirtySum < 0);
        FZero = (dirtySum == 0);
        FSubtract = TRUE;
        break;
    
    case 191:
        FHalfCarry = FCarry = FALSE;
        FZero = FSubtract = TRUE;
        break;
    
    case 192:
        if (!FZero) {
            programCounter = (memoryRead((stackPointer + 1) & 0xFFFF) << 8) + memoryRead(stackPointer);
            stackPointer = (stackPointer + 2) & 0xFFFF;
            CPUTicks += 3;
        }
        break;
    
    case 193:
        registerC = memoryRead(stackPointer);
        registerB = memoryRead((stackPointer + 1) & 0xFFFF);
        stackPointer = (stackPointer + 2) & 0xFFFF;
        break;
    
    case 194:
        if (!FZero) {
            programCounter = (memoryRead((programCounter + 1) & 0xFFFF) << 8) + memoryRead(programCounter);
            ++CPUTicks;
        } else {
            programCounter = (programCounter + 2) & 0xFFFF;
        }
        break;
    
    case 195:
        programCounter = (memoryRead((programCounter + 1) & 0xFFFF) << 8) + memoryRead(programCounter);
        break;
    
    case 196:
        if (!FZero) {
            temp_pc = (memoryRead((programCounter + 1) & 0xFFFF) << 8) + memoryRead(programCounter);
            programCounter = (programCounter + 2) & 0xFFFF;
            stackPointer = unswtuw(stackPointer - 1);
            memoryWrite(stackPointer, programCounter >> 8);
            stackPointer = unswtuw(stackPointer - 1);
            memoryWrite(stackPointer, programCounter & 0xFF);
            programCounter = temp_pc;
            CPUTicks += 3;
        } else {
            programCounter = (programCounter + 2) & 0xFFFF;
        }
        break;
    
    case 197:
        stackPointer = unswtuw(stackPointer - 1);
        memoryWrite(stackPointer, registerB);
        stackPointer = unswtuw(stackPointer - 1);
        memoryWrite(stackPointer, registerC);
        break;
    
    case 198:
        dirtySum = registerA + memoryRead(programCounter);
        FHalfCarry = (dirtySum & 0xF) < (registerA & 0xF);
        FCarry = (dirtySum > 0xFF);
        registerA = dirtySum & 0xFF;
        FZero = (registerA == 0);
        FSubtract = FALSE;
        programCounter = (programCounter + 1) & 0xFFFF;
        break;
    
    case 199:
        stackPointer = unswtuw(stackPointer - 1);
        memoryWrite(stackPointer, programCounter >> 8);
        stackPointer = unswtuw(stackPointer - 1);
        memoryWrite(stackPointer, programCounter & 0xFF);
        programCounter = 0;
        break;
    
    case 200:
        if (FZero) {
            programCounter = (memoryRead((stackPointer + 1) & 0xFFFF) << 8) + memoryRead(stackPointer);
            stackPointer = (stackPointer + 2) & 0xFFFF;
            CPUTicks += 3;
        }
        break;
    
    case 201:
        programCounter = (memoryRead((stackPointer + 1) & 0xFFFF) << 8) + memoryRead(stackPointer);
        stackPointer = (stackPointer + 2) & 0xFFFF;
        break;
    
    case 202:
        if (FZero) {
            programCounter = (memoryRead((programCounter + 1) & 0xFFFF) << 8) + memoryRead(programCounter);
            ++CPUTicks;
        } else {
            programCounter = (programCounter + 2) & 0xFFFF;
        }
        break;
    
    case 203:
        cb_opcode = memoryRead(programCounter);
        //Increment the program counter to the next instruction:
        programCounter = (programCounter + 1) & 0xFFFF;
        //Get how many CPU cycles the current 0xCBXX op code counts for:
        CPUTicks = SecondaryTICKTable[cb_opcode];
        //Execute secondary OP codes for the 0xCB OP code call.
        //Cbopcode::run($core, $opcode);
        #include "Cbopcode";
        break;
    
    case 204:
        if (FZero) {
            temp_pc = (memoryRead((programCounter + 1) & 0xFFFF) << 8) + memoryRead(programCounter);
            programCounter = (programCounter + 2) & 0xFFFF;
            stackPointer = unswtuw(stackPointer - 1);
            memoryWrite(stackPointer, programCounter >> 8);
            stackPointer = unswtuw(stackPointer - 1);
            memoryWrite(stackPointer, programCounter & 0xFF);
            programCounter = temp_pc;
            CPUTicks += 3;
        } else {
            programCounter = (programCounter + 2) & 0xFFFF;
        }
        break;
    
    case 205:
        temp_pc = (memoryRead((programCounter + 1) & 0xFFFF) << 8) + memoryRead(programCounter);
        programCounter = (programCounter + 2) & 0xFFFF;
        stackPointer = unswtuw(stackPointer - 1);
        memoryWrite(stackPointer, programCounter >> 8);
        stackPointer = unswtuw(stackPointer - 1);
        memoryWrite(stackPointer, programCounter & 0xFF);
        programCounter = temp_pc;
        break;
    
    case 206:
        tempValue = memoryRead(programCounter);
        dirtySum = registerA + tempValue + t((FCarry),1,0);
        FHalfCarry = ((registerA & 0xF) + (tempValue & 0xF) + t((FCarry),1,0) > 0xF);
        FCarry = (dirtySum > 0xFF);
        registerA = dirtySum & 0xFF;
        FZero = (registerA == 0);
        FSubtract = FALSE;
        programCounter = (programCounter + 1) & 0xFFFF;
        break;
    
    case 207:
        stackPointer = unswtuw(stackPointer - 1);
        memoryWrite(stackPointer, programCounter >> 8);
        stackPointer = unswtuw(stackPointer - 1);
        memoryWrite(stackPointer, programCounter & 0xFF);
        programCounter = 0x8;
        break;
    
    case 208:
        if (!FCarry) {
            programCounter = (memoryRead((stackPointer + 1) & 0xFFFF) << 8) + memoryRead(stackPointer);
            stackPointer = (stackPointer + 2) & 0xFFFF;
            CPUTicks += 3;
        }
        break;
    
    case 209:
        registerE = memoryRead(stackPointer);
        registerD = memoryRead((stackPointer + 1) & 0xFFFF);
        stackPointer = (stackPointer + 2) & 0xFFFF;
        break;
    
    case 210:
        if (!FCarry) {
            programCounter = (memoryRead((programCounter + 1) & 0xFFFF) << 8) + memoryRead(programCounter);
            ++CPUTicks;
        } else {
            programCounter = (programCounter + 2) & 0xFFFF;
        }
        break;
    
    case 211:
        // @TODO
        // cout("Illegal op code 0xD3 called, pausing emulation.", 2);
        // pause();
        break;
    
    case 212:
        if (!FCarry) {
            temp_pc = (memoryRead((programCounter + 1) & 0xFFFF) << 8) + memoryRead(programCounter);
            programCounter = (programCounter + 2) & 0xFFFF;
            stackPointer = unswtuw(stackPointer - 1);
            memoryWrite(stackPointer, programCounter >> 8);
            stackPointer = unswtuw(stackPointer - 1);
            memoryWrite(stackPointer, programCounter & 0xFF);
            programCounter = temp_pc;
            CPUTicks += 3;
        } else {
            programCounter = (programCounter + 2) & 0xFFFF;
        }
        break;
    
    case 213:
        stackPointer = unswtuw(stackPointer - 1);
        memoryWrite(stackPointer, registerD);
        stackPointer = unswtuw(stackPointer - 1);
        memoryWrite(stackPointer, registerE);
        break;
    
    case 214:
        temp_var = memoryRead(programCounter);
        dirtySum = registerA - temp_var;
        FHalfCarry = (registerA & 0xF) < (temp_var & 0xF);
        FCarry = (dirtySum < 0);
        registerA = unsbtub(dirtySum);
        programCounter = (programCounter + 1) & 0xFFFF;
        FZero = (registerA == 0);
        FSubtract = TRUE;
        break;
    
    case 215:
        stackPointer = unswtuw(stackPointer - 1);
        memoryWrite(stackPointer, programCounter >> 8);
        stackPointer = unswtuw(stackPointer - 1);
        memoryWrite(stackPointer, programCounter & 0xFF);
        programCounter = 0x10;
        break;
    
    case 216:
        if (FCarry) {
            programCounter = (memoryRead((stackPointer + 1) & 0xFFFF) << 8) + memoryRead(stackPointer);
            stackPointer = (stackPointer + 2) & 0xFFFF;
            CPUTicks += 3;
        }
        break;
    
    case 217:
        programCounter = (memoryRead((stackPointer + 1) & 0xFFFF) << 8) + memoryRead(stackPointer);
        stackPointer = (stackPointer + 2) & 0xFFFF;
        //IME = TRUE;
        untilEnable = 2;
        break;
    
    case 218:
        if (FCarry) {
            programCounter = (memoryRead((programCounter + 1) & 0xFFFF) << 8) + memoryRead(programCounter);
            ++CPUTicks;
        } else {
            programCounter = (programCounter + 2) & 0xFFFF;
        }
        break;
    
    case 219:
        "Illegal op code 0xDB called, pausing emulation.\n";
        PressAKey;
        break;
    
    case 220:
        if (FCarry) {
            temp_pc = (memoryRead((programCounter + 1) & 0xFFFF) << 8) + memoryRead(programCounter);
            programCounter = (programCounter + 2) & 0xFFFF;
            stackPointer = unswtuw(stackPointer - 1);
            memoryWrite(stackPointer, programCounter >> 8);
            stackPointer = unswtuw(stackPointer - 1);
            memoryWrite(stackPointer, programCounter & 0xFF);
            programCounter = temp_pc;
            CPUTicks += 3;
        } else {
            programCounter = (programCounter + 2) & 0xFFFF;
        }
        break;
    
    case 221:
        "Illegal op code 0xDD called, pausing emulation.\n";
        PressAKey;
        break;
    
    case 222:
        temp_var = memoryRead(programCounter);
        dirtySum = registerA - temp_var - t((FCarry),1,0);
        FHalfCarry = ((registerA & 0xF) - (temp_var & 0xF) - t((FCarry),1,0) < 0);
        FCarry = (dirtySum < 0);
        registerA = unsbtub(dirtySum);
        programCounter = (programCounter + 1) & 0xFFFF;
        FZero = (registerA == 0);
        FSubtract = TRUE;
        break;
    
    case 223:
        stackPointer = unswtuw(stackPointer - 1);
        memoryWrite(stackPointer, programCounter >> 8);
        stackPointer = unswtuw(stackPointer - 1);
        memoryWrite(stackPointer, programCounter & 0xFF);
        programCounter = 0x18;
        break;
    
    case 224:
        memoryWrite(0xFF00 + memoryRead(programCounter), registerA);
        programCounter = (programCounter + 1) & 0xFFFF;
        break;
    
    case 225:
        registersHL = (memoryRead((stackPointer + 1) & 0xFFFF) << 8) + memoryRead(stackPointer);
        stackPointer = (stackPointer + 2) & 0xFFFF;
        break;
    
    case 226:
        memoryWrite(0xFF00 + registerC, registerA);
        break;
    
    case 227:
        "Illegal op code 0xE3 called, pausing emulation.\n";
        PressAKey;
        break;
    
    case 228:
        "Illegal op code 0xE4 called, pausing emulation.\n";
        PressAKey;
        break;
    
    case 229:
        stackPointer = unswtuw(stackPointer - 1);
        memoryWrite(stackPointer, registersHL >> 8);
        stackPointer = unswtuw(stackPointer - 1);
        memoryWrite(stackPointer, registersHL & 0xFF);
        break;
    
    case 230:
        registerA &= memoryRead(programCounter);
        programCounter = (programCounter + 1) & 0xFFFF;
        FZero = (registerA == 0);
        FHalfCarry = TRUE;
        FSubtract = FCarry = FALSE;
        break;
    
    case 231:
        stackPointer = unswtuw(stackPointer - 1);
        memoryWrite(stackPointer, programCounter >> 8);
        stackPointer = unswtuw(stackPointer - 1);
        memoryWrite(stackPointer, programCounter & 0xFF);
        programCounter = 0x20;
        break;
    
    case 232:
        signedByte = usbtsb(memoryRead(programCounter));
        temp_value = nswtuw(stackPointer + signedByte);
        FCarry = (((stackPointer ^ signedByte ^ temp_value) & 0x100) == 0x100);
        FHalfCarry = (((stackPointer ^ signedByte ^ temp_value) & 0x10) == 0x10);
        stackPointer = temp_value;
        programCounter = (programCounter + 1) & 0xFFFF;
        FZero = FSubtract = FALSE;
        break;
    
    case 233:
        programCounter = registersHL;
        break;
    
    case 234:
        memoryWrite((memoryRead((programCounter + 1) & 0xFFFF) << 8) + memoryRead(programCounter), registerA);
        programCounter = (programCounter + 2) & 0xFFFF;
        break;
    
    case 235:
        "Illegal op code 0xEB called, pausing emulation.\n";
        PressAKey;
        break;
    
    case 236:
        "Illegal op code 0xEC called, pausing emulation.\n";
        PressAKey;
        break;
    
    case 237:
        "Illegal op code 0xED called, pausing emulation.\n";
        PressAKey;
        break;
    
    case 238:
        registerA ^= memoryRead(programCounter);
        FZero = (registerA == 0);
        programCounter = (programCounter + 1) & 0xFFFF;
        FSubtract = FHalfCarry = FCarry = FALSE;
        break;
    
    case 239:
        stackPointer = unswtuw(stackPointer - 1);
        memoryWrite(stackPointer, programCounter >> 8);
        stackPointer = unswtuw(stackPointer - 1);
        memoryWrite(stackPointer, programCounter & 0xFF);
        programCounter = 0x28;
        break;
    
    case 240:
        registerA = memoryRead(0xFF00 + memoryRead(programCounter));
        programCounter = (programCounter + 1) & 0xFFFF;
        break;
    
    case 241:
        temp_var = memoryRead(stackPointer);
        FZero = ((temp_var & 0x80) == 0x80);
        FSubtract = ((temp_var & 0x40) == 0x40);
        FHalfCarry = ((temp_var & 0x20) == 0x20);
        FCarry = ((temp_var & 0x10) == 0x10);
        registerA = memoryRead((stackPointer + 1) & 0xFFFF);
        stackPointer = (stackPointer + 2) & 0xFFFF;
        break;
    
    case 242:
        registerA = memoryRead(0xFF00 + registerC);
        break;
    
    case 243:
        IME = FALSE;
        untilEnable = 0;
        break;
    
    case 244:
        // @TODO
        // cout("Illegal op code 0xF4 called, pausing emulation.", 2);
        // pause();
        break;
    
    case 245:
        stackPointer = unswtuw(stackPointer - 1);
        memoryWrite(stackPointer, registerA);
        stackPointer = unswtuw(stackPointer - 1);
        memoryWrite(stackPointer, t((FZero),0x80,0) + t((FSubtract),0x40,0) + t((FHalfCarry),0x20,0) + t((FCarry),0x10,0));
        break;
    
    case 246:
        registerA |= memoryRead(programCounter);
        FZero = (registerA == 0);
        programCounter = (programCounter + 1) & 0xFFFF;
        FSubtract = FCarry = FHalfCarry = FALSE;
        break;
    
    case 247:
        stackPointer = unswtuw(stackPointer - 1);
        memoryWrite(stackPointer, programCounter >> 8);
        stackPointer = unswtuw(stackPointer - 1);
        memoryWrite(stackPointer, programCounter & 0xFF);
        programCounter = 0x30;
        break;
    
    case 248:
        signedByte = usbtsb(memoryRead(programCounter));
        registersHL = nswtuw(stackPointer + signedByte);
        FCarry = (((stackPointer ^ signedByte ^ registersHL) & 0x100) == 0x100);
        FHalfCarry = (((stackPointer ^ signedByte ^ registersHL) & 0x10) == 0x10);
        programCounter = (programCounter + 1) & 0xFFFF;
        FZero = FSubtract = FALSE;
        break;
    
    case 249:
        stackPointer = registersHL;
        break;
    
    case 250:
        registerA = memoryRead((memoryRead((programCounter + 1) & 0xFFFF) << 8) + memoryRead(programCounter));
        programCounter = (programCounter + 2) & 0xFFFF;
        break;
    
    case 251:
        untilEnable = 2;
        break;
    
    case 252:
        "Illegal op code 0xFC called, pausing emulation.\n";
        PressAKey;
        break;
    
    case 253:
        "Illegal op code 0xFD called, pausing emulation.\n";
        PressAKey;
        break;
    
    case 254:
        dirtySum = registerA - memoryRead(programCounter);
        FHalfCarry = (unsbtub(dirtySum) & 0xF) > (registerA & 0xF);
        FCarry = (dirtySum < 0);
        FZero = (dirtySum == 0);
        programCounter = (programCounter + 1) & 0xFFFF;
        FSubtract = TRUE;
        break;
    
    case 255:
        stackPointer = unswtuw(stackPointer - 1);
        memoryWrite(stackPointer, programCounter >> 8);
        stackPointer = unswtuw(stackPointer - 1);
        memoryWrite(stackPointer, programCounter & 0xFF);
        programCounter = 0x38;
        break;
    default:
        break;
};
