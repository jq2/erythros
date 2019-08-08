switch (cb_opcode)
{
    case 0:
        FCarry = ((registerB & 0x80) == 0x80);
        registerB = ((registerB << 1) & 0xFF) + t((FCarry),1,0);
        FHalfCarry = FSubtract = FALSE;
        FZero = (registerB == 0);
        break;
    
    case 1:
        FCarry = ((registerC & 0x80) == 0x80);
        registerC = ((registerC << 1) & 0xFF) + t((FCarry),1,0);
        FHalfCarry = FSubtract = FALSE;
        FZero = (registerC == 0);
        break;
    
    case 2:
        FCarry = ((registerD & 0x80) == 0x80);
        registerD = ((registerD << 1) & 0xFF) + t((FCarry),1,0);
        FHalfCarry = FSubtract = FALSE;
        FZero = (registerD == 0);
        break;
    
    case 3:
        FCarry = ((registerE & 0x80) == 0x80);
        registerE = ((registerE << 1) & 0xFF) + t((FCarry),1,0);
        FHalfCarry = FSubtract = FALSE;
        FZero = (registerE == 0);
        break;
    
    case 4:
        FCarry = ((registersHL & 0x8000) == 0x8000);
        registersHL = ((registersHL << 1) & 0xFE00) + t((FCarry),0x100,0) + (registersHL & 0xFF);
        FHalfCarry = FSubtract = FALSE;
        FZero = (registersHL <= 0xFF);
        break;
    
    case 5:
        FCarry = ((registersHL & 0x80) == 0x80);
        registersHL = (registersHL & 0xFF00) + ((registersHL << 1) & 0xFF) + t((FCarry),1,0);
        FHalfCarry = FSubtract = FALSE;
        FZero = ((registersHL & 0xFF) == 0x00);
        break;
    
    case 6:
        temp_var = memoryRead(registersHL);
        FCarry = ((temp_var & 0x80) == 0x80);
        temp_var = ((temp_var << 1) & 0xFF) + t((FCarry),1,0);
        memoryWrite(registersHL, temp_var);
        FHalfCarry = FSubtract = FALSE;
        FZero = (temp_var == 0x00);
        break;
    
    case 7:
        FCarry = ((registerA & 0x80) == 0x80);
        registerA = ((registerA << 1) & 0xFF) + t((FCarry),1,0);
        FHalfCarry = FSubtract = FALSE;
        FZero = (registerA == 0x00);
        break;
    
    case 8:
        FCarry = ((registerB & 0x01) == 0x01);
        registerB = t((FCarry),0x80,0) + (registerB >> 1);
        FHalfCarry = FSubtract = FALSE;
        FZero = (registerB == 0);
        break;
    
    case 9:
        FCarry = ((registerC & 0x01) == 0x01);
        registerC = t((FCarry),0x80,0) + (registerC >> 1);
        FHalfCarry = FSubtract = FALSE;
        FZero = (registerC == 0);
        break;
    
    case 10:
        FCarry = ((registerD & 0x01) == 0x01);
        registerD = t((FCarry),0x80,0) + (registerD >> 1);
        FHalfCarry = FSubtract = FALSE;
        FZero = (registerD == 0);
        break;
    
    case 11:
        FCarry = ((registerE & 0x01) == 0x01);
        registerE = t((FCarry),0x80,0) + (registerE >> 1);
        FHalfCarry = FSubtract = FALSE;
        FZero = (registerE == 0);
        break;
    
    case 12:
        FCarry = ((registersHL & 0x0100) == 0x0100);
        registersHL = t((FCarry),0x8000,0) + ((registersHL >> 1) & 0xFF00) + (registersHL & 0xFF);
        FHalfCarry = FSubtract = FALSE;
        FZero = (registersHL <= 0xFF);
        break;
    
    case 13:
        FCarry = ((registersHL & 0x01) == 0x01);
        registersHL = (registersHL & 0xFF00) + t((FCarry),0x80,0) + ((registersHL & 0xFF) >> 1);
        FHalfCarry = FSubtract = FALSE;
        FZero = ((registersHL & 0xFF) == 0x00);
        break;
    
    case 14:
        temp_var = memoryRead(registersHL);
        FCarry = ((temp_var & 0x01) == 0x01);
        temp_var = t((FCarry),0x80,0) + (temp_var >> 1);
        memoryWrite(registersHL, temp_var);
        FHalfCarry = FSubtract = FALSE;
        FZero = (temp_var == 0x00);
        break;
    
    case 15:
        FCarry = ((registerA & 0x01) == 0x01);
        registerA = t((FCarry),0x80,0) + (registerA >> 1);
        FHalfCarry = FSubtract = FALSE;
        FZero = (registerA == 0x00);
        break;
    
    case 16:
        newFCarry = ((registerB & 0x80) == 0x80);
        registerB = ((registerB << 1) & 0xFF) + t((FCarry),1,0);
        FCarry = newFCarry;
        FHalfCarry = FSubtract = FALSE;
        FZero = (registerB == 0);
        break;
    
    case 17:
        newFCarry = ((registerC & 0x80) == 0x80);
        registerC = ((registerC << 1) & 0xFF) + t((FCarry),1,0);
        FCarry = newFCarry;
        FHalfCarry = FSubtract = FALSE;
        FZero = (registerC == 0);
        break;
    
    case 18:
        newFCarry = ((registerD & 0x80) == 0x80);
        registerD = ((registerD << 1) & 0xFF) + t((FCarry),1,0);
        FCarry = newFCarry;
        FHalfCarry = FSubtract = FALSE;
        FZero = (registerD == 0);
        break;
    
    case 19:
        newFCarry = ((registerE & 0x80) == 0x80);
        registerE = ((registerE << 1) & 0xFF) + t((FCarry),1,0);
        FCarry = newFCarry;
        FHalfCarry = FSubtract = FALSE;
        FZero = (registerE == 0);
        break;
    
    case 20:
        newFCarry = ((registersHL & 0x8000) == 0x8000);
        registersHL = ((registersHL << 1) & 0xFE00) + t((FCarry),0x100,0) + (registersHL & 0xFF);
        FCarry = newFCarry;
        FHalfCarry = FSubtract = FALSE;
        FZero = (registersHL <= 0xFF);
        break;
    
    case 21:
        newFCarry = ((registersHL & 0x80) == 0x80);
        registersHL = (registersHL & 0xFF00) + ((registersHL << 1) & 0xFF) + t((FCarry),1,0);
        FCarry = newFCarry;
        FHalfCarry = FSubtract = FALSE;
        FZero = ((registersHL & 0xFF) == 0x00);
        break;
    
    case 22:
        temp_var = memoryRead(registersHL);
        newFCarry = ((temp_var & 0x80) == 0x80);
        temp_var = ((temp_var << 1) & 0xFF) + t((FCarry),1,0);
        FCarry = newFCarry;
        memoryWrite(registersHL, temp_var);
        FHalfCarry = FSubtract = FALSE;
        FZero = (temp_var == 0x00);
        break;
    
    case 23:
        newFCarry = ((registerA & 0x80) == 0x80);
        registerA = ((registerA << 1) & 0xFF) + t((FCarry),1,0);
        FCarry = newFCarry;
        FHalfCarry = FSubtract = FALSE;
        FZero = (registerA == 0x00);
        break;
    
    case 24:
        newFCarry = ((registerB & 0x01) == 0x01);
        registerB = t((FCarry),0x80,0) + (registerB >> 1);
        FCarry = newFCarry;
        FHalfCarry = FSubtract = FALSE;
        FZero = (registerB == 0);
        break;
    
    case 25:
        newFCarry = ((registerC & 0x01) == 0x01);
        registerC = t((FCarry),0x80,0) + (registerC >> 1);
        FCarry = newFCarry;
        FHalfCarry = FSubtract = FALSE;
        FZero = (registerC == 0);
        break;
    
    case 26:
        newFCarry = ((registerD & 0x01) == 0x01);
        registerD = t((FCarry),0x80,0) + (registerD >> 1);
        FCarry = newFCarry;
        FHalfCarry = FSubtract = FALSE;
        FZero = (registerD == 0);
        break;
    
    case 27:
        newFCarry = ((registerE & 0x01) == 0x01);
        registerE = t((FCarry),0x80,0) + (registerE >> 1);
        FCarry = newFCarry;
        FHalfCarry = FSubtract = FALSE;
        FZero = (registerE == 0);
        break;
    
    case 28:
        newFCarry = ((registersHL & 0x0100) == 0x0100);
        registersHL = t((FCarry),0x8000,0) + ((registersHL >> 1) & 0xFF00) + (registersHL & 0xFF);
        FCarry = newFCarry;
        FHalfCarry = FSubtract = FALSE;
        FZero = (registersHL <= 0xFF);
        break;
    
    case 29:
        newFCarry = ((registersHL & 0x01) == 0x01);
        registersHL = (registersHL & 0xFF00) + t((FCarry),0x80,0) + ((registersHL & 0xFF) >> 1);
        FCarry = newFCarry;
        FHalfCarry = FSubtract = FALSE;
        FZero = ((registersHL & 0xFF) == 0x00);
        break;
    
    case 30:
        temp_var = memoryRead(registersHL);
        newFCarry = ((temp_var & 0x01) == 0x01);
        temp_var = t((FCarry),0x80,0) + (temp_var >> 1);
        FCarry = newFCarry;
        memoryWrite(registersHL, temp_var);
        FHalfCarry = FSubtract = FALSE;
        FZero = (temp_var == 0x00);
        break;
    
    case 31:
        newFCarry = ((registerA & 0x01) == 0x01);
        registerA = t((FCarry),0x80,0) + (registerA >> 1);
        FCarry = newFCarry;
        FHalfCarry = FSubtract = FALSE;
        FZero = (registerA == 0x00);
        break;
    
    case 32:
        FCarry = ((registerB & 0x80) == 0x80);
        registerB = (registerB << 1) & 0xFF;
        FHalfCarry = FSubtract = FALSE;
        FZero = (registerB == 0);
        break;
    
    case 33:
        FCarry = ((registerC & 0x80) == 0x80);
        registerC = (registerC << 1) & 0xFF;
        FHalfCarry = FSubtract = FALSE;
        FZero = (registerC == 0);
        break;
    
    case 34:
        FCarry = ((registerD & 0x80) == 0x80);
        registerD = (registerD << 1) & 0xFF;
        FHalfCarry = FSubtract = FALSE;
        FZero = (registerD == 0);
        break;
    
    case 35:
        FCarry = ((registerE & 0x80) == 0x80);
        registerE = (registerE << 1) & 0xFF;
        FHalfCarry = FSubtract = FALSE;
        FZero = (registerE == 0);
        break;
    
    case 36:
        FCarry = ((registersHL & 0x8000) == 0x8000);
        registersHL = ((registersHL << 1) & 0xFE00) + (registersHL & 0xFF);
        FHalfCarry = FSubtract = FALSE;
        FZero = (registersHL <= 0xFF);
        break;
    
    case 37:
        FCarry = ((registersHL & 0x0080) == 0x0080);
        registersHL = (registersHL & 0xFF00) + ((registersHL << 1) & 0xFF);
        FHalfCarry = FSubtract = FALSE;
        FZero = ((registersHL & 0xFF) == 0x00);
        break;
    
    case 38:
        temp_var = memoryRead(registersHL);
        FCarry = ((temp_var & 0x80) == 0x80);
        temp_var = (temp_var << 1) & 0xFF;
        memoryWrite(registersHL, temp_var);
        FHalfCarry = FSubtract = FALSE;
        FZero = (temp_var == 0x00);
        break;
    
    case 39:
        FCarry = ((registerA & 0x80) == 0x80);
        registerA = (registerA << 1) & 0xFF;
        FHalfCarry = FSubtract = FALSE;
        FZero = (registerA == 0x00);
        break;
    
    case 40:
        FCarry = ((registerB & 0x01) == 0x01);
        registerB = (registerB & 0x80) + (registerB >> 1);
        FHalfCarry = FSubtract = FALSE;
        FZero = (registerB == 0);
        break;
    
    case 41:
        FCarry = ((registerC & 0x01) == 0x01);
        registerC = (registerC & 0x80) + (registerC >> 1);
        FHalfCarry = FSubtract = FALSE;
        FZero = (registerC == 0);
        break;
    
    case 42:
        FCarry = ((registerD & 0x01) == 0x01);
        registerD = (registerD & 0x80) + (registerD >> 1);
        FHalfCarry = FSubtract = FALSE;
        FZero = (registerD == 0);
        break;
    
    case 43:
        FCarry = ((registerE & 0x01) == 0x01);
        registerE = (registerE & 0x80) + (registerE >> 1);
        FHalfCarry = FSubtract = FALSE;
        FZero = (registerE == 0);
        break;
    
    case 44:
        FCarry = ((registersHL & 0x0100) == 0x0100);
        registersHL = ((registersHL >> 1) & 0xFF00) + (registersHL & 0x80FF);
        FHalfCarry = FSubtract = FALSE;
        FZero = (registersHL <= 0xFF);
        break;
    
    case 45:
        FCarry = ((registersHL & 0x0001) == 0x0001);
        registersHL = (registersHL & 0xFF80) + ((registersHL & 0xFF) >> 1);
        FHalfCarry = FSubtract = FALSE;
        FZero = ((registersHL & 0xFF) == 0x00);
        break;
    
    case 46:
        temp_var = memoryRead(registersHL);
        FCarry = ((temp_var & 0x01) == 0x01);
        temp_var = (temp_var & 0x80) + (temp_var >> 1);
        memoryWrite(registersHL, temp_var);
        FHalfCarry = FSubtract = FALSE;
        FZero = (temp_var == 0x00);
        break;
    
    case 47:
        FCarry = ((registerA & 0x01) == 0x01);
        registerA = (registerA & 0x80) + (registerA >> 1);
        FHalfCarry = FSubtract = FALSE;
        FZero = (registerA == 0x00);
        break;
    
    case 48:
        registerB = ((registerB & 0xF) << 4) + (registerB >> 4);
        FZero = (registerB == 0);
        FCarry = FHalfCarry = FSubtract = FALSE;
        break;
    
    case 49:
        registerC = ((registerC & 0xF) << 4) + (registerC >> 4);
        FZero = (registerC == 0);
        FCarry = FHalfCarry = FSubtract = FALSE;
        break;
    
    case 50:
        registerD = ((registerD & 0xF) << 4) + (registerD >> 4);
        FZero = (registerD == 0);
        FCarry = FHalfCarry = FSubtract = FALSE;
        break;
    
    case 51:
        registerE = ((registerE & 0xF) << 4) + (registerE >> 4);
        FZero = (registerE == 0);
        FCarry = FHalfCarry = FSubtract = FALSE;
        break;
    
    case 52:
        registersHL = ((registersHL & 0xF00) << 4) + ((registersHL & 0xF000) >> 4) + (registersHL & 0xFF);
        FZero = (registersHL <= 0xFF);
        FCarry = FHalfCarry = FSubtract = FALSE;
        break;
    
    case 53:
        registersHL = (registersHL & 0xFF00) + ((registersHL & 0xF) << 4) + ((registersHL & 0xF0) >> 4);
        FZero = ((registersHL & 0xFF) == 0);
        FCarry = FHalfCarry = FSubtract = FALSE;
        break;
    
    case 54:
        temp_var = memoryRead(registersHL);
        temp_var = ((temp_var & 0xF) << 4) + (temp_var >> 4);
        memoryWrite(registersHL, temp_var);
        FZero = (temp_var == 0);
        FCarry = FHalfCarry = FSubtract = FALSE;
        break;
    
    case 55:
        registerA = ((registerA & 0xF) << 4) + (registerA >> 4);
        FZero = (registerA == 0);
        FCarry = FHalfCarry = FSubtract = FALSE;
        break;
    
    case 56:
        FCarry = ((registerB & 0x01) == 0x01);
        registerB >>= 1;
        FHalfCarry = FSubtract = FALSE;
        FZero = (registerB == 0);
        break;
    
    case 57:
        FCarry = ((registerC & 0x01) == 0x01);
        registerC >>= 1;
        FHalfCarry = FSubtract = FALSE;
        FZero = (registerC == 0);
        break;
    
    case 58:
        FCarry = ((registerD & 0x01) == 0x01);
        registerD >>= 1;
        FHalfCarry = FSubtract = FALSE;
        FZero = (registerD == 0);
        break;
    
    case 59:
        FCarry = ((registerE & 0x01) == 0x01);
        registerE >>= 1;
        FHalfCarry = FSubtract = FALSE;
        FZero = (registerE == 0);
        break;
    
    case 60:
        FCarry = ((registersHL & 0x0100) == 0x0100);
        registersHL = ((registersHL >> 1) & 0xFF00) + (registersHL & 0xFF);
        FHalfCarry = FSubtract = FALSE;
        FZero = (registersHL <= 0xFF);
        break;
    
    case 61:
        FCarry = ((registersHL & 0x0001) == 0x0001);
        registersHL = (registersHL & 0xFF00) + ((registersHL & 0xFF) >> 1);
        FHalfCarry = FSubtract = FALSE;
        FZero = ((registersHL & 0xFF) == 0x00);
        break;
    
    case 62:
        temp_var = memoryRead(registersHL);
        FCarry = ((temp_var & 0x01) == 0x01);
        memoryWrite(registersHL, temp_var >>= 1);
        FHalfCarry = FSubtract = FALSE;
        FZero = (temp_var == 0x00);
        break;
    
    case 63:
        FCarry = ((registerA & 0x01) == 0x01);
        registerA >>= 1;
        FHalfCarry = FSubtract = FALSE;
        FZero = (registerA == 0x00);
        break;
    
    case 64:
        FHalfCarry = TRUE;
        FSubtract = FALSE;
        FZero = ((registerB & 0x01) == 0);
        break;
    
    case 65:
        FHalfCarry = TRUE;
        FSubtract = FALSE;
        FZero = ((registerC & 0x01) == 0);
        break;
    
    case 66:
        FHalfCarry = TRUE;
        FSubtract = FALSE;
        FZero = ((registerD & 0x01) == 0);
        break;
    
    case 67:
        FHalfCarry = TRUE;
        FSubtract = FALSE;
        FZero = ((registerE & 0x01) == 0);
        break;
    
    case 68:
        FHalfCarry = TRUE;
        FSubtract = FALSE;
        FZero = ((registersHL & 0x0100) == 0);
        break;
    
    case 69:
        FHalfCarry = TRUE;
        FSubtract = FALSE;
        FZero = ((registersHL & 0x0001) == 0);
        break;
    
    case 70:
        FHalfCarry = TRUE;
        FSubtract = FALSE;
        FZero = ((memoryRead(registersHL) & 0x01) == 0);
        break;
    
    case 71:
        FHalfCarry = TRUE;
        FSubtract = FALSE;
        FZero = ((registerA & 0x01) == 0);
        break;
    
    case 72:
        FHalfCarry = TRUE;
        FSubtract = FALSE;
        FZero = ((registerB & 0x02) == 0);
        break;
    
    case 73:
        FHalfCarry = TRUE;
        FSubtract = FALSE;
        FZero = ((registerC & 0x02) == 0);
        break;
    
    case 74:
        FHalfCarry = TRUE;
        FSubtract = FALSE;
        FZero = ((registerD & 0x02) == 0);
        break;
    
    case 75:
        FHalfCarry = TRUE;
        FSubtract = FALSE;
        FZero = ((registerE & 0x02) == 0);
        break;
    
    case 76:
        FHalfCarry = TRUE;
        FSubtract = FALSE;
        FZero = ((registersHL & 0x0200) == 0);
        break;
    
    case 77:
        FHalfCarry = TRUE;
        FSubtract = FALSE;
        FZero = ((registersHL & 0x0002) == 0);
        break;
    
    case 78:
        FHalfCarry = TRUE;
        FSubtract = FALSE;
        FZero = ((memoryRead(registersHL) & 0x02) == 0);
        break;
    
    case 79:
        FHalfCarry = TRUE;
        FSubtract = FALSE;
        FZero = ((registerA & 0x02) == 0);
        break;
    
    case 80:
        FHalfCarry = TRUE;
        FSubtract = FALSE;
        FZero = ((registerB & 0x04) == 0);
        break;
    
    case 81:
        FHalfCarry = TRUE;
        FSubtract = FALSE;
        FZero = ((registerC & 0x04) == 0);
        break;
    
    case 82:
        FHalfCarry = TRUE;
        FSubtract = FALSE;
        FZero = ((registerD & 0x04) == 0);
        break;
    
    case 83:
        FHalfCarry = TRUE;
        FSubtract = FALSE;
        FZero = ((registerE & 0x04) == 0);
        break;
    
    case 84:
        FHalfCarry = TRUE;
        FSubtract = FALSE;
        FZero = ((registersHL & 0x0400) == 0);
        break;
    
    case 85:
        FHalfCarry = TRUE;
        FSubtract = FALSE;
        FZero = ((registersHL & 0x0004) == 0);
        break;
    
    case 86:
        FHalfCarry = TRUE;
        FSubtract = FALSE;
        FZero = ((memoryRead(registersHL) & 0x04) == 0);
        break;
    
    case 87:
        FHalfCarry = TRUE;
        FSubtract = FALSE;
        FZero = ((registerA & 0x04) == 0);
        break;
    
    case 88:
        FHalfCarry = TRUE;
        FSubtract = FALSE;
        FZero = ((registerB & 0x08) == 0);
        break;
    
    case 89:
        FHalfCarry = TRUE;
        FSubtract = FALSE;
        FZero = ((registerC & 0x08) == 0);
        break;
    
    case 90:
        FHalfCarry = TRUE;
        FSubtract = FALSE;
        FZero = ((registerD & 0x08) == 0);
        break;
    
    case 91:
        FHalfCarry = TRUE;
        FSubtract = FALSE;
        FZero = ((registerE & 0x08) == 0);
        break;
    
    case 92:
        FHalfCarry = TRUE;
        FSubtract = FALSE;
        FZero = ((registersHL & 0x0800) == 0);
        break;
    
    case 93:
        FHalfCarry = TRUE;
        FSubtract = FALSE;
        FZero = ((registersHL & 0x0008) == 0);
        break;
    
    case 94:
        FHalfCarry = TRUE;
        FSubtract = FALSE;
        FZero = ((memoryRead(registersHL) & 0x08) == 0);
        break;
    
    case 95:
        FHalfCarry = TRUE;
        FSubtract = FALSE;
        FZero = ((registerA & 0x08) == 0);
        break;
    
    case 96:
        FHalfCarry = TRUE;
        FSubtract = FALSE;
        FZero = ((registerB & 0x10) == 0);
        break;
    
    case 97:
        FHalfCarry = TRUE;
        FSubtract = FALSE;
        FZero = ((registerC & 0x10) == 0);
        break;
    
    case 98:
        FHalfCarry = TRUE;
        FSubtract = FALSE;
        FZero = ((registerD & 0x10) == 0);
        break;
    
    case 99:
        FHalfCarry = TRUE;
        FSubtract = FALSE;
        FZero = ((registerE & 0x10) == 0);
        break;
    
    case 100:
        FHalfCarry = TRUE;
        FSubtract = FALSE;
        FZero = ((registersHL & 0x1000) == 0);
        break;
    
    case 101:
        FHalfCarry = TRUE;
        FSubtract = FALSE;
        FZero = ((registersHL & 0x0010) == 0);
        break;
    
    case 102:
        FHalfCarry = TRUE;
        FSubtract = FALSE;
        FZero = ((memoryRead(registersHL) & 0x10) == 0);
        break;
    
    case 103:
        FHalfCarry = TRUE;
        FSubtract = FALSE;
        FZero = ((registerA & 0x10) == 0);
        break;
    
    case 104:
        FHalfCarry = TRUE;
        FSubtract = FALSE;
        FZero = ((registerB & 0x20) == 0);
        break;
    
    case 105:
        FHalfCarry = TRUE;
        FSubtract = FALSE;
        FZero = ((registerC & 0x20) == 0);
        break;
    
    case 106:
        FHalfCarry = TRUE;
        FSubtract = FALSE;
        FZero = ((registerD & 0x20) == 0);
        break;
    
    case 107:
        FHalfCarry = TRUE;
        FSubtract = FALSE;
        FZero = ((registerE & 0x20) == 0);
        break;
    
    case 108:
        FHalfCarry = TRUE;
        FSubtract = FALSE;
        FZero = ((registersHL & 0x2000) == 0);
        break;
    
    case 109:
        FHalfCarry = TRUE;
        FSubtract = FALSE;
        FZero = ((registersHL & 0x0020) == 0);
        break;
    
    case 110:
        FHalfCarry = TRUE;
        FSubtract = FALSE;
        FZero = ((memoryRead(registersHL) & 0x20) == 0);
        break;
    
    case 111:
        FHalfCarry = TRUE;
        FSubtract = FALSE;
        FZero = ((registerA & 0x20) == 0);
        break;
    
    case 112:
        FHalfCarry = TRUE;
        FSubtract = FALSE;
        FZero = ((registerB & 0x40) == 0);
        break;
    
    case 113:
        FHalfCarry = TRUE;
        FSubtract = FALSE;
        FZero = ((registerC & 0x40) == 0);
        break;
    
    case 114:
        FHalfCarry = TRUE;
        FSubtract = FALSE;
        FZero = ((registerD & 0x40) == 0);
        break;
    
    case 115:
        FHalfCarry = TRUE;
        FSubtract = FALSE;
        FZero = ((registerE & 0x40) == 0);
        break;
    
    case 116:
        FHalfCarry = TRUE;
        FSubtract = FALSE;
        FZero = ((registersHL & 0x4000) == 0);
        break;
    
    case 117:
        FHalfCarry = TRUE;
        FSubtract = FALSE;
        FZero = ((registersHL & 0x0040) == 0);
        break;
    
    case 118:
        FHalfCarry = TRUE;
        FSubtract = FALSE;
        FZero = ((memoryRead(registersHL) & 0x40) == 0);
        break;
    
    case 119:
        FHalfCarry = TRUE;
        FSubtract = FALSE;
        FZero = ((registerA & 0x40) == 0);
        break;
    
    case 120:
        FHalfCarry = TRUE;
        FSubtract = FALSE;
        FZero = ((registerB & 0x80) == 0);
        break;
    
    case 121:
        FHalfCarry = TRUE;
        FSubtract = FALSE;
        FZero = ((registerC & 0x80) == 0);
        break;
    
    case 122:
        FHalfCarry = TRUE;
        FSubtract = FALSE;
        FZero = ((registerD & 0x80) == 0);
        break;
    
    case 123:
        FHalfCarry = TRUE;
        FSubtract = FALSE;
        FZero = ((registerE & 0x80) == 0);
        break;
    
    case 124:
        FHalfCarry = TRUE;
        FSubtract = FALSE;
        FZero = ((registersHL & 0x8000) == 0);
        break;
    
    case 125:
        FHalfCarry = TRUE;
        FSubtract = FALSE;
        FZero = ((registersHL & 0x0080) == 0);
        break;
    
    case 126:
        FHalfCarry = TRUE;
        FSubtract = FALSE;
        FZero = ((memoryRead(registersHL) & 0x80) == 0);
        break;
    
    case 127:
        FHalfCarry = TRUE;
        FSubtract = FALSE;
        FZero = ((registerA & 0x80) == 0);
        break;
    
    case 128:
        registerB &= 0xFE;
        break;
    
    case 129:
        registerC &= 0xFE;
        break;
    
    case 130:
        registerD &= 0xFE;
        break;
    
    case 131:
        registerE &= 0xFE;
        break;
    
    case 132:
        registersHL &= 0xFEFF;
        break;
    
    case 133:
        registersHL &= 0xFFFE;
        break;
    
    case 134:
        memoryWrite(registersHL, memoryRead(registersHL) & 0xFE);
        break;
    
    case 135:
        registerA &= 0xFE;
        break;
    
    case 136:
        registerB &= 0xFD;
        break;
    
    case 137:
        registerC &= 0xFD;
        break;
    
    case 138:
        registerD &= 0xFD;
        break;
    
    case 139:
        registerE &= 0xFD;
        break;
    
    case 140:
        registersHL &= 0xFDFF;
        break;
    
    case 141:
        registersHL &= 0xFFFD;
        break;
    
    case 142:
        memoryWrite(registersHL, memoryRead(registersHL) & 0xFD);
        break;
    
    case 143:
        registerA &= 0xFD;
        break;
    
    case 144:
        registerB &= 0xFB;
        break;
    
    case 145:
        registerC &= 0xFB;
        break;
    
    case 146:
        registerD &= 0xFB;
        break;
    
    case 147:
        registerE &= 0xFB;
        break;
    
    case 148:
        registersHL &= 0xFBFF;
        break;
    
    case 149:
        registersHL &= 0xFFFB;
        break;
    
    case 150:
        memoryWrite(registersHL, memoryRead(registersHL) & 0xFB);
        break;
    
    case 151:
        registerA &= 0xFB;
        break;
    
    case 152:
        registerB &= 0xF7;
        break;
    
    case 153:
        registerC &= 0xF7;
        break;
    
    case 154:
        registerD &= 0xF7;
        break;
    
    case 155:
        registerE &= 0xF7;
        break;
    
    case 156:
        registersHL &= 0xF7FF;
        break;
    
    case 157:
        registersHL &= 0xFFF7;
        break;
    
    case 158:
        memoryWrite(registersHL, memoryRead(registersHL) & 0xF7);
        break;
    
    case 159:
        registerA &= 0xF7;
        break;
    
    case 160:
        registerB &= 0xEF;
        break;
    
    case 161:
        registerC &= 0xEF;
        break;
    
    case 162:
        registerD &= 0xEF;
        break;
    
    case 163:
        registerE &= 0xEF;
        break;
    
    case 164:
        registersHL &= 0xEFFF;
        break;
    
    case 165:
        registersHL &= 0xFFEF;
        break;
    
    case 166:
        memoryWrite(registersHL, memoryRead(registersHL) & 0xEF);
        break;
    
    case 167:
        registerA &= 0xEF;
        break;
    
    case 168:
        registerB &= 0xDF;
        break;
    
    case 169:
        registerC &= 0xDF;
        break;
    
    case 170:
        registerD &= 0xDF;
        break;
    
    case 171:
        registerE &= 0xDF;
        break;
    
    case 172:
        registersHL &= 0xDFFF;
        break;
    
    case 173:
        registersHL &= 0xFFDF;
        break;
    
    case 174:
        memoryWrite(registersHL, memoryRead(registersHL) & 0xDF);
        break;
    
    case 175:
        registerA &= 0xDF;
        break;
    
    case 176:
        registerB &= 0xBF;
        break;
    
    case 177:
        registerC &= 0xBF;
        break;
    
    case 178:
        registerD &= 0xBF;
        break;
    
    case 179:
        registerE &= 0xBF;
        break;
    
    case 180:
        registersHL &= 0xBFFF;
        break;
    
    case 181:
        registersHL &= 0xFFBF;
        break;
    
    case 182:
        memoryWrite(registersHL, memoryRead(registersHL) & 0xBF);
        break;
    
    case 183:
        registerA &= 0xBF;
        break;
    
    case 184:
        registerB &= 0x7F;
        break;
    
    case 185:
        registerC &= 0x7F;
        break;
    
    case 186:
        registerD &= 0x7F;
        break;
    
    case 187:
        registerE &= 0x7F;
        break;
    
    case 188:
        registersHL &= 0x7FFF;
        break;
    
    case 189:
        registersHL &= 0xFF7F;
        break;
    
    case 190:
        memoryWrite(registersHL, memoryRead(registersHL) & 0x7F);
        break;
    
    case 191:
        registerA &= 0x7F;
        break;
    
    case 192:
        registerB |= 0x01;
        break;
    
    case 193:
        registerC |= 0x01;
        break;
    
    case 194:
        registerD |= 0x01;
        break;
    
    case 195:
        registerE |= 0x01;
        break;
    
    case 196:
        registersHL |= 0x0100;
        break;
    
    case 197:
        registersHL |= 0x01;
        break;
    
    case 198:
        memoryWrite(registersHL, memoryRead(registersHL) | 0x01);
        break;
    
    case 199:
        registerA |= 0x01;
        break;
    
    case 200:
        registerB |= 0x02;
        break;
    
    case 201:
        registerC |= 0x02;
        break;
    
    case 202:
        registerD |= 0x02;
        break;
    
    case 203:
        registerE |= 0x02;
        break;
    
    case 204:
        registersHL |= 0x0200;
        break;
    
    case 205:
        registersHL |= 0x02;
        break;
    
    case 206:
        memoryWrite(registersHL, memoryRead(registersHL) | 0x02);
        break;
    
    case 207:
        registerA |= 0x02;
        break;
    
    case 208:
        registerB |= 0x04;
        break;
    
    case 209:
        registerC |= 0x04;
        break;
    
    case 210:
        registerD |= 0x04;
        break;
    
    case 211:
        registerE |= 0x04;
        break;
    
    case 212:
        registersHL |= 0x0400;
        break;
    
    case 213:
        registersHL |= 0x04;
        break;
    
    case 214:
        memoryWrite(registersHL, memoryRead(registersHL) | 0x04);
        break;
    
    case 215:
        registerA |= 0x04;
        break;
    
    case 216:
        registerB |= 0x08;
        break;
    
    case 217:
        registerC |= 0x08;
        break;
    
    case 218:
        registerD |= 0x08;
        break;
    
    case 219:
        registerE |= 0x08;
        break;
    
    case 220:
        registersHL |= 0x0800;
        break;
    
    case 221:
        registersHL |= 0x08;
        break;
    
    case 222:
        memoryWrite(registersHL, memoryRead(registersHL) | 0x08);
        break;
    
    case 223:
        registerA |= 0x08;
        break;
    
    case 224:
        registerB |= 0x10;
        break;
    
    case 225:
        registerC |= 0x10;
        break;
    
    case 226:
        registerD |= 0x10;
        break;
    
    case 227:
        registerE |= 0x10;
        break;
    
    case 228:
        registersHL |= 0x1000;
        break;
    
    case 229:
        registersHL |= 0x10;
        break;
    
    case 230:
        memoryWrite(registersHL, memoryRead(registersHL) | 0x10);
        break;
    
    case 231:
        registerA |= 0x10;
        break;
    
    case 232:
        registerB |= 0x20;
        break;
    
    case 233:
        registerC |= 0x20;
        break;
    
    case 234:
        registerD |= 0x20;
        break;
    
    case 235:
        registerE |= 0x20;
        break;
    
    case 236:
        registersHL |= 0x2000;
        break;
    
    case 237:
        registersHL |= 0x20;
        break;
    
    case 238:
        memoryWrite(registersHL, memoryRead(registersHL) | 0x20);
        break;
    
    case 239:
        registerA |= 0x20;
        break;
    
    case 240:
        registerB |= 0x40;
        break;
    
    case 241:
        registerC |= 0x40;
        break;
    
    case 242:
        registerD |= 0x40;
        break;
    
    case 243:
        registerE |= 0x40;
        break;
    
    case 244:
        registersHL |= 0x4000;
        break;
    
    case 245:
        registersHL |= 0x40;
        break;
    
    case 246:
        memoryWrite(registersHL, memoryRead(registersHL) | 0x40);
        break;
    
    case 247:
        registerA |= 0x40;
        break;
    
    case 248:
        registerB |= 0x80;
        break;
    
    case 249:
        registerC |= 0x80;
        break;
    
    case 250:
        registerD |= 0x80;
        break;
    
    case 251:
        registerE |= 0x80;
        break;
    
    case 252:
        registersHL |= 0x8000;
        break;
    
    case 253:
        registersHL |= 0x80;
        break;
    
    case 254:
        memoryWrite(registersHL, memoryRead(registersHL) | 0x80);
        break;
    
    case 255:
        registerA |= 0x80;
        break;
    default:
        break;
};
